# 💳 Credit Card Fraud Detection — SQL Analytics Project

<div align="center">

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Analytics-F29111?style=flat-square)
![Dataset](https://img.shields.io/badge/Dataset-Kaggle-20BEFF?style=flat-square&logo=kaggle&logoColor=white)
![Records](https://img.shields.io/badge/Records-284%2C807-brightgreen?style=flat-square)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat-square)

**A deep-dive SQL analytics project on 284,807 real-world credit card transactions — built to simulate the work of a fraud analytics engineer at a financial institution. No ML, no Python. Just SQL surfacing meaningful patterns from severely imbalanced data.**

*Personal Portfolio Project — Data Analytics / Data Engineering | 2025–26*

</div>

---

## 📌 Table of Contents

- [Overview](#overview)
- [Dataset Schema](#dataset-schema)
- [Skills Demonstrated](#skills-demonstrated)
- [Findings](#findings)
- [Key Takeaways](#key-takeaways)
- [How to Reproduce](#how-to-reproduce)
- [About](#about)

---

## Overview

Credit card fraud costs the global financial industry billions annually — but detecting it is a data problem, not just a security one. The dataset has 284,807 transactions with only 492 fraud cases (0.17%). That class imbalance alone makes standard accuracy metrics useless and forces you to think in Precision, Recall, and F1.

This project works through the full fraud analytics workflow in pure SQL — from basic aggregations to a 4-stage CTE detection pipeline — the way an analyst at a bank or fintech would actually approach it.

**Key numbers:**
- 284,807 total transactions analyzed
- 492 fraud cases (0.17% — severely imbalanced)
- 14 analytical queries across 3 difficulty levels
- Multi-signal scoring model achieving 88% precision in top 100 flagged transactions
- End-to-end detection pipeline capturing 73.17% of all fraud at 0.24% false positive rate

---

## Dataset Schema

| Column | Description |
|:-------|:------------|
| `Time_sec` | Seconds elapsed since first transaction in dataset |
| `V1`–`V28` | PCA-anonymized features (original features masked for confidentiality) |
| `Amount` | Transaction amount in USD |
| `Class` | `1` = Fraud, `0` = Legitimate |

> ⚠️ V1–V28 are PCA components — they have no direct business interpretation. In a real system these would map to features like merchant category, geo-distance, or device fingerprint.

---

## Skills Demonstrated

| Skill | Where Used |
|:------|:-----------|
| Aggregations & Filtering | Fraud rate, amount summaries |
| CASE WHEN / Bucketing | Amount tiers, risk scoring, rule flags |
| Window Functions | Velocity detection, median calculation |
| CTEs (multi-stage pipelines) | Fraud scoring, detection pipeline |
| Z-score / Statistical Functions | Outlier detection via stddev |
| Median via ROW_NUMBER workaround | Robust central tendency on skewed data |
| UNION ALL (long-format output) | Feature distribution comparison |
| Confusion Matrix in SQL | TP, FP, TN, FN → Precision, Recall, F1 |
| End-to-end detection pipeline | 4-stage CTE chain with capture rate metrics |

---

## Findings

### 🔰 Level 1 — Foundational

**Q1: Overall fraud rate**

| Total | Fraud Count | Fraud Rate |
|:------|:------------|:-----------|
| 284,807 | 492 | 0.1727% |

Only 0.17% of transactions are fraud. A model that predicts "not fraud" on every transaction achieves 99.83% accuracy while catching zero fraud cases. Accuracy is useless here — Precision, Recall, and F1 are the right metrics.

---

**Q2–Q4: Transaction amount analysis**

| Amount Bucket | Total | Fraud Cases | Fraud Rate |
|:--------------|:------|:------------|:-----------|
| $0–$10 | 97,314 | 249 | 0.2559% |
| $10–$100 | 130,108 | 113 | 0.0869% |
| $100–$500 | 47,893 | 95 | 0.1984% |
| $500+ | 9,492 | 35 | 0.3687% |

249 out of 492 fraud cases (50.6%) are under $10 — classic **card-testing behavior**, where fraudsters make tiny charges to verify a stolen card before going big. The $500+ bucket has the highest fraud *rate* (0.37%) but lowest absolute count.

Fraud mean ($122) looks higher than legit mean ($88) — but the **median tells the opposite story**: fraud median is $9.25 vs. legit median of $22. A few large outliers inflate the mean. Most fraud is actually cheaper than a typical legitimate transaction.

---

### ⚙️ Level 2 — Intermediate

**Q5: Hour-of-day fraud patterns**

| Hour | Total Transactions | Fraud Cases | Fraud Rate |
|:-----|:-------------------|:------------|:-----------|
| 2 AM | 3,328 | 57 | 1.7127% |
| 4 AM | 2,209 | 23 | 1.0412% |
| 3 AM | 3,492 | 17 | 0.4868% |
| 10 AM | 16,598 | 8 | 0.0482% |

2AM has a fraud rate of 1.71% — **10x the global baseline**. Low transaction volume + high fraud concentration points to automated scripts and cross-timezone fraudsters operating while cardholders are asleep.

---

**Q6–Q9: Anomaly detection & feature analysis**

- **Z-score flagging** (>3 std devs on amount) gives only 0.27% fraud rate — barely above the 0.17% baseline. A naive "flag big transactions" rule doesn't work.
- **Top divergent PCA features:** V3, V14, V17, V12, and V10 show the largest mean separation between fraud and legit — all strongly negative for fraud, near-zero for legit. These become the scoring signals in Q11.
- **Single rule (Amount > $500 AND 0–5AM):** Achieves 1.68% fraud rate (10x baseline) but catches only 7 out of 492 fraud cases. High precision relative to baseline, terrible recall. Sets up the core tradeoff.

---

### 🔥 Level 3 — Advanced

**Q11: Multi-signal fraud scoring model**

Signals combined:
- Amount tier — very low (<$10) or very high (>$500)
- Time-of-day — transactions between 0–5AM
- V14 anomaly — values below -5
- V12 anomaly — values below -5
- V10 anomaly — values below -5

| Metric | Result |
|:-------|:-------|
| Fraud cases in top 100 highest-scored transactions | **88 out of 100** |
| Precision in top bucket | **88%** |
| Lift over baseline | **~500x** |

Combining weak individual signals into a composite score puts 88 genuine fraud cases in the top 100 flagged transactions.

---

**Q12: Confusion matrix — single rule baseline**

Rule: Amount > $200 AND hour between 0–5AM

| TP | FP | TN | FN | Precision | Recall | F1 |
|:---|:---|:---|:---|:----------|:-------|:---|
| 14 | 1,523 | 282,792 | 478 | 0.91% | 2.85% | 0.014 |

14 fraud cases caught, 1,523 real customers incorrectly flagged. F1 of 0.014. This is the baseline the multi-signal approach demolishes.

---

**Q14: End-to-end detection pipeline (4-stage CTE chain)**

Pipeline stages:
- **Stage 1** — Flag high-amount night transactions (Amount > $500 AND 0–5AM)
- **Stage 2** — Flag V-feature anomalies (V14 < -5 OR V12 < -5 OR V10 < -5)
- **Stage 3** — Combine signals with OR logic
- **Stage 4** — Compute capture rate and false positive rate

| TP | FP | Capture Rate | False Positive Rate | Precision |
|:---|:---|:-------------|:--------------------|:----------|
| 360 | 689 | **73.17%** | **0.2423%** | 34.32% |

73.17% of all fraud caught while flagging only 0.24% of legitimate transactions as false positives. The remaining 27% of missed fraud — the cases that don't trigger either signal — is where an ML layer would sit in production.

---

## Key Takeaways

**1. Accuracy is a lie on imbalanced data**
99.83% accuracy is achievable by predicting "not fraud" on everything. Always use Precision, Recall, and F1 on imbalanced datasets.

**2. Mean vs. Median — skewed distributions need both**
Fraud mean ($122) > legit mean ($88), suggesting fraud is high-value. Fraud median ($9.25) < legit median ($22), revealing the truth: most fraud is tiny card-testing charges. A few outliers inflate the mean entirely.

**3. Time-of-day is a real, usable signal**
2AM has a fraud rate 10x the global baseline. Combining it with amount signals creates a rule with measurable lift.

**4. Single rules perform terribly in isolation**
Best single rule: F1 = 0.014. Multi-signal scoring: 88% precision in the top 100 flagged transactions. Composite signals always beat individual thresholds.

**5. Velocity signals need a customer identifier**
Global velocity is meaningless at scale. Per-card velocity is the real fraud signal — this dataset's anonymization makes that impossible, which is itself a lesson about real-world constraints of anonymized data.

**6. SQL is the first layer, not the whole system**
73% fraud capture with 0.24% false positive rate — with zero ML. The remaining 27% is where machine learning earns its place, trained on features this SQL pipeline surfaces.

---

## How to Reproduce

```bash
# 1. Download the dataset
# https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud

# 2. Set up MySQL 8.0+
# Create the database and table
source queries/setup.sql

# 3. Load the CSV
LOAD DATA LOCAL INFILE 'creditcard.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

# 4. Run queries in order
source queries/Queries.sql
```

Full query file: [`Queries.sql`](Queries.sql)

---

## About

Built by **Rupin** — CS Engineering fresher (2026), actively looking for Data Engineering and Data Analytics roles.

Connect on [LinkedIn](https://www.linkedin.com/in/rupin-r) | [GitHub](https://github.com/rupin2207)
