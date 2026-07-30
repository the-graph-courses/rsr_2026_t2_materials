# ---------------------------------------------------------------------------
# Building a publication-style univariable regression table from scratch
# ---------------------------------------------------------------------------
#
# WHAT THIS SCRIPT IS FOR
#
# In the workshop you are asked to get an LLM to build a "figure-table": a
# single object that shows, for every predictor,
#
#   * the raw numbers (how many people, how many events),
#   * the observed rate, drawn as a small bar,
#   * the univariable odds ratio with its confidence interval,
#   * and a forest plot of that odds ratio.
#
# Most published examples of this only contain CATEGORICAL predictors, so an
# LLM asked to copy them often has no idea what to do with a CONTINUOUS
# predictor. There is no "group" to count, so there is no bar to draw.
#
# The trick used by good papers is this:
#
#     MODEL the continuous variable as continuous (one OR per unit),
#     but DESCRIBE it in bins (so the reader can still see the raw rates).
#
# The bin rows get a bar and counts but NO odds ratio -- they are description
# only. The single continuous row gets the odds ratio.
#
# This script builds that table from scratch so you can see every step.
#
# DATA: MASS::birthwt -- 189 births at Baystate Medical Center, 1986.
# OUTCOME: `low`, birth weight under 2500 g.
# PREDICTORS: age (continuous), lwt (continuous), race (polytomous),
#             smoke (binary), ptl (polytomous, collapsed to 0 / 1 / 2+).
# ---------------------------------------------------------------------------

if (!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, MASS, broom, gt, glue, scales, htmltools)

# `MASS::select()` masks `dplyr::select()`, so state which one we want.
select <- dplyr::select


# ---------------------------------------------------------------------------
# STEP 1. Prepare the data
# ---------------------------------------------------------------------------
# The raw variables are stored as bare integers, so we label them as factors.
# `ptl` (previous premature labours) has very few 2s and 3s, so we collapse
# the top of the distribution into a single "2+" group.

birthwt_clean <- MASS::birthwt %>%
  as_tibble() %>%
  mutate(
    low_bw = factor(low, levels = c(0, 1), labels = c("Normal", "Low")),
    race   = factor(race, levels = c(1, 2, 3), labels = c("White", "Black", "Other")),
    smoke  = factor(smoke, levels = c(0, 1), labels = c("Non-smoker", "Smoker")),
    ptl_group = factor(pmin(ptl, 2), levels = c(0, 1, 2),
                       labels = c("0", "1", "2+")),
    # Descriptive bins for the two continuous predictors. These are used for
    # the display rows ONLY; every model below uses the exact value.
    age_band = cut(age, breaks = c(0, 19, 24, 29, Inf),
                   labels = c("under 20", "20-24", "25-29", "30+")),
    lwt_band = cut(lwt, breaks = c(0, 109, 129, 149, Inf),
                   labels = c("under 110", "110-129", "130-149", "150+"))
  ) %>%
  select(low_bw, age, age_band, lwt, lwt_band, race, smoke, ptl_group)

glimpse(birthwt_clean)


# ---------------------------------------------------------------------------
# STEP 2. Fit the univariable models
# ---------------------------------------------------------------------------
# One model per predictor. The two continuous predictors are entered as
# continuous terms -- we do NOT model the bands.

model_age   <- glm(low_bw ~ age,       family = binomial, data = birthwt_clean)
model_lwt   <- glm(low_bw ~ lwt,       family = binomial, data = birthwt_clean)
model_race  <- glm(low_bw ~ race,      family = binomial, data = birthwt_clean)
model_smoke <- glm(low_bw ~ smoke,     family = binomial, data = birthwt_clean)
model_ptl   <- glm(low_bw ~ ptl_group, family = binomial, data = birthwt_clean)


# ---------------------------------------------------------------------------
# STEP 3. Rescale the continuous odds ratios to a readable unit
# ---------------------------------------------------------------------------
# A one-year change in age, or a one-pound change in weight, is a tiny step,
# so the OR sits very close to 1 and looks like nothing is happening.
# Multiplying the log-odds coefficient by 10 before exponentiating gives the
# OR "per 10 units", which is much easier to read.
#
#     OR per 10 units = exp(10 * beta)
#
# We apply the same multiplier to both confidence limits.

scale_or <- function(model, term, per = 10) {
  tidy(model, conf.int = TRUE) %>%          # NOTE: not exponentiated yet
    filter(term == !!term) %>%
    transmute(
      or       = exp(per * estimate),
      or_low   = exp(per * conf.low),
      or_high  = exp(per * conf.high),
      p_value  = p.value
    )
}

# For categorical predictors we just exponentiate directly.
plain_or <- function(model) {
  tidy(model, conf.int = TRUE, exponentiate = TRUE) %>%
    filter(term != "(Intercept)") %>%
    transmute(term, or = estimate, or_low = conf.low,
              or_high = conf.high, p_value = p.value)
}

or_age   <- scale_or(model_age, "age", per = 10)
or_lwt   <- scale_or(model_lwt, "lwt", per = 10)
or_race  <- plain_or(model_race)
or_smoke <- plain_or(model_smoke)
or_ptl   <- plain_or(model_ptl)


# ---------------------------------------------------------------------------
# STEP 4. Helper functions that build the display rows
# ---------------------------------------------------------------------------
# Each helper returns rows in one common shape, so that we can stack them all
# with bind_rows() at the end. The shared columns are:
#
#   group     variable heading the row belongs to
#   label     text shown in the first column
#   row_type  "estimate" (has an OR), "bin" (description only), or "subhead"
#   n         number of people in the row
#   events    number of low-birth-weight babies in the row
#   pct       observed percentage, used to draw the bar
#   summary   distribution text such as "mean 23.2 (SD 5.3)"
#   or/or_low/or_high/p_value   the effect estimate, where one exists

# -- Rows for a CONTINUOUS predictor -----------------------------------------
# Produces one "estimate" row for the continuous term, then a "subhead" and
# one "bin" row per band.

continuous_rows <- function(data, var, band, group, unit_label, or_result) {
  var  <- rlang::ensym(var)
  band <- rlang::ensym(band)

  # The single modelled row.
  overall <- data %>%
    summarise(
      n      = n(),
      events = sum(low_bw == "Low"),
      mean_x = mean(!!var),
      sd_x   = sd(!!var)
    ) %>%
    transmute(
      group    = group,
      label    = unit_label,
      row_type = "estimate",
      n, events,
      pct      = NA_real_,
      summary  = as.character(glue("mean {round(mean_x, 1)} (SD {round(sd_x, 1)})")),
      or       = or_result$or,
      or_low   = or_result$or_low,
      or_high  = or_result$or_high,
      p_value  = or_result$p_value
    )

  # The descriptive band rows.
  bins <- data %>%
    group_by(label = !!band) %>%
    summarise(
      n      = n(),
      events = sum(low_bw == "Low"),
      .groups = "drop"
    ) %>%
    transmute(
      group    = group,
      label    = as.character(label),
      row_type = "bin",
      n, events,
      pct      = 100 * events / n,
      summary  = NA_character_,
      or = NA_real_, or_low = NA_real_, or_high = NA_real_, p_value = NA_real_
    )

  subhead <- tibble(
    group = group, label = "Observed rate by band", row_type = "subhead",
    n = NA_integer_, events = NA_integer_, pct = NA_real_,
    summary = NA_character_,
    or = NA_real_, or_low = NA_real_, or_high = NA_real_, p_value = NA_real_
  )

  bind_rows(overall, subhead, bins)
}

# -- Rows for a CATEGORICAL predictor ----------------------------------------
# One row per level. The reference level gets OR = 1 with no interval.

categorical_rows <- function(data, var, group, or_result) {
  var <- rlang::ensym(var)

  counts <- data %>%
    group_by(level = !!var) %>%
    summarise(n = n(), events = sum(low_bw == "Low"), .groups = "drop") %>%
    mutate(pct = 100 * events / n)

  # broom names each term "<variable><level>", e.g. "raceBlack". Strip the
  # variable name off the front so the term matches the factor level.
  ors <- or_result %>%
    mutate(level = str_remove(term, paste0("^", rlang::as_string(var)))) %>%
    select(level, or, or_low, or_high, p_value)

  counts %>%
    left_join(ors, by = "level") %>%
    mutate(
      # The level with no matching coefficient is the reference.
      is_ref  = is.na(or),
      or      = if_else(is_ref, 1, or),
      label   = if_else(is_ref, paste0(level, " (ref)"), as.character(level)),
      group   = group,
      row_type = "estimate",
      summary = NA_character_
    ) %>%
    select(group, label, row_type, n, events, pct, summary,
           or, or_low, or_high, p_value)
}


# ---------------------------------------------------------------------------
# STEP 5. Stack every predictor into one table
# ---------------------------------------------------------------------------

table_rows <- bind_rows(
  continuous_rows(birthwt_clean, age, age_band,
                  group = "Age, years",
                  unit_label = "Continuous, per 10 years",
                  or_result = or_age),
  continuous_rows(birthwt_clean, lwt, lwt_band,
                  group = "Weight at last period, lbs",
                  unit_label = "Continuous, per 10 lbs",
                  or_result = or_lwt),
  categorical_rows(birthwt_clean, race,      "Race",                or_race),
  categorical_rows(birthwt_clean, smoke,     "Smoking during pregnancy", or_smoke),
  categorical_rows(birthwt_clean, ptl_group, "Previous premature labours", or_ptl)
) %>%
  mutate(group = fct_inorder(group))

print(table_rows, n = 30)


# ---------------------------------------------------------------------------
# STEP 6. Draw the two graphical columns as inline SVG
# ---------------------------------------------------------------------------
# `gt` will happily render raw HTML inside a cell, so we write small SVG
# strings by hand. This keeps everything in one table with no image files.

# -- The percentage bar -------------------------------------------------------
# A fixed-width track with a filled rectangle whose length is proportional to
# the observed percentage, and the number printed beside it.

BAR_MAX_PCT <- 60   # percentage that corresponds to a full-length bar

bar_svg <- function(pct) {
  if (is.na(pct)) return("")
  width <- 70 * min(pct / BAR_MAX_PCT, 1)
  glue(
    '<svg width="120" height="18">',
    '<rect x="0" y="3" width="{round(width, 1)}" height="12" fill="#aab4e8"/>',
    '<text x="78" y="13" font-size="11" fill="#333">{sprintf("%.1f", pct)}</text>',
    '</svg>'
  )
}

# -- The forest plot ----------------------------------------------------------
# All rows share one horizontal scale so that the points are comparable.
# Odds ratios are plotted on a LOG scale, which is the correct scale for
# ratios: OR 0.5 and OR 2 then sit the same distance either side of 1.

or_limits <- range(c(table_rows$or_low, table_rows$or_high, table_rows$or),
                   na.rm = TRUE)
or_limits <- c(min(or_limits[1], 0.5), max(or_limits[2], 2))

PLOT_WIDTH <- 90

# Map an odds ratio to a horizontal pixel position.
or_to_x <- function(or) {
  frac <- (log(or) - log(or_limits[1])) / (log(or_limits[2]) - log(or_limits[1]))
  10 + PLOT_WIDTH * pmin(pmax(frac, 0), 1)
}

forest_svg <- function(or, lo, hi) {
  if (is.na(or)) return('<span style="color:#999">&mdash;</span>')

  x_ref <- or_to_x(1)
  parts <- glue(
    # dashed line at OR = 1
    '<line x1="{x_ref}" y1="1" x2="{x_ref}" y2="19" ',
    'stroke="#999" stroke-width="1" stroke-dasharray="2,2"/>'
  )

  # Reference levels have no interval, so draw a hollow square only.
  if (!is.na(lo) && !is.na(hi)) {
    parts <- glue(
      parts,
      '<line x1="{or_to_x(lo)}" y1="10" x2="{or_to_x(hi)}" y2="10" ',
      'stroke="#3b3b3b" stroke-width="1.4"/>'
    )
  }

  glue(
    '<svg width="{PLOT_WIDTH + 20}" height="20">', parts,
    '<rect x="{or_to_x(or) - 3.5}" y="6.5" width="7" height="7" fill="#1f2544"/>',
    '</svg>'
  )
}


# ---------------------------------------------------------------------------
# STEP 7. Format the text columns and render with gt
# ---------------------------------------------------------------------------

table_display <- table_rows %>%
  mutate(
    n_text      = if_else(is.na(n), "", format(n, big.mark = " ", trim = TRUE)),
    events_text = if_else(is.na(events), "", as.character(events)),
    # The rate column holds either the distribution summary (continuous row)
    # or the bar (band and category rows).
    rate_cell = case_when(
      !is.na(summary) ~ as.character(glue(
        '<span style="color:#6b7280;font-style:italic">{summary}</span>')),
      !is.na(pct)     ~ map_chr(pct, bar_svg),
      TRUE            ~ ""
    ),
    or_text = case_when(
      row_type == "bin"  ~ "—",
      row_type != "estimate" ~ "",
      is.na(or_low)      ~ "1 (reference)",
      TRUE ~ sprintf("%.2f (%.2f – %.2f)", or, or_low, or_high)
    ),
    forest_cell = case_when(
      row_type == "estimate" ~ pmap_chr(list(or, or_low, or_high), forest_svg),
      # Bands are description only, so we print a dash to make clear that no
      # model was fitted to them. The sub-heading row stays empty.
      row_type == "bin"      ~ '<span style="color:#999">&mdash;</span>',
      TRUE                   ~ ""
    ),
    # Indent the descriptive rows so they read as subordinate.
    label_cell = case_when(
      row_type == "subhead" ~ as.character(glue(
        '<span style="padding-left:14px;font-style:italic;color:#6b7280">{label}</span>')),
      row_type == "bin"     ~ as.character(glue(
        '<span style="padding-left:28px">{label}</span>')),
      TRUE                  ~ as.character(glue(
        '<span style="padding-left:6px">{label}</span>'))
    )
  ) %>%
  select(group, label_cell, n_text, events_text, rate_cell, or_text, forest_cell)

# Row numbers of the modelled continuous rows, so we can shade them.
continuous_row_index <- which(str_detect(table_rows$label, "^Continuous, per"))

final_table <- table_display %>%
  gt(groupname_col = "group") %>%
  # Render the four columns that contain HTML rather than plain text.
  fmt_markdown(columns = c(label_cell, rate_cell, forest_cell)) %>%
  cols_label(
    label_cell  = "",
    n_text      = html("Num<br>births"),
    events_text = html("Num low<br>birth weight"),
    rate_cell   = html("% low<br>birth weight"),
    or_text     = html("Univariable<br>OR (95% CI)"),
    forest_cell = html("Univariable<br>OR plot")
  ) %>%
  cols_align(align = "right",  columns = c(n_text, events_text)) %>%
  cols_align(align = "left",   columns = c(rate_cell, forest_cell)) %>%
  cols_align(align = "center", columns = or_text) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_row_groups()
  ) %>%
  tab_style(
    style = cell_fill(color = "#eef0fb"),
    locations = cells_body(rows = continuous_row_index)
  ) %>%
  tab_style(
    style = cell_text(style = "italic"),
    locations = cells_body(columns = or_text, rows = continuous_row_index)
  ) %>%
  tab_header(
    title = md("**Predictors of low birth weight**"),
    subtitle = md(paste0(
      "*Age and weight modelled as continuous linear terms; ",
      "bands shown for description only*"))
  ) %>%
  tab_source_note(md(paste0(
    "Data: `MASS::birthwt`, 189 births, Baystate Medical Center, 1986. ",
    "Each odds ratio comes from a separate univariable logistic regression. ",
    "Continuous odds ratios are expressed per 10 units. ",
    "The forest plot uses a log scale, with the dashed line at OR = 1."
  ))) %>%
  tab_options(
    table.font.size = px(13),
    data_row.padding = px(4),
    row_group.background.color = "#f3f4f6"
  )

final_table


# ---------------------------------------------------------------------------
# STEP 8. Save
# ---------------------------------------------------------------------------

dir.create("outputs", showWarnings = FALSE)
gtsave(final_table, "outputs/birthwt_univariable_table.html")

# `gtsave()` can also write .docx and .png:
# gtsave(final_table, "outputs/birthwt_univariable_table.docx")


# ---------------------------------------------------------------------------
# WHAT TO TAKE AWAY
# ---------------------------------------------------------------------------
#
# 1. The continuous predictors are MODELLED continuously but DESCRIBED in
#    bands. That is what lets a continuous variable sit in the same table as
#    a categorical one without pretending it has groups.
#
# 2. Bands are description only. They carry counts and a bar, but a dash in
#    the odds-ratio columns, because no model was fitted to them. Putting an
#    OR on both the continuous row and its own bands would be reporting the
#    same variable twice.
#
# 3. Continuous odds ratios were rescaled to "per 10 units" so they are
#    readable. Always state the unit in the row label -- an unlabelled OR of
#    1.08 is ambiguous.
#
# 4. The forest plot is on a log scale, because odds ratios are ratios.
#
# 5. Every graphical element is an inline SVG string, so the whole table is a
#    single self-contained HTML object with no separate image files.
# ---------------------------------------------------------------------------
