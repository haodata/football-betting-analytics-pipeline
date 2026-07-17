"""Loads football-data.co.uk CSV files into BigQuery Raw tables, one table per league.

Responsibilities per CLAUDE.md Python rules: read CSV, upload to BigQuery, log, handle
errors. No business transformations or calculated columns beyond pure ingestion-lineage
metadata (_source_file, _loaded_at). Column names are sanitized only to the extent
BigQuery's identifier rules require (e.g. "B365>2.5" -> "B365_gt_2_5", "1XBH" -> "_1XBH") —
values are never touched.
"""

import logging
import re
import sys
from datetime import datetime, timezone

import pandas as pd
from google.cloud import bigquery
from google.cloud.bigquery import LoadJobConfig, SchemaUpdateOption, WriteDisposition

from config import DATA_SOURCE_DIR, GCP_PROJECT_ID, RAW_DATASET
from league_map import LEAGUE_CODE_TO_TABLE

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)

_INVALID_COLUMN_CHARS = re.compile(r"[^A-Za-z0-9_]")


def sanitize_column_name(name):
    """Makes a source column name a legal BigQuery field name without touching
    any data values. Needed because some odds columns use characters BigQuery
    field names can't contain (e.g. "B365>2.5") or start with a digit (e.g.
    "1XBH") — a hard storage-layer constraint, not a data-cleaning choice.

    ">" and "<" are mapped to distinct tokens (not both to "_") because a
    single file can have both "B365>2.5" and "B365<2.5" columns — collapsing
    both to the same character would silently merge two different columns.
    """
    sanitized = name.replace(">", "_gt_").replace("<", "_lt_")
    sanitized = _INVALID_COLUMN_CHARS.sub("_", sanitized)
    if sanitized[0].isdigit():
        sanitized = f"_{sanitized}"
    return sanitized


def load_csv_to_table(client, csv_path, table_id, write_disposition):
    """Loads a single CSV file into a BigQuery table, appending lineage metadata columns.

    Every column is read as a string. Raw source files change column sets and
    inferred types across seasons (verified: 61-132 columns, same field sometimes
    numeric/blank across files); loading everything as STRING avoids append-time
    schema conflicts. Type casting belongs to the staging layer.
    """
    # keep_default_na=False keeps missing cells as "" instead of NaN, so every
    # column stays a clean pandas/pyarrow string type (mixed str/NaN columns can
    # break dataframe-to-BigQuery type inference on load).
    df = pd.read_csv(csv_path, dtype=str, encoding="utf-8-sig", keep_default_na=False)
    df = df.rename(columns=sanitize_column_name)
    df["_source_file"] = csv_path.name
    df["_loaded_at"] = datetime.now(timezone.utc).isoformat()

    # Schema is inferred from the dataframe's dtypes (all STRING, since dtype=str
    # above); schema_update_options only applies to appends, per the BigQuery API.
    job_config = LoadJobConfig(
        write_disposition=write_disposition,
        schema_update_options=(
            [SchemaUpdateOption.ALLOW_FIELD_ADDITION]
            if write_disposition == WriteDisposition.WRITE_APPEND
            else []
        ),
    )
    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()
    logger.info(
        "Loaded %s rows from %s into %s (job_id=%s)",
        job.output_rows,
        csv_path.name,
        table_id,
        job.job_id,
    )


def main():
    client = bigquery.Client(project=GCP_PROJECT_ID)
    truncated_tables = set()
    failures = []

    for league_code, table_name in LEAGUE_CODE_TO_TABLE.items():
        league_dir = DATA_SOURCE_DIR / league_code
        if not league_dir.is_dir():
            logger.error("League folder not found, skipping: %s", league_dir)
            failures.append(str(league_dir))
            continue

        table_id = f"{GCP_PROJECT_ID}.{RAW_DATASET}.{table_name}"
        csv_files = sorted(league_dir.glob("*.csv"))
        if not csv_files:
            logger.error("No CSV files found in %s", league_dir)
            continue

        for csv_path in csv_files:
            write_disposition = (
                WriteDisposition.WRITE_TRUNCATE
                if table_name not in truncated_tables
                else WriteDisposition.WRITE_APPEND
            )
            try:
                load_csv_to_table(client, csv_path, table_id, write_disposition)
                truncated_tables.add(table_name)
            except Exception:
                logger.exception("Failed to load %s into %s", csv_path, table_id)
                failures.append(str(csv_path))

    if failures:
        logger.error("Completed with %d failed file(s): %s", len(failures), failures)
        sys.exit(1)

    logger.info("All files loaded successfully.")


if __name__ == "__main__":
    main()
