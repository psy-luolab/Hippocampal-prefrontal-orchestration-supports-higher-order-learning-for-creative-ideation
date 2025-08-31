# 加载所需包
library(readxl)        # 读取Excel
library(dplyr)         # 数据处理
library(lme4)          # 混合效应模型
library(ggplot2)       # 可视化
library(broom.mixed)   # 模型结果输出

# 1. 读取并预处理数据
df <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionErrortradeoff.xlsx")

data <- df %>%
  filter(!subject %in% c(16, 26, 27)) %>%
  mutate(
    subject = as.factor(subject),
    item = as.factor(item),
    # 主体：把subjective_creativity变为因子，标签清楚易懂
    subjective_creativity = factor(subjective_creativity, levels = c(4, 3), labels = c("Low Error", "High Error")),
    trade_off = as.numeric(trade_off)
  )

# 2. 检查数据结构
str(data)
# 将trade_off中为Inf的值替换为对应的similarity_rating
data$trade_off <- ifelse(is.infinite(data$trade_off), data$similarity_rating, data$trade_off)
# NA（空值）替换为 0
data$trade_off[is.na(data$trade_off)] <- 0

data_clean <- data %>%
  filter(!is.na(trade_off))



# 3. 线性混合效应模型
tradeoff_lmm <- lmer(
  trade_off ~ subjective_creativity + (1 | subject) + (1 | item),
  data = data_clean
)
summary(tradeoff_lmm)

confint(tradeoff_lmm, level = 0.95, method = "Wald")


# 先构造分组变量
data_plot <- data_clean %>%
  mutate(
    prediction_error = factor(
      as.character(subjective_creativity),  # 保证是字符再factor
      levels = c("Low Error", "High Error"),
      labels = c("Low Error", "High Error")
    )
  )

# 按组汇总均值和标准误
summary_tab <- data_plot %>%
  group_by(prediction_error) %>%
  summarise(
    mean_tradeoff = mean(trade_off, na.rm = TRUE),
    n = n(),
    se = sd(trade_off, na.rm = TRUE) / sqrt(n())
  )

# 绘制柱状图
p <- ggplot(summary_tab, aes(x = prediction_error, y = mean_tradeoff, fill = prediction_error)) +
  geom_bar(stat = "identity", width = 0.55, color = NA) +
  geom_errorbar(aes(ymin = mean_tradeoff - se, ymax = mean_tradeoff + se),
                width = 0.17, linewidth = 1.1,
                position = position_dodge(width = 0.55)) +
  scale_fill_manual(values = c("Low Error" = "#4575b4", "High Error" = "#d73027")) +
  scale_y_continuous(limits = c(0, 0.8),   # 或者你根据实际数据设最大值
                     breaks = seq(0, 0.8, 0.2), 
                     expand = expansion(mult = c(0, .07))) +
  labs(
    x = " ",                           
    y = "Imitation-Creation Trade-off"
  ) +
  theme_minimal(base_size = 17, base_family = "sans") +
  theme(
    legend.position = "none",
    axis.title.x = element_text(size = 17, face = "plain"),
    axis.title.y = element_text(size = 17, face = "plain"),
    axis.text = element_text(size = 15, color = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(linetype = "dotted", linewidth = 0.7, color = "#aaaaaa"),
    plot.margin = margin(10, 20, 10, 20),
    axis.line.x = element_line(linewidth = 1.0, color = "black"),
    axis.line.y = element_line(linewidth = 1.0, color = "black")
  )
print(p)

