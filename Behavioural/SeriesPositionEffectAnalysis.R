library(readxl)    # 读取Excel文件
library(lme4)      # 混合线性模型，支持被试内设计
library(lmerTest)  # 在lme4基础上补充显著性p值
library(ggplot2)   # 画图
library(dplyr)     # 数据整理


df <- read_excel("")
colnames(df) # 检查变量名


lm_simple <- lm(creative_score ~ learning_order, data = df)
summary(lm_simple)

# 目的：考察学习顺序对创造分数的影响，同时以被试为随机截距，排除个体基线差异
model_mixed <- lmer(creative_score ~ learning_order + (1|subject), data = df)
summary(model_mixed)

# 目的：将学习顺序划分为四段，检验各区间创造分数是否有显著差异（不依赖分布假设）
df$order_bin <- cut(df$learning_order, breaks = 4, labels = FALSE)
kruskal.test(creative_score ~ order_bin, data = df)

# 目的：计算每个被试“学习顺序-创造分数”相关性，了解个体水平的一致性和趋势
cor_results <- df %>%
  group_by(subject) %>%
  summarise(spearman_cor = cor(learning_order, creative_score, method = "spearman"))

#画图
ggplot(df, aes(x = learning_order, y = creative_score)) +
  geom_point(alpha = 0.15, color = "grey30", size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "#d73027", fill = "#b3cde3", size = 2) +
  labs(
    x = "Presentation Order in Exemplar-learning",
    y = "Creative Performance"
  ) +
  scale_x_continuous(limits = c(0, 125), expand = c(0,0), breaks = seq(0, 120, 20)) +
  scale_y_continuous(limits = c(0, 5.5), expand = c(0,0), breaks = seq(0, 5, 1)) +
  theme_classic() +
  theme(
    axis.line = element_line(size = 0.5, colour = "black"),
    axis.ticks = element_line(size = 0.5, colour = "black"),
    axis.text = element_text(size = 15, colour = "black"),
    axis.title = element_text(size = 15, colour = "black"),
    plot.title = element_blank()
  )


ggsave(
  filename = "",  
  plot = last_plot(),     
  width = 8,              
  height = 5,             
  dpi = 400               
)

