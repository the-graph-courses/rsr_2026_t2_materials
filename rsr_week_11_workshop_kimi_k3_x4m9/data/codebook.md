# Variables used in the Week 11 burns workshop

The source is the `Sheet2` tab of the PLOS ONE S1 Dataset.

| Workshop variable | Source column | Meaning and coding |
|:--|:--|:--|
| `mortality` | `mortaltiy` | 0 = survived, 1 = died |
| `age_years` | `age` | Age in years |
| `tbsa_percent` | `TBSA` | Percentage of total body surface area burned |
| `co_hemo` | `CoHemo` | Carboxyhemoglobin level (%) |
| `inhalation_injury` | `INHdiv` | 0 = Normal, 1 = Subjective, 2 = Upper, 3 = Lower |
| `mech_vent` | derived | Proxy for mechanical ventilation: "Yes" when `inhalation_injury` is Upper or Lower, "No" otherwise. See the note below. |
| `pf_ratio` | `PF ratio` | Arterial oxygen pressure divided by fraction of inspired oxygen |
| `pf_ratio_group` | `Pfdivide` | 0 = >300, 1 = 200-300, 2 = 100-200, 3 = <100, using the paper's displayed labels |

## Reproducibility notes

- The S1 workbook has 676 rows and reproduces the paper's age, TBSA, inhalation-injury, PF-ratio, and carboxyhemoglobin univariable models.
- `co_hemo` is missing for 93 patients. Models that include `co_hemo` therefore use 583 complete rows.
- The workbook does not contain a mechanical-ventilation column. In the paper's methods, the Upper and Lower inhalation groups were the patients who were intubated, so we derive `mech_vent` as a proxy: Upper/Lower = "Yes", Normal/Subjective = "No". This proxy cannot reproduce the paper's exact ventilation rows, and because it is a perfect function of `inhalation_injury`, the two variables cannot enter the same model.
- The workbook also contains a patient with PF ratio exactly 100 coded in the lowest group, even though the paper displays that group as `<100`.
