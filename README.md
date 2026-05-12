# Healthcare Cost Analysis

**Tools:** Python · SQL · Tableau  
**Domain:** Healthcare Analytics  
**Dataset:** 500 patient records | 2022–2024

---

## Objective

Analyze healthcare cost patterns across regions, diagnosis categories, insurance types, and patient demographics to identify cost drivers and provide actionable insights for healthcare administrators.

## Key Business Questions

1. Which regions have the highest average treatment costs?
2. Which diagnosis categories drive the most total expenditure?
3. How does insurance type affect patient financial burden?
4. Are there seasonal patterns in healthcare costs and utilization?
5. Which patient segments are at the highest financial risk?

---

## Key Findings

| # | Finding | Impact |
|---|---------|--------|
| 1 | **West region** costs run ~30% above the national average | High |
| 2 | **Oncology** has the highest per-patient avg cost ($45K+); Cardiovascular follows | High |
| 3 | **Inpatient** admissions drive ~65% of total costs despite being <40% of all cases | High |
| 4 | **Self-Pay patients** bear ~1.4x the cost burden of insured patients | Medium |
| 5 | Patients **61+** incur 1.8x the avg cost of patients under 30 | Medium |
| 6 | **Q4** shows consistent cost and utilization spikes across all years analysed | Low |

---

## Project Structure

```
healthcare-cost-analysis/
├── notebooks/
│   └── healthcare_cost_analysis.ipynb   # Full EDA + visualizations
├── sql/
│   └── cost_analysis_queries.sql        # 10 SQL queries (CTEs, Window Functions)
├── requirements.txt
└── README.md
```

---

## Analysis Highlights

### Cost Distribution
- Right-skewed distribution — a small proportion of high-cost cases drive total expenditure
- Mean cost significantly exceeds median, indicating outlier high-cost patients

### Regional Analysis
- West and Northeast regions exceed the national average
- Southeast and Southwest regions are below-average cost markets

### Diagnosis Categories
- Oncology, Cardiovascular, and Neurological are the top 3 cost drivers
- Mental Health and Diabetes have the highest patient volumes but lower per-case costs

### Insurance Impact
- Private Insurance and Medicare/Medicaid reduce patient cost burden through negotiated rates
- Self-Pay patients face the highest out-of-pocket exposure, risking financial toxicity

### Time Trends
- Q4 shows consistent cost spikes — likely driven by elective procedure scheduling before year-end insurance resets

---

## SQL Highlights

The `sql/cost_analysis_queries.sql` file includes:

- **KPI Summary** — total patients, avg cost, total expenditure
- **Regional Breakdown** — cost vs national average using subquery
- **Diagnosis Cost Share** — percentage of total expenditure using Window Functions
- **High-Cost Segment** — top 10% patients using `PERCENTILE_CONT`
- **Quarterly Trend** — utilization and cost over time
- **Age Group Ranking** — cost deviation from overall average using `RANK()` Window Function

---

## How to Run

```bash
# Clone the repository
git clone https://github.com/jagjeetjenagit/healthcare-cost-analysis.git
cd healthcare-cost-analysis

# Install dependencies
pip install -r requirements.txt

# Launch Jupyter
jupyter notebook notebooks/healthcare_cost_analysis.ipynb
```

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Python (Pandas, NumPy) | Data generation, cleaning, feature engineering |
| Matplotlib, Seaborn | EDA visualizations — histograms, bar charts, heatmaps, trend lines |
| SQL (PostgreSQL syntax) | Aggregations, CTEs, Window Functions for cost KPIs |
| Tableau | Interactive dashboard for stakeholder exploration |

---

**Author:** Jagjeet Jena  
**LinkedIn:** [linkedin.com/in/jagjeet-jena](https://linkedin.com/in/jagjeet-jena)  
**Portfolio:** [jagjeetjenagit.github.io/jagjeetsweb](https://jagjeetjenagit.github.io/jagjeetsweb)
