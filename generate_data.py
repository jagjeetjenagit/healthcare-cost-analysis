import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta

np.random.seed(42)
random.seed(42)

N = 500

# --- Distributions (must match dashboard stats) ---
regions     = ["West","Northeast","Southwest","Southeast","Midwest"]
reg_counts  = [96, 122, 74, 104, 104]
reg_mult    = {"West":1.38,"Northeast":1.025,"Southwest":0.98,"Southeast":0.83,"Midwest":0.807}

diagnoses   = ["Oncology","Cardiovascular","Orthopedic","Neurological","Respiratory","Diabetes","Mental Health"]
diag_counts = [48, 114, 82, 60, 65, 76, 55]
diag_base   = {"Oncology":67933,"Cardiovascular":26493,"Orthopedic":26471,
               "Neurological":20217,"Respiratory":8461,"Diabetes":8367,"Mental Health":5801}

insurances  = ["Medicare/Medicaid","Private Insurance","Self-Pay"]
ins_counts  = [192, 246, 62]
ins_mult    = {"Medicare/Medicaid":1.0,"Private Insurance":1.0,"Self-Pay":0.77}

treatments  = ["Inpatient","Emergency","Outpatient"]
treat_counts= [183, 86, 231]
treat_mult  = {"Inpatient":1.47,"Emergency":1.17,"Outpatient":0.56}

age_groups  = ["18-30","31-45","46-60","61-75","76+"]
age_ranges  = [(18,30),(31,45),(46,60),(61,75),(76,90)]
age_counts  = [75, 120, 130, 110, 65]

# --- Assign base columns by count ---
region_col    = np.repeat(regions, reg_counts)
diagnosis_col = np.repeat(diagnoses, diag_counts)
insurance_col = np.repeat(insurances, ins_counts)
treatment_col = np.repeat(treatments, treat_counts)
age_grp_col   = np.repeat(age_groups, age_counts)

np.random.shuffle(region_col)
np.random.shuffle(diagnosis_col)
np.random.shuffle(insurance_col)
np.random.shuffle(treatment_col)
np.random.shuffle(age_grp_col)

# --- Generate ages from age groups ---
ages = []
for grp in age_grp_col:
    lo, hi = age_ranges[age_groups.index(grp)]
    ages.append(random.randint(lo, hi))

# --- Admission dates (2022-2024) ---
start = datetime(2022, 1, 1)
end   = datetime(2024, 12, 31)
dates = [start + timedelta(days=random.randint(0, (end-start).days)) for _ in range(N)]
dates_str = [d.strftime("%Y-%m-%d") for d in dates]

# --- Compute treatment cost ---
costs = []
for i in range(N):
    base  = diag_base[diagnosis_col[i]]
    cost  = base * reg_mult[region_col[i]] * treat_mult[treatment_col[i]] * ins_mult[insurance_col[i]]
    noise = np.random.lognormal(0, 0.35)
    cost  = max(500, round(cost * noise, -1))
    costs.append(int(cost))

# --- Length of stay ---
los = []
for i in range(N):
    if treatment_col[i] == "Inpatient":
        los.append(random.randint(2, 21))
    elif treatment_col[i] == "Emergency":
        los.append(random.randint(1, 5))
    else:
        los.append(random.randint(0, 2))

# --- Gender ---
genders = np.random.choice(["Male","Female"], N, p=[0.48, 0.52])

# --- Build DataFrame ---
df = pd.DataFrame({
    "Patient_ID":       [f"P{str(i+1).zfill(4)}" for i in range(N)],
    "Age":              ages,
    "Age_Group":        age_grp_col,
    "Gender":           genders,
    "Region":           region_col,
    "Diagnosis":        diagnosis_col,
    "Treatment_Type":   treatment_col,
    "Insurance_Type":   insurance_col,
    "Admission_Date":   dates_str,
    "Length_of_Stay":   los,
    "Treatment_Cost":   costs,
})

df["Year"]    = df["Admission_Date"].str[:4].astype(int)
df["Quarter"] = pd.to_datetime(df["Admission_Date"]).dt.quarter.map({1:"Q1",2:"Q2",3:"Q3",4:"Q4"})
df["Year_Quarter"] = df["Year"].astype(str) + " " + df["Quarter"]

df.to_csv("healthcare_patients.csv", index=False)
print(f"Generated {len(df)} records")
print(f"Avg cost:  ${df['Treatment_Cost'].mean():,.0f}")
print(f"Total:     ${df['Treatment_Cost'].sum():,.0f}")
print(f"\nRegion avg:\n{df.groupby('Region')['Treatment_Cost'].mean().sort_values(ascending=False).round(0)}")
print(f"\nDiagnosis avg:\n{df.groupby('Diagnosis')['Treatment_Cost'].mean().sort_values(ascending=False).round(0)}")
