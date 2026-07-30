# Example: a "raw numbers + forest plot" regression table, built from scratch
# ----------------------------------------------------------------------------
# Data: `birthwt` from the MASS package (189 mothers; outcome: low birth weight)
# Predictors chosen to cover the three common types:
#   - continuous: `age` (mother's age, years), `lwt` (mother's weight, pounds)
#   - binary:     `smoke` (smoked during pregnancy)
#   - polytomous: `race`; `ptl` recoded as 0 / 1 / 2+
#
# Key idea: continuous predictors are MODELLED as continuous (one odds ratio per
# unit increase), but we still CUT them into categories to display raw event
# proportions, because readers like to see n/N (%) alongside odds ratios.
#
# Run from the workshop project root with:
#   Rscript scripts/birthwt_regression_table_example.R
# or source() the file from an interactive session.
# ----------------------------------------------------------------------------

library(tidyverse)
library(broom)
library(patchwork)
# Note: we access the data as MASS::birthwt instead of library(MASS),
# because attaching MASS masks dplyr::select().

# ---- 1. Prepare the data -----------------------------------------------------

bw <- MASS::birthwt %>%
  as_tibble() %>%
  mutate(
    low = factor(low, levels = c(0, 1), labels = c("Normal", "Low")),
    race = factor(race, levels = 1:3, labels = c("White", "Black", "Other")),
    smoke = factor(smoke, levels = c(0, 1), labels = c("No", "Yes")),
    ptl_cat = factor(
      case_when(ptl == 0 ~ "0", ptl == 1 ~ "1", ptl >= 2 ~ "2+"),
      levels = c("0", "1", "2+")
    ),
    lwt10 = lwt / 10, # OR per 10 lb reads better than per 1 lb
    # Display-only categories for the continuous predictors
    age_cat = cut(age, breaks = c(-Inf, 19, 24, 29, Inf),
                  labels = c("<20", "20-24", "25-29", "30+")),
    lwt_cat = cut(lwt, breaks = c(-Inf, 129, 169, Inf),
                  labels = c("<130", "130-169", "170+"))
  )

# ---- 2. Fit the univariable models -------------------------------------------

fit_or <- function(formula, data = bw) {
  glm(formula, family = binomial, data = data) %>%
    tidy(conf.int = TRUE, exponentiate = TRUE)
}

or_age   <- fit_or(low ~ age)
or_lwt   <- fit_or(low ~ lwt10)
or_race  <- fit_or(low ~ race)
or_smoke <- fit_or(low ~ smoke)
or_ptl   <- fit_or(low ~ ptl_cat)

# ---- 3. Helper: raw event counts, n/N (%) -----------------------------------

raw_prop <- function(data, var) {
  data %>%
    count(.data[[var]], low) %>%
    pivot_wider(names_from = low, values_from = n, values_fill = 0) %>%
    mutate(
      n_total = Normal + Low,
      raw = sprintf("%d/%d (%.0f%%)", Low, n_total, 100 * Low / n_total)
    ) %>%
    select(level = 1, raw)
}

raw_age   <- raw_prop(bw, "age_cat")
raw_lwt   <- raw_prop(bw, "lwt_cat")
raw_race  <- raw_prop(bw, "race")
raw_smoke <- raw_prop(bw, "smoke")
raw_ptl   <- raw_prop(bw, "ptl_cat")

# ---- 4. Assemble the display rows --------------------------------------------
# Row types:
#   head : bold variable header; carries the OR when the variable is continuous
#   cat  : indented category row with raw n/N (%); carries the OR for
#          non-reference levels of categorical predictors

fmt_or <- function(tidy_df, term_name) {
  r <- tidy_df %>% filter(term == term_name)
  list(
    or = r$estimate, lo = r$conf.low, hi = r$conf.high,
    or_ci = sprintf("%.2f (%.2f-%.2f)", r$estimate, r$conf.low, r$conf.high),
    p = scales::pvalue(r$p.value, accuracy = 0.001)
  )
}

blank_row <- list(or = NA, lo = NA, hi = NA, or_ci = "", p = "")

rows <- bind_rows(
  # Age: modelled continuously; categories only display raw proportions
  tibble(label = "Age, years (OR per 1-year)", type = "head", raw = "",
         !!!fmt_or(or_age, "age")),
  tibble(label = paste0("   ", raw_age$level), type = "cat", raw = raw_age$raw,
         !!!blank_row),

  # Weight: modelled continuously per 10 lb
  tibble(label = "Mother's weight (OR per 10 lb)", type = "head", raw = "",
         !!!fmt_or(or_lwt, "lwt10")),
  tibble(label = paste0("   ", raw_lwt$level), type = "cat", raw = raw_lwt$raw,
         !!!blank_row),

  # Race: polytomous, White is the reference
  tibble(label = "Race", type = "head", raw = "", !!!blank_row),
  tibble(label = "   White (reference)", type = "cat",
         raw = raw_race$raw[raw_race$level == "White"],
         or_ci = "Reference", p = "", or = 1, lo = NA, hi = NA),
  tibble(label = "   Black", type = "cat",
         raw = raw_race$raw[raw_race$level == "Black"],
         !!!fmt_or(or_race, "raceBlack")),
  tibble(label = "   Other", type = "cat",
         raw = raw_race$raw[raw_race$level == "Other"],
         !!!fmt_or(or_race, "raceOther")),

  # Smoking: binary, No is the reference
  tibble(label = "Smoked during pregnancy", type = "head", raw = "", !!!blank_row),
  tibble(label = "   No (reference)", type = "cat",
         raw = raw_smoke$raw[raw_smoke$level == "No"],
         or_ci = "Reference", p = "", or = 1, lo = NA, hi = NA),
  tibble(label = "   Yes", type = "cat",
         raw = raw_smoke$raw[raw_smoke$level == "Yes"],
         !!!fmt_or(or_smoke, "smokeYes")),

  # Previous premature labours: ordinal, 0 is the reference
  tibble(label = "Previous premature labours", type = "head", raw = "", !!!blank_row),
  tibble(label = "   0 (reference)", type = "cat",
         raw = raw_ptl$raw[raw_ptl$level == "0"],
         or_ci = "Reference", p = "", or = 1, lo = NA, hi = NA),
  tibble(label = "   1", type = "cat",
         raw = raw_ptl$raw[raw_ptl$level == "1"],
         !!!fmt_or(or_ptl, "ptl_cat1")),
  tibble(label = "   2+", type = "cat",
         raw = raw_ptl$raw[raw_ptl$level == "2+"],
         !!!fmt_or(or_ptl, "ptl_cat2+"))
) %>%
  mutate(
    y = rev(row_number()), # first row at the top
    p = if_else(!is.na(or) & or == 1 & or_ci == "Reference", "", p)
  )

# ---- 5. Table panel (text columns drawn with ggplot) --------------------------

x_label <- 0
x_raw   <- 6.0
x_or    <- 8.0
x_p     <- 10.3

header_row <- tibble(
  y = max(rows$y) + 1,
  label = "Characteristic", raw = "Low birthweight, n/N (%)",
  or_ci = "OR (95% CI)", p = "p-value"
)

table_panel <- ggplot(rows, aes(y = y)) +
  geom_text(aes(x = x_label, label = label, fontface = ifelse(type == "head", 2, 1)),
            hjust = 0, size = 3.4) +
  geom_text(aes(x = x_raw, label = raw), hjust = 0.5, size = 3.2) +
  geom_text(aes(x = x_or, label = or_ci), hjust = 0.5, size = 3.2) +
  geom_text(aes(x = x_p, label = p), hjust = 0.5, size = 3.2) +
  geom_text(data = header_row, aes(x = x_label, label = label),
            hjust = 0, size = 3.4, fontface = 2) +
  geom_text(data = header_row, aes(x = x_raw, label = raw),
            hjust = 0.5, size = 3.2, fontface = 2) +
  geom_text(data = header_row, aes(x = x_or, label = or_ci),
            hjust = 0.5, size = 3.2, fontface = 2) +
  geom_text(data = header_row, aes(x = x_p, label = p),
            hjust = 0.5, size = 3.2, fontface = 2) +
  annotate("segment", x = -0.4, xend = 11.2,
           y = max(rows$y) + 0.45, yend = max(rows$y) + 0.45, linewidth = 0.4) +
  annotate("segment", x = -0.4, xend = 11.2,
           y = max(rows$y) + 1.55, yend = max(rows$y) + 1.55, linewidth = 0.6) +
  scale_y_continuous(limits = c(min(rows$y) - 1.2, max(rows$y) + 1.7),
                     expand = c(0, 0)) +
  scale_x_continuous(limits = c(-0.4, 11.2), expand = c(0, 0)) +
  theme_void()

# ---- 6. Forest plot panel -----------------------------------------------------

forest_panel <- ggplot(rows %>% filter(!is.na(or)), aes(y = y, x = or)) +
  annotate("segment", x = 1, xend = 1,
           y = min(rows$y) - 1.0, yend = max(rows$y) + 0.45,
           linetype = "dashed", color = "grey55", linewidth = 0.5) +
  geom_errorbar(aes(xmin = lo, xmax = hi), width = 0, orientation = "y",
                na.rm = TRUE, color = "grey35", linewidth = 0.5) +
  geom_point(aes(shape = or == 1, size = or == 1), color = "#00565e", show.legend = FALSE) +
  scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 15)) +
  scale_size_manual(values = c("FALSE" = 2.2, "TRUE" = 1.6)) +
  scale_x_log10(breaks = c(0.25, 0.5, 1, 2, 4, 8), limits = c(0.2, 17)) +
  scale_y_continuous(limits = c(min(rows$y) - 1.2, max(rows$y) + 1.7),
                     expand = c(0, 0)) +
  labs(x = "Odds ratio (log scale)", y = NULL) +
  theme_minimal(base_size = 9) +
  theme(axis.text.y = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.x = element_text(size = 8.5, color = "grey30"))

# ---- 7. Combine and save ------------------------------------------------------

combined <- table_panel + forest_panel +
  plot_layout(widths = c(2.9, 1)) +
  plot_annotation(
    title = "Univariable logistic regression: predictors of low birth weight",
    subtitle = "Data: MASS::birthwt (189 mothers). Continuous predictors are modelled on their original scale;\ncategories are shown only to display raw event proportions.",
    caption = "Squares mark reference categories (OR = 1 by definition). ORs and 95% CIs from separate glm() fits with family = binomial."
  ) &
  theme(plot.title = element_text(size = 13, face = "bold"),
        plot.subtitle = element_text(size = 9.5, color = "grey30"),
        plot.caption = element_text(size = 8, color = "grey45"))

print(combined)

out_file <- here::here("scripts/birthwt_regression_table.png")
ggsave(out_file, combined, width = 11.5, height = 7.5, dpi = 200)
message("Saved: ", out_file)
