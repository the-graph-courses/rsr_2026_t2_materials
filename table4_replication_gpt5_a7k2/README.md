# Table 4 replication

This folder independently reproduces the supplied figure from the supplied
602-row Excel dataset. Run from this folder with:

```sh
Rscript replicate_table4.R
```

The script uses `readxl`, `dplyr`, `gtsummary`, and `gt`. It creates a PNG for
viewing and an HTML table with selectable text.

## Reproducibility result

The dataset reproduces all displayed counts, row percentages, crude odds
ratios, and Wald 95% confidence intervals after rounding to one decimal, with
one exception in the published figure: the area-council counts are shown under
the opposite parasite-status columns. The data-correct values are:

| Area council | Parasite present | Parasite absent |
|---|---:|---:|
| Abuja municipal | 275 (71.4%) | 110 (28.6%) |
| Kuje | 120 (68.2%) | 56 (31.8%) |
| Kwali | 26 (63.4%) | 15 (36.6%) |

The reproduced table uses these data-correct placements. They agree with the
published odds ratios (Kuje 0.9 and Kwali 0.7, versus Abuja municipal).

The copied source files in `data/` are unchanged.
