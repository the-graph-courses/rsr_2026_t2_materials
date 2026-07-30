# Worked example: descriptive data, univariable odds ratios, and a forest plot
# in one figure. Continuous predictors are modelled continuously, while
# categories are used only to show raw outcome proportions.

if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(tidyverse, broom, patchwork)

birthwt_clean <- MASS::birthwt %>%
  transmute(
    low = low,
    age = age,
    lwt = lwt,
    race = factor(race, levels = 1:3, labels = c("White", "Black", "Other")),
    smoke = factor(smoke, levels = 0:1, labels = c("No", "Yes")),
    ptl_cat = factor(case_when(ptl == 0 ~ "0", ptl == 1 ~ "1", ptl >= 2 ~ "2+"),
                     levels = c("0", "1", "2+")),
    age_5 = age / 5,
    lwt_10 = lwt / 10,
    age_band = cut(age, breaks = c(-Inf, 19, 24, 29, Inf),
                   labels = c("<20", "20–24", "25–29", "30+")),
    lwt_band = cut(lwt, breaks = c(-Inf, 109, 129, 149, Inf),
                   labels = c("<110", "110–129", "130–149", "150+"))
  )

# The odds ratios for age and maternal weight use meaningful increments.
age_model <- glm(low ~ age_5, family = binomial, data = birthwt_clean)
lwt_model <- glm(low ~ lwt_10, family = binomial, data = birthwt_clean)
race_model <- glm(low ~ race, family = binomial, data = birthwt_clean)
smoke_model <- glm(low ~ smoke, family = binomial, data = birthwt_clean)
ptl_model <- glm(low ~ ptl_cat, family = binomial, data = birthwt_clean)

wald_or <- function(model, term_name, row_key) {
  tidy(model) %>%
    filter(term == term_name) %>%
    mutate(log_estimate = estimate) %>%
    transmute(
      key = row_key,
      estimate = exp(log_estimate),
      conf_low = exp(log_estimate - 1.96 * std.error),
      conf_high = exp(log_estimate + 1.96 * std.error),
      reference = FALSE
    )
}

model_rows <- bind_rows(
  wald_or(age_model, "age_5", "age_cont"),
  wald_or(lwt_model, "lwt_10", "lwt_cont"),
  tibble(key = "race_white", estimate = 1, conf_low = NA_real_,
         conf_high = NA_real_, reference = TRUE),
  wald_or(race_model, "raceBlack", "race_black"),
  wald_or(race_model, "raceOther", "race_other"),
  tibble(key = "smoke_no", estimate = 1, conf_low = NA_real_,
         conf_high = NA_real_, reference = TRUE),
  wald_or(smoke_model, "smokeYes", "smoke_yes"),
  tibble(key = "ptl_0", estimate = 1, conf_low = NA_real_,
         conf_high = NA_real_, reference = TRUE),
  wald_or(ptl_model, "ptl_cat1", "ptl_1"),
  wald_or(ptl_model, "ptl_cat2+", "ptl_2plus")
) %>%
  mutate(or_text = if_else(
    reference,
    "Reference",
    sprintf("%.2f (%.2f–%.2f)", estimate, conf_low, conf_high)
  ))

summarise_group <- function(data, variable, key_prefix) {
  data %>%
    group_by(level = .data[[variable]]) %>%
    summarise(patients = n(), low_birthweight = sum(low),
              observed = sprintf("%.1f%%", 100 * mean(low))) %>%
    mutate(key = paste0(key_prefix, as.character(level))) %>%
    select(key, patients, low_birthweight, observed)
}

age_descriptive <- summarise_group(birthwt_clean, "age_band", "age_") %>%
  mutate(key = recode(key, `age_<20` = "age_lt20", `age_20–24` = "age_20_24",
                      `age_25–29` = "age_25_29", `age_30+` = "age_30plus"))

lwt_descriptive <- summarise_group(birthwt_clean, "lwt_band", "lwt_") %>%
  mutate(key = recode(key, `lwt_<110` = "lwt_lt110", `lwt_110–129` = "lwt_110_129",
                      `lwt_130–149` = "lwt_130_149", `lwt_150+` = "lwt_150plus"))

race_descriptive <- summarise_group(birthwt_clean, "race", "race_") %>%
  mutate(key = recode(key, race_White = "race_white", race_Black = "race_black",
                      race_Other = "race_other"))

smoke_descriptive <- summarise_group(birthwt_clean, "smoke", "smoke_") %>%
  mutate(key = recode(key, smoke_No = "smoke_no", smoke_Yes = "smoke_yes"))

ptl_descriptive <- summarise_group(birthwt_clean, "ptl_cat", "ptl_") %>%
  mutate(key = recode(key, `ptl_2+` = "ptl_2plus"))

continuous_descriptive <- tibble(
  key = c("age_cont", "lwt_cont"),
  patients = nrow(birthwt_clean),
  low_birthweight = sum(birthwt_clean$low),
  observed = c(
    sprintf("Mean %.1f (SD %.1f)", mean(birthwt_clean$age), sd(birthwt_clean$age)),
    sprintf("Mean %.1f (SD %.1f)", mean(birthwt_clean$lwt), sd(birthwt_clean$lwt))
  )
)

descriptive_rows <- bind_rows(
  continuous_descriptive, age_descriptive, lwt_descriptive,
  race_descriptive, smoke_descriptive, ptl_descriptive
)

row_layout <- tribble(
  ~key, ~label, ~row_type,
  "age_header", "Maternal age, years", "header",
  "age_cont", "  Continuous, per 5 years", "analysis",
  "age_sub", "      Observed rate by age band", "subheader",
  "age_lt20", "      <20", "description",
  "age_20_24", "      20–24", "description",
  "age_25_29", "      25–29", "description",
  "age_30plus", "      30+", "description",
  "lwt_header", "Maternal weight, pounds", "header",
  "lwt_cont", "  Continuous, per 10 pounds", "analysis",
  "lwt_sub", "      Observed rate by weight band", "subheader",
  "lwt_lt110", "      <110", "description",
  "lwt_110_129", "      110–129", "description",
  "lwt_130_149", "      130–149", "description",
  "lwt_150plus", "      150+", "description",
  "race_header", "Race", "header",
  "race_white", "  White", "analysis",
  "race_black", "  Black", "analysis",
  "race_other", "  Other", "analysis",
  "smoke_header", "Smoking during pregnancy", "header",
  "smoke_no", "  No", "analysis",
  "smoke_yes", "  Yes", "analysis",
  "ptl_header", "Previous premature labours", "header",
  "ptl_0", "  0", "analysis",
  "ptl_1", "  1", "analysis",
  "ptl_2plus", "  2+", "analysis"
) %>%
  mutate(y = rev(row_number()))

display_rows <- row_layout %>%
  left_join(descriptive_rows, by = "key") %>%
  left_join(model_rows, by = "key") %>%
  mutate(
    patients_text = if_else(is.na(patients), "", format(patients, big.mark = ",")),
    low_text = if_else(is.na(low_birthweight), "", format(low_birthweight, big.mark = ",")),
    observed = replace_na(observed, ""),
    or_text = replace_na(or_text, ""),
    fontface = case_when(row_type == "header" ~ "bold",
                         row_type == "subheader" ~ "italic",
                         TRUE ~ "plain")
  )

header_rows <- display_rows %>% filter(row_type == "header")
forest_rows <- display_rows %>% filter(!is.na(estimate))
top_y <- max(display_rows$y) + 1.25

text_table <- ggplot(display_rows) +
  geom_rect(data = header_rows,
            aes(xmin = -Inf, xmax = Inf, ymin = y - 0.48, ymax = y + 0.48),
            inherit.aes = FALSE, fill = "#dfe5ec") +
  geom_text(aes(x = 0, y = y, label = label, fontface = fontface),
            hjust = 0, size = 3.6, color = "#202733") +
  geom_text(aes(x = 4.3, y = y, label = patients_text), size = 3.5) +
  geom_text(aes(x = 5.45, y = y, label = low_text), size = 3.5) +
  geom_text(aes(x = 6.75, y = y, label = observed), size = 3.4) +
  geom_text(aes(x = 9.25, y = y, label = or_text),
            hjust = 1, size = 3.4, fontface = ifelse(display_rows$row_type == "analysis",
                                                     "bold", "plain")) +
  annotate("text", x = 0, y = top_y, label = "Predictor", hjust = 0,
           fontface = "bold", size = 3.8) +
  annotate("text", x = 4.3, y = top_y, label = "Patients", fontface = "bold", size = 3.8) +
  annotate("text", x = 5.45, y = top_y, label = "Low BW", fontface = "bold", size = 3.8) +
  annotate("text", x = 6.75, y = top_y, label = "Observed", fontface = "bold", size = 3.8) +
  annotate("text", x = 9.25, y = top_y, label = "Univariable OR (95% CI)",
           hjust = 1, fontface = "bold", size = 3.8) +
  coord_cartesian(xlim = c(0, 9.5), ylim = c(0.35, top_y + 0.35), clip = "off") +
  theme_void() +
  theme(plot.margin = margin(10, 5, 10, 10))

forest_plot <- ggplot(display_rows) +
  geom_rect(data = header_rows,
            aes(xmin = 0.15, xmax = 20, ymin = y - 0.48, ymax = y + 0.48),
            inherit.aes = FALSE, fill = "#dfe5ec") +
  geom_vline(xintercept = 1, linetype = 2, color = "#58626e") +
  geom_segment(data = forest_rows %>% filter(!reference),
               aes(x = conf_low, xend = conf_high, y = y, yend = y),
               linewidth = 0.7, color = "#24364b") +
  geom_point(data = forest_rows,
             aes(x = estimate, y = y, shape = reference),
             size = 2.6, color = "#24364b", fill = "white") +
  annotate("text", x = 1, y = top_y, label = "Univariable OR plot",
           fontface = "bold", size = 3.8) +
  scale_shape_manual(values = c(`FALSE` = 15, `TRUE` = 0), guide = "none") +
  scale_x_log10(limits = c(0.15, 20), breaks = c(0.25, 0.5, 1, 2, 5, 10, 20)) +
  scale_y_continuous(limits = c(0.35, top_y + 0.35), expand = c(0, 0)) +
  labs(x = "Odds ratio (log scale)", y = NULL) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 5)
  )

combined_table <- text_table + forest_plot +
  plot_layout(widths = c(4.6, 1.7)) +
  plot_annotation(
    title = "Risk factors for low birthweight",
    subtitle = "Continuous predictors are modelled continuously; bands are descriptive only",
    caption = "Data: MASS::birthwt. BW = birthweight. ORs use separate univariable logistic regressions."
  )

dir.create("outputs", showWarnings = FALSE)
ggsave(
  "outputs/birthwt_univariable_forest_table_gpt5_x7q2.png",
  combined_table, width = 15, height = 10, dpi = 180
)

combined_table
