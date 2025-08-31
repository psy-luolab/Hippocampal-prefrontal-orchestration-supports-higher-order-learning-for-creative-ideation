library(readxl)
library(lme4)
library(sjPlot)
library(broom.mixed) 
library(dplyr)
library(ggplot2)
library(scales)  

# 2. 读取Excel数据文件
df <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionError.xlsx")

# 过滤掉subject为16、26、27的被试
data <- df %>% filter(!subject %in% c(16, 26, 27))

# 3. 将“subject”与“item”列转为因子类型，便于混合模型分析
data$subject <- as.factor(data$subject)
data$item <- as.factor(data$item)

# 创建预测误差变量：3=有创意（JC），4=无创意（JUC）
data$prediction_error <- factor(
  data$subjective_creativity,           # 使用主观创造性列
  levels = c(4, 3),                     # 4表示无创意，3表示有创意
  labels = c("Low Error", "High Error") # 分别命名
)

# 5. 构建广义线性混合模型（GLMM），分析预测误差对记忆的影响
# memory 是二分类（0=没记住，1=记住），适合用logistic回归
memory_model <- glmer(
  memory ~ prediction_error +           # 预测误差为主要自变量
    (1 | subject) + (1 | item),         # 随机效应控制被试和题目间差异
  data = data,
  family = binomial                     # 指定logistic回归（适用于0/1变量）
)

# 6. 查看模型结果摘要
summary(memory_model)


#柱状图 汇总
summary_tab <- data %>%
  group_by(prediction_error) %>%
  summarise(mean_memory = mean(memory),
            n = n(),
            se = sd(memory)/sqrt(n))
se = sd(memory)/sqrt(n))
p <- ggplot(summary_tab, aes(x = prediction_error, y = mean_memory, fill = prediction_error)) +
  geom_bar(stat = "identity", width = 0.55, color = NA) +   # 柱状图主体，无边框
  geom_errorbar(aes(ymin = mean_memory - se, ymax = mean_memory + se),
                width = 0.17, linewidth = 1.1,              # 加粗误差线
                position = position_dodge(width = 0.55)) +
  scale_fill_manual(values = c("Low Error" = "#4575b4", "High Error" = "#d73027")) +  # 论文常用蓝红色
  scale_y_continuous(labels = percent_format(accuracy = 1),             # y轴为百分比
                     expand = expansion(mult = c(0, .07))) +
  labs(
    x = " ",                  # x轴标题
    y = "Memory Rate (%)"                  # y轴标题
  ) +
  theme_minimal(base_size = 17, base_family = "sans") +       # 简洁主题
  theme(
    legend.position = "none",                                 # 不显示图例
    axis.title.x = element_text(size = 17, face = "plain"),   # x轴标题常规
    axis.title.y = element_text(size = 17, face = "plain"),   # y轴标题常规
    axis.text = element_text(size = 15, color = "black"),     # 坐标轴标签黑色
    panel.grid.major.x = element_blank(),                     # 不显示x主网格线
    panel.grid.minor = element_blank(),                       # 不显示次网格线
    panel.grid.major.y = element_line(linetype = "dotted", linewidth = 0.7, color = "#aaaaaa"),
    plot.margin = margin(10, 20, 10, 20),
    # 加入坐标轴线条
    axis.line.x = element_line(linewidth = 1.0, color = "black"),    # x轴线
    axis.line.y = element_line(linewidth = 1.0, color = "black")     # y轴线
  )

# 3. 显示图形
print(p)

ggsave("memory_JCbar.png", width = 5.3, height = 4.3)



