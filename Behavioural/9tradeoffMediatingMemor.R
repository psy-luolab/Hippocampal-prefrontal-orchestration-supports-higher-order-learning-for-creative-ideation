library(brms)
library(readxl)
library(dplyr)
library(bayestestR)

# 1. 读取并预处理数据
df <- read_excel("/Users/zhangze/Desktop/NCreview1st/predictionErrortradeoff.xlsx")
data <- df %>%
  filter(!subject %in% c(16, 26, 27)) %>%
  mutate(
    subject = as.factor(subject),
    item = as.factor(item),
    subjective_creativity = factor(subjective_creativity, levels = c(4, 3), labels = c("Low Error", "High Error")),
    subjective_creativity_bin = ifelse(subjective_creativity == "High Error", 1, 0),
    trade_off = as.numeric(trade_off),
    trade_off = ifelse(is.infinite(trade_off), similarity_rating, trade_off),
    trade_off = ifelse(is.na(trade_off), 0, trade_off)
  ) 

# 2. 检查数据结构
str(data)

# 3. 多元联合建模公式，trade_off为中介
formula_m <- bf(trade_off ~ subjective_creativity_bin + (1|subject) + (1|item))
formula_y <- bf(memory ~ trade_off + subjective_creativity_bin + (1|subject) + (1|item), family = bernoulli())

# 4. 联合建模
fit_joint_mem <- brm(
  formula = formula_m + formula_y + set_rescor(FALSE),
  data = data,
  cores = 4,
  chains = 4,
  iter = 2000
)

# 5. 查看模型拟合结果
summary(fit_joint_mem)

# 6. 提取MCMC样本，计算间接、直接、总效应（在logit尺度上）
draws <- as_draws_df(fit_joint_mem)

# 路径a：High Error (vs. Low Error) 对 trade_off 的影响
a <- draws$b_tradeoff_subjective_creativity_bin

# 路径b：trade_off 对 memory (logit 尺度) 的影响
b <- draws$b_memory_trade_off

# 直接效应c'：High Error (vs. Low Error) 对 memory 的直接影响（控制 trade_off）
direct <- draws$b_memory_subjective_creativity_bin

# 间接效应
indirect <- a * b

# 总效应
total_effect <- direct + indirect

# 7. 输出效应的均值与贝叶斯置信区间（logit尺度）
cat("Indirect effect (logit scale) mean: ", mean(indirect), "\n")
print(ci(indirect, ci = 0.95))

cat("Direct effect (logit scale) mean: ", mean(direct), "\n")
print(ci(direct, ci = 0.95))

cat("Total effect (logit scale) mean: ", mean(total_effect), "\n")
print(ci(total_effect, ci = 0.95))

# ===== 路径图（参数a/b/c自动填充） =====
library(DiagrammeR)

a_mean <- mean(a)
a_ci <- ci(a, ci = 0.95)
a_est_mem <- sprintf("%.2f [%.2f, %.2f]", a_mean, a_ci$CI_low, a_ci$CI_high)

b_mean <- mean(b)
b_ci <- ci(b, ci = 0.95)
b_est_mem <- sprintf("%.2f [%.2f, %.2f]", b_mean, b_ci$CI_low, b_ci$CI_high)

c_mean <- mean(direct)
c_ci <- ci(direct, ci = 0.95)
c_est_mem <- sprintf("%.2f [%.2f, %.2f]", c_mean, c_ci$CI_low, c_ci$CI_high)


# ===== 后验分布密度图 =====
library(ggplot2)
indirect_df <- data.frame(indirect_effect = indirect)
ggplot(indirect_df, aes(x = indirect_effect)) +
  geom_density(fill = "#4575b4", alpha = 0.5) +
  geom_vline(xintercept = mean(indirect), color = "red", linetype = "dashed", size = 1) +
  geom_vline(xintercept = quantile(indirect, c(0.025, 0.975)), color = "black", linetype = "dotted") +
  labs(
    title = " ",
    x = "Indirect Effect (logit scale)",
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

  ggsave("/Users/zhangze/Desktop/NCreview1st/画图/tradeoff中介记忆.png", width = 7, height = 4.3)



