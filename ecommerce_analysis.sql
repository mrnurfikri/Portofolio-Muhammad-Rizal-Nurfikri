-- =====================================================
-- E-COMMERCE SALES ANALYSIS
-- =====================================================
-- Dataset: 2,500 transactions | 500 customers
-- Period: January - April 2024
-- Categories: Elektronik, Fashion, Home & Living, Groceries, Beauty
-- =====================================================

-- =====================================================
-- SECTION 1: BASIC AGGREGATION & FILTERING
-- =====================================================

-- Query 1: Total Revenue by Payment Method (E-Wallet)
-- Question: How much revenue came from E-Wallet payments?
SELECT 
    payment_method, 
    SUM(revenue) AS total_revenue
FROM transactions
WHERE payment_method = 'E-Wallet';

-- Insight: E-Wallet users contribute significant revenue


-- Query 2: Count Transactions with Discounts
-- Question: How many transactions had discount applied?
SELECT 
    discount, 
    COUNT(*) AS jumlah_transaksi
FROM transactions
WHERE discount > 0
GROUP BY discount
ORDER BY discount;

-- Insight: Understanding discount distribution helps optimize promo strategy


-- Query 3: Conversion Rate Analysis
-- Question: What percentage of transactions are completed vs cancelled/returned?
SELECT 
    status, 
    COUNT(*) AS jumlah_transaksi, 
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions), 2) AS persentase
FROM transactions
WHERE status = 'Completed'
GROUP BY status
ORDER BY persentase DESC;

-- Insight: 84.28% completion rate indicates healthy conversion


-- =====================================================
-- SECTION 2: PRODUCT & CATEGORY ANALYSIS
-- =====================================================

-- Query 4: Highest and Lowest Transaction Values
-- Question: What are the most expensive and cheapest transactions?
SELECT 'Tertinggi' AS tipe, produk, total
FROM (
    SELECT produk, total
    FROM transactions
    ORDER BY total DESC
    LIMIT 1
)

UNION

SELECT 'Terendah' AS tipe, produk, total
FROM (
    SELECT produk, total
    FROM transactions
    ORDER BY total ASC
    LIMIT 1
);

-- Insight: Tas Gucci Original (74.9M) vs Minyak Goreng 2L (45K) - 1665x difference


-- Query 5: Average Transaction Value by Category
-- Question: What's the average transaction value for Elektronik category?
SELECT 
    AVG(total) AS rata_rata_transaksi
FROM transactions
WHERE kategori = 'Elektronik';

-- Insight: Elektronik has highest AOV at ~14.5M per transaction


-- Query 6: Revenue and Transaction Count by Month
-- Question: What's the monthly trend of revenue and transactions?
SELECT 
    bulan, 
    COUNT(*) AS jumlah_transaksi, 
    SUM(revenue) AS total_revenue
FROM transactions
GROUP BY bulan
ORDER BY total_revenue DESC;

-- Insight: March 2024 had highest revenue (466M) - investigate what drove this spike


-- =====================================================
-- SECTION 3: ADVANCED ANALYSIS WITH JOIN
-- =====================================================

-- Query 7: Revenue by Customer Segment
-- Question: Which customer segment generates most revenue?
SELECT 
    customers.segment, 
    SUM(transactions.revenue) AS total_revenue,
    COUNT(transactions.transaction_id) AS total_transactions,
    ROUND(SUM(transactions.revenue) / COUNT(transactions.transaction_id), 0) AS avg_order_value
FROM transactions
JOIN customers ON transactions.customer_id = customers.customer_id
GROUP BY customers.segment
ORDER BY total_revenue DESC;

-- Insight: VIP segment likely drives majority of revenue despite smaller customer count


-- Query 8: Cities with Revenue > 50 Million
-- Question: Which cities are our top revenue generators?
SELECT 
    kota, 
    SUM(revenue) AS total_revenue,
    COUNT(*) AS total_transaksi
FROM transactions
GROUP BY kota
HAVING total_revenue > 50000000
ORDER BY total_revenue DESC;

-- Insight: Focus marketing budget on high-revenue cities


-- =====================================================
-- SECTION 4: CANCELLED & RETURNED TRANSACTIONS
-- =====================================================

-- Query 9: Cancelled and Returned Rate Analysis
-- Question: What percentage of transactions fail (cancelled/returned)?
SELECT 
    status,
    COUNT(*) AS jumlah_transaksi,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions), 2) AS persentase
FROM transactions
WHERE status IN ('Cancelled', 'Returned')
GROUP BY status
ORDER BY persentase DESC;

-- Insight: 10.2% cancelled + 5.52% returned = 15.72% total loss
-- Action: Investigate root causes - payment issues? Product quality? Delivery problems?


-- =====================================================
-- SECTION 5: PROFITABILITY ANALYSIS
-- =====================================================

-- Query 10: Top 10 Most Profitable Products
-- Question: Which products generate highest profit?
SELECT 
    produk,
    kategori,
    COUNT(*) AS total_terjual,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 2) AS profit_margin_pct
FROM transactions
WHERE status = 'Completed'
GROUP BY produk, kategori
ORDER BY total_profit DESC
LIMIT 10;

-- Insight: Focus inventory and marketing on high-profit products


-- Query 11: Revenue by Payment Method with AOV
-- Question: Which payment method has highest average order value?
SELECT 
    payment_method,
    COUNT(*) AS total_transaksi,
    SUM(revenue) AS total_revenue,
    ROUND(AVG(total), 0) AS avg_order_value
FROM transactions
WHERE status = 'Completed'
GROUP BY payment_method
ORDER BY avg_order_value DESC;

-- Insight: Premium payment methods (Credit Card) may correlate with higher spending


-- =====================================================
-- SECTION 6: CATEGORY DEEP DIVE
-- =====================================================

-- Query 12: Category Performance Summary
-- Question: Complete performance breakdown by category
SELECT 
    kategori,
    COUNT(*) AS total_transaksi,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(AVG(total), 0) AS avg_order_value,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 2) AS profit_margin_pct,
    ROUND(COUNT(CASE WHEN status = 'Completed' THEN 1 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM transactions
GROUP BY kategori
ORDER BY total_revenue DESC;

-- Insight: Balance high-revenue categories with high-profit ones for optimal portfolio


-- =====================================================
-- BUSINESS RECOMMENDATIONS
-- =====================================================

-- Based on the analysis above:
-- 1. Focus on Elektronik (highest revenue) and optimize fulfillment to reduce cancellations
-- 2. Investigate March spike - replicate successful campaigns
-- 3. Target VIP/Premium segments with personalized offers
-- 4. Reduce 15.72% failure rate (cancelled + returned) through better product info & CS
-- 5. Expand E-Wallet payment options given high adoption
-- 6. Focus inventory on top 10 profitable products
-- 7. Invest marketing budget in high-revenue cities (Jakarta, Surabaya, etc)

-- =====================================================
-- END OF ANALYSIS
-- =====================================================
