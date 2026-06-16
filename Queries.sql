 CREATE TABLE transactions (
         Time_sec FLOAT,
         V1 FLOAT, V2 FLOAT, V3 FLOAT, V4 FLOAT, V5 FLOAT, V6 FLOAT, V7 FLOAT, V8 FLOAT,
         V9 FLOAT, V10 FLOAT, V11 FLOAT, V12 FLOAT, V13 FLOAT, V14 FLOAT, V15 FLOAT,
         V16 FLOAT, V17 FLOAT, V18 FLOAT, V19 FLOAT, V20 FLOAT, V21 FLOAT, V22 FLOAT,
         V23 FLOAT, V24 FLOAT, V25 FLOAT, V26 FLOAT, V27 FLOAT, V28 FLOAT,
         Amount FLOAT,
         Class INT
     );

mysql --local-infile=1 -u root -p

 LOAD DATA LOCAL INFILE 'C:/Users/RUPIN/Downloads/creditcard.csv (1)/creditcard.csv'
      INTO TABLE transactions
      FIELDS TERMINATED BY ','
     ENCLOSED BY '"'
      LINES TERMINATED BY '\n'
     IGNORE 1 ROWS;
 #Q1    
SELECT COUNT(*) AS total,
            SUM(Class) AS fraud_count,
            ROUND(100.0 * SUM(Class) / COUNT(*), 4) AS fraud_rate_pct
     FROM transactions;

#Q2
SELECT Class,
            ROUND(AVG(Amount),2) AS avg_amt,
            MIN(Amount) AS min_amt,
            MAX(Amount) AS max_amt
     FROM transactions
     GROUP BY Class;

#Q3&Q4
SELECT
  CASE
    WHEN Amount < 10 THEN '0-10'
    WHEN Amount < 100 THEN '10-100'
    WHEN Amount < 500 THEN '100-500'
    ELSE '500+'
  END AS amt_bucket,
  COUNT(*) AS total_txns,
  SUM(Class) AS fraud_txns,
  ROUND(100.0 * SUM(Class) / COUNT(*), 4) AS fraud_rate_pct
FROM transactions
GROUP BY amt_bucket
ORDER BY MIN(Amount);

#Q5
SELECT FLOOR(MOD(Time_sec, 86400) / 3600) AS hour_of_day,
       COUNT(*) AS total,
       SUM(Class) AS fraud_count,
       ROUND(100.0 * SUM(Class)/COUNT(*), 4) AS fraud_rate
FROM transactions
GROUP BY hour_of_day
ORDER BY hour_of_day;


#Q6
SELECT 
  ROUND(100.0 * SUM(CASE WHEN Class=1 THEN 1 ELSE 0 END) / COUNT(*), 4) AS fraud_pct_among_outliers,
  COUNT(*) AS outlier_count
FROM transactions
WHERE (Amount - (SELECT AVG(Amount) FROM transactions)) / (SELECT STDDEV(Amount) FROM transactions) > 3;

#Q7
SELECT Class,
  AVG(Amount) AS median_amt
FROM (
  SELECT Amount, Class,
    ROW_NUMBER() OVER (PARTITION BY Class ORDER BY Amount) AS rn,
    COUNT(*) OVER (PARTITION BY Class) AS cnt
  FROM transactions
) ranked
WHERE rn IN (FLOOR((cnt+1)/2), FLOOR((cnt+2)/2))
GROUP BY Class;

#Q8
WITH flagged AS (
  SELECT *,
    CASE WHEN Amount > 500 AND FLOOR(MOD(Time_sec,86400)/3600) BETWEEN 0 AND 5 
         THEN 1 ELSE 0 END AS rule_flag
  FROM transactions
)
SELECT rule_flag,
       COUNT(*) AS total,
       SUM(Class) AS fraud_count,
       ROUND(100.0*SUM(Class)/COUNT(*),4) AS fraud_rate
FROM flagged
GROUP BY rule_flag;

#Q9
SELECT 'V1' AS feature, AVG(CASE WHEN Class=1 THEN V1 END) AS avg_fraud, AVG(CASE WHEN Class=0 THEN V1 END) AS avg_legit, ABS(AVG(CASE WHEN Class=1 THEN V1 END) - AVG(CASE WHEN Class=0 THEN V1 END)) AS diff FROM transactions
UNION ALL SELECT 'V2', AVG(CASE WHEN Class=1 THEN V2 END), AVG(CASE WHEN Class=0 THEN V2 END), ABS(AVG(CASE WHEN Class=1 THEN V2 END) - AVG(CASE WHEN Class=0 THEN V2 END)) FROM transactions
UNION ALL SELECT 'V3', AVG(CASE WHEN Class=1 THEN V3 END), AVG(CASE WHEN Class=0 THEN V3 END), ABS(AVG(CASE WHEN Class=1 THEN V3 END) - AVG(CASE WHEN Class=0 THEN V3 END)) FROM transactions
UNION ALL SELECT 'V4', AVG(CASE WHEN Class=1 THEN V4 END), AVG(CASE WHEN Class=0 THEN V4 END), ABS(AVG(CASE WHEN Class=1 THEN V4 END) - AVG(CASE WHEN Class=0 THEN V4 END)) FROM transactions
UNION ALL SELECT 'V5', AVG(CASE WHEN Class=1 THEN V5 END), AVG(CASE WHEN Class=0 THEN V5 END), ABS(AVG(CASE WHEN Class=1 THEN V5 END) - AVG(CASE WHEN Class=0 THEN V5 END)) FROM transactions
UNION ALL SELECT 'V6', AVG(CASE WHEN Class=1 THEN V6 END), AVG(CASE WHEN Class=0 THEN V6 END), ABS(AVG(CASE WHEN Class=1 THEN V6 END) - AVG(CASE WHEN Class=0 THEN V6 END)) FROM transactions
UNION ALL SELECT 'V7', AVG(CASE WHEN Class=1 THEN V7 END), AVG(CASE WHEN Class=0 THEN V7 END), ABS(AVG(CASE WHEN Class=1 THEN V7 END) - AVG(CASE WHEN Class=0 THEN V7 END)) FROM transactions
UNION ALL SELECT 'V8', AVG(CASE WHEN Class=1 THEN V8 END), AVG(CASE WHEN Class=0 THEN V8 END), ABS(AVG(CASE WHEN Class=1 THEN V8 END) - AVG(CASE WHEN Class=0 THEN V8 END)) FROM transactions
UNION ALL SELECT 'V9', AVG(CASE WHEN Class=1 THEN V9 END), AVG(CASE WHEN Class=0 THEN V9 END), ABS(AVG(CASE WHEN Class=1 THEN V9 END) - AVG(CASE WHEN Class=0 THEN V9 END)) FROM transactions
UNION ALL SELECT 'V10', AVG(CASE WHEN Class=1 THEN V10 END), AVG(CASE WHEN Class=0 THEN V10 END), ABS(AVG(CASE WHEN Class=1 THEN V10 END) - AVG(CASE WHEN Class=0 THEN V10 END)) FROM transactions
UNION ALL SELECT 'V11', AVG(CASE WHEN Class=1 THEN V11 END), AVG(CASE WHEN Class=0 THEN V11 END), ABS(AVG(CASE WHEN Class=1 THEN V11 END) - AVG(CASE WHEN Class=0 THEN V11 END)) FROM transactions
UNION ALL SELECT 'V12', AVG(CASE WHEN Class=1 THEN V12 END), AVG(CASE WHEN Class=0 THEN V12 END), ABS(AVG(CASE WHEN Class=1 THEN V12 END) - AVG(CASE WHEN Class=0 THEN V12 END)) FROM transactions
UNION ALL SELECT 'V13', AVG(CASE WHEN Class=1 THEN V13 END), AVG(CASE WHEN Class=0 THEN V13 END), ABS(AVG(CASE WHEN Class=1 THEN V13 END) - AVG(CASE WHEN Class=0 THEN V13 END)) FROM transactions
UNION ALL SELECT 'V14', AVG(CASE WHEN Class=1 THEN V14 END), AVG(CASE WHEN Class=0 THEN V14 END), ABS(AVG(CASE WHEN Class=1 THEN V14 END) - AVG(CASE WHEN Class=0 THEN V14 END)) FROM transactions
UNION ALL SELECT 'V15', AVG(CASE WHEN Class=1 THEN V15 END), AVG(CASE WHEN Class=0 THEN V15 END), ABS(AVG(CASE WHEN Class=1 THEN V15 END) - AVG(CASE WHEN Class=0 THEN V15 END)) FROM transactions
UNION ALL SELECT 'V16', AVG(CASE WHEN Class=1 THEN V16 END), AVG(CASE WHEN Class=0 THEN V16 END), ABS(AVG(CASE WHEN Class=1 THEN V16 END) - AVG(CASE WHEN Class=0 THEN V16 END)) FROM transactions
UNION ALL SELECT 'V17', AVG(CASE WHEN Class=1 THEN V17 END), AVG(CASE WHEN Class=0 THEN V17 END), ABS(AVG(CASE WHEN Class=1 THEN V17 END) - AVG(CASE WHEN Class=0 THEN V17 END)) FROM transactions
UNION ALL SELECT 'V18', AVG(CASE WHEN Class=1 THEN V18 END), AVG(CASE WHEN Class=0 THEN V18 END), ABS(AVG(CASE WHEN Class=1 THEN V18 END) - AVG(CASE WHEN Class=0 THEN V18 END)) FROM transactions
UNION ALL SELECT 'V19', AVG(CASE WHEN Class=1 THEN V19 END), AVG(CASE WHEN Class=0 THEN V19 END), ABS(AVG(CASE WHEN Class=1 THEN V19 END) - AVG(CASE WHEN Class=0 THEN V19 END)) FROM transactions
UNION ALL SELECT 'V20', AVG(CASE WHEN Class=1 THEN V20 END), AVG(CASE WHEN Class=0 THEN V20 END), ABS(AVG(CASE WHEN Class=1 THEN V20 END) - AVG(CASE WHEN Class=0 THEN V20 END)) FROM transactions
UNION ALL SELECT 'V21', AVG(CASE WHEN Class=1 THEN V21 END), AVG(CASE WHEN Class=0 THEN V21 END), ABS(AVG(CASE WHEN Class=1 THEN V21 END) - AVG(CASE WHEN Class=0 THEN V21 END)) FROM transactions
UNION ALL SELECT 'V22', AVG(CASE WHEN Class=1 THEN V22 END), AVG(CASE WHEN Class=0 THEN V22 END), ABS(AVG(CASE WHEN Class=1 THEN V22 END) - AVG(CASE WHEN Class=0 THEN V22 END)) FROM transactions
UNION ALL SELECT 'V23', AVG(CASE WHEN Class=1 THEN V23 END), AVG(CASE WHEN Class=0 THEN V23 END), ABS(AVG(CASE WHEN Class=1 THEN V23 END) - AVG(CASE WHEN Class=0 THEN V23 END)) FROM transactions
UNION ALL SELECT 'V24', AVG(CASE WHEN Class=1 THEN V24 END), AVG(CASE WHEN Class=0 THEN V24 END), ABS(AVG(CASE WHEN Class=1 THEN V24 END) - AVG(CASE WHEN Class=0 THEN V24 END)) FROM transactions
UNION ALL SELECT 'V25', AVG(CASE WHEN Class=1 THEN V25 END), AVG(CASE WHEN Class=0 THEN V25 END), ABS(AVG(CASE WHEN Class=1 THEN V25 END) - AVG(CASE WHEN Class=0 THEN V25 END)) FROM transactions
UNION ALL SELECT 'V26', AVG(CASE WHEN Class=1 THEN V26 END), AVG(CASE WHEN Class=0 THEN V26 END), ABS(AVG(CASE WHEN Class=1 THEN V26 END) - AVG(CASE WHEN Class=0 THEN V26 END)) FROM transactions
UNION ALL SELECT 'V27', AVG(CASE WHEN Class=1 THEN V27 END), AVG(CASE WHEN Class=0 THEN V27 END), ABS(AVG(CASE WHEN Class=1 THEN V27 END) - AVG(CASE WHEN Class=0 THEN V27 END)) FROM transactions
UNION ALL SELECT 'V28', AVG(CASE WHEN Class=1 THEN V28 END), AVG(CASE WHEN Class=0 THEN V28 END), ABS(AVG(CASE WHEN Class=1 THEN V28 END) - AVG(CASE WHEN Class=0 THEN V28 END)) FROM transactions
ORDER BY diff DESC
LIMIT 5;

#Q10
SELECT Class, velocity,
       COUNT(*) AS total
FROM (
  SELECT Class,
    COUNT(*) OVER (ORDER BY Time_sec RANGE BETWEEN 600 PRECEDING AND CURRENT ROW) - 1 AS velocity
  FROM transactions
) v
GROUP BY Class, velocity > 5
ORDER BY Class;

#Q11
SELECT SUM(Class) AS actual_fraud_in_top100
FROM (
  WITH scored AS (
    SELECT *,
      (CASE WHEN Amount > 500 THEN 30 WHEN Amount > 100 THEN 15 WHEN Amount < 10 THEN 15 ELSE 0 END) AS amount_score,
      (CASE WHEN FLOOR(MOD(Time_sec,86400)/3600) BETWEEN 0 AND 5 THEN 30 ELSE 0 END) AS time_score,
      (CASE WHEN V14 < -5 THEN 20 ELSE 0 END) AS v14_score,
      (CASE WHEN V12 < -5 THEN 10 ELSE 0 END) AS v12_score,
      (CASE WHEN V10 < -5 THEN 10 ELSE 0 END) AS v10_score
    FROM transactions
  )
  SELECT *, (amount_score + time_score + v14_score + v12_score + v10_score) AS fraud_score
  FROM scored
  ORDER BY fraud_score DESC
  LIMIT 100
) top100;

#Q12
WITH flagged AS (
  SELECT Class,
    CASE WHEN Amount > 200 AND FLOOR(MOD(Time_sec,86400)/3600) BETWEEN 0 AND 5 
         THEN 1 ELSE 0 END AS predicted
  FROM transactions
),
matrix AS (
  SELECT
    SUM(CASE WHEN Class=1 AND predicted=1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN Class=0 AND predicted=1 THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN Class=0 AND predicted=0 THEN 1 ELSE 0 END) AS TN,
    SUM(CASE WHEN Class=1 AND predicted=0 THEN 1 ELSE 0 END) AS FN
  FROM flagged
)
SELECT TP, FP, TN, FN,
  ROUND(TP/(TP+FP), 4) AS precision_,
  ROUND(TP/(TP+FN), 4) AS recall_,
  ROUND(2*(TP/(TP+FP))*(TP/(TP+FN)) / ((TP/(TP+FP)) + (TP/(TP+FN))), 4) AS f1_score
FROM matrix;

#Q13
SELECT 'V1' AS feature, Class, AVG(V1) AS mean, STDDEV(V1) AS stddev FROM transactions GROUP BY Class
UNION ALL
SELECT 'V2', Class, AVG(V2), STDDEV(V2) FROM transactions GROUP BY Class
UNION ALL
SELECT 'V3', Class, AVG(V3), STDDEV(V3) FROM transactions GROUP BY Class
UNION ALL
SELECT 'V4', Class, AVG(V4), STDDEV(V4) FROM transactions GROUP BY Class
UNION ALL
SELECT 'V5', Class, AVG(V5), STDDEV(V5) FROM transactions GROUP BY Class
ORDER BY feature, Class;

#Q14
WITH stage1 AS (
  -- Flag high-amount night transactions
  SELECT *,
    CASE WHEN Amount > 500 
         AND FLOOR(MOD(Time_sec,86400)/3600) BETWEEN 0 AND 5 
         THEN 1 ELSE 0 END AS night_high_amt
  FROM transactions
),
stage2 AS (
  -- Flag V-feature anomalies (top 3 separating features)
  SELECT *,
    CASE WHEN V14 < -5 OR V12 < -5 OR V10 < -5 
         THEN 1 ELSE 0 END AS vfeature_anomaly
  FROM stage1
),
stage3 AS (
  -- Combine both signals with OR
  SELECT *,
    CASE WHEN night_high_amt = 1 OR vfeature_anomaly = 1 
         THEN 1 ELSE 0 END AS final_flag
  FROM stage2
),
stage4 AS (
  -- Compute capture rate and false positive rate
  SELECT
    SUM(CASE WHEN Class=1 AND final_flag=1 THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN Class=0 AND final_flag=1 THEN 1 ELSE 0 END) AS FP,
    SUM(Class) AS total_fraud,
    SUM(CASE WHEN Class=0 THEN 1 ELSE 0 END) AS total_legit
  FROM stage3
)
SELECT
  TP, FP, total_fraud, total_legit,
  ROUND(100.0 * TP / total_fraud, 2) AS capture_rate_pct,
  ROUND(100.0 * FP / total_legit, 4) AS false_positive_rate_pct,
  ROUND(TP/(TP+FP), 4) AS precision_
FROM stage4;


     
