# Power BI — Connection & Overview Page

Phase 1 scope: connection instructions and an Overview page design spec. No `.pbix`
file is built here — the schema below reflects what `fact_matches` / `dim_*` actually
produce once `dbt run` has completed.

## Connecting to BigQuery

1. Power BI Desktop → **Get Data** → **More...** → **Database** → **Google BigQuery**.
2. Sign in with the Google account that has access to the target GCP project (the same
   project as `GCP_PROJECT_ID`).
3. Navigate to dataset **`sbi_mart`** only — never connect directly to `sbi_raw`,
   `sbi_staging`, or `sbi_intermediate` (per CLAUDE.md: Power BI reads from Mart only).
4. Select `fact_matches`, `dim_team`, `dim_league`, `dim_date`, `dim_season`.
5. Storage mode: **Import** for Phase 1 (data volume is small — a few thousand rows
   total across 5 leagues/10 seasons). DirectQuery is unnecessary until this becomes a
   live/incremental pipeline (Phase 4/5).
6. In Power BI's Model view, build relationships:
   - `fact_matches.home_team_key` → `dim_team.team_key` (rename the relationship/role
     "Home Team")
   - `fact_matches.away_team_key` → `dim_team.team_key` (role "Away Team" — requires an
     inactive relationship + `USERELATIONSHIP()` in DAX measures, since `dim_team` can
     only have one active relationship to `fact_matches`)
   - `fact_matches.league_key` → `dim_league.league_key`
   - `fact_matches.date_key` → `dim_date.date_key`
   - `fact_matches.season_key` → `dim_season.season_key`

## Overview page — design spec

**KPI cards** (top row):
- Total Matches (`COUNT(fact_matches[match_key])`)
- Avg Goals / Match (`AVERAGE(fact_matches[total_goals])`)
- Home Win % (`DIVIDE(COUNTROWS(FILTER(fact_matches, fact_matches[home_win])), COUNT(fact_matches[match_key]))`)
- Avg Bookmaker Overround (`AVERAGE(fact_matches[bookmaker_overround])`) — betting-analytics-specific KPI

**Charts**:
- Goals-per-season trend — line chart, x = `dim_season[season]` (sorted by `start_year`), y = avg `total_goals`
- League comparison — bar chart, x = `dim_league[league_name]`, y = avg `total_goals` or match count
- Match result split — donut/stacked bar of `match_result` (Home Win / Draw / Away Win) share

**Filters/slicers**: `dim_league[league_name]`, `dim_season[season]`, date range on `dim_date[date_day]`.

Later Phase 1+ pages (League Analysis, Team Analysis, Season Analysis, Home vs Away,
Betting Analysis, Prediction) are out of scope for this pass — `fact_matches` already
carries the odds/overround/form columns a future Betting Analysis page will need.
