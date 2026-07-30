# Build the solution as a strict line-by-line superset of the exercise.
# Every exercise line is preserved. Answer blocks are inserted immediately
# after their matching SOLUTION marker.

exercise_path <- "rsr_week_11_exercise_gpt5_x7q2.Rmd"
solution_path <- "rsr_week_11_solutions_gpt5_x7q2.Rmd"

solution_blocks <- list(
  q1_1 = c(
    "",
    "**Answer:** `co_hemo`, the carboxyhemoglobin level, has missing values.",
    ""
  ),
  q1_2 = c(
    "",
    "**Answer:** There are **93** missing carboxyhemoglobin values.",
    ""
  ),
  q1_3 = c(
    "",
    "**Answer:** No. Upper and Lower contain 179 patients, not the 274 ventilated patients reported in the paper. The paper also says ventilation was not given to every patient in those categories. The patient-level ventilation assignments cannot be recovered.",
    ""
  ),
  q2_1 = c(
    "",
    "**Answer:** Higher. The coefficient is positive and its odds ratio is about **1.031 per one-unit increase**.",
    ""
  ),
  q2_2 = c(
    "",
    "**Answer:** No. The p-value is about **0.178**, and the 95% confidence interval for the odds ratio includes 1.",
    ""
  ),
  q2_3 = c(
    "",
    "**Answer:** **Age** and **TBSA** have statistically significant univariable associations. Carboxyhemoglobin does not.",
    ""
  ),
  q2_4 = c(
    "",
    "**Answer:** **Upper** and **Lower** have statistically significant odds ratios compared with Normal. Subjective does not.",
    ""
  ),
  q2_5 = c(
    "",
    "**Answer:** The **<100** PF-ratio group has a statistically significant odds ratio compared with >300.",
    ""
  ),
  q3_1 = c(
    "",
    "**Answer:** The model uses **583 patients**.",
    ""
  ),
  q3_2 = c(
    "",
    "**Answer:** There are 156 deaths for 10 parameters, or about **15.6 deaths per parameter**. This exceeds the rough teaching rule of 10 events per parameter.",
    ""
  ),
  code_multiv_model = c(
    "",
    "```{r multivariable-model-answer}",
    "multiv_model <- glm(",
    "  mortality ~ age_years + tbsa_percent + inhalation_injury +",
    "    pf_ratio_group + co_hemo,",
    "  family = binomial,",
    "  data = burns_model_data",
    ")",
    "",
    "summary(multiv_model)",
    "```",
    ""
  ),
  q3_3 = c(
    "",
    "**Answer:** Yes. `multiv_model$converged` is `TRUE`.",
    ""
  ),
  q3_4 = c(
    "",
    "**Answer:** One acceptable equation is:",
    "",
    "$$",
    "\\log\\left(\\frac{p}{1-p}\\right) = \\beta_0 + \\beta_1(\\mathrm{age}) + \\beta_2(\\mathrm{TBSA}) + \\beta_3 I(\\mathrm{Subjective}) + \\beta_4 I(\\mathrm{Upper}) + \\beta_5 I(\\mathrm{Lower}) + \\beta_6 I(\\mathrm{PF\\ 200{-}300}) + \\beta_7 I(\\mathrm{PF\\ 100{-}200}) + \\beta_8 I(\\mathrm{PF<100}) + \\beta_9(\\mathrm{COHb})",
    "$$",
    "",
    "Normal inhalation injury and PF ratio >300 are the reference levels, so their indicators do not appear as separate terms.",
    ""
  ),
  code_multiv_tidy = c(
    "",
    "```{r multivariable-tidy-answer}",
    "multiv_results <- tidy(",
    "  multiv_model,",
    "  conf.int = TRUE,",
    "  exponentiate = TRUE",
    ")",
    "",
    "multiv_results",
    "```",
    ""
  ),
  q3_5 = c(
    "",
    "**Answer:** Holding TBSA, inhalation injury, PF-ratio group, and carboxyhemoglobin constant, each additional year of age was associated with about **1.068 times the odds**, or **6.8% higher odds**, of mortality.",
    ""
  ),
  q3_6 = c(
    "",
    "**Answer:** Holding the other included variables constant, each additional percentage point of TBSA burned was associated with about **1.100 times the odds**, or **10.0% higher odds**, of mortality.",
    ""
  ),
  q3_7 = c(
    "",
    "**Answer:** Holding the other included variables constant, the Upper group had about **3.99 times the odds of mortality** compared with the Normal group. The profile-likelihood 95% CI is approximately 1.63 to 9.95.",
    ""
  ),
  q3_8 = c(
    "",
    "**Answer:** **Age** and **TBSA** both have larger odds ratios after adjustment than in their univariable models.",
    ""
  ),
  q3_9 = c(
    "",
    "**Answer:** The **inhalation-injury coefficients**, especially Upper and Lower, differ most. The other adjusted odds ratios are quite close to the published values.",
    ""
  ),
  q3_10 = c(
    "",
    "**Answer:** Yes. Removing inhalation injury worsens fit in our model (likelihood-ratio p about **0.0002**), so the three inhalation terms are jointly associated with mortality in this available-data model.",
    ""
  ),
  q4_1 = c(
    "",
    "**Answer:** No obvious violation is described. Each row is one patient and there are no repeated measurements. Independence still relies on the study design and cannot be proven from a residual plot.",
    ""
  ),
  q4_2 = c(
    "",
    "**Answer:** No. All VIF values are low, below about **1.4**, so the panel does not suggest serious multicollinearity.",
    ""
  ),
  q4_3 = c(
    "",
    "**Answer:** No. Some observations have relatively large residuals, but none crosses the displayed Cook's-distance contours.",
    ""
  ),
  q4_4 = c(
    "",
    "**Answer:** Yes. The observed survivor and death counts fall within the model-predicted intervals. This checks the overall outcome distribution, but it is a weak check of predictor-specific fit.",
    ""
  ),
  q4_5 = c(
    "",
    "**Answer:** Several binned average residuals lie outside their error bounds, including bins at high fitted probabilities. This suggests systematic lack of fit in parts of the prediction range.",
    ""
  ),
  code_age_forms = c(
    "",
    "```{r age-form-models-answer}",
    "age_linear_model <- multiv_model",
    "",
    "age_quadratic_model <- glm(",
    "  mortality ~ age_years + I(age_years^2) + tbsa_percent +",
    "    inhalation_injury + pf_ratio_group + co_hemo,",
    "  family = binomial,",
    "  data = burns_model_data",
    ")",
    "",
    "age_decade_model <- glm(",
    "  mortality ~ age_decade + tbsa_percent + inhalation_injury +",
    "    pf_ratio_group + co_hemo,",
    "  family = binomial,",
    "  data = burns_model_data",
    ")",
    "",
    "AIC(age_linear_model, age_quadratic_model, age_decade_model)",
    "```",
    ""
  ),
  q5_1 = c(
    "",
    "**Answer:** The **age-decade model** has the lowest AIC, about **319.8**.",
    ""
  ),
  q5_2 = c(
    "",
    "**Answer:** It is about **5.4 AIC points lower** than the linear-age model (325.2 − 319.8).",
    ""
  ),
  q5_3 = c(
    "",
    "**Answer:** The simple linear-age model must be straight in the **log-odds panel**. Its probability curve is not required to be straight.",
    ""
  ),
  q5_4 = c(
    "",
    "**Answer:** Everyone within an age group receives the same age contribution and therefore the same fitted value when the other predictors are fixed. The fitted value changes only at a group boundary.",
    ""
  ),
  q5_5 = c(
    "",
    "**Answer:** No. Their AIC values differ by only about **0.9**, which is weak evidence for choosing between them.",
    ""
  ),
  code_forest_challenge = c(
    "",
    "```{r forest-challenge-answer}",
    "source(here(\"scripts/birthwt_univariable_forest_table_gpt5_x7q2.R\"))",
    "```",
    "",
    "The script constructs aligned text and forest-plot panels and saves the combined high-resolution PNG in `outputs`.",
    ""
  )
)

exercise_lines <- readLines(exercise_path, warn = FALSE)
solution_lines <- character()
used_blocks <- character()

for (line in exercise_lines) {
  solution_lines <- c(solution_lines, line)
  marker <- regmatches(line, regexec("<!-- SOLUTION: ([A-Za-z0-9_]+) -->", line))[[1]]
  if (length(marker) == 2) {
    block_name <- marker[2]
    if (is.null(solution_blocks[[block_name]])) {
      stop("No solution block found for marker: ", block_name)
    }
    solution_lines <- c(solution_lines, solution_blocks[[block_name]])
    used_blocks <- c(used_blocks, block_name)
  }
}

unused_blocks <- setdiff(names(solution_blocks), used_blocks)
if (length(unused_blocks) > 0) {
  stop("Unused solution blocks: ", paste(unused_blocks, collapse = ", "))
}

writeLines(solution_lines, solution_path, useBytes = TRUE)
message("Wrote ", solution_path, " with ", length(used_blocks), " inserted answer blocks.")

