library(brms)
library(readxl)
library(dplyr)
library(bayestestR)

# 2. 读取原始数据
df <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionError.xlsx")

# 3. 数据筛选
#   - 删除subject为16, 26, 27的被试
#   - 删除similarity_rating为0的记录
df <- df %>%
  filter(
    !subject %in% c(16, 26, 27),       # 不等于16、26、27的被试
    similarity_rating != 0             # similarity_rating不等于0
  )

# 4. 变量重编码（将主观判断转为0/1）
df <- df %>%
  mutate(subjective_creativity_bin = ifelse(subjective_creativity == 3, 1, 0))

# 5. 设置贝叶斯多元混合模型的公式
formula_m <- bf(similarity_rating ~ subjective_creativity_bin + (1|subject) + (1|item))
formula_y <- bf(creativity_rating ~ similarity_rating + subjective_creativity_bin + (1|subject) + (1|item))

# 6. 联合建模
fit_joint <- brm(
  formula = formula_m + formula_y + set_rescor(FALSE),  # 不估计残差相关
  data = df,
  cores = 4,       # 根据你电脑实际CPU核心数设置
  chains = 4,      # MCMC链数，常用4
  iter = 2000      # 迭代步数，数值越大模型越稳妥
)

# 7. 查看模型结果
summary(fit_joint)

# 8. 提取每次MCMC采样下的参数，进行中介效应（a*b）贝叶斯估计
draws <- as_draws_df(fit_joint)

# 路径a（subjective_creativity_bin → similarity_rating）
a <- draws$b_similarityrating_subjective_creativity_bin

# 路径b（similarity_rating → creativity_rating）
b <- draws$b_creativityrating_similarity_rating

# 计算间接效应分布
indirect <- a * b

# 计算间接效应均值和95%贝叶斯置信区间
mean_indirect <- mean(indirect)
ci_indirect <- ci(indirect, ci = 0.95)

cat("间接效应均值：", mean_indirect, "\n")
print(ci_indirect)

# 直接效应（creativity_rating ~ subjective_creativity_bin）
direct <- draws$b_creativityrating_subjective_creativity_bin
cat("直接效应均值：", mean(direct), "\n")
print(ci(direct, ci = 0.95))

# 总效应（直接效应+间接效应）
total_effect <- direct + indirect
cat("总效应均值：", mean(total_effect), "\n")
print(ci(total_effect, ci = 0.95))

#画图2
library(ggplot2)

# 构造数据框
indirect_df <- data.frame(indirect_effect = indirect)

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


ggsave("/Users/zhangze/Desktop/NCreview1st/画图/模仿中介创造间接效应分布.png", width = 7, height = 4.3)

