# UFUG1811 Final Project — R Code Submission
# Family background, reading processes, and reading performance
#
# Reproducibility instructions:
# 1. Put this script and PISA2018_top10_new.sav in the same folder.
# 2. Set the R working directory to that folder.
# 3. Run the complete script from the first line.
#
# Required packages: haven and car.
# Results are written to the project_output folder.

output_dir <- "project_output"

library(haven)
library(car)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Read only the variables used in this project.
pisa <- read_sav(
  "PISA2018_top10_new.sav",
  col_select = c(
    CNT, ST004D01T, ST013Q01TA, ESCS, PV1READ,
    GRADE, REPEAT, JOYREAD, SCREADCOMP, SCREADDIFF,
    UNDREM, METASUM, METASPAM, EFFORT1
  )
)

# Recode labelled categorical variables.
pisa$gender <- factor(
  pisa$ST004D01T,
  levels = c(1, 2),
  labels = c("Female", "Male")
)

pisa$books <- factor(
  pisa$ST013Q01TA,
  levels = 1:6,
  labels = c(
    "0-10 books", "11-25 books", "26-100 books",
    "101-200 books", "201-500 books", "More than 500 books"
  )
)

pisa$country <- factor(pisa$CNT)

pisa$repeat_grade <- factor(
  pisa$REPEAT,
  levels = c(0, 1),
  labels = c("No", "Yes")
)

# -----------------------------------------------------------------------------
# 1. Descriptive analysis
# -----------------------------------------------------------------------------
continuous_variables <- c(
  "PV1READ", "ESCS", "GRADE", "JOYREAD", "SCREADCOMP",
  "SCREADDIFF", "UNDREM", "METASUM", "METASPAM", "EFFORT1"
)

continuous_stats <- data.frame(
  Variable = continuous_variables,
  N = sapply(pisa[continuous_variables], function(x) sum(!is.na(x))),
  Missing = sapply(pisa[continuous_variables], function(x) sum(is.na(x))),
  Mean = sapply(pisa[continuous_variables], mean, na.rm = TRUE),
  SD = sapply(pisa[continuous_variables], sd, na.rm = TRUE),
  Min = sapply(pisa[continuous_variables], min, na.rm = TRUE),
  Median = sapply(pisa[continuous_variables], median, na.rm = TRUE),
  Max = sapply(pisa[continuous_variables], max, na.rm = TRUE)
)
rownames(continuous_stats) <- NULL

missing_stats <- data.frame(
  Variable = c(
    "PV1READ", "ESCS", "Books", "Gender", "Country", "GRADE", "REPEAT",
    "JOYREAD", "SCREADCOMP", "SCREADDIFF", "UNDREM", "METASUM",
    "METASPAM", "EFFORT1"
  ),
  N_nonmissing = c(
    sum(!is.na(pisa$PV1READ)),
    sum(!is.na(pisa$ESCS)),
    sum(!is.na(pisa$books)),
    sum(!is.na(pisa$gender)),
    sum(!is.na(pisa$country)),
    sum(!is.na(pisa$GRADE)),
    sum(!is.na(pisa$repeat_grade)),
    sum(!is.na(pisa$JOYREAD)),
    sum(!is.na(pisa$SCREADCOMP)),
    sum(!is.na(pisa$SCREADDIFF)),
    sum(!is.na(pisa$UNDREM)),
    sum(!is.na(pisa$METASUM)),
    sum(!is.na(pisa$METASPAM)),
    sum(!is.na(pisa$EFFORT1))
  )
)
missing_stats$Missing <- nrow(pisa) - missing_stats$N_nonmissing
missing_stats$Missing_percent <- 100 * missing_stats$Missing / nrow(pisa)

book_freq <- as.data.frame(table(pisa$books, useNA = "no"))
names(book_freq) <- c("Books", "N")
book_freq$Percent <- 100 * book_freq$N / sum(book_freq$N)

repeat_freq <- as.data.frame(table(pisa$repeat_grade, useNA = "no"))
names(repeat_freq) <- c("Repeated_grade", "N")
repeat_freq$Percent <- 100 * repeat_freq$N / sum(repeat_freq$N)

gender_stats <- aggregate(
  PV1READ ~ gender,
  data = subset(pisa, !is.na(PV1READ) & !is.na(gender)),
  FUN = function(x) c(N = length(x), Mean = mean(x), SD = sd(x))
)
gender_stats <- data.frame(
  Gender = gender_stats$gender,
  N = gender_stats$PV1READ[, "N"],
  Mean = gender_stats$PV1READ[, "Mean"],
  SD = gender_stats$PV1READ[, "SD"]
)

book_stats <- aggregate(
  PV1READ ~ books,
  data = subset(pisa, !is.na(PV1READ) & !is.na(books)),
  FUN = function(x) {
    c(N = length(x), Mean = mean(x), SD = sd(x), SE = sd(x) / sqrt(length(x)))
  }
)
book_stats <- data.frame(
  Books = book_stats$books,
  N = book_stats$PV1READ[, "N"],
  Mean = book_stats$PV1READ[, "Mean"],
  SD = book_stats$PV1READ[, "SD"],
  SE = book_stats$PV1READ[, "SE"]
)
book_stats$Lower95 <- book_stats$Mean - 1.96 * book_stats$SE
book_stats$Upper95 <- book_stats$Mean + 1.96 * book_stats$SE

# -----------------------------------------------------------------------------
# 2. Comparative analyses
# -----------------------------------------------------------------------------
t_data <- subset(pisa, !is.na(PV1READ) & !is.na(gender))
gender_levene <- leveneTest(PV1READ ~ gender, data = t_data, center = median)
gender_t <- t.test(PV1READ ~ gender, data = t_data, var.equal = FALSE)

anova_data <- subset(pisa, !is.na(PV1READ) & !is.na(books))
books_levene <- leveneTest(PV1READ ~ books, data = anova_data, center = median)
books_welch <- oneway.test(PV1READ ~ books, data = anova_data, var.equal = FALSE)
books_pairwise <- pairwise.t.test(
  anova_data$PV1READ,
  anova_data$books,
  p.adjust.method = "holm",
  pool.sd = FALSE
)

# -----------------------------------------------------------------------------
# 3. Correlation analysis
# -----------------------------------------------------------------------------
cor_data <- subset(pisa, !is.na(PV1READ) & !is.na(ESCS))
escs_cor <- cor.test(cor_data$ESCS, cor_data$PV1READ, method = "pearson")

# -----------------------------------------------------------------------------
# 4. Multiple linear regression
# -----------------------------------------------------------------------------
# All four models use the same complete-case sample so that R-squared values
# can be compared fairly.
reg_data <- subset(
  pisa,
  complete.cases(
    PV1READ, ESCS, books, gender, country, GRADE, repeat_grade,
    JOYREAD, SCREADCOMP, SCREADDIFF,
    UNDREM, METASUM, METASPAM, EFFORT1
  )
)

model_1 <- lm(
  PV1READ ~ ESCS + books + gender + country + GRADE + repeat_grade,
  data = reg_data
)
model_2 <- lm(
  PV1READ ~ ESCS + books + gender + country + GRADE + repeat_grade +
    JOYREAD + SCREADCOMP + SCREADDIFF,
  data = reg_data
)
model_3 <- lm(
  PV1READ ~ ESCS + books + gender + country + GRADE + repeat_grade +
    JOYREAD + SCREADCOMP + SCREADDIFF +
    UNDREM + METASUM + METASPAM,
  data = reg_data
)
model_4 <- lm(
  PV1READ ~ ESCS + books + gender + country + GRADE + repeat_grade +
    JOYREAD + SCREADCOMP + SCREADDIFF +
    UNDREM + METASUM + METASPAM + EFFORT1,
  data = reg_data
)

model_summary <- data.frame(
  Model = c(
    "Background and education context",
    "+ reading engagement and self-concept",
    "+ metacognitive strategy knowledge",
    "+ test effort"
  ),
  N = sapply(list(model_1, model_2, model_3, model_4), nobs),
  R2 = sapply(
    list(model_1, model_2, model_3, model_4),
    function(m) summary(m)$r.squared
  ),
  Adjusted_R2 = sapply(
    list(model_1, model_2, model_3, model_4),
    function(m) summary(m)$adj.r.squared
  ),
  Residual_SE = sapply(
    list(model_1, model_2, model_3, model_4),
    sigma
  )
)

block_comparison <- anova(model_1, model_2, model_3, model_4)

# The residual-variance test is significant in this large sample. Coefficients
# are unchanged, but HC3 heteroskedasticity-robust standard errors are used for
# the final coefficient tests and confidence intervals.
robust_vcov <- hccm(model_4, type = "hc3")
robust_se <- sqrt(diag(robust_vcov))
robust_t <- coef(model_4) / robust_se
robust_p <- 2 * pt(abs(robust_t), df.residual(model_4), lower.tail = FALSE)
critical_t <- qt(0.975, df.residual(model_4))

robust_coef_table <- data.frame(
  Term = names(coef(model_4)),
  Estimate = unname(coef(model_4)),
  Robust_SE = unname(robust_se),
  t_value = unname(robust_t),
  p_value = unname(robust_p),
  Lower95 = unname(coef(model_4) - critical_t * robust_se),
  Upper95 = unname(coef(model_4) + critical_t * robust_se)
)

# Regression diagnostics.
vif_raw <- vif(model_4)
if (is.matrix(vif_raw)) {
  vif_table <- data.frame(
    Term = rownames(vif_raw),
    GVIF = vif_raw[, "GVIF"],
    Df = vif_raw[, "Df"],
    Adjusted_GVIF = vif_raw[, "GVIF^(1/(2*Df))"]
  )
} else {
  vif_table <- data.frame(Term = names(vif_raw), VIF = as.numeric(vif_raw))
}

ncv_result <- ncvTest(model_4)
cook <- cooks.distance(model_4)
diagnostic_stats <- data.frame(
  Metric = c(
    "Maximum Cook's distance",
    "Cases with Cook's distance > 4/n",
    "Non-constant variance test chi-square",
    "Non-constant variance test p-value"
  ),
  Value = c(
    max(cook),
    sum(cook > 4 / nobs(model_4)),
    unname(ncv_result$ChiSquare),
    ncv_result$p
  )
)

# -----------------------------------------------------------------------------
# Save tables
# -----------------------------------------------------------------------------
write.csv(continuous_stats, file.path(output_dir, "continuous_stats.csv"), row.names = FALSE)
write.csv(missing_stats, file.path(output_dir, "missing_stats.csv"), row.names = FALSE)
write.csv(book_freq, file.path(output_dir, "book_frequencies.csv"), row.names = FALSE)
write.csv(repeat_freq, file.path(output_dir, "repeat_frequencies.csv"), row.names = FALSE)
write.csv(gender_stats, file.path(output_dir, "gender_stats.csv"), row.names = FALSE)
write.csv(book_stats, file.path(output_dir, "book_stats.csv"), row.names = FALSE)
write.csv(model_summary, file.path(output_dir, "model_summary.csv"), row.names = FALSE)
write.csv(
  as.data.frame(block_comparison),
  file.path(output_dir, "block_comparison.csv"),
  row.names = FALSE
)
write.csv(robust_coef_table, file.path(output_dir, "robust_coefficients.csv"), row.names = FALSE)
write.csv(vif_table, file.path(output_dir, "vif.csv"), row.names = FALSE)
write.csv(diagnostic_stats, file.path(output_dir, "diagnostic_stats.csv"), row.names = FALSE)

# -----------------------------------------------------------------------------
# Figures
# -----------------------------------------------------------------------------
png(file.path(output_dir, "figure1_distributions.png"), width = 1800, height = 760, res = 180)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 2.5, 1))
hist(
  pisa$PV1READ,
  breaks = 35,
  col = "#D9E8F5",
  border = "white",
  main = "Reading score",
  xlab = "PV1READ",
  ylab = "Number of students"
)
abline(v = mean(pisa$PV1READ, na.rm = TRUE), col = "#1F4E79", lwd = 2)
hist(
  pisa$ESCS,
  breaks = 35,
  col = "#E5E5E5",
  border = "white",
  main = "Economic, social and cultural status",
  xlab = "ESCS",
  ylab = "Number of students"
)
abline(v = mean(pisa$ESCS, na.rm = TRUE), col = "#1F4E79", lwd = 2)
dev.off()

png(file.path(output_dir, "figure2_books_means.png"), width = 1500, height = 900, res = 180)
par(mar = c(9, 5, 2, 1))
x <- seq_len(nrow(book_stats))
plot(
  x, book_stats$Mean,
  ylim = range(book_stats$Lower95, book_stats$Upper95),
  pch = 19, cex = 1.3, col = "#1F4E79",
  xaxt = "n", xlab = "", ylab = "Mean PV1READ score"
)
arrows(
  x, book_stats$Lower95, x, book_stats$Upper95,
  angle = 90, code = 3, length = 0.05, col = "#1F4E79"
)
axis(1, at = x, labels = book_stats$Books, las = 2, cex.axis = 0.85)
lines(x, book_stats$Mean, col = "#7A9BB8", lwd = 1.5)
dev.off()

set.seed(1811)
scatter_data <- cor_data[
  sample(seq_len(nrow(cor_data)), min(12000, nrow(cor_data))),
]
png(file.path(output_dir, "figure3_escs_reading.png"), width = 1500, height = 950, res = 180)
par(mar = c(5, 5, 2, 1))
plot(
  scatter_data$ESCS, scatter_data$PV1READ,
  pch = 16, cex = 0.35,
  col = rgb(31, 78, 121, alpha = 45, maxColorValue = 255),
  xlab = "PISA index of economic, social and cultural status (ESCS)",
  ylab = "Reading score (PV1READ)"
)
abline(lm(PV1READ ~ ESCS, data = cor_data), col = "#B33A3A", lwd = 2.5)
dev.off()

png(file.path(output_dir, "figure4_model_r2.png"), width = 1500, height = 900, res = 180)
par(mar = c(8, 5, 2, 1))
model_labels <- c(
  "Background\nand context",
  "+ engagement\nand self-concept",
  "+ metacognitive\nstrategies",
  "+ test effort"
)
bars <- barplot(
  model_summary$R2,
  names.arg = model_labels,
  las = 2,
  ylim = c(0, 0.50),
  col = c("#D9E8F5", "#B8D3E6", "#789FBD", "#1F4E79"),
  border = NA,
  ylab = "R-squared"
)
text(
  bars,
  model_summary$R2 + 0.012,
  labels = sprintf("%.3f", model_summary$R2),
  cex = 0.9
)
dev.off()

set.seed(1812)
diag_n <- min(15000, nrow(reg_data))
diag_idx <- sample(seq_len(nrow(reg_data)), diag_n)
diag_fit <- fitted(model_4)[diag_idx]
diag_res <- rstandard(model_4)[diag_idx]
png(file.path(output_dir, "figure5_regression_diagnostics.png"), width = 1800, height = 760, res = 180)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 2.5, 1))
plot(
  diag_fit, diag_res,
  pch = 16, cex = 0.35,
  col = rgb(31, 78, 121, alpha = 40, maxColorValue = 255),
  xlab = "Fitted values", ylab = "Standardised residuals",
  main = "Residuals versus fitted values"
)
abline(h = 0, col = "#B33A3A", lwd = 2)
qqnorm(
  diag_res,
  pch = 16, cex = 0.35,
  col = rgb(31, 78, 121, alpha = 45, maxColorValue = 255),
  main = "Normal Q-Q plot"
)
qqline(diag_res, col = "#B33A3A", lwd = 2)
dev.off()

# -----------------------------------------------------------------------------
# Save a readable record of the results
# -----------------------------------------------------------------------------
sink(file.path(output_dir, "inferential_results.txt"))
cat("DESCRIPTIVE STATISTICS\n")
print(continuous_stats)
cat("\nMISSING DATA\n")
print(missing_stats)
cat("\nBOOK FREQUENCIES\n")
print(book_freq)
cat("\nGRADE-REPETITION FREQUENCIES\n")
print(repeat_freq)
cat("\nGENDER DESCRIPTIVES\n")
print(gender_stats)
cat("\nBOOK DESCRIPTIVES\n")
print(book_stats)
cat("\nGENDER LEVENE TEST\n")
print(gender_levene)
cat("\nWELCH T-TEST\n")
print(gender_t)
cat("\nBOOKS LEVENE TEST\n")
print(books_levene)
cat("\nWELCH ONE-WAY ANOVA\n")
print(books_welch)
cat("\nPAIRWISE WELCH TESTS WITH HOLM ADJUSTMENT\n")
print(books_pairwise)
cat("\nPEARSON CORRELATION\n")
print(escs_cor)
cat("\nREGRESSION MODEL COMPARISON\n")
print(model_summary)
cat("\nNESTED MODEL TESTS\n")
print(block_comparison)
cat("\nFINAL REGRESSION MODEL\n")
print(summary(model_4))
cat("\nHC3 ROBUST COEFFICIENTS\n")
print(robust_coef_table)
cat("\nMULTICOLLINEARITY\n")
print(vif_table)
cat("\nNON-CONSTANT VARIANCE TEST\n")
print(ncv_result)
cat("\nINFLUENCE DIAGNOSTICS\n")
print(diagnostic_stats)
sink()

cat("Analysis completed. Results were saved to:", normalizePath(output_dir), "\n")

