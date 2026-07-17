# Dashboard Data Brief

> Verified, real numbers queried directly from **BigQuery `data-engineering-501612.sbi_mart`**
> (the production mart layer built by this project's dbt pipeline) on 2026-07-17.
> Use **only** the numbers in this file, or numbers derived from the schema section below via a
> fresh query. Do not invent plausible-looking placeholder numbers — the previous dashboard build
> had this problem and had to be discarded.

## Dataset scope

- **17,937 matches** total
- **5 leagues**: Premier League (England), La Liga (Spain), Bundesliga (Germany), Serie A (Italy), Ligue 1 (France)
- **10 seasons**: 2016/2017 through 2025/2026 (all complete as of today; season boundary is
  derived from match date, not file name)
- Date range: **2016-08-12** to **2026-05-24**
- Source: [football-data.co.uk](https://www.football-data.co.uk/), loaded via Python →
  BigQuery raw → dbt staging/intermediate/mart

## Overall KPIs (all leagues, all seasons)

| Metric | Value |
|---|---|
| Total matches | 17,937 |
| Total goals scored | 50,106 |
| Avg goals / match | 2.79 |
| Home win % | 44.04% (7,900 matches) |
| Away win % | 30.95% (5,551 matches) |
| Draw % | 25.01% (4,486 matches) |
| Both teams to score % | 53.70% |
| Over 2.5 goals % | 53.09% |
| Avg bookmaker overround | 5.24% (i.e. avg total implied probability ≈ 105.24%) |

Home/Away/Draw percentages sum to 100.00% (7,900 + 5,551 + 4,486 = 17,937). Use these three as a
donut/pie chart — do not reuse the older mock numbers (44.8%/... from the discarded dashboard,
which were close but not exact).

## By league

Sorted by avg goals/match, descending — this ordering (Bundesliga highest, La Liga lowest) is a
real, well-known characteristic of these leagues, not an artifact.

| League | Country | Matches | Total goals | Avg goals/match | Home win % | Avg overround |
|---|---|---|---|---|---|---|
| Bundesliga | Germany | 3,060 | 9,474 | 3.096 | 44.22% | 5.38% |
| Premier League | England | 3,800 | 10,773 | 2.835 | 44.63% | 4.68% |
| Serie A | Italy | 3,800 | 10,423 | 2.743 | 41.95% | 5.40% |
| Ligue 1 | France | 3,477 | 9,486 | 2.728 | 43.95% | 5.37% |
| La Liga | Spain | 3,800 | 9,950 | 2.618 | 45.50% | 5.43% |

Note: Bundesliga has fewer matches (18-team league, 10×306) and Ligue 1 has fewer than the
3,800 (10×380) expected for the other three because of the COVID-shortened 2019/20 season and a
later reduction to 18 teams — this is a documented, verified data quirk (see project README),
not a data-loading bug.

## By season

| Season | Matches | Total goals | Avg goals/match | Home win % | Avg overround |
|---|---|---|---|---|---|
| 2016/2017 | 1,826 | 5,176 | 2.835 | 48.63% | 4.64% |
| 2017/2018 | 1,826 | 4,947 | 2.709 | 45.35% | 4.77% |
| 2018/2019 | 1,826 | 5,019 | 2.749 | 44.74% | 4.74% |
| 2019/2020 | 1,504 | 4,177 | 2.777 | 44.02% | 5.35% |
| 2020/2021 | 2,047 | 5,753 | 2.810 | 40.40% | 5.63% |
| 2021/2022 | 1,826 | 5,132 | 2.811 | 42.77% | 5.43% |
| 2022/2023 | 1,826 | 5,051 | 2.766 | 45.73% | 5.38% |
| 2023/2024 | 1,752 | 5,054 | 2.885 | 43.09% | 5.39% |
| 2024/2025 | 1,752 | 4,953 | 2.827 | 42.01% | 5.56% |
| 2025/2026 | 1,752 | 4,844 | 2.765 | 44.01% | 5.56% |

Notes on irregular season sizes (all verified, not bugs):
- **2019/2020** is short (1,504 matches) — COVID-19 suspended/curtailed several leagues.
- **2020/2021** is unusually large (2,047 matches) — fixture backlog from the COVID-delayed
  2019/20 season spilled into calendar-2020, and since `season` is derived from `match_date`
  (not file name) some of those catch-up matches land in this season bucket.
- **2023/2024** onward drops to 1,752 (down from 1,826) — Ligue 1 and/or Bundesliga team-count
  changes; see README "Known data quirks".
- Home win % has a clear long-run downward drift (48.6% in 2016/17 → low-40s recently) — this is
  a real trend worth calling out on a season-trend chart, not noise.

## Top 10 goal-scoring teams (all-time, all competitions in this dataset)

| Team | Matches played | Goals scored |
|---|---|---|
| Bayern Munich | 340 | 972 |
| Man City | 380 | 904 |
| Barcelona | 380 | 890 |
| Paris SG | 357 | 883 |
| Liverpool | 380 | 808 |
| Real Madrid | 380 | 797 |
| Inter | 380 | 777 |
| Dortmund | 340 | 753 |
| Atalanta | 380 | 716 |
| Napoli | 380 | 715 |

(`matches_played` here counts matches where the team appears as either home or away in this
dataset's leagues only — not each club's true all-competition total.)

## Schema reference (for anything not covered above — requery, don't guess)

Live tables in `data-engineering-501612.sbi_mart`:

- **`fact_matches`** (17,937 rows) — one row per match. Key columns: `match_key`,
  `home_team_key`/`away_team_key` (→ `dim_team`), `league_key` (→ `dim_league`), `date_key`
  (→ `dim_date`), `season_key` (→ `dim_season`), `full_time_home_goals`, `full_time_away_goals`,
  `total_goals`, `goal_difference`, `home_points`/`away_points`, `match_result`
  ('Home Win'/'Away Win'/'Draw'), `home_win`/`away_win`/`draw` (booleans), `home_clean_sheet`/
  `away_clean_sheet`, `both_teams_to_score`, `over_2_5_goals`, `home_shot_accuracy`/
  `away_shot_accuracy`, `home_goal_conversion_rate`/`away_goal_conversion_rate`,
  `bet365_home_odds`/`bet365_draw_odds`/`bet365_away_odds`, `implied_prob_home`/
  `implied_prob_draw`/`implied_prob_away` (each in [0,1]), `bookmaker_overround`,
  `home_form_points_last5`/`away_form_points_last5` (+ goals scored/conceded avg last-5 —
  leakage-safe, computed only from strictly-prior matches).
- **`dim_team`** — `team_key`, `team_name`.
- **`dim_league`** — `league_key`, `league_code`, `league_name`, `country`.
- **`dim_season`** — `season_key`, `season`, `start_year`, `end_year`.
- **`dim_date`** — `date_key`, `date_day`, `year`, `month`, `day`, `day_of_week`, `month_name`,
  `day_name`.

Full column-level documentation: `dbt/models/marts/_marts.yml` and `dbt/models/docs.md` in this
project.

To pull a fresh number not listed above, join `fact_matches` to the relevant dimension and
aggregate — e.g. avg overround by season, BTTS% by league, top scoring teams per season, etc.
follow the same join pattern used in the queries that produced this brief.

## Design notes carried over from the discarded dashboard

The visual design spec (dark theme, colors, layout — `#34d399` mint for Home Win, `#38bdf8` sky
blue for Away Win, `#fbbf24` amber for Draw, card/grid layout) is still valid and can be reused.
**Only the data was wrong** — the previous build showed a filtered "2025/2026" view with
1,826 total matches and 4,912 total goals, which do not match the real season total of 1,752
matches / 4,844 goals above. Any rebuild should bind to the real numbers in this file (or a fresh
BigQuery query using the schema above) instead of the earlier placeholder values.
