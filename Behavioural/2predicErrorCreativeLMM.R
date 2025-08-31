library(readxl)   
library(lme4)     
library(ggplot2)  
library(dplyr)    
library(broom.mixed) 

# 1. 读取并预处理数据
df <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionError.xlsx")
data <- df %>%
  filter(!subject %in% c(16, 26, 27)) %>%
  mutate(
    subject = as.factor(subject),
    item = as.factor(item),
    # 转换为有意义的二分类因子
    subjective_creativity = factor(subjective_creativity, 
                                   levels = c(4, 3), 
                                   labels = c("Low Error", "High Error")),
    creativity_rating = as.numeric(creativity_rating)
  )

# 2. 检查数据结构
str(data)

# 3. 相关分析（仅针对数值型相关性，按需可省略）
# cor_test <- cor.test(as.numeric(data$subjective_creativity), data$creativity_rating)
# print(cor_test)

# 4. 线性混合效应模型（类别型自变量直接进入模型）
creativity_model_lmm <- lmer(
  creativity_rating ~ subjective_creativity + (1 | subject) + (1 | item),
  data = data
)
summary(creativity_model_lmm)

# 5. 分组均值与标准误
summary_tab <- data %>%
  group_by(subjective_creativity) %>%
  summarise(
    mean_creativity = mean(creativity_rating, na.rm = TRUE),
    n = n(),
    se = sd(creativity_rating, na.rm = TRUE) / sqrt(n())
  )

# 6. 柱状图
p <- ggplot(summary_tab, aes(x = subjective_creativity, y = mean_creativity, fill = subjective_creativity)) +
  geom_bar(stat = "identity", width = 0.55, color = NA) +
  geom_errorbar(aes(ymin = mean_creativity - se, ymax = mean_creativity + se),
                width = 0.17, linewidth = 1.1,
                position = position_dodge(width = 0.55)) +
  scale_fill_manual(values = c("Low Error" = "#4575b4", "High Error" = "#d73027")) +
  scale_y_continuous( limits = c(0, 5),
                      breaks = 0:5,
                      expand = expansion(mult = c(0, .07))
  ) +
  labs(
    x = " ",                            
    y = "Subsequent Creativity Score"   
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

# 7. 散点+回归拟合线（类别型散点抖动）
ggplot(data, aes(x = subjective_creativity, y = creativity_rating, fill = subjective_creativity)) +
  geom_jitter(width = 0.2, height = 0.2, alpha = 0.3, shape = 21) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 4, fill = "white") +
  scale_fill_manual(values = c("Low Error" = "#4575b4", "High Error" = "#d73027")) +
  labs(
    x = "Prediction Error",
    y = "Creativity Rating",
    title = "Subsequent Creativity by Prediction Error"
  ) +
  theme_minimal(base_size = 15) +
  theme(legend.position = "none")

# 8. 模型诊断
par(mfrow = c(1, 2))
plot(resid(creativity_model_lmm), main = "Residuals")
qqnorm(resid(creativity_model_lmm)); qqline(resid(creativity_model_lmm))
par(mfrow = c(1, 1))


