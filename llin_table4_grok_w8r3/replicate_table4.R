# Replicate Table 4 from Onyiah et al. (PLOS ONE) with Dryad data
# Minimal script: crosstabs + crude ORs via logistic regression

library(readxl)

d <- read_excel("data/llin_abuya.xls")
d$mal <- as.integer(d[["Microscopy result"]] == "pos")

# Area council codes → labels (1=Abuja municipal, 2=Kuje, 3=Kwali)
d$area <- factor(d$AreaCouncilCode, levels = 1:3,
                 labels = c("Abuja municipal", "Kuje", "Kwali"))
d$age <- factor(d$Age_RECODED,
                levels = c("<5", "5-9", "10-19", "20-24", "25-34", "35>"),
                labels = c("<5", "5–9", "10–19", "20–24", "25–34", "≥35"))
d$llin <- factor(d[["LLIN use_RECODED"]], levels = c(0, 1), labels = c("No", "Yes"))
d$wall <- factor(d$Housewall, levels = c("cement-plastered", "mud"),
                 labels = c("Cement plastered", "Mud"))

# Row of table: n (%) present | n (%) absent | OR (CI) or "ref"
row_or <- function(x, ref) {
  xt <- table(x, d$mal)
  levs <- levels(x)
  fit <- glm(mal ~ relevel(x, ref), data = d, family = binomial)
  or <- exp(coef(fit)); ci <- exp(confint.default(fit))
  out <- lapply(levs, function(lv) {
    n1 <- xt[lv, "1"]; n0 <- xt[lv, "0"]; N <- n1 + n0
    pct1 <- sprintf("%.1f", 100 * n1 / N)
    pct0 <- sprintf("%.1f", 100 * n0 / N)
    or_txt <- if (lv == ref) "ref" else {
      nm <- paste0("relevel(x, ref)", lv)
      sprintf("%.1f (%.1f–%.1f)", or[nm], ci[nm, 1], ci[nm, 2])
    }
    data.frame(
      Characteristics = lv,
      present = sprintf("%d (%.1f)", n1, as.numeric(pct1)),
      absent  = sprintf("%d (%.1f)", n0, as.numeric(pct0)),
      OR = or_txt, stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

hdr <- function(label) {
  data.frame(Characteristics = label, present = "", absent = "", OR = "",
             stringsAsFactors = FALSE)
}

tab <- rbind(
  hdr("Sex"),
  row_or(factor(d$Sex, levels = c("male", "female"),
                labels = c("Male", "Female")), "Female"),
  hdr("Age group (years)"),
  row_or(d$age, "<5"),
  hdr("Area council"),
  row_or(d$area, "Abuja municipal"),
  hdr("Slept in the same room with patient"),
  row_or(factor(d[["sleep same room with patient"]],
                levels = c("yes", "no"), labels = c("Yes", "No")), "No"),
  hdr("Uncovered water receptacles"),
  row_or(factor(d[["Uncovered water receptacles"]],
                levels = c("yes", "no"), labels = c("Yes", "No")), "No"),
  hdr("Bushes around house"),
  row_or(factor(d[["Bushes around the house"]],
                levels = c("yes", "no"), labels = c("Yes", "No")), "No"),
  hdr("LLIN use"),
  row_or(factor(d$llin, levels = c("Yes", "No")), "No"),
  hdr("House walls"),
  row_or(factor(d$wall, levels = c("Mud", "Cement plastered")), "Cement plastered")
)

names(tab) <- c(
  "Characteristics",
  sprintf("Malaria parasite present (N = %d)\nn (%%)", sum(d$mal == 1)),
  sprintf("Malaria parasite absent (N = %d)\nn (%%)", sum(d$mal == 0)),
  "Crude OR (95% CI)"
)

print(tab, row.names = FALSE, right = FALSE)
write.csv(tab, "table4_replication.csv", row.names = FALSE)
cat("\nWrote table4_replication.csv\n")
cat("Present N =", sum(d$mal == 1), "| Absent N =", sum(d$mal == 0), "\n")
