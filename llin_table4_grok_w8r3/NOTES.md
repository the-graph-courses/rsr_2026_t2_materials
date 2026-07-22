# Table 4 replication (Onyiah et al., PLOS ONE)

**Verdict: yes, the Dryad data can recreate Table 4.**

Run: `Rscript replicate_table4.R` (needs `readxl`).

## What matches

- N = 602 (421 microscopy-positive, 181 negative)
- All cell counts and row % for Sex, Age, Sleep same room, Water, Bushes, LLIN use, House walls
- Crude ORs (logistic regression) match published values to 1 d.p. for Sex, Age, Area, Bushes, House walls

## Small differences

1. **Area council columns in the paper are swapped.** Published table puts 110 / 56 / 15 under “present” and 275 / 120 / 26 under “absent”, but those sums are 181 and 421 (the opposite of the column N’s). The data have the correct orientation: Abuja 275 present (71.4%) / 110 absent (28.6%). ORs are unchanged.
2. **Three CI lower bounds** round to 0.5 here vs 0.6 in the paper (sleep same room, uncovered water, LLIN use). Point estimates still match (0.8, 0.9, 0.9).

## Variable mapping

| Table row | Dataset variable |
|-----------|------------------|
| Outcome | `Microscopy result` (pos/neg) |
| Age | `Age_RECODED` |
| Area council | `AreaCouncilCode` (1=Abuja municipal, 2=Kuje, 3=Kwali) |
| LLIN use | `LLIN use_RECODED` (0=No, 1=Yes); raw `LLIN use` has many NAs |
| House walls | `Housewall` |
