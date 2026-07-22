library(readxl)
library(dplyr)
library(gtsummary)
library(gt)

yn <- function(x) factor(x, c("yes", "no"), c("Yes", "No"))

d <- read_excel("data/source_data.xls", sheet = "Results") |>
  transmute(
    positive = `Microscopy result` == "pos",
    parasite = factor(`Microscopy result`, c("pos", "neg"),
                      c("Malaria parasite present", "Malaria parasite absent")),
    Sex = factor(Sex, c("male", "female"), c("Male", "Female")),
    `Age group (years)` = factor(Age_RECODED,
      c("<5", "5-9", "10-19", "20-24", "25-34", "35>"),
      c("<5", "5–9", "10–19", "20–24", "25–34", "≥35")),
    `Area council` = factor(AreaCouncilCode, 1:3,
                            c("Abuja municipal", "Kuje", "Kwali")),
    `Slept in the same room with patient` = yn(`sleep same room with patient`),
    `Uncovered water receptacles` = yn(`Uncovered water receptacles`),
    `Bushes around house` = yn(`Bushes around the house`),
    `LLIN use` = factor(`LLIN use_RECODED`, 1:0, c("Yes", "No")),
    `House walls` = factor(Housewall, c("mud", "cement-plastered"),
                           c("Mud", "Cement plastered"))
  )

vars <- names(d)[3:ncol(d)]
for (v in vars[c(1, 4:8)]) contrasts(d[[v]]) <- contr.treatment(2, base = 2)

counts <- d |>
  tbl_summary(
    by = parasite, include = all_of(vars), type = all_categorical() ~ "categorical",
    statistic = all_categorical() ~ "{n} ({p}%)", percent = "row",
    digits = all_categorical() ~ c(0, 1), missing = "no"
  ) |>
  modify_header(label = "**Characteristics**",
                all_stat_cols() ~ "**{level}**  \nN = {n}  \n*n (%)*")

odds <- d |>
  tbl_uvregression(
    y = positive, include = all_of(vars), method = glm,
    method.args = list(family = binomial), exponentiate = TRUE, hide_n = TRUE,
    estimate_fun = function(x) sprintf("%.1f", round(x, 2))
  ) |>
  modify_table_body(~ mutate(.x,
    conf.low = exp(log(estimate) - qnorm(.975) * std.error),
    conf.high = exp(log(estimate) + qnorm(.975) * std.error))) |>
  modify_column_merge(pattern = "{estimate} ({conf.low}–{conf.high})",
                      rows = !is.na(estimate)) |>
  modify_column_hide(columns = p.value)

table4 <- tbl_merge(list(counts, odds), tab_spanner = FALSE, quiet = TRUE) |>
  modify_header(estimate_2 = "**Crude OR (95% CI)**") |>
  modify_missing_symbol("ref", columns = estimate_2, rows = reference_row_2) |>
  modify_footnote(everything() ~ NA) |>
  remove_abbreviation() |>
  bold_labels() |>
  as_gt() |>
  cols_align("left", columns = label) |>
  cols_align("center", columns = -label) |>
  tab_style(
    style = cell_borders(sides = "all", color = "#999999", weight = px(1)),
    locations = list(cells_column_labels(), cells_body())
  ) |>
  tab_options(
    table.font.names = c("Times New Roman", "serif"), table.font.size = px(17),
    column_labels.font.size = px(17), data_row.padding = px(7), table.width = pct(100)
  ) |>
  tab_source_note(md("*significant at 5% level;")) |>
  tab_source_note(md("https://doi.org/10.1371/journal.pone.0203686.t004"))

gtsave(table4, "table4_reproduced.html")
gtsave(table4, "table4_reproduced.png", zoom = 2, vwidth = 1600)
