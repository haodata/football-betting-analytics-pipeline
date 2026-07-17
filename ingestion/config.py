"""Loads ingestion configuration from environment variables / .env."""

import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parent.parent / ".env")

GCP_PROJECT_ID = os.environ["GCP_PROJECT_ID"]
RAW_DATASET = os.environ.get("RAW_DATASET", "sbi_raw")
DATA_SOURCE_DIR = Path(os.environ["DATA_SOURCE_DIR"])
