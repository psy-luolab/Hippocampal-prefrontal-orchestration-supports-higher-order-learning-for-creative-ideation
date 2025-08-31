library(brms)
library(readxl)
library(dplyr)
library(bayestestR)

# 2. 读取原始数据
df <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionError.xlsx")

# 3. 删除subject为16, 26, 27的被试
df <- df %>%
  filter(!subject %in% c(16, 26, 27)) %>%   # 删除指定被试
  mutate(subjective_creativity_bin = ifelse(subjective_creativity == 3, 1, 0))  # 主观判断转为0/1


# 4. 设置brms的多元联合建模公式
# 中介方程：similarity_rating（高斯）~ 主观判断 + (1|subject) + (1|item)
# 结局方程：memory（二分）~ similarity_rating + 主观判断 + (1|subject) + (1|item)，family=bernoulli

formula_m <- bf(similarity_rating ~ subjective_creativity_bin + (1|subject) + (1|item))
formula_y <- bf(memory ~ similarity_rating + subjective_creativity_bin + (1|subject) + (1|item), family = bernoulli())

# 5. 联合建模
fit_joint_mem <- brm(
  formula = formula_m + formula_y + set_rescor(FALSE),
  data = df,
  cores = 4,
  chains = 4,
  iter = 2000
)

# 6. 查看模型拟合结果
summary(fit_joint_mem)

# 7. 提取MCMC样本，计算间接效应、直接效应、总效应（在logit尺度上）
draws <- as_draws_df(fit_joint_mem)

# 路径a：主观判断对相似性评分的影响
a <- draws$b_similarityrating_subjective_creativity_bin

# 路径b'：相似性评分对memory（logit尺度）的影响
b <- draws$b_memory_similarity_rating

# 直接效应c''：主观判断对memory的影响（logit尺度，控制相似性）
direct <- draws$b_memory_subjective_creativity_bin

# 间接效应
indirect <- a * b

# 总效应
total_effect <- direct + indirect

# 8. 输出效应的均值与贝叶斯置信区间（logit尺度）
cat("间接效应（logit尺度）均值：", mean(indirect), "\n")
print(ci(indirect, ci = 0.95))

cat("直接效应（logit尺度）均值：", mean(direct), "\n")
print(ci(direct, ci = 0.95))

cat("总效应（logit尺度）均值：", mean(total_effect), "\n")
print(ci(total_effect, ci = 0.95))


#画图2
# 假设你前面已经有了indirect这个向量
indirect_df <- data.frame(indirect_effect = indirect)

# 检查数据框是否构造成功
head(indirect_df)

# 绘制密度曲线，去掉背景网格线
ggplot(indirect_df, aes(x = indirect_effect)) +
  geom_density(fill = "#4575b4", alpha = 0.5) +
  geom_vline(xintercept = mean(indirect), color = "red", linetype = "dashed", size = 1) +
  geom_vline(xintercept = quantile(indirect, c(0.025, 0.975)), color = "black", linetype = "dotted") +
  labs(
    title = " ",
    x = "Indirect Effect (a × b)",
    y = "Density"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    panel.grid.major = element_blank(),  # 去掉主网格线
    panel.grid.minor = element_blank(),  # 去掉次网格线
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # 设置标题字体大小和加粗
    axis.title.x = element_text(size = 16, face = "plain"),  # 设置X轴标题字体
    axis.title.y = element_text(size = 16, face = "plain"),  # 设置Y轴标题字体
    axis.text = element_text(size = 14, color = "black")  # 设置坐标轴标签字体
  )



ggsave("/Users/zhangze/Desktop/NCreview1st/画图/模仿中介记忆.png", width = 7, height = 4.3)



