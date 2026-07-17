"""Maps football-data.co.uk league folder codes to BigQuery raw table names."""

LEAGUE_CODE_TO_TABLE = {
    "E0": "raw_premier_league",
    "SP1": "raw_la_liga",
    "D1": "raw_bundesliga",
    "I1": "raw_serie_a",
    "F1": "raw_ligue1",
}
