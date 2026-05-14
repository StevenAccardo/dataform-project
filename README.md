# NYC Taxi ELT Pipeline — GCP + Dataform

A multi-layer ELT pipeline built on Google Cloud Platform using BigQuery and Dataform.
Transforms raw NYC yellow taxi trip data through staging and mart layers with built-in
data quality assertions and a daily automated schedule.

## Architecture
BigQuery Public Data (nyc_taxi.tlc_yellow_trips_2022)
↓
raw dataset
↓
Dataform (stg_taxi_trips)
- Filters invalid records
- Calculates trip duration
- Standardises column names
↓
staging dataset
+ data quality assertions
↓
Dataform (mart_daily_taxi_summary)
- Aggregates by day
- Trip counts, revenue, averages
↓
marts dataset

## Services Used

- **BigQuery** — data warehouse and transformation execution
- **Dataform** — pipeline orchestration and SQL transformation framework
- **Cloud Scheduler** — daily pipeline execution at 7:00 AM UTC
- **Secret Manager** — secure storage of GitHub access token
- **IAM** — service account permissions for Dataform

## Project Structure
dataform-project/
├── README.md
├── setup.sh                              # Creates GCP datasets and loads raw data
├── teardown.sh                           # Deletes all GCP datasets and resources
├── dataform.json                         # Dataform project configuration
├── package.json                          # Dataform core dependency
├── .env.example                          # Environment variable template
├── definitions/
│   ├── sources/
│   │   └── raw_taxi_trips.sqlx           # Declaration of raw source table
│   ├── staging/
│   │   └── stg_taxi_trips.sqlx           # Cleans and standardises raw taxi data
│   └── marts/
│       └── mart_daily_taxi_summary.sqlx  # Daily aggregated metrics
└── docs/
└── architecture.md

## Prerequisites

- Google Cloud SDK installed and authenticated
- A GCP project with billing enabled
- A GitHub account with a personal access token (repo scope)
- Python 3.8+ (optional, for local testing)

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/dataform-project.git
cd dataform-project
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Open `.env` and fill in your values:

```bash
GCP_PROJECT_ID=your-project-id
GCP_REGION=us-central1
BQ_LOCATION=US
DATAFORM_REPO=dataform-project
```

### 3. Run setup script

Creates BigQuery datasets and loads raw NYC taxi data from the public dataset:

```bash
./setup.sh
```

This creates three datasets in BigQuery:
- `raw` — source data loaded as-is from BigQuery public datasets
- `staging` — cleaned and standardised data
- `marts` — aggregated business-ready tables

### 4. Create Dataform repository

In the GCP console:

1. Navigate to **Dataform**
2. Click **Create repository**
3. Set name to `dataform-project` and region to `us-central1`
4. Navigate to **Settings → Link remote repository**
5. Select **HTTPS** and enter your GitHub repository URL
6. Store your GitHub personal access token in Secret Manager when prompted
7. Grant the Dataform service account `Secret Manager Secret Accessor` role in **IAM & Admin → IAM**

### 5. Create a workspace

Inside the Dataform repository:

1. Click **Create workspace**
2. Name it `dev`
3. Click **Pull from default branch** to sync your code from GitHub

### 6. Run the pipeline manually

In the Dataform workspace:

1. Confirm the compiled graph shows all four nodes connected correctly
2. Click **Start execution → Execute actions → All actions**
3. Select **Execute with user credentials**
4. Click **Start execution**
5. Monitor the execution — all actions should succeed including assertions

Verify results in BigQuery:

```bash
bq ls your-project-id:staging
bq ls your-project-id:marts
bq query --use_legacy_sql=false \
  "SELECT * FROM your-project-id.marts.mart_daily_taxi_summary LIMIT 10"
```

### 7. Set up automated schedule

**Release configuration:**
1. Console → Dataform → your repository → **Release configurations → Create**
2. Name: `production`
3. Git commitish: `main`

**Workflow configuration:**
1. **Workflow configurations → Create**
2. Name: `daily-run`
3. Release configuration: `production`
4. Authentication: **Execute with user credentials**
5. Schedule: Daily at 7:00 AM UTC
6. Actions: **All actions**
7. Click **Create**

## Data Quality

The staging model includes automated assertions that fail the pipeline if:

- `vendor_id`, `pickup_datetime`, or `fare_amount` are null
- `trip_distance` is zero or negative
- `fare_amount` is zero or negative

Results are stored in the `dataform_assertions` dataset in BigQuery.

## Output

The `marts.mart_daily_taxi_summary` table contains one row per day with:

| Column | Description |
|---|---|
| trip_date | Date of trips |
| total_trips | Total number of trips |
| avg_distance_miles | Average trip distance |
| avg_duration_minutes | Average trip duration |
| avg_fare | Average fare amount |
| avg_tip | Average tip amount |
| total_revenue | Total revenue for the day |
| credit_card_trips | Number of credit card payments |
| cash_trips | Number of cash payments |

## Teardown

To delete the BigQuery datasets only:

```bash
./teardown.sh
```

To fully remove all resources including the Dataform repository, workspace, 
release configurations, workflow configurations, and Secret Manager secrets, 
delete the entire GCP project:

```bash
gcloud projects delete your-project-id
```

Note: Project deletion has a 30 day recovery window. Billing stops immediately.
To restore a deleted project within that window:

```bash
gcloud projects undelete your-project-id
```

## Cost

This project runs entirely within the GCP free tier:

- BigQuery — 1 TB queries per month free
- Dataform — free
- Secret Manager — first 6 secret versions free
- Cloud Scheduler — 3 jobs per month free