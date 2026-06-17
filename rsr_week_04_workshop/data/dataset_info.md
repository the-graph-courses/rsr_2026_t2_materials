# Datasets for Workshop 4 (SE, CIs, hypothesis testing, and the t-test)

This folder contains the three datasets used in the demo and the exercise.

---

## `sarcopenia_elderly.csv` (used in the **demo**)

A cross-sectional study of sarcopenia in adults over 60 years in Karnataka, India.
You have already seen this dataset in the descriptive statistics workshop. Here we
use it again to estimate standard errors, confidence intervals, and a two-sample
t-test for skeletal muscle index.

239 rows, 9 columns.

| Variable                | Description                                  |
|-------------------------|----------------------------------------------|
| `number`                | Participant ID number                        |
| `age`                   | Age in years                                 |
| `age_group`             | Age decade ("Sixties", "Seventies", "Eighties") |
| `sex_male_1_female_0`   | Sex, coded 1 = male, 0 = female              |
| `marital_status`        | Marital status                               |
| `height_meters`         | Height in metres                             |
| `weight_kg`             | Weight in kilograms                          |
| `grip_strength_kg`      | Hand grip strength in kilograms              |
| `skeletal_muscle_index` | Skeletal muscle index                        |

Source: Zenodo (https://zenodo.org/record/3691939);
publication https://doi.org/10.12688/f1000research.22580.1

---

## `Whitehall_fossa.csv` (used in the **exercise**)

The Whitehall FoSSA Study is a *simulated* cohort study modelled on the original
Whitehall Study of London civil servants, set up in the 1960s to investigate
cardiovascular disease and mortality. This simulated version contains 4,327
individuals followed from 1997 to 2005.

Because the data are simulated, some associations are not real and do not reflect
current science on cardiovascular risk.

| Variable       | Description                    | Coding                                           |
|----------------|--------------------------------|--------------------------------------------------|
| `whl1_id`      | Participant ID number          |                                                  |
| `age_grp`      | Age group (years)              | 1 = 60-70; 2 = 71-75; 3 = 76-80; 4 = 81-95       |
| `prior_cvd`    | Prior CVD                      | 0 = No; 1 = Yes                                  |
| `prior_t2dm`   | Prior type 2 diabetes          | 0 = No; 1 = Yes                                  |
| `prior_cancer` | Prior cancer                   | 0 = No; 1 = Yes                                  |
| `sbp`          | Systolic blood pressure (mmHg) | 86-230 mmHg                                      |
| `bmi`          | Body mass index (kg/m^2)       | 15-44 kg/m^2                                     |
| `bmi_grp4`     | BMI, grouped                   | 1 = Underweight; 2 = Normal; 3 = Overweight; 4 = Obese |
| `hdlc`         | HDL cholesterol (mmol/L)       | 0.5-3.07                                         |
| `ldlc`         | LDL cholesterol (mmol/L)       | 1.05-6.81                                        |
| `chol`         | Total cholesterol (mmol/L)     | 2.24-10.77                                       |
| `currsmoker`   | Current smoker                 | 0 = No; 1 = Yes                                  |
| `frailty`      | Summary frailty score          | 1 = least frail quintile; 5 = most frail quintile |
| `vitd`         | Vitamin D [25(OH)D] (nmol/L)   | 18.92-419.89                                     |
| `cvd_death`    | Fatal CVD                      | 0 = No; 1 = Yes                                  |
| `death`        | Death                          | 0 = No; 1 = Yes                                  |
| `fu_years`     | Years of follow-up             | 0.03-8.5 years                                   |

A few values of `sbp` and `bmi` are missing, so missing values must be removed
when calculating summaries.

Source: based on Clarke et al. (2007), Arch Intern Med, 167(13).

---

## `diabetes_china_chen.csv` (used in the **exercise**)

A large population cohort of Chinese adults (about 211,800 rows, 25 columns),
with anthropometric, blood pressure, and metabolic measurements. The column names
are already clean, so no renaming is needed. The two variables used in the exercise:

| Variable    | Meaning                        |
|-------------|--------------------------------|
| `sbp_mm_hg` | Systolic blood pressure (mmHg) |
| `bmi`       | Body mass index (kg/m^2)       |
| `age`       | Age in years                   |
| `gender`    | Sex (1 = male, 2 = female)     |

A small number of `sbp_mm_hg` values are missing, so use `na.rm = TRUE` (and
`!is.na()` for the count) when summarising. `bmi` has no missing values.

Source: Chinese diabetes cohort study (Zenodo record 4997196).
