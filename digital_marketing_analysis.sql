-- =====================================================
-- DIGITAL MARKETING CAMPAIGN ANALYTICS
-- =====================================================
-- Dataset: 2,300 rows | 125 campaigns | 5 platforms
-- Period: January - March 2024
-- Platforms: Facebook, Instagram, Google, TikTok, YouTube
-- Campaign Types: Conversion, Awareness, Traffic, Retargeting, Lead Generation
-- =====================================================

-- =====================================================
-- SECTION 1: BASIC CAMPAIGN PERFORMANCE
-- =====================================================

-- Query 1: Overall Performance Summary
-- Question: What's the total spend, impressions, clicks, and conversions?
SELECT 
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2) AS overall_ctr,
    ROUND(SUM(conversions) * 100.0 / SUM(clicks), 2) AS overall_cvr
FROM performa_harian;

-- Insight: Total spend 4B, 130K conversions, 4% CTR, showing healthy campaign performance


-- Query 2: Performance by Platform
-- Question: Which platform drives the most spend and conversions?
SELECT 
    campaigns.platform,
    SUM(performa_harian.spend) AS total_spend,
    SUM(performa_harian.impressions) AS total_impressions,
    SUM(performa_harian.clicks) AS total_clicks,
    SUM(performa_harian.conversions) AS total_conversions
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.platform
ORDER BY total_spend DESC;

-- Insight: Google leads in spend (872M), Instagram second (829M), balanced distribution


-- =====================================================
-- SECTION 2: EFFICIENCY METRICS (CTR, CVR, CPA)
-- =====================================================

-- Query 3: CTR (Click-Through Rate) by Platform
-- Question: Which platform has the best engagement rate?
SELECT 
    campaigns.platform,
    SUM(performa_harian.clicks) AS total_clicks,
    SUM(performa_harian.impressions) AS total_impressions,
    ROUND(SUM(performa_harian.clicks) * 100.0 / SUM(performa_harian.impressions), 2) AS ctr_percentage
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.platform
ORDER BY ctr_percentage DESC;

-- Insight: Google has highest CTR at 6.22%, YouTube lowest at 1.07%
-- Recommendation: Google ads are most engaging, optimize YouTube creative


-- Query 4: CVR (Conversion Rate) by Platform
-- Question: Which platform converts clicks to conversions most efficiently?
SELECT 
    campaigns.platform,
    SUM(performa_harian.conversions) AS total_conversions,
    SUM(performa_harian.clicks) AS total_clicks,
    ROUND(SUM(performa_harian.conversions) * 100.0 / SUM(performa_harian.clicks), 2) AS cvr_percentage
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.platform
ORDER BY cvr_percentage DESC;

-- Insight: Google leads with 4.42% CVR, YouTube lowest at 0.75%


-- Query 5: CPA (Cost Per Acquisition) by Platform
-- Question: Which platform is most cost-efficient for conversions?
SELECT 
    campaigns.platform,
    SUM(performa_harian.spend) AS total_spend,
    SUM(performa_harian.conversions) AS total_conversions,
    ROUND(SUM(performa_harian.spend) * 1.0 / SUM(performa_harian.conversions), 2) AS cpa
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.platform
ORDER BY cpa ASC;

-- Insight: Google most efficient (CPA: 9,174), YouTube most expensive (CPA: 634,157)
-- Recommendation: Allocate more budget to Google, review YouTube strategy


-- =====================================================
-- SECTION 3: CAMPAIGN TYPE ANALYSIS
-- =====================================================

-- Query 6: Performance by Campaign Type
-- Question: Which campaign objective performs best?
SELECT 
    campaigns.tipe_iklan,
    COUNT(DISTINCT campaigns.id_campaign) AS total_campaigns,
    SUM(performa_harian.spend) AS total_spend,
    SUM(performa_harian.conversions) AS total_conversions,
    ROUND(SUM(performa_harian.spend) * 1.0 / SUM(performa_harian.conversions), 2) AS cpa
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.tipe_iklan
ORDER BY total_conversions DESC;

-- Insight: Conversion campaigns deliver most conversions (37.5K)
-- Awareness has highest CPA (122,179) as expected - not optimized for conversions


-- Query 7: Top 10 Best Performing Campaigns
-- Question: Which individual campaigns are winners?
SELECT 
    campaigns.nama_campaign,
    campaigns.platform,
    campaigns.tipe_iklan,
    SUM(performa_harian.spend) AS total_spend,
    SUM(performa_harian.conversions) AS total_conversions,
    ROUND(SUM(performa_harian.spend) * 1.0 / SUM(performa_harian.conversions), 2) AS cpa
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.nama_campaign, campaigns.platform, campaigns.tipe_iklan
ORDER BY total_conversions DESC
LIMIT 10;

-- Insight: Top campaigns are Retargeting + Conversion types on Google platform


-- =====================================================
-- SECTION 4: BUDGET OPTIMIZATION
-- =====================================================

-- Query 8: Campaigns Over Budget
-- Question: Which campaigns exceeded their allocated budget?
SELECT 
    campaigns.nama_campaign,
    campaigns.platform,
    campaigns.budget,
    SUM(performa_harian.spend) AS total_spend,
    SUM(performa_harian.spend) - campaigns.budget AS over_budget_amount,
    ROUND((SUM(performa_harian.spend) - campaigns.budget) * 100.0 / campaigns.budget, 2) AS over_budget_pct
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.nama_campaign, campaigns.platform, campaigns.budget
HAVING SUM(performa_harian.spend) > campaigns.budget
ORDER BY over_budget_amount DESC;

-- Insight: 16 campaigns exceeded budget, top overspend is Skincare Lead Generation
-- Recommendation: Implement daily budget caps to prevent overspending


-- Query 9: Budget Efficiency Score
-- Question: Which campaigns deliver best ROI relative to budget?
SELECT 
    campaigns.nama_campaign,
    campaigns.platform,
    campaigns.budget,
    SUM(performa_harian.spend) AS actual_spend,
    SUM(performa_harian.conversions) AS total_conversions,
    ROUND(SUM(performa_harian.conversions) * 1.0 / campaigns.budget * 1000000, 2) AS conversions_per_million_budget
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.nama_campaign, campaigns.platform, campaigns.budget
ORDER BY conversions_per_million_budget DESC
LIMIT 10;

-- Insight: Identifies best budget-to-conversion ratio campaigns for scaling


-- =====================================================
-- SECTION 5: TEMPORAL TRENDS
-- =====================================================

-- Query 10: Monthly Performance Trends
-- Question: How did performance change month-over-month?
SELECT 
    performa_harian.bulan,
    SUM(performa_harian.spend) AS monthly_spend,
    SUM(performa_harian.conversions) AS monthly_conversions,
    ROUND(SUM(performa_harian.spend) * 1.0 / SUM(performa_harian.conversions), 2) AS monthly_cpa
FROM performa_harian
GROUP BY performa_harian.bulan
ORDER BY performa_harian.bulan;

-- Insight: Spend increased Jan→Feb, stable Feb→Mar
-- Conversions decreased consistently - requires investigation


-- Query 11: Platform Performance Over Time
-- Question: Which platform's performance is improving or declining?
SELECT 
    performa_harian.bulan,
    campaigns.platform,
    SUM(performa_harian.conversions) AS monthly_conversions
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY performa_harian.bulan, campaigns.platform
ORDER BY performa_harian.bulan, campaigns.platform;

-- Insight: Track platform-specific trends to identify seasonality


-- =====================================================
-- SECTION 6: PRODUCT CATEGORY ANALYSIS
-- =====================================================

-- Query 12: Performance by Product Category
-- Question: Which product categories perform best in advertising?
SELECT 
    campaigns.produk,
    COUNT(DISTINCT campaigns.id_campaign) AS total_campaigns,
    SUM(performa_harian.spend) AS total_spend,
    SUM(performa_harian.conversions) AS total_conversions,
    ROUND(SUM(performa_harian.spend) * 1.0 / SUM(performa_harian.conversions), 2) AS cpa,
    ROUND(SUM(performa_harian.clicks) * 100.0 / SUM(performa_harian.impressions), 2) AS avg_ctr
FROM performa_harian
JOIN campaigns ON performa_harian.id_campaign = campaigns.id_campaign
GROUP BY campaigns.produk
ORDER BY total_conversions DESC;

-- Insight: Product-level insights for inventory and marketing planning


-- =====================================================
-- BUSINESS RECOMMENDATIONS
-- =====================================================

-- Based on comprehensive analysis:

-- 1. PLATFORM STRATEGY
--    → Increase Google budget (best CTR 6.22%, CPA 9,174)
--    → Optimize Instagram (CTR only 1.83%, CPA 118,458)
--    → Review YouTube strategy (very high CPA 634,157)
--    → Maintain Facebook & TikTok (balanced performance)

-- 2. CAMPAIGN TYPE OPTIMIZATION
--    → Scale Conversion & Retargeting campaigns (proven converters)
--    → Keep Awareness campaigns for top-of-funnel
--    → Reduce Lead Generation spend (underperforming)

-- 3. BUDGET CONTROL
--    → Implement daily caps on 16 over-budget campaigns
--    → Reallocate budget from low-performers to top 10 campaigns
--    → Set alerts at 80% budget threshold

-- 4. CONVERSION DECLINE INVESTIGATION
--    → Conversions dropped Jan→Feb→Mar consistently
--    → Possible causes: creative fatigue, audience saturation, seasonality
--    → Action: A/B test new creatives, refresh targeting

-- 5. COST EFFICIENCY
--    → Current overall CPA: ~30,835
--    → Target: reduce to 25,000 by optimizing bottom 20% campaigns
--    → Focus budget on campaigns with <20,000 CPA

-- =====================================================
-- KEY METRICS SUMMARY
-- =====================================================

-- Total Spend: 4,013,650,852
-- Total Conversions: 130,164
-- Total Impressions: 113,533,914
-- Overall CTR: 4%
-- Overall CVR: ~3%
-- Average CPA: ~30,835

-- Best Platform: Google (CTR 6.22%, CPA 9,174)
-- Best Campaign Type: Conversion & Retargeting
-- Campaigns Over Budget: 16 campaigns
-- Trend: Declining conversions despite stable/increasing spend

-- =====================================================
-- END OF ANALYSIS
-- =====================================================
