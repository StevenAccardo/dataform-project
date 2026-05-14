# Architecture

## Overview
A multi-layer ELT pipeline using BigQuery and Dataform.

## Layers
- **Raw** — source data loaded as-is from BigQuery public datasets
- **Staging** — cleaned and standardised, one-to-one with source tables
- **Marts** — aggregated, business-ready tables for analysis

## Data Flow
BigQuery Public Data
↓
raw dataset
↓
Dataform (stg_taxi_trips)
↓
staging dataset
↓
Dataform (mart_daily_taxi_summary)
↓
marts dataset

## Services Used
- BigQuery — data warehouse and transformation execution
- Dataform — pipeline orchestration and SQL transformation framework
- Cloud Scheduler — daily pipeline execution
