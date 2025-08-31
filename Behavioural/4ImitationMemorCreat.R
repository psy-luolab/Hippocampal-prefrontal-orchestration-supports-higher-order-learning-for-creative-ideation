library(lme4)
library(lmerTest)
library(readxl)
library(dplyr)

data <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionError.xlsx")
# 过滤掉subject为16、26、27的被试；创造成绩是极端值
df <- data %>% filter(!subject %in% c(16, 26, 27))

# 1. 相似性评分对记忆成绩的预测（广义线性混合模型，logistic回归）
#    memory 是二分类（0/1），需用 family = "binomial"
model_memory <- glmer(
  memory ~ similarity_rating + (1|subject) + (1|item), # 固定效应：similarity_rating；随机效应：被试、题目
  data = df,
  family = "binomial"  # 二分类结局，使用logistic回归
)
summary(model_memory)  # 输出模型结果
confint(model_memory, parm = "beta_", method = "Wald") 
tab_model(model_memory, file = "similarity_memory_results.html")

#画图
# 生成等距的相似性评分点
pred_tab <- data.frame(
  similarity_rating = seq(min(df$similarity_rating, na.rm=TRUE), 
                          max(df$similarity_rating, na.rm=TRUE), 
                          length.out = 100)
)

# 用predict得出拟合概率及置信区间
pred <- predict(model_memory, newdata = pred_tab, type = "link", se.fit = TRUE, re.form = NA)
pred_tab$fit <- pred$fit
pred_tab$se <- pred$se.fit
# logit变概率
pred_tab$prob <- plogis(pred_tab$fit)
pred_tab$lwr <- plogis(pred_tab$fit - 1.96 * pred_tab$se)
pred_tab$upr <- plogis(pred_tab$fit + 1.96 * pred_tab$se)
#画图
ggplot() +
  # 1. 原始点（记忆成功1为上，0为下，透明灰色）
  geom_jitter(data = df, aes(x = similarity_rating, y = memory), 
              width = 0, height = 0.03, color = "grey60", alpha = 0.16, size = 1.8) +
  # 2. 置信区间带
  geom_ribbon(data = pred_tab, aes(x = similarity_rating, ymin = lwr, ymax = upr), 
              fill = "#4575b4", alpha = 0.18) +
  # 3. 拟合曲线
  geom_line(data = pred_tab, aes(x = similarity_rating, y = prob), 
            color = "#d73027", size = 1.5) +
  # 4. 坐标和主题美化
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 1), expand = c(0, 0.02)) +
  labs(
    x = "Imitation Degree",
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

ggsave("/Users/zhangze/Desktop/NCreview1st/画图/similarity_memory.png", width = 7, height = 5, units = "in", dpi = 300)



# 2. 相似性评分对创造性评分的预测（线性混合模型）
df_sub <- df %>% filter(similarity_rating != 0)

# 2. 拟合线性混合效应模型（LMM）
model_creativity <- lmer(
  creativity_rating ~ similarity_rating + (1 | subject) + (1 | item),
  data = df_sub
)

# 3. 输出模型汇总结果
summary(model_creativity)

# 4. 计算固定效应的95%置信区间
confint(model_creativity, parm = "beta_", method = "Wald")

# 5. 输出可视化HTML表格（适合论文、报告使用）
tab_model(model_creativity, file = "similarity_creativity_results.html")



# 画图 生成预测区间
pred_tab <- data.frame(
  similarity_rating = seq(min(df$similarity_rating, na.rm=TRUE),
                          max(df$similarity_rating, na.rm=TRUE),
                          length.out = 100)
)

# 拟合预测及置信区间
pred <- predict(model_creativity, newdata = pred_tab, type = "response", se.fit = TRUE, re.form = NA)
pred_tab$fit <- pred$fit
pred_tab$se <- pred$se.fit
pred_tab$lwr <- pred_tab$fit - 1.96 * pred_tab$se
pred_tab$upr <- pred_tab$fit + 1.96 * pred_tab$se

ggplot() +
  # 原始散点（透明灰）
  geom_jitter(data = df, aes(x = similarity_rating, y = creativity_rating),
              width = 0, height = 0.12, color = "grey60", alpha = 0.16, size = 1.8) +
  # 置信区间带
  geom_ribbon(data = pred_tab, aes(x = similarity_rating, ymin = lwr, ymax = upr),
              fill = "#4575b4", alpha = 0.18) +
  # 拟合曲线
  geom_line(data = pred_tab, aes(x = similarity_rating, y = fit),
            color = "#d73027", size = 1.5) +
  # 设置x轴范围和刻度
  scale_x_continuous(
    limits = c(1, 5),            # x轴范围1到5
    breaks = seq(1, 5, by = 1)   # 每1为一个刻度
  ) +
  scale_y_continuous(expand = c(0.01, 0.01)) +
  labs(
    x = "Imitation Degree",
    y = "Predicted Creativity Rating"
  ) +
  theme_classic(base_size = 18, base_family = "sans") +
  theme(
    axis.title.x = element_text(size = 18, face = "plain"),
    axis.title.y = element_text(size = 18, face = "plain"),
    axis.text = element_text(size = 16, color = "black"),
    plot.margin = margin(12, 18, 12, 18),
    axis.line.x = element_line(linewidth = 1, color = "black"),
    axis.line.y = element_line(linewidth = 1, color = "black")
  )

# 保存高分辨率图：
ggsave("/Users/zhangze/Desktop/NCreview1st/画图/similarity_Creativity.png", width = 7, height = 5, units = "in", dpi = 300)
