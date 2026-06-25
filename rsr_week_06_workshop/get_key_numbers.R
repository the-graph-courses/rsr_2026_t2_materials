library(readr)
library(dplyr)

fev <- read_csv("data/fev_kahn.csv", show_col_types = FALSE)

age_model <- lm(fev_l ~ age_yrs, data = fev)
height_model <- lm(fev_l ~ height_in, data = fev)
raw_smoke_model <- lm(fev_l ~ smoke, data = fev)
controlled_smoke_model <- lm(fev_l ~ smoke + age_yrs + height_in, data = fev)

cat("Dataset dimensions:", dim(fev), "\n\n")

cat("Age model: fev_l ~ age_yrs\n")
cat("cor(age, FEV):", cor(fev$age_yrs, fev$fev_l), "\n")
print(coef(summary(age_model)))
cat("R-squared:", summary(age_model)$r.squared, "\n")
cat("age model predicted FEV at age 12:", predict(age_model, newdata = tibble(age_yrs = 12)), "\n\n")

cat("Height model: fev_l ~ height_in\n")
cat("cor(height, FEV):", cor(fev$height_in, fev$fev_l), "\n")
print(coef(summary(height_model)))
cat("R-squared:", summary(height_model)$r.squared, "\n")
cat("height model predicted FEV at 60 inches:", predict(height_model, newdata = tibble(height_in = 60)), "\n")
cat("height model predicted FEV at 20 inches:", predict(height_model, newdata = tibble(height_in = 20)), "\n\n")

cat("Smoking summary\n")
print(
  fev %>%
    group_by(smoke) %>%
    summarise(
      n = n(),
      mean_age = mean(age_yrs),
      mean_height = mean(height_in),
      mean_fev = mean(fev_l),
      .groups = "drop"
    )
)

cat("\nRaw smoking model: fev_l ~ smoke\n")
print(coef(summary(raw_smoke_model)))
cat("R-squared:", summary(raw_smoke_model)$r.squared, "\n")

cat("\nControlled smoking model: fev_l ~ smoke + age_yrs + height_in\n")
print(coef(summary(controlled_smoke_model)))
cat("R-squared:", summary(controlled_smoke_model)$r.squared, "\n")
