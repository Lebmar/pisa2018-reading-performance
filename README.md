# PISA 2018 Reading Performance

家庭背景与阅读过程对阅读成绩的预测作用 · UFUG1811 量化数据分析课程项目 · 全班最高成绩 A

> **一句话（简历用）**：基于 PISA 2018 十个教育系统 80,016 名学生数据（建模样本 63,284）独立完成全流程分析。分层多元回归显示，家庭背景与教育情境解释 18.8% 的方差，而**元认知策略知识单独贡献 +14.7 个百分点**（最终 R² = 0.437），其最强单一预测变量（可信度评估策略，β = 25.2）的解释力远超家庭背景（β = 10.5）。

---

## 研究问题

| 编号 | 问题 |
|---|---|
| RQ1 | 阅读成绩、ESCS、家庭藏书量及主要阅读相关指数在清洗后数据集中的分布如何？ |
| RQ2a | 男女学生的平均阅读成绩是否存在差异？ |
| RQ2b | 六个家庭藏书量类别之间的平均阅读成绩是否存在差异？ |
| RQ3 | ESCS 与阅读成绩是否线性相关？ |
| RQ4a | 多元线性回归能解释多少变异？分块加入背景与教育情境、阅读投入与自我概念、元认知策略知识、考试投入后，R² 如何变化？ |
| RQ4b | 在控制家庭背景、性别、教育系统、年级位置与留级情况后，哪些阅读相关预测变量仍与成绩显著相关？ |

**方法论边界**：本研究考察的是**统计关联**，不是因果效应。

## 数据

| 项目 | 内容 |
|---|---|
| 来源 | PISA 2018 学生问卷（课程提供的精简版数据文件） |
| 样本 | 80,016 名学生 |
| 教育系统（10 个） | Canada、Estonia、Finland、Hong Kong (China)、Ireland、Korea、Macao (China)、Poland、B-S-J-Z (China)、Singapore |
| 建模样本 | 63,284（完整案例分析，保证各模型 R² 可比） |

> 各教育系统样本量不等，合并数据未按系统平衡；课程数据仅含第一个阅读 plausible value，不含抽样权重与重复权重，因此结果未做抽样加权。

### 变量

| 变量 | 说明 | 角色 |
|---|---|---|
| PV1READ | 阅读成绩（第一个 plausible value） | 因变量 |
| ESCS | 经济、社会与文化地位指数 | 背景 |
| ST013Q01TA | 家庭藏书量（六分类） | 背景 |
| ST004D01T | 性别 | 控制 |
| CNT | 教育系统 | 控制 |
| GRADE | 相对系统内常态年级的年级位置 | 控制 |
| REPEAT | 是否留过级 | 控制 |
| JOYREAD | 阅读乐趣 | 投入 |
| SCREADCOMP / SCREADDIFF | 感知阅读能力 / 感知阅读难度 | 自我概念 |
| UNDREM / METASUM / METASPAM | 理解记忆 / 概括 / 可信度评估策略知识 | 元认知 |
| EFFORT1 | 自评考试投入（1–10） | 考试投入 |

### 缺失处理

| 变量 | 缺失 | 变量 | 缺失 |
|---|---|---|---|
| PV1READ / GRADE | 0% | SCREADDIFF | 4.65% |
| ESCS | 2.28% | UNDREM / METASUM / METASPAM | 6.64% / 6.44% / 7.01% |
| 家庭藏书 | 2.20% | EFFORT1 | 10.25% |
| JOYREAD | 2.73% | 性别 | 2 人 |
| SCREADCOMP | 4.79% | 留级 | 2,532 人（3.16%） |

描述与双变量分析使用全部可用观测；**所有回归模型统一使用 63,284 的完整案例样本**，以保证 R² 可比。

## 结果

### R² 的分块递进

| 模型 | N | R² | 调整 R² | ΔR² | 残差标准误 |
|---|---|---|---|---|---|
| 家庭背景 + 教育情境 | 63,284 | 0.1884 | 0.1882 | — | 86.44 |
| ＋阅读投入与自我概念 | 63,284 | 0.2841 | 0.2839 | +0.0957 | 81.19 |
| **＋元认知策略知识** | 63,284 | **0.4314** | 0.4312 | **+0.1473** | 72.36 |
| ＋考试投入 | 63,284 | **0.4371** | 0.4369 | +0.0057 | 71.99 |

四个分块的 F 检验全部显著（p < 2.9e-141）。**元认知策略知识这一块的贡献（+14.7）超过了家庭背景之后所有心理变量的合计，也远超"阅读投入与自我概念"（+9.6）。**

### 控制后仍显著的预测变量（稳健标准误）

| 变量 | β | 稳健 SE | t | 显著性 |
|---|---|---|---|---|
| **METASPAM（可信度评估策略）** | **25.25** | 0.32 | 78.24 | *** |
| METASUM（概括策略） | 15.97 | 0.35 | 45.24 | *** |
| SCREADCOMP（感知阅读能力） | 12.62 | 0.41 | 30.45 | *** |
| JOYREAD（阅读乐趣） | 8.90 | 0.35 | 25.52 | *** |
| UNDREM（理解记忆策略） | 8.65 | 0.34 | 25.61 | *** |
| SCREADDIFF（感知阅读难度） | −8.21 | 0.36 | −22.65 | *** |
| ESCS | 10.52 | 0.39 | 26.97 | *** |
| GRADE | 14.72 | 0.69 | 21.35 | *** |
| 留过级 | −29.77 | 1.46 | −20.46 | *** |
| EFFORT1（考试投入） | 4.29 | 0.19 | 22.34 | *** |
| 性别（男） | −0.73 | 0.60 | −1.22 | n.s. (p = 0.22) |

**教育系统固定效应**（以 Canada 为参照）：Hong Kong (China) +47.06、Macao (China) +43.11、B-S-J-Z (China) +36.61、Singapore +34.07、Estonia +7.67、Korea +7.15、Ireland −10.33、Poland +2.45 (n.s.)、Finland +1.64 (n.s.)。

### 三个值得注意的发现

1. **"怎么读"比"家里有什么"更能解释差异。** 元认知策略块 ΔR² = +0.147，其中可信度评估策略（METASPAM）以 β = 25.25 成为最强单一预测变量，而家庭背景 ESCS 的 β 仅 10.52。
2. **性别差异在控制后消失。** 男生 β = −0.73，p = 0.22，不显著——成绩差异主要由阅读过程和策略知识解释，而非性别本身。
3. **藏书量与成绩非单调。** 相对 0–10 本：11–25 本 +8.30、26–100 本 +19.37、101–200 本 +26.39、201–500 本 +34.39（峰值）、500 本以上回落至 +27.04。

### 诊断

所有预测变量的调整 GVIF^(1/(2·df)) 均 < 1.32，**不存在多重共线性问题**。回归诊断图见 `output/figure5_regression_diagnostics.png`。

## 项目结构

```
pisa2018-reading-performance/
├── README.md
├── LICENSE
├── docs/
│   └── QUAN-Report.pdf              # 完整研究报告（25 页）
├── src/
│   └── R Code.R                     # 全部分析代码（441 行）
└── output/                          # 代码生成的全部产出
    ├── model_summary.csv            # 四个模型的 R² / 调整 R² / 残差标准误
    ├── block_comparison.csv         # 分块 F 检验
    ├── robust_coefficients.csv      # 稳健标准误下的系数与显著性
    ├── vif.csv                      # 共线性诊断
    ├── inferential_results.txt      # 描述统计与推断结果
    └── figure1–5*.png               # 分布、组间差异、R² 递进、回归诊断图
```

## 如何运行

```r
# R 4.x，需要以下包
install.packages(c("tidyverse", "haven", "sandwich", "lmtest", "car", "ggplot2"))

# 把 PISA 数据文件路径改到脚本顶部，然后运行
source("src/R Code.R")
```

结果会输出到 `output/`。

## 技术栈

R（tidyverse / sandwich / lmtest / car / ggplot2）· 稳健标准误 · 分层多元回归 · 共线性诊断

---

## English Summary

Independent end-to-end analysis of PISA 2018 reading performance across ten education systems (80,016 students; 63,284 in the complete-case modeling sample). Hierarchical multiple regression shows that family background and education context explain 18.8% of variance, reading engagement and self-concept add 9.6 points, and **metacognitive strategy knowledge alone adds 14.7 points** to a final R² of 0.437. The strongest single predictor is credibility-assessment strategy knowledge (β = 25.25), far exceeding family background (ESCS, β = 10.52). After controls, the gender gap is not significant (β = −0.73, p = 0.22), and the home-book gradient peaks at 201–500 books before declining. All findings are framed as statistical associations, not causal effects. Diagnostics: adjusted GVIF < 1.32 throughout; robust standard errors used.

---

**Author**: Chengxuan Yuan (Lebmar) · Hong Kong University of Science and Technology (Guangzhou)
**Course**: UFUG1811 Quantitative Data Analysis for Social Research · Highest grade in class
