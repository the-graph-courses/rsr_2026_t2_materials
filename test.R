# install.packages("pacman")
pacman::p_load(performance, see, qqplotr)

mc_high_overlap <- data.frame(
  age_years = c(8, 8.9, 15.2, 7.2, 6.4, 11.2, 8.6, 9.9, 6.6, 7.8, 8.7, 12, 9.6, 11.8, 4.1, 10.7, 9.3, 7.8, 9.6, 8.5, 8.4, 6.5, 10.3, 9.7, 10.7, 8.3, 6.7, 6.5, 10.1, 5.4, 12.2, 8.7, 10.7, 14.9, 7.3, 6.1, 10.7, 13.9, 7, 7.4, 12.7, 9.2, 8.1, 12.3, 11.4, 6.7, 12.2, 7.8, 6.7, 9.8, 11, 7.5, 10.8, 13.1, 4.9, 9.3, 12.9, 9.1, 7.7, 13),
  grade = c(2, 3, 9, 1, 1, 6, 3, 4, 1, 2, 3, 6, 5, 6, -1, 5, 4, 2, 4, 3, 3, 1, 5, 4, 5, 3, 1, 1, 4, 0, 6, 3, 5, 9, 2, 1, 5, 8, 2, 2, 7, 3, 3, 7, 5, 1, 7, 2, 1, 5, 6, 2, 5, 8, -1, 4, 8, 4, 2, 8),
  height_cm = c(123.1, 133.4, 172.1, 122.1, 119.3, 156.9, 137.5, 141.4, 121.5, 126, 132.5, 152.3, 137.1, 153.7, 107.2, 152.6, 139.1, 128.7, 140.2, 128, 132.7, 122.9, 144.5, 134.8, 150.2, 139.1, 121.7, 115.6, 137.5, 113.2, 153.5, 134.6, 147.2, 172.2, 125.9, 121.3, 140, 159.6, 121.2, 120.9, 162.3, 134.7, 122.6, 154.9, 156.4, 120.7, 153.7, 129.9, 121.2, 138.8, 154.6, 128.3, 146.1, 165.7, 109.2, 136.6, 164.6, 137.8, 125.6, 163.1)
)

model <- lm(height_cm ~ age_years + grade, data = mc_high_overlap)
summary(model)

check_model(model)

# --- Model fitting on msleep dataset ---
# Load ggplot2 to access msleep dataset
library(ggplot2)

# View the data structure
head(msleep)

# Fit a model predicting sleep_total with:
# - Two numeric predictors: bodywt (body weight) and brainwt (brain weight)
# - One categorical predictor: vore (diet type: herbivore, carnivore, etc.)

# Remove rows with missing values first
msleep_complete <- na.omit(msleep)

# Fit the linear model
model_msleep <- lm(sleep_total ~ bodywt + brainwt + vore, data = msleep_complete)

# Display model summary
summary(model_msleep)

# Check model assumptions
check_model(model_msleep)

# Visualize the data with a scatterplot
ggplot(msleep_complete, aes(x = bodywt, y = sleep_total, color = vore)) +
  geom_point(alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = FALSE, aes(group = vore)) +
  labs(
    title = "Sleep Duration vs Body Weight by Diet Type",
    x = "Body Weight (kg)",
    y = "Total Sleep (hours)",
    color = "Diet Type"
  ) +
  theme_minimal() +
  scale_x_log10() +  # Log scale for body weight due to wide range
  theme(legend.position = "bottom")