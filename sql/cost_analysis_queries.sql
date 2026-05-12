-- ============================================================
-- Healthcare Cost Analysis — SQL Queries
-- Author : Jagjeet Jena
-- Tools  : PostgreSQL / SQLite compatible
-- ============================================================

-- -----------------------------------------------
-- 1. Overall KPI Summary
-- -----------------------------------------------
SELECT
    COUNT(patient_id)                          AS total_patients,
    ROUND(AVG(total_cost_usd), 2)              AS avg_cost,
    ROUND(SUM(total_cost_usd), 2)              AS total_expenditure,
    ROUND(MIN(total_cost_usd), 2)              AS min_cost,
    ROUND(MAX(total_cost_usd), 2)              AS max_cost,
    ROUND(AVG(length_of_stay_days), 1)         AS avg_los_days
FROM healthcare_costs;


-- -----------------------------------------------
-- 2. Average Cost by Region (sorted high → low)
-- -----------------------------------------------
SELECT
    region,
    COUNT(patient_id)                          AS patient_count,
    ROUND(AVG(total_cost_usd), 0)              AS avg_cost,
    ROUND(SUM(total_cost_usd), 0)              AS total_cost,
    ROUND(AVG(total_cost_usd) / (
        SELECT AVG(total_cost_usd) FROM healthcare_costs
    ) * 100, 1)                                AS pct_of_national_avg
FROM healthcare_costs
GROUP BY region
ORDER BY avg_cost DESC;


-- -----------------------------------------------
-- 3. Cost Breakdown by Diagnosis Category
-- -----------------------------------------------
SELECT
    diagnosis_category,
    COUNT(patient_id)                          AS cases,
    ROUND(AVG(total_cost_usd), 0)              AS avg_cost,
    ROUND(SUM(total_cost_usd), 0)              AS total_cost,
    ROUND(SUM(total_cost_usd) * 100.0 /
        SUM(SUM(total_cost_usd)) OVER (), 1)   AS pct_of_total
FROM healthcare_costs
GROUP BY diagnosis_category
ORDER BY total_cost DESC;


-- -----------------------------------------------
-- 4. Insurance Type Impact on Cost
-- -----------------------------------------------
SELECT
    insurance_type,
    COUNT(patient_id)                          AS patients,
    ROUND(AVG(total_cost_usd), 0)              AS avg_cost,
    ROUND(AVG(length_of_stay_days), 1)         AS avg_los
FROM healthcare_costs
GROUP BY insurance_type
ORDER BY avg_cost DESC;


-- -----------------------------------------------
-- 5. High-Cost Patient Segments (top 10%)
-- -----------------------------------------------
WITH percentiles AS (
    SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_cost_usd) AS p90
    FROM healthcare_costs
)
SELECT
    hc.patient_id,
    hc.age,
    hc.diagnosis_category,
    hc.region,
    hc.insurance_type,
    hc.treatment_type,
    ROUND(hc.total_cost_usd, 0) AS total_cost
FROM healthcare_costs hc, percentiles p
WHERE hc.total_cost_usd >= p.p90
ORDER BY hc.total_cost_usd DESC;


-- -----------------------------------------------
-- 6. Quarterly Cost Trend
-- -----------------------------------------------
SELECT
    year,
    quarter,
    COUNT(patient_id)                          AS patients,
    ROUND(AVG(total_cost_usd), 0)              AS avg_cost,
    ROUND(SUM(total_cost_usd), 0)              AS total_cost,
    ROUND(AVG(length_of_stay_days), 1)         AS avg_los
FROM healthcare_costs
GROUP BY year, quarter
ORDER BY year, quarter;


-- -----------------------------------------------
-- 7. Inpatient vs Outpatient Cost Comparison
-- -----------------------------------------------
SELECT
    treatment_type,
    COUNT(patient_id)                          AS cases,
    ROUND(AVG(total_cost_usd), 0)              AS avg_cost,
    ROUND(SUM(total_cost_usd), 0)              AS total_cost,
    ROUND(AVG(length_of_stay_days), 1)         AS avg_los_days,
    ROUND(COUNT(patient_id) * 100.0 /
        SUM(COUNT(patient_id)) OVER (), 1)     AS pct_of_cases
FROM healthcare_costs
GROUP BY treatment_type
ORDER BY avg_cost DESC;


-- -----------------------------------------------
-- 8. Region × Diagnosis Cost Matrix (CTE approach)
-- -----------------------------------------------
WITH cost_matrix AS (
    SELECT
        region,
        diagnosis_category,
        ROUND(AVG(total_cost_usd), 0) AS avg_cost,
        COUNT(patient_id)              AS cases
    FROM healthcare_costs
    GROUP BY region, diagnosis_category
)
SELECT *
FROM cost_matrix
ORDER BY region, avg_cost DESC;


-- -----------------------------------------------
-- 9. Age Group Cost Analysis (Window Function)
-- -----------------------------------------------
SELECT
    age_group,
    COUNT(patient_id)                          AS patients,
    ROUND(AVG(total_cost_usd), 0)              AS avg_cost,
    ROUND(AVG(total_cost_usd) - AVG(AVG(total_cost_usd)) OVER (), 0)
                                               AS diff_from_overall_avg,
    RANK() OVER (ORDER BY AVG(total_cost_usd) DESC) AS cost_rank
FROM healthcare_costs
GROUP BY age_group
ORDER BY cost_rank;


-- -----------------------------------------------
-- 10. Hospital Type Performance
-- -----------------------------------------------
SELECT
    hospital_type,
    COUNT(patient_id)                          AS patients,
    ROUND(AVG(total_cost_usd), 0)              AS avg_cost,
    ROUND(AVG(length_of_stay_days), 1)         AS avg_los,
    COUNT(CASE WHEN total_cost_usd > 30000 THEN 1 END) AS high_cost_cases
FROM healthcare_costs
GROUP BY hospital_type
ORDER BY avg_cost DESC;
