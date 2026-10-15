# ENG2040 Assignment 1: Marketplace Orders and Delivery Outcomes

Imran Turganov

Pipeline from the supplied `data/raw.sql` to cleaned order data, charts and a model-ready feature table for `delivered_after_estimate`.

## Run everything with one command

The GitHub repository holds the code only: `assignment1.ipynb`, `sql/` and this README.
The data (`data/raw.sql`) and the loader (`setup_db.py`) come from the course package and are not copied there.
Put `assignment1.ipynb` and `sql/` into the extracted course folder, next to `setup_db.py` and `data/`.

Install the packages once (Python 3.12+):

```sh
pip install pandas==2.3.3 numpy==2.3.3 pyarrow==22.0.0 matplotlib==3.10.7 psutil nbconvert ipykernel
```

Then run every step with one command:

```sh
jupyter nbconvert --to notebook --execute --inplace assignment1.ipynb
```

In my submitted folder the environment is locked with `pyproject.toml` and `uv.lock`, so there the same run is
`uv run jupyter nbconvert --to notebook --execute --inplace assignment1.ipynb` ([uv](https://docs.astral.sh/uv/) creates the environment on the first run).

The notebook deletes and rebuilds `outputs/00_marketplace.sqlite` from `data/raw.sql`, so every run starts from the supplied data.
A full run takes about 2 seconds of pipeline time (about 10 s with kernel start) and needs about 40 MB of disk.
`data/raw.sql` and `setup_db.py` are unchanged. The notebook imports `populate()` from `setup_db.py`.

## Files

| File | Purpose |
|---|---|
| `assignment1.ipynb` | The whole pipeline, Steps 0-5, with outputs |
| `sql/01_orders.sql` | Executed SQL: one row per order (child tables grouped, then LEFT JOIN) |
| `sql/01_relationships.sql` | Executed SQL: key and orphan checks |
| `sql/01_naive_join.sql` | Executed SQL: the naive join used only to show the fan-out |
| `sql/02_items.sql` | Executed SQL: item rows for cleaning |
| `outputs/` | Output data of every step (below) from my run; the notebook recreates it |
| `pyproject.toml`, `uv.lock` | Locked environment (submitted folder only) |
| `report/` | LaTeX source of the report (submitted folder only) |

## Steps, inputs and outputs

| Step | Notebook section | Input | Output | One row is |
|---|---|---|---|---|
| 0 Build database | Step 0 | `data/raw.sql` | `outputs/00_marketplace.sqlite` (intermediate, 24 MB, not in the GitHub repo: Step 0 creates it from `raw.sql`) | table rows as supplied |
| 1 Load | Step 1 | SQLite | `01_orders_loaded.parquet` | one order (20,000), raw values, child tables aggregated |
| | | | `01_tables.csv`, `01_relationships.csv`, `01_checks.csv`, `01_load_comparison.csv` | one table / relationship / check / loading approach |
| 2 Clean and label | Step 2 | Step 1 output, SQLite | `02_orders_clean.parquet` | one order (20,000), cleaned, with `label_status` and `delivered_after_estimate` (empty if unlabelled) |
| | | | `02_items_clean.parquet` | one item (22,662) with cleaned product and seller attributes |
| | | | `02_change_log.csv` | one changed value: table, key, column, old, new, rule |
| | | | `02_change_summary.csv`, `02_issues.csv`, `02_label_accounting.csv` | one rule / problem / label reason |
| | | | `02_unit_evidence.csv`, `02_payment_reconciliation.csv`, `02_size_evidence.csv` | evidence for the unit and sign fixes |
| 3 Explore | Step 3 | Step 2 output | `figures/fig1-3*.png`, `chart_data/*.csv` | chart data: one bin, month or state |
| | | | `03_q1_summary.csv`, `03_state_priority.csv`, `03_sensitivity.csv` | one statistic / state / inclusion scenario |
| 4 Features | Step 4 | Step 2 output | `04_features.parquet` | one retained order (16,481), 64 numeric features, no ID and no label |
| | | | `04_labels.csv` | `order_id`, `delivered_after_estimate`, same row order as the features |
| | | | `04_feature_dictionary.csv`, `04_exclusions.csv`, `04_feature_label_correlation.csv` | one feature / exclusion reason / feature |
| 5 Resources | Step 5 | all steps | `05_resources.csv`, `05_file_inventory.csv`, `environment.json` | one step / file |

## Loading the outputs

```python
import pandas as pd

X = pd.read_parquet("outputs/04_features.parquet")
y = pd.read_csv("outputs/04_labels.csv")
assert len(X) == len(y)
orders = pd.read_parquet("outputs/02_orders_clean.parquet")
labelled = orders[orders["label_status"] == "labelled"]
```

Row `i` of `04_features.parquet` belongs to row `i` of `04_labels.csv`.
Amounts are BRL, weights kg, volumes litres, times on the recorded local clock (no UTC offset).

## Label

`delivered_after_estimate` = 1 if the calendar date of delivery is after the calendar date of the estimate, 0 otherwise (delivery on the estimated date is on time).
Only delivered orders with a valid delivery date, a valid estimate and a possible chronology are labelled. The reason for every other order is in `label_status`.

## Database setup (from the supplied package)

`setup_db.py` creates and populates a SQLite database from `data/raw.sql` without cleaning it (`python3 setup_db.py`, or `--db another_name.sqlite`).
The notebook calls the same `populate()` function itself, so this is not needed for the pipeline.

Dataset: modified version of Olist's Brazilian E-Commerce Public Dataset, educational use only, licence CC BY-NC-SA 4.0.
