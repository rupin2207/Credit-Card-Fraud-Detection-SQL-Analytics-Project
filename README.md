# 💳 Credit Card Fraud Detection — SQL Analytics Project

A deep-dive SQL analytics project on 284,807 real-world credit card transactions, built to simulate the work of a **fraud analytics engineer** at a financial institution. Every finding is derived purely from SQL — no ML, no Python, just structured queries that surface meaningful patterns from messy, imbalanced data.

---

## 📌 Project Overview

| Detail | Value |
|--------|-------|
| **Dataset** | [Kaggle — Credit Card Fraud Detection](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud) |
| **Records** | 284,807 transactions |
| **Fraud cases** | 492 (0.17% — severely imbalanced) |
| **Tech Stack** | MySQL 8.0 |
| **Difficulty** | Intermediate → Advanced |
| **Role Focus** | Data Analyst / Data Engineer / Fraud Analyst |

---

## 🗂️ Dataset Schema

| Column | Description |
|--------|-------------|
| `Time_sec` | Seconds elapsed since first transaction in dataset |
| `V1`–`V28` | PCA-anonymized features (original features masked for confidentiality) |
| `Amount` | Transaction amount in USD |
| `Class` | `1` = Fraud, `0` = Legitimate |

> ⚠️ V1–V28 are PCA components — they have no direct business interpretation. In a real system, these would map to features like merchant category, geo-distance, or device fingerprint.

---

## 🧠 Skills Demonstrated

| Skill | Where Used |
|-------|-----------|
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

## 📊 Questions & Findings

### 🔰 Level 1 — Foundational

---

**Q1: What is the overall fraud rate?**

| total | fraud_count | fraud_rate_pct |
|-------|-------------|----------------|
| 284,807 | 492 | 0.1727% |

**Finding:** Only 0.17% of transactions are fraudulent. This extreme class imbalance means accuracy is a useless metric — a model that predicts "not fraud" on every single transaction achieves 99.83% accuracy while catching zero fraud cases. Precision, Recall, and F1 are the right metrics here.

---

**Q2: Average, min, and max transaction amount by class**

| Class | avg_amt | min_amt | max_amt |
|-------|---------|---------|---------|
| Legitimate (0) | $88.29 | $0 | $25,691.16 |
| Fraud (1) | $122.21 | $0 | $2,125.87 |

**Finding:** Fraud mean ($122) is higher than legit mean ($88) — but this is misleading. See Q7 for why the median tells the opposite story.

---

**Q3 & Q4: Transaction amount buckets — fraud count and fraud rate**

| Amount Bucket | Total Transactions | Fraud Cases | Fraud Rate |
|--------------|-------------------|-------------|------------|
| $0–$10 | 97,314 | 249 | 0.2559% |
| $10–$100 | 130,108 | 113 | 0.0869% |
| $100–$500 | 47,893 | 95 | 0.1984% |
| $500+ | 9,492 | 35 | 0.3687% |

**Finding:** 249 out of 492 fraud cases (50.6%) involve amounts under $10 — classic card-testing behavior, where fraudsters make tiny charges to verify a stolen card is still active before making larger purchases. The $500+ bucket has the highest fraud *rate* (0.37%) but the lowest absolute count — high-value fraud is rare but disproportionate.

---

### ⚙️ Level 2 — Intermediate

---

**Q5: Hour-of-day fraud patterns**

| Hour | Total Transactions | Fraud Cases | Fraud Rate |
|------|--------------------|-------------|------------|
| 2 AM | 3,328 | 57 | 1.7127% |
| 4 AM | 2,209 | 23 | 1.0412% |
| 3 AM | 3,492 | 17 | 0.4868% |
| 10 AM | 16,598 | 8 | 0.0482% ← lowest |

**Finding:** 2AM has a fraud rate of 1.71% — 10x the global baseline of 0.17%. Hours 3–5AM are similarly elevated. Low transaction volume + high fraud concentration points to automated scripts and cross-timezone fraudsters operating while cardholders are asleep. Daytime hours (8AM–10AM) have the lowest fraud rates despite the highest transaction volumes.

---

**Q6: Z-score anomaly detection on transaction amount**

| Outlier Count (>3 std devs) | Fraud % Among Outliers |
|-----------------------------|------------------------|
| 4,076 | 0.2699% |

**Finding:** Flagging high-amount outliers (>3 standard deviations above mean) gives only a 0.27% fraud rate — barely above the 0.17% baseline. A naive "flag big transactions" rule doesn't work. Fraudsters aren't always spending big; the card-testing pattern from Q3 confirms most fraud is actually small. Amount alone is a weak signal.

---

**Q7: Median transaction amount by class**

| Class | Median Amount |
|-------|---------------|
| Legitimate (0) | $22.00 |
| Fraud (1) | $9.25 |

**Finding:** Fraud median ($9.25) is less than half the legit median ($22) — the opposite of what the mean suggested. The mean was inflated by a handful of large fraudulent transactions. The *typical* fraud transaction is actually cheaper than a typical legitimate one. This is a textbook case of why median is more robust than mean for right-skewed distributions.

---

**Q8: Single rule flag — high amount + late night**

| Rule Triggered | Total | Fraud Cases | Fraud Rate |
|---------------|-------|-------------|------------|
| No | 284,390 | 485 | 0.1705% |
| Yes (Amount > $500 AND 0–5AM) | 417 | 7 | 1.6787% |

**Finding:** This single rule achieves a 1.68% fraud rate — 10x the baseline. But it only catches 7 out of 492 fraud cases (1.4% recall). High precision relative to baseline, terrible recall. This sets up the core precision/recall tradeoff that Q12 quantifies properly.

---

**Q9: Top 5 most divergent PCA features**

| Feature | Avg (Fraud) | Avg (Legit) | Separation |
|---------|-------------|-------------|------------|
| V3 | -7.033 | 0.012 | 7.045 |
| V14 | -6.972 | 0.012 | 6.984 |
| V17 | -6.666 | 0.012 | 6.677 |
| V12 | -6.259 | 0.011 | 6.270 |
| V10 | -5.677 | 0.010 | 5.687 |

**Finding:** V3, V14, V17, V12, and V10 show the highest mean separation between fraud and legitimate transactions — all strongly negative for fraud, near-zero for legit. These become the anomaly signal in the multi-signal scoring model (Q11). Since these are PCA components, they don't have direct business meaning here, but in a real system would correspond to interpretable features like merchant category or transaction frequency.

---

### 🔥 Level 3 — Advanced

---

**Q10: Transaction velocity detection (with important data limitation)**

| High Velocity (>5 in 600s) | Total | Fraud Cases | Fraud Rate |
|---------------------------|-------|-------------|------------|
| No | 6 | 0 | 0.0000% |
| Yes | 284,801 | 492 | 0.1728% |

**Finding and honest limitation:** Virtually every transaction has velocity > 5 because the dataset averages ~1 transaction every 0.6 seconds globally — at that density, almost any 10-minute window contains hundreds of transactions. The signal is broken at the global level.

In a real fraud detection system, velocity must be **partitioned by card_id or customer_id** — "5 transactions on the same card in 10 minutes" is suspicious; "5 transactions across the entire bank in 10 minutes" is just normal volume. This dataset is fully anonymized with no customer identifier, making per-card velocity impossible to compute. The SQL pattern is correct — the data constraint makes the result uninformative.

---

**Q11: Multi-signal fraud scoring model**

Signals used:
- **Amount tier** — very low (<$10) or very high (>$500) amounts score higher
- **Time-of-day risk** — transactions between 0–5AM score higher
- **V14 anomaly** — values below -5 (strong fraud indicator from Q9)
- **V12 anomaly** — values below -5
- **V10 anomaly** — values below -5

| Metric | Result |
|--------|--------|
| Actual fraud in top 100 highest-scored transactions | **88 out of 100** |
| Precision in top bucket | **88%** |
| Lift over baseline (0.17%) | **~500x** |

**Finding:** The multi-signal score puts 88 genuine fraud cases in the top 100 flagged transactions — 88% precision against a 0.17% baseline. This is the power of combining weak individual signals into a composite score.

---

**Q12: Confusion matrix — Precision, Recall, F1 for a single rule**

Rule tested: Amount > $200 AND hour between 0–5AM

| TP | FP | TN | FN | Precision | Recall | F1 Score |
|----|----|----|----|-----------|--------|----------|
| 14 | 1,523 | 282,792 | 478 | 0.91% | 2.85% | 0.0138 |

**Finding:** A single rule catches 14 fraud cases while incorrectly flagging 1,523 real customers. F1 of 0.014 is barely better than nothing for the fraud class. This is the baseline that the multi-signal approach in Q11 demolishes. Demonstrates why SQL-computed confusion matrices are essential for evaluating any rule-based system before deploying it.

---

**Q13: Feature distribution — fraud vs legitimate (long format)**

| Feature | Class | Mean | Std Dev |
|---------|-------|------|---------|
| V1 | Legitimate | 0.0083 | 1.9298 |
| V1 | Fraud | -4.7719 | 6.7768 |
| V2 | Legitimate | -0.0063 | 1.6361 |
| V2 | Fraud | 3.6238 | 4.2869 |
| V3 | Legitimate | 0.0122 | 1.4594 |
| V3 | Fraud | -7.0333 | 7.1037 |
| V4 | Legitimate | -0.0079 | 1.3993 |
| V4 | Fraud | 4.5420 | 2.8704 |
| V5 | Legitimate | 0.0055 | 1.3569 |
| V5 | Fraud | -3.1512 | 5.3670 |

**Finding:** Fraud standard deviation is consistently much larger than legitimate across all features — fraudulent behavior is diverse and spread out, while legitimate transactions cluster tightly around zero. This long-format output is directly pipeable into a visualization tool for feature distribution charts.

---

**Q14: End-to-end fraud detection pipeline (4-stage CTE chain)**

Pipeline stages:
- **Stage 1** — Flag high-amount night transactions (Amount > $500 AND 0–5AM)
- **Stage 2** — Flag V-feature anomalies (V14 < -5 OR V12 < -5 OR V10 < -5)
- **Stage 3** — Combine both signals with OR logic
- **Stage 4** — Compute capture rate and false positive rate

| TP | FP | Total Fraud | Total Legit | Capture Rate | False Positive Rate | Precision |
|----|----|-------------|-------------|--------------|---------------------|-----------|
| 360 | 689 | 492 | 284,315 | **73.17%** | **0.2423%** | 34.32% |

**Finding:** The pipeline catches 73.17% of all fraud while flagging only 0.24% of legitimate transactions as false positives. Precision of 34% represents a 200x lift over the 0.17% baseline. The remaining 27% of missed fraud (132 cases) doesn't trigger either signal — in production, this is where an ML layer would sit on top of these SQL-engineered features.

---

## 🔑 Key Takeaways

**1. Accuracy is a lie on imbalanced data**
A model predicting "no fraud" on every transaction achieves 99.83% accuracy while catching zero fraud. Always use Precision, Recall, and F1 on imbalanced datasets.

**2. Mean vs Median — skewed distributions need both**
Fraud mean ($122) > legit mean ($88), suggesting fraud is high-value. But fraud median ($9.25) < legit median ($22), revealing the truth: most fraud is tiny card-testing charges. A few large outliers inflate the mean entirely.

**3. Time-of-day is a real, usable signal**
2AM has a fraud rate 10x the global baseline. Combining this with amount signals creates a rule with measurable lift — demonstrated from Q8 through Q14.

**4. Single rules perform terribly in isolation**
The best single rule achieves F1 = 0.014. Multi-signal scoring hits 88% precision in the top 100 flagged transactions. Composite signals always beat individual thresholds.

**5. Velocity signals need a customer identifier**
Global transaction velocity is meaningless at scale. Per-card velocity is the real fraud signal — this dataset's anonymization makes that impossible, which is itself an important lesson about the real-world constraints of working with anonymized data.

**6. SQL is the first layer, not the whole system**
The final pipeline captures 73% of fraud with 0.24% false positive rate — strong performance with zero ML. The remaining 27% is where machine learning earns its place, trained on features this SQL pipeline surfaces.

---

## 🗃️ How to Reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud)
2. Set up MySQL 8.0+
3. Create the database and table (schema in `/queries/setup.sql`)
4. Load the CSV using `LOAD DATA LOCAL INFILE`
5. Run queries from the `/queries/` folder in order

Full setup instructions in [`/Queries.sql`](Queries.sql)



## 👤 About

Built by **Rupin** — CS Engineering fresher (2026), actively looking for Data Engineering and Data Analytics roles.

Connect on [LinkedIn](#) | [GitHub](#)
