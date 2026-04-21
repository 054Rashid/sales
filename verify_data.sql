// ============================================================
//  SALES BI PLATFORM — DAX Measures
//  Paste each measure in Power BI:
//  Home tab → New Measure (or right-click a table → New Measure)
//  Recommended table to store all measures: fact_sales
// ============================================================


// ── CORE KPI MEASURES ────────────────────────────────────────

Total Revenue =
SUM(fact_sales[net_revenue])


Total Orders =
COUNT(fact_sales[sale_id])


Total Units Sold =
SUM(fact_sales[quantity])


Avg Order Value =
AVERAGE(fact_sales[net_revenue])


Avg Discount % =
AVERAGE(fact_sales[discount]) * 100


Total Gross Revenue =
SUM(fact_sales[sales_amount])


Total Discount Amount =
[Total Gross Revenue] - [Total Revenue]


// ── TIME INTELLIGENCE MEASURES ───────────────────────────────

// Month-over-Month Revenue Growth
MoM Growth % =
VAR cur  = CALCULATE(SUM(fact_sales[net_revenue]))
VAR prev = CALCULATE(
    SUM(fact_sales[net_revenue]),
    DATEADD(dim_date[full_date], -1, MONTH)
)
RETURN
    DIVIDE(cur - prev, prev, 0) * 100


// Year-over-Year Revenue Growth
YoY Growth % =
VAR cur  = CALCULATE(SUM(fact_sales[net_revenue]))
VAR prev = CALCULATE(
    SUM(fact_sales[net_revenue]),
    SAMEPERIODLASTYEAR(dim_date[full_date])
)
RETURN
    DIVIDE(cur - prev, prev, 0) * 100


// Year-to-Date Revenue
Revenue YTD =
TOTALYTD(
    SUM(fact_sales[net_revenue]),
    dim_date[full_date]
)


// Quarter-to-Date Revenue
Revenue QTD =
TOTALQTD(
    SUM(fact_sales[net_revenue]),
    dim_date[full_date]
)


// Month-to-Date Revenue
Revenue MTD =
TOTALMTD(
    SUM(fact_sales[net_revenue]),
    dim_date[full_date]
)


// Rolling 3-Month Revenue
Revenue Rolling 3M =
CALCULATE(
    SUM(fact_sales[net_revenue]),
    DATESINPERIOD(dim_date[full_date], LASTDATE(dim_date[full_date]), -3, MONTH)
)


// Rolling 12-Month Revenue
Revenue Rolling 12M =
CALCULATE(
    SUM(fact_sales[net_revenue]),
    DATESINPERIOD(dim_date[full_date], LASTDATE(dim_date[full_date]), -12, MONTH)
)


// Previous Month Revenue (for MoM card)
Revenue Prev Month =
CALCULATE(
    SUM(fact_sales[net_revenue]),
    DATEADD(dim_date[full_date], -1, MONTH)
)


// Previous Year Revenue (for YoY card)
Revenue Prev Year =
CALCULATE(
    SUM(fact_sales[net_revenue]),
    SAMEPERIODLASTYEAR(dim_date[full_date])
)


// ── TARGET & ACHIEVEMENT MEASURES ────────────────────────────

Revenue Target =
5000000


Target Achievement % =
DIVIDE([Total Revenue], [Revenue Target], 0) * 100


Revenue vs Target =
[Total Revenue] - [Revenue Target]


// Dynamic target based on year (adjust values as needed)
Revenue Target Dynamic =
SWITCH(
    SELECTEDVALUE(dim_date[year]),
    2024, 4500000,
    2025, 5000000,
    2026, 5500000,
    5000000
)


// ── RANKING MEASURES ─────────────────────────────────────────

// Rank products by revenue (dense rank, ignores blanks)
Product Revenue Rank =
IF(
    HASONEVALUE(dim_product[product_name]),
    RANKX(
        ALL(dim_product[product_name]),
        [Total Revenue],
        ,
        DESC,
        DENSE
    )
)


// Top N Product flag (use with slicer for dynamic Top N)
Is Top 10 Product =
[Product Revenue Rank] <= 10


// Region Revenue Rank
Region Revenue Rank =
IF(
    HASONEVALUE(dim_customer[region]),
    RANKX(
        ALL(dim_customer[region]),
        [Total Revenue],
        ,
        DESC,
        DENSE
    )
)


// ── CUSTOMER METRICS ─────────────────────────────────────────

Unique Customers =
DISTINCTCOUNT(fact_sales[customer_id])


Revenue per Customer =
DIVIDE([Total Revenue], [Unique Customers], 0)


Orders per Customer =
DIVIDE([Total Orders], [Unique Customers], 0)


// ── PRODUCT METRICS ──────────────────────────────────────────

Unique Products Sold =
DISTINCTCOUNT(fact_sales[product_id])


Avg Unit Price =
AVERAGE(fact_sales[unit_price])


// ── DYNAMIC TITLE MEASURE (for chart titles) ─────────────────

// Use this measure as a title for visuals to show active filter
Selected Year Title =
"Revenue Analysis — " &
IF(
    ISFILTERED(dim_date[year]),
    CONCATENATEX(VALUES(dim_date[year]), dim_date[year], ", "),
    "All Years"
)


Selected Category Title =
IF(
    ISFILTERED(dim_product[category]),
    CONCATENATEX(VALUES(dim_product[category]), dim_product[category], " | "),
    "All Categories"
)
