# GharSaathi — Query Timings

Execution timings are reported in milliseconds. The first three runs from each benchmark CSV are used for the Run 1, Run 2, Run 3 and Average columns.

## Read and Write Query Timings

| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |
|---|---|---|---:|---:|---:|---:|---|
| R1 | READ | Health check - verify database connectivity | 0.024 | 0.022 | 0.022 | 0.023 | No table scan |
| R2 | READ | Registration - check whether an email already exists | 0.035 | 0.026 | 0.026 | 0.029 | Index Scan |
| R3 | READ | Login - retrieve user by email, including password hash | 0.027 | 0.028 | 0.027 | 0.027 | Index Scan |
| R4 | READ | Get the current user's profile | 0.055 | 0.065 | 0.053 | 0.058 | Seq Scan, Index Scan |
| R5 | READ | Get a property by ID, with its images and landlord details | 0.116 | 0.100 | 0.099 | 0.105 | Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R6 | READ | Check property ownership before landlord-only operations | 0.052 | 0.042 | 0.041 | 0.045 | Index Scan |
| R7 | READ | List available properties with optional filters | 0.118 | 0.114 | 0.143 | 0.125 | Seq Scan, Index Scan |
| R8 | READ | List properties owned by a landlord | 0.131 | 0.131 | 0.122 | 0.128 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R9 | READ | Verify property exists and is available before application submission | 0.046 | 0.044 | 0.043 | 0.044 | Index Scan |
| R10 | READ | List applications submitted by a tenant | 0.157 | 0.130 | 0.136 | 0.141 | Seq Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R11 | READ | List applications received by a landlord | 0.149 | 0.154 | 0.148 | 0.150 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R12 | READ | Get an application and verify that it belongs to landlord's property | 0.056 | 0.056 | 0.067 | 0.060 | Index Scan |
| R13 | READ | Check whether the property already has an active lease | 0.245 | 0.075 | 0.075 | 0.132 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R14 | READ | Get an approved application with its property and any existing lease | 0.099 | 0.098 | 0.127 | 0.108 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R15 | READ | Check for an active lease on the property before lease creation | 0.088 | 0.076 | 0.072 | 0.079 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R16 | READ | List leases for the logged-in landlord or tenant | 0.158 | 0.142 | 0.141 | 0.147 | Seq Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R17 | READ | Get a lease with related property, landlord, and tenant details | 0.213 | 0.196 | 0.221 | 0.210 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R18 | READ | Get lease and property ownership details before status update | 0.133 | 0.118 | 0.110 | 0.120 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R19 | READ | Check for another active lease on the same property | 0.122 | 0.114 | 0.123 | 0.120 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R20 | READ | Get lease/application information before a tenant creates maintenance request | 0.102 | 0.099 | 0.095 | 0.099 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R21 | READ | List maintenance requests for the logged-in landlord or tenant | 0.139 | 0.138 | 0.177 | 0.151 | Seq Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R22 | READ | Get a maintenance request and verify landlord ownership | 0.143 | 0.159 | 0.151 | 0.151 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R23 | READ | Get lease information before creating a payment | 0.116 | 0.170 | 0.108 | 0.131 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| R24 | READ | List payments for the logged-in landlord or tenant | 0.155 | 0.149 | 0.172 | 0.159 | Seq Scan, Index Scan, Bitmap Heap Scan, Bitmap Index Scan |
| R25 | READ | Get payment and related ownership details before status update | 0.158 | 0.138 | 0.150 | 0.149 | Seq Scan, Bitmap Heap Scan, Bitmap Index Scan, Index Scan |
| W1 | WRITE | Register a new user | 1.450 | 0.198 | 0.265 | 0.638 | — |
| W2 | WRITE | Create a property and its images | 0.672 | 0.616 | 0.589 | 0.626 | — |
| W3 | WRITE | Update property details | 0.811 | 0.121 | 0.125 | 0.352 | — |
| W4 | WRITE | Update property availability/status | 0.223 | 0.189 | 0.221 | 0.211 | — |
| W5 | WRITE | Submit a rental application | 0.345 | 0.306 | 0.313 | 0.321 | — |
| W6 | WRITE | Approve or reject an application | 0.171 | 0.174 | 0.173 | 0.173 | — |
| W7 | WRITE | Create a lease | 0.277 | 0.268 | 0.253 | 0.266 | — |
| W8 | WRITE | Update lease status | 0.189 | 0.207 | 0.196 | 0.197 | — |
| W9 | WRITE | Create a maintenance request | 0.637 | 0.624 | 0.610 | 0.624 | — |
| W10 | WRITE | Update maintenance request status | 0.224 | 0.236 | 0.201 | 0.220 | — |
| W11 | WRITE | Create a payment | 0.671 | 0.560 | 0.618 | 0.616 | — |
| W12 | WRITE | Update payment status and paid date | 0.202 | 0.198 | 0.202 | 0.201 | — |

## Benchmark Notes

- Each query was benchmarked five times; this report uses the first three runs to match the required submission format.
- R13–R25 use the fixture-based rerun results and plans.
- R1–R12 use the original read benchmark results and plans.
- W1–W12 use the write benchmark results. Write operations were executed in transactions and rolled back.
- R2 and R3 used an incorrect email parameter in the original benchmark. Their recorded timings are retained, but they should not be treated as validated matching-user lookup results.
- W2 measures the main property-creation SQL operation; optional image insertion was not included in that benchmark.
- Scan type is identified from the first selected run's PostgreSQL execution plan. Write queries are marked with a dash.

## Benchmark Environment

- Database: `gharsaathi_ap_test`
- Database engine: PostgreSQL
- Measurement: `EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)`
- Read queries: R1–R25
- Write queries: W1–W12
- Reported runs per query: 3
- Write benchmark transactions: rolled back after each run

## Raw Execution Plans

The `plans/` directory contains one JSON execution plan for each of the three reported runs of every query.

Total queries: 37
Total plan files: 111
