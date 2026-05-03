# CFO Deep Domain Knowledge — Indian Personal Finance

Read this reference when you need detailed financial knowledge for evaluating calculations, tax implications, regulatory compliance, or accounting correctness.

## Table of Contents
1. [Accounting Fundamentals](#accounting-fundamentals)
2. [Indian Tax Regime](#indian-tax-regime)
3. [Investment Taxation](#investment-taxation)
4. [Credit & Lending](#credit--lending)
5. [Insurance & Pension](#insurance--pension)
6. [Regulatory Landscape](#regulatory-landscape)
7. [Financial Ratios & Analysis](#financial-ratios--analysis)
8. [Using Project Context](#using-project-context)

---

## Accounting Fundamentals

### Double-Entry Mechanics for Every the system Event

| Real-World Event | Debit (increase) | Credit (increase) | the system Tables Affected |
|---|---|---|---|
| Salary credit | Bank Asset (current_value) | Income record | Asset, Income |
| CC swipe at store | Expense record | CC Liability (outstanding) | Expense, Liability |
| CC bill payment | CC Liability (reduces outstanding) | Bank Asset (reduces cash) | LiabilityPayment, Asset |
| CC bill via CRED (with cashback) | CC Liability (full amount) | Bank Asset (net amount) + Cashback Income (delta) | LiabilityPayment, Asset, Income |
| Home loan EMI | Loan Liability (principal) + Interest Expense | Bank Asset | LiabilityPayment, Asset, Expense |
| SIP investment | MF Asset (new units) | Bank Asset (outflow) | AssetTransaction, Asset |
| SIP redemption | Bank Asset (inflow) | MF Asset (units sold) + Capital Gain/Loss | AssetTransaction, Asset, Income |
| FD maturity | Bank Asset (principal + interest) | FD Asset (closed) + Interest Income | Asset, Income |
| Insurance premium | Insurance Asset or Expense (term vs endowment) | Bank Asset | Depends on policy type |
| Dividend received | Bank Asset | Dividend Income | Asset, Income |
| Rental income | Bank Asset | Rental Income (with TDS already deducted) | Asset, Income |
| EPF contribution | EPF Asset | Salary (employer) or Bank (voluntary) | Asset |

### Accrual vs Cash — When It Matters

**Accrual basis** (when the event economically occurs):
- CC expenses: recognized at swipe date, not bill payment date
- FD interest: accrues daily even if paid at maturity (Ind AS requires this for institutional, but for personal finance apps, showing maturity-based is acceptable)
- Loan interest: accrues daily, recognized in EMI payment
- Rental income: recognized per month even if received quarterly

**Cash basis** (when money moves):
- Bank balance: always cash basis (reflects actual bank position)
- Cashflow reports: should be cash basis (actual money in/out of bank)
- Surplus calculation: uses income received minus expenses paid in the period

**The hybrid approach the system uses**: Expenses are accrual (CC swipe date), but cashflow is cash (actual bank movements). This is correct for personal finance — users need both views.

### Materiality Thresholds

| Context | Acceptable Tolerance | Rationale |
|---|---|---|
| Statement reconciliation | ±Rs.10 | Rounding from paise truncation |
| CC payment matching (no cashback) | ±Rs.1 | Should match exactly minus paise |
| CC payment matching (with cashback) | Up to 20% less than outstanding | CRED/platform cashback offers |
| EMI amount vs expected | ±Rs.5 | Rounding in amortization schedules |
| Net worth daily delta | No tolerance on systematic errors | Individual rounding OK, patterns not |
| Cross-source date matching | ±5 business days | Payment clearing time |
| CIBIL reported vs actual | ±Rs.100 | Reporting lag |

### Balance Sheet Identity

At any point in time: **Total Assets - Total Liabilities = Net Worth**

This must hold after EVERY operation:
- After recording a payment
- After uploading a statement
- After deleting a document
- After backfilling a historical date
- After currency conversion (for multi-currency)

If this identity breaks, the system has a bug. There is no "temporary inconsistency" that's acceptable for a financial app.

---

## Indian Tax Regime (AY 2026-27)

**Last verified: March 2026. Budget 2025 introduced major changes to new regime slabs and rebates.**

### Income Tax Slabs — New Regime (Default, AY 2026-27 — Budget 2025 revised)

| Income Slab | Tax Rate |
|---|---|
| Up to Rs.4,00,000 | Nil |
| Rs.4,00,001 - Rs.8,00,000 | 5% |
| Rs.8,00,001 - Rs.12,00,000 | 10% |
| Rs.12,00,001 - Rs.16,00,000 | 15% |
| Rs.16,00,001 - Rs.20,00,000 | 20% |
| Rs.20,00,001 - Rs.24,00,000 | 25% |
| Above Rs.24,00,000 | 30% |

**Key points:**
- Standard deduction: Rs.75,000 (salaried/pensioners)
- Section 87A rebate: Rs.60,000 (raised from Rs.25,000 in Budget 2025). Effective result: zero tax for income up to Rs.12,00,000 (Rs.12,75,000 for salaried after standard deduction).
- No Chapter VI-A deductions except employer NPS contribution under 80CCD(2)
- 80CCD(1B) (employee NPS self-contribution Rs.50K extra) is NOT available in new regime from FY 2025-26

**Break-even vs old regime**: Old regime only beats new regime for high deduction claimants (large HRA + 80C fully utilized + home loan interest). For most salaried with < Rs.3-3.5L in deductions, new regime is better.

### Income Tax — Old Regime (opt-in)

| Income Slab | Tax Rate |
|---|---|
| Up to Rs.2,50,000 | Nil |
| Rs.2,50,001 - Rs.5,00,000 | 5% |
| Rs.5,00,001 - Rs.10,00,000 | 20% |
| Above Rs.10,00,000 | 30% |

Standard deduction: Rs.50,000. Key deductions: 80C (Rs.1.5L), 80D (health insurance Rs.25K self + Rs.25K parents; Rs.50K if senior citizen), 80E (education loan — unlimited interest deduction for 8 years), 24(b) home loan interest (Rs.2L self-occupied, unlimited let-out), HRA, LTA, 80G (donations), 80CCD(1B) NPS Rs.50K.

**Old regime is typically worth it if**: HRA is significant + 80C fully utilized + home loan with Section 24(b) benefit → combined deductions > Rs.3-3.5L.

### TDS (Tax Deducted at Source)

| Income Type | TDS Rate | Threshold | Section |
|---|---|---|---|
| Salary | Per slab | — | 192 |
| Bank FD interest (general) | 10% (20% if no PAN) | >Rs.50,000/yr per bank | 194A |
| Bank FD interest (senior citizens) | 10% | >Rs.1,00,000/yr | 194A |
| Dividend | 10% | >Rs.5,000/yr | 194 |
| Rent (individual payer) | 5% (now restructured) | >Rs.50,000/month | 194IB |
| Professional fees | 10% | >Rs.30,000 | 194J |
| Commission/brokerage | 5% | — | 194H |
| EPF withdrawal | 10% | Interest on contribution > Rs.2.5L threshold | 192A / 194A |

**FD TDS update (2025-26)**: Threshold raised from Rs.40,000 to Rs.50,000 for general taxpayers. Senior citizen threshold raised to Rs.1,00,000.

**Rent TDS (2025-26 update)**: Threshold raised to Rs.50,000/month (was Rs.50,000/quarter).

the system implication: When income shows in bank statement, it's NET of TDS. Gross income = net received / (1 - TDS rate). For accurate income reporting, the system should track gross income and TDS separately.

### HRA Exemption Calculation

Least of:
1. Actual HRA received
2. 50% of basic salary (metro cities: Delhi, Mumbai, Kolkata, Chennai) or 40% (non-metro)
3. Rent paid minus 10% of basic salary

"Salary" = Basic + DA only (not gross). the system doesn't break salary into components today — this limits HRA calculation accuracy. Only claimable in old regime.

---

## Investment Taxation

### Equity & Equity Mutual Funds (post-Budget 2024, effective July 23, 2024)

| Holding Period | Classification | Tax Rate | Notes |
|---|---|---|---|
| ≤ 12 months | STCG (Section 111A) | 20% | Increased from 15% in Budget 2024 |
| > 12 months | LTCG (Section 112A) | 12.5% | Increased from 10%; exemption raised to Rs.1.25L |

- LTCG exemption: Rs.1.25 lakh per financial year (raised from Rs.1L in Budget 2024)
- Applies to: listed equity shares, equity-oriented MFs, business trust units where STT is paid
- No changes in Budget 2025-26 — Budget 2024 rates continue

**Tax-loss harvesting**: STCL offsets both STCG and LTCG (most flexible). LTCL offsets only LTCG. Carry forward for 8 years. Must file ITR before due date to activate carry forward. LTCG harvesting under Rs.1.25L/year is common — sell and rebuy to reset cost basis tax-free.

### Debt Mutual Funds

**Purchased on or after April 1, 2023**: ALL gains taxed at slab rate regardless of holding period. No indexation, no special LTCG rate. Holding 3+ years provides no tax advantage. Tax parity with bank FDs for slab-rate taxpayers.

**Purchased before April 1, 2023**: LTCG at 12.5% if held > 24 months (Budget 2024 clarified 24-month threshold). STCG at slab rate if ≤ 24 months. These older purchases retain preferential treatment.

**Practical impact**: For 30% tax bracket investors, debt MFs (post-Apr 2023) = FDs from tax perspective. Arbitrage funds (>65% in equity) retain equity taxation (20% STCG / 12.5% LTCG). Liquid funds are preferred for short-term parking despite slab taxation due to better post-tax returns vs savings accounts.

### Fixed Deposits

- Interest taxed at slab rate in the year of accrual (not just payout)
- Cumulative FDs: tax accrues annually even though money isn't received until maturity
- TDS: 10% if annual interest > Rs.50,000 (general); > Rs.1,00,000 (senior citizens) — updated in FY 2025-26
- Tax-saving FD: 5-year lock-in, qualifies for 80C deduction (old regime only)

### NPS (National Pension System)

| Contribution | Tax Benefit | Regime |
|---|---|---|
| Employee self-contribution (80CCD(1)) | Up to 10% of Basic+DA, within Rs.1.5L overall 80C limit | Both |
| Additional employee contribution (80CCD(1B)) | Rs.50,000 extra beyond 80C | Old regime ONLY (not available in new regime from FY 2025-26) |
| Employer contribution (80CCD(2)) | Up to 14% of Basic+DA (all employees, Budget 2024 raised private sector from 10% to 14%) | Both regimes |

- At maturity (age 60): 60% lump sum tax-free, 40% must buy annuity (annuity income taxed at slab)
- Partial withdrawal: up to 25% tax-free for specified purposes (child education, medical emergency, home purchase)
- Tier II: no tax benefit (except Central Govt employees), no lock-in — treat as flexible investment account

**Key change (Budget 2024)**: Employer NPS contribution cap raised to 14% of Basic+DA for private sector employees (was 10%). This is deductible in the new regime — the most powerful NPS benefit available in new regime.

### EPF

- Employee contribution (up to 12% of Basic+DA): 80C deduction (old regime)
- Interest: tax-free on employee contribution up to Rs.2.5 lakh/year. Interest on excess is taxed at slab.
- Government employees (SPF): limit is Rs.5 lakh/year
- Withdrawal after 5 years of continuous service: tax-free (all components)
- Withdrawal before 5 years: entire employer contribution + interest taxed at slab
- EPF interest rate: set annually by EPFO (currently ~8.25% for FY 2024-25)

### PPF

- Annual limit: Rs.1.5 lakh/year (unchanged)
- Interest rate: 7.1% p.a. (unchanged since April 2020, reviewed quarterly by government)
- Tax status: EEE — contribution deductible under 80C (old regime), interest tax-free, maturity tax-free
- Lock-in: 15 years with partial withdrawal from year 7 onwards
- Government-backed: no credit risk
- PPF interest is NOT available as deduction in new regime (80C not claimable), but the interest itself remains tax-free for existing accounts

### Real Estate Capital Gains (post-Budget 2024 — critical nuance)

**Purchased before July 23, 2024**:
- Individuals and HUFs have a CHOICE: 12.5% LTCG without indexation OR 20% LTCG with indexation (Budget 2024 amendment reinstated indexation for pre-Jul 23 purchases after industry backlash)
- Choose whichever gives lower tax — compute both scenarios

**Purchased on or after July 23, 2024**:
- Flat 12.5% LTCG, no indexation. No choice.
- Holding period for LTCG: > 24 months

**STCG** (any purchase date, held ≤ 24 months): taxed at slab rate

**Key exemptions**:
- Section 54: LTCG exempt if reinvested in new residential property within 2 years (purchase) or 3 years (construction)
- Section 54EC: LTCG exempt if invested in NHAI/REC bonds within 6 months, max Rs.50L
- TDS on sale: 1% if consideration > Rs.50L (Section 194-IA, buyer deducts)
- Stamp duty: 5-7% + 1% registration (state-specific)

### Capital Loss Set-off Rules

- STCL can offset STCG and LTCG
- LTCL can only offset LTCG
- Carried forward for 8 assessment years
- Must file return before due date to carry forward

the system implication: The system tracks `purchase_value` and `current_value` on assets but doesn't do per-lot FIFO tracking. For tax reporting, users need lot-level buy date and cost basis — especially for equity MFs where LTCG exemption applies per lot.

---

## Credit & Lending

### Credit Card Mechanics (India-Specific)

**Billing cycle**: Typically 28-31 days. Statement generated on "billing date." Payment due 18-21 days after billing date.

**Minimum due**: Typically 5% of outstanding or Rs.200, whichever is higher. Paying only minimum due:
- Avoids late payment fee
- Triggers interest on ENTIRE outstanding (not just unpaid portion) — this is called "loss of interest-free period"
- Interest rate: 36-42% APR (3-3.5% per month)

**Interest calculation**: Daily reducing balance method on outstanding amount from transaction date (not statement date) once interest-free period is lost.

**Credit limit utilization**: Reported to CIBIL. >30% utilization negatively impacts score. >80% is a red flag. the system insight Rule D4 flags this.

**Auto-debit mandates**: Many users set up NACH mandate for CC bill. Bank debit narration is "NACH" or "SI" (standing instruction) — harder to classify as CC payment without counterparty info.

**CC EMI conversion**: Converting a transaction to EMI:
- Original charge stays on CC statement
- EMI amount replaces it in future statements
- Processing fee (1-2%) added
- Interest rate: 12-24% APR (lower than revolving credit)
- In the system: separate `credit_card_emi` liability. CC closing_balance EXCLUDES remaining EMI principal.

**Reward points/cashback accounting**:
- Statement credit rewards: reduce next statement balance (not a separate income event)
- CRED coins/cashback: applied at payment time → bank debit < CC credit
- Milestone rewards: one-time credits, appear as negative charges on statement
- For financial reporting: cashback that reduces outflow IS income (it's money you didn't spend that you would have)

### Loan Types and Their Quirks

**Home Loan**:
- Longest tenure (up to 30 years)
- Interest deduction: Section 24(b) up to Rs.2L (self-occupied), unlimited (let-out)
- Principal repayment: 80C deduction
- Prepayment: no penalty (per RBI, floating rate loans)
- Co-borrower: both can claim deductions proportional to ownership
- Under construction: interest accumulated during construction claimed in 5 equal installments after possession

**Personal Loan**:
- No tax deduction on interest (unless used for home renovation/business)
- Higher interest rate (10-20%)
- Prepayment penalty: typically 2-5% of outstanding
- Foreclosure penalty: may differ from prepayment

**Auto Loan**:
- No tax deduction for personal use
- Hypothecation: car is collateral (appears as asset with encumbrance)
- Insurance bundled: comprehensive insurance mandatory year 1

**Education Loan**:
- Section 80E: FULL interest deduction (no cap) for 8 years from repayment start
- Moratorium period: during course + 6 months or 1 year after
- Interest accrues during moratorium

**Gold Loan**:
- Interest-only EMI option (bullet repayment of principal)
- LTV typically 75% of gold value
- Renewal: outstanding carried forward with fresh valuation

### CIBIL Score Mechanics

Score range: 300-900. Factors and approximate weights:
1. **Payment history (~35%)**: Even 1 day late is reported. 30+ days past due = "overdue" flag. Single late payment can drop score 50-100 points.
2. **Credit utilization (~30%)**: Per-card and overall. Keep under 30% for healthy score. >50% causes noticeable drop even with perfect payments.
3. **Credit age (~15%)**: Average age of all credit lines. Closing old CC reduces average age and hurts score.
4. **Credit mix (~10%)**: Secured (home/auto) + unsecured (personal/CC) mix is scored higher than all unsecured.
5. **Hard inquiries (~10%)**: Each loan application = hard inquiry. Multiple in 30 days may be rate-shopping and counted as one.

**Reporting cadence (2025 update)**: From January 1, 2025, banks and NBFCs are mandated to update CIBIL data twice per month (15th and last working day). Was previously monthly. Borrowers receive SMS/email alerts for every credit check.

**What "current balance" means in CIBIL**: Banks report the outstanding balance as of the reporting date — NOT the statement closing balance. For credit cards, this means:
- Statement cuts on 15th showing Rs.1.5L balance → reported to CIBIL at that moment
- If you pay Rs.1.5L on 25th (before due date), next CIBIL update on 31st shows Rs.0
- Trick: pay large CC purchases before statement generation date to show lower utilization

**Credit utilization threshold**: 30% is the widely accepted "safe" threshold. 30-50% = moderate risk signal. >50% = significant negative impact. Applies per-card AND aggregate across all cards.

**Key nuance for the system**: CC closing_balance shown in statement = what gets reported to CIBIL. This is why tracking CC outstanding accurately (as of statement date, not payment date) matters for credit health insights.

---

## Insurance & Pension

### Term Insurance
- Pure risk cover, no maturity value
- Premium is an expense (not an asset) — should appear as Insurance expense in the system
- Tax benefit: Section 80C on premium (old regime)
- Payout: tax-free under Section 10(10D) if annual premium ≤ 10% of sum assured

### Endowment / ULIP / Traditional Plans
- Have maturity value — track as asset
- Surrender value: often < premiums paid in early years (negative return)
- ULIP: market-linked, NAV-based valuation like MF
- Maturity: tax-free if premium ≤ 10% of sum assured (5% for policies after April 2012 with sum assured < 10x premium)
- For policies with annual premium > Rs.5L (post April 2023): maturity proceeds taxable

### NPS Pension
- Tier I: locked till 60 (partial withdrawal for specific purposes)
- Tier II: no lock-in (like MF, but no tax benefit except for Central Govt employees)
- Asset allocation: Equity (E), Corporate Bonds (C), Government Securities (G), Alternative (A)
- Auto choice: age-based allocation shift

---

## Regulatory Landscape

### RBI Regulations Affecting Personal Finance Apps

**1. Digital Lending Guidelines (2022) — key requirements:**
- Key Fact Statement (KFS): mandatory disclosure of all charges before loan signing. Any fee not in KFS cannot be charged.
- Direct disbursal: all loan money flows directly borrower ↔ lender. No pass-through pool accounts of third parties.
- All digital loans (regardless of tenure) must be reported to credit bureaus (CICs).
- All loan documents (KFS, sanction letter, T&C, privacy policy) must be auto-sent to borrower's registered email/SMS on execution.
- Lenders must conduct due diligence on Lending Service Providers (LSPs). Customer data must not be stored by LSPs beyond transaction completion.
- For the system: loan data displayed must reflect actual outstanding, not AI-estimated values, to avoid misleading borrowers.

**2. RBI (Commercial Banks — Credit Cards & Debit Cards: Issuance and Conduct) Directions, 2025 (updated):**
- Minimum due must include defined principal portion (not just interest/fees) — prevents debt trap from paying only token minimums
- Outstanding balance definition: total billed amount minus refunds and partial payments. Reversed transactions excluded.
- Clear statement separation of: billed amount, minimum due, total outstanding
- Interest charged only on outstanding amount (not entire limit)
- Credit limit can only be increased with explicit cardholder consent

**3. Account Aggregator (AA) Framework — current state (2025):**
- 17 companies hold RBI Certificate of Registration as AAs
- 126+ financial institutions live as both FIP (data provider) and FIU (data consumer)
- 2.61 billion+ financial accounts enabled for data sharing
- Key licensed AAs: Finvu, OneMoney, CAMSFinServ, NESL NADL, Setu (acquired by Pine Labs)
- Framework spans: banking (RBI), securities (SEBI), insurance (IRDAI), pension (PFRDA)
- Data shared under AA: bank statements, MF holdings, insurance, EPF, NPS — with user consent
- the system future integration: AA could replace manual document upload for bank statements. User consent → bank pushes data directly to the system as FIU.

**4. UPI Regulations and Limits:**
- Standard per-transaction limit: Rs.1,00,000
- Daily aggregate cap: Rs.1,00,000 (standard); higher for specific categories
- Enhanced limits (September 2025, NPCI): Rs.5,00,000 per transaction for hospital bills, insurance premiums, education fees
- Credit lines via UPI: RBI permits pre-approved credit lines through UPI with defined bank-set limits
- P2P transfers: Rs.1,00,000/day standard limit

**5. KYC Master Direction**: Any app handling financial data may need to comply. UPI and bank statement access has implications.

**6. NBFC lending rate guidelines**: Benchmark-linked (MCLR/EBLR). Rate changes must pass through to borrowers. Home loans since Oct 2019 are EBLR-linked (reset every 3 months) — pass-through of repo cuts is 85-95%. Older MCLR loans pass through only 65-70%.

### SEBI Regulations

1. **Mutual Fund NAV**: Must be published daily by AMCs. the system uses this for current_value.
2. **CAS (Consolidated Account Statement)**: Monthly from CAMS/KFintech. Lists all MF holdings. the system's `investment_statement` document type.
3. **Demat statements**: From NSDL/CDSL. Lists equity, bonds, government securities.
4. **LTCG reporting**: Brokers provide capital gains statement. Key dates: pre-July 23, 2024 (choice of indexation), post-July 23, 2024 (no indexation).

### DPDP Act 2023 and DPDP Rules 2025 (Data Protection)

**Rules notified: November 14, 2025. Compliance deadline: May 13, 2027 (18-month phased period).**

- Financial data is "sensitive personal data" under DPDP
- **Fintech dual compliance burden**: DPDP obligations OVERLAY RBI frameworks (Digital Lending Guidelines, AA ecosystem, payments data localisation). Both must be satisfied simultaneously.
- **Consent requirements**: Notice-and-consent model. Notice must state: (a) itemised list of personal data to be processed, (b) specific purpose, (c) link to withdraw consent. Withdrawal must be as easy as granting consent.
- **Purpose limitation**: data collected for loan processing cannot be used for marketing without separate consent
- **Right to erasure**: users can request deletion. the system's 6-step cascade delete directly addresses this. Must be complete — no orphan data.
- **Third-party data sharing**: credit bureaus, analytics vendors, and financial intermediaries must be bound by DPDP-compliant data processing agreements
- **Significant Data Fiduciary (SDF)**: large fintech platforms handling financial data at scale may be classified as SDF — triggers additional obligations (DPIA, data audits, etc.)
- **Data breach notification**: now mandatory; 72-hour reporting window to Data Protection Board
- **Consent Manager**: entities that manage consent on behalf of data principals must register with DPDP Board, hold Rs.2 crore minimum net worth, be India-incorporated

---

## Financial Ratios & Analysis

### Ratios a CFO Tracks for Personal Finance

| Ratio | Formula | Healthy | Warning | Critical |
|---|---|---|---|---|
| Savings Rate | (Income - Expenses) / Income | >20% | 10-20% | <10% |
| Debt-to-Asset | Total Liabilities / Total Assets | <0.3 | 0.3-0.5 | >0.5 |
| Debt-to-Income (DTI) | Monthly Debt Service / Monthly Income | <30% | 30-50% | >50% |
| Emergency Fund | Liquid Assets / Monthly Expenses | >6 months | 3-6 months | <3 months |
| Credit Utilization | CC Outstanding / CC Credit Limit | <30% | 30-50% | >50% |
| Illiquidity Ratio | Illiquid Assets / Total Assets | <50% | 50-70% | >70% |
| Interest Coverage | Monthly Income / Monthly Interest Expense | >5x | 2-5x | <2x |
| DSCR | Net Income / Total Debt Service | >1.5x | 1-1.5x | <1x |

### India-Specific Benchmarks (verified 2025)

**Debt-to-Income (DTI) — Indian lender thresholds:**
- <30%: strong, most loans approved easily
- 30-40%: acceptable, most lenders approve
- 40-43%: borderline; home loan approvals become harder
- >50%: typically rejected. Most lenders use 40-43% as their ceiling.
- India household debt as % of GDP: ~17.6% (Mar 2025, far lower than developed markets at 60-80%)

**Emergency Fund:**
- Salaried, stable sector (IT, govt, banking): 3-6 months of essential expenses
- Salaried, volatile sector (startups, sales, media): 6-9 months
- Self-employed / freelancers: 9-12 months
- Single-income household with dependants: 12 months
- Essential expenses only: rent/EMI, groceries, utilities, school fees, insurance premiums, loan repayments (exclude dining, entertainment, travel)

**India household savings rate (RBI data 2024-25):**
- Net household financial savings: ~5.1% of GNDI in FY 2023-24 (recovering from 7-year low)
- Projected FY 2024-25: ~6.5% of GNDI
- Gross savings rate: ~30-32% of GDP (but much of this is physical — gold, real estate)
- Physical vs financial split: physical savings rose to 71.5% of household savings by FY 2023-24 (was 59.7% in FY 2019-20)

**Insurance coverage benchmarks:**
- Term insurance: 7-10x annual income (some advisors say 10-15x if liabilities are high or single-income family). Cover should also include outstanding liabilities (home loan, personal loan).
- Health insurance: minimum Rs.5L for individuals; Rs.10-20L for family floater in metros (medical inflation ~15%/yr)
- Recommendation: upgrade term cover proportionally as income/liabilities rise; don't keep static cover throughout career

### Cash Flow Statement Structure

For personal finance, the three activities:
1. **Operating**: Salary, business income, rental income MINUS living expenses, utilities, groceries, etc.
2. **Investing**: MF SIP, equity purchases, FD creation MINUS MF redemption, FD maturity
3. **Financing**: Loan disbursement MINUS EMI payments, CC bill payments, prepayments

Net cash flow = Operating + Investing + Financing. Should approximately equal change in bank balance.

### Time Value of Money

Critical for evaluating:
- **Prepayment decisions**: Is it worth prepaying a 9% home loan when equity returns 12%? Consider post-tax returns and risk.
- **SIP vs lump sum**: Rupee cost averaging vs opportunity cost of delayed deployment
- **FD vs debt MF**: Post-tax return comparison accounting for taxation timing
- **Loan refinancing**: Total interest saved vs processing fees and time remaining

### CFO Decision Frameworks

**1. Prepayment vs Investment Decision**

The mathematically correct comparison: post-tax guaranteed return on prepayment vs expected post-tax investment return.

- **Guaranteed return from prepaying** = loan interest rate (after tax savings if applicable). For old regime home loan at 8.5%: effective post-tax cost = 8.5% × (1 - 0.30) = 5.95% (because Section 24(b) deduction saves Rs.2L tax). For new regime or personal loans (no deduction): full rate is cost = 8.5-12%.
- **Break-even for home loans (2025 context)**: With repo rate cuts in 2025, home loan rates are 8.5-9.5%. EBLR-linked loans now reset lower. Decision rule:
  - Loan rate < 7% (post-tax effective): invest in equity SIP (12-15% long-run expected LTCG-adjusted return)
  - Loan rate 7-8.5%: hybrid strategy — 40-60% prepayment, 40-60% SIP
  - Loan rate > 9%: prepay aggressively, especially in years 1-7 when 70-80% of EMI is interest
- **Regime matters**: New regime removes Section 24(b) deduction advantage → effective home loan cost is full rate → prepayment becomes more attractive for new regime filers
- **Stage in loan**: prepayment in early years (high interest component) saves more than late years. Prepaying in year 15 of a 20-year loan saves little interest.
- **Psychological factor**: debt-free milestone has real utility for many Indian families — quantify the non-financial value

**2. Tax-Loss Harvesting Framework**

Rules for India:
- STCL offsets both STCG and LTCG (most flexible — do this first)
- LTCL offsets only LTCG
- Carry forward for 8 assessment years (must file ITR before due date)
- Wash-sale rule: India does NOT have wash-sale rules (unlike US). Can sell and immediately rebuy same fund.

Decision process:
1. Identify losing positions by March 31
2. Calculate tax saving: STCL × 20% (if offsetting STCG) or × 12.5% (if offsetting LTCG)
3. Subtract transaction costs (STT + brokerage + GST)
4. If net saving > Rs.1,000 and you would hold the position anyway: harvest
5. Do NOT exit fundamentally good positions just for tax. Best use: trimming poor performers you'd reduce anyway.

**Annual LTCG harvest**: Even without losses, harvest LTCG gains up to Rs.1.25L/year and rebuy immediately. This resets cost basis tax-free. Over 10 years, this compounds significantly.

**3. Loan Refinancing Decision**

When to refinance (balance transfer):
- Rate differential > 0.5% (worthwhile to process)
- Processing fee: typically 0.5-1% of outstanding principal
- Break-even calculation: monthly EMI saving ÷ processing cost = months to break even (typically 10-14 months)
- Remaining tenure: only refinance if enough tenure left to recover processing cost
- Watch out: some banks have prepayment penalty on fixed-rate loans (floating rate: RBI prohibits prepayment penalty)

2025 context: RBI cut repo rate by 125 bps in 2025 (total: rate now 5.25%). EBLR-linked loans got full benefit. Old MCLR loans should be converted to EBLR — call bank, it's free. Borrowers not getting benefit: can refinance to another bank.

**4. Metrics CFOs Track for Household Financial Health**

Monthly dashboard metrics:
- **Savings rate**: (post-tax income - total expenses - SIP) / post-tax income. Target: >20%.
- **EMI-to-income ratio**: (all EMIs) / net monthly income. Target: <40% (Indian lender benchmark).
- **Liquid asset coverage**: (FD + savings account + liquid MF) / monthly expenses. Target: >6 months.
- **Net worth growth rate**: (current NW - last year NW) / last year NW. Should outpace inflation (7%+).
- **Insurance coverage ratio**: (term cover sum assured) / annual income. Target: 10x minimum.
- **Credit utilization**: CC outstanding as of statement date / total CC limit. Target: <30%.
- **Investment allocation**: equity / total financial assets. For age 30-40: 60-70% equity is healthy long term.

Quarterly review items:
- Rebalance investment portfolio if drifted > 5% from target allocation
- Review insurance coverage vs current liabilities and income
- Check if home loan rate reflects current repo rate (post 2025 cuts)
- Tax planning: estimate tax liability, maximize deductions, plan tax-loss harvesting before March 31

---

## Using Project Context

This skill provides portable financial domain expertise. Project-specific architecture (transaction taxonomy, processing pipelines, code paths, net worth computation details) lives in the project's context hierarchy:

- **`.claude/rules/`** — Domain-level financial patterns and constraints, auto-loaded when working in matching directories
- **`.claude/context/components/`** — Component-level financial logic details (outstanding calculation, surplus formula, dedup mechanics)
- **`.claude/context/decisions/ADR-*.md`** — Financial architecture decisions with rationale

When applying this skill to a specific project, read the relevant context files first. They contain the project's transaction taxonomy, net worth computation path, surplus formula, and key code paths for financial accuracy verification.

### Universal Financial Verification Checklist

Regardless of project, when reviewing financial code verify:
- Is `Assets - Liabilities = Net Worth` maintained after every operation?
- Are bill payments net-worth-neutral? (asset decrease = liability decrease)
- Is EMI debt service split correctly? (principal = net-worth-neutral, interest = net-worth-negative)
- Are CC expenses captured at swipe time (not bill payment time) to avoid double-counting?
- Is surplus = income - (expenses + non-CC debt service)?
- Is the dedup chain complete? (same event from multiple sources = one financial impact)
- Does the processing pipeline maintain balance sheet identity at every step?
