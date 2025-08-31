library(lme4)
library(lmerTest)
library(readxl)
library(dplyr)
library(ggplot2)

# 1. 读取数据
data <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionErrortradeoff.xlsx")

# 2. 检查数据结构
str(data)

# 3. 数据预处理：处理 trade_off 极端值
#   - Inf 替换为 similarity_rating
data$trade_off <- ifelse(is.infinite(data$trade_off), data$similarity_rating, data$trade_off)

# 4. 剔除被试16, 26, 27，并删除 trade_off 为 NA 的行
data_clean <- data %>%
  filter(!subject %in% c(16, 26, 27)) %>%
  filter(!is.na(trade_off))   # <--- 新增：仅保留 trade_off 有效值

# 后续分析均以 data_clean 为准

# 5. trade_off 对记忆成绩的预测（GLMM，logistic回归）
model_memory <- glmer(
  memory ~ trade_off + (1|subject) + (1|item),
  data = data_clean,
  family = "binomial"
)
summary(model_memory)
confint(model_memory, parm = "beta_", method = "Wald")
# tab_model(model_memory, file = "tradeoff_memory_results.html")  # 需要sjPlot包

# 6. 拟合概率及置信区间
pred_tab <- data.frame(
  trade_off = seq(min(data_clean$trade_off, na.rm=TRUE),
                  max(data_clean$trade_off, na.rm=TRUE),
                  length.out = 100)
)
pred <- predict(model_memory, newdata = pred_tab, type = "link", se.fit = TRUE, re.form = NA)
pred_tab$fit <- pred$fit
pred_tab$se <- pred$se.fit
pred_tab$prob <- plogis(pred_tab$fit)
pred_tab$lwr <- plogis(pred_tab$fit - 1.96 * pred_tab$se)
pred_tab$upr <- plogis(pred_tab$fit + 1.96 * pred_tab$se)

# 7. 画概率预测图
ggplot() +
  geom_jitter(data = data_clean, aes(x = trade_off, y = memory),
              width = 0, height = 0.03, color = "grey60", alpha = 0.16, size = 1.8) +
  geom_ribbon(data = pred_tab, aes(x = trade_off, ymin = lwr, ymax = upr),
              fill = "#4575b4", alpha = 0.18) +
  geom_line(data = pred_tab, aes(x = trade_off, y = prob),
            color = "#d73027", size = 1.5) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 1), expand = c(0, 0.02)) +
  labs(
    x = "Imitation-Creation Trade-off",
    y = "Predicted Probability of Memory"
  ) +
  theme_classic(base_size = 18, base_family = "sans") +
  theme(
    axis.title.x = element_text(size = 18, face = "plain"),
    axis.title.y = element_text(size = 18, face = "plain"),
    axis.text = element_text(size = 16, color = "black"),
    plot.margin = margin(12, 18, 12, 10),
    axis.line.x = element_line(linewidth = 1, color = "black"),
    axis.line.y = element_line(linewidth = 1, color = "black")
  )
ggsave("/Users/zhangze/Desktop/NCreview1st/画图/tradeoff_memory.png", width = 7, height = 5, units = "in", dpi = 300)

