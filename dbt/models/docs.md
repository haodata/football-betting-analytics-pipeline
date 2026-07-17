{#- Reusable column descriptions. Referenced via {{ doc('block_name') }} instead
    of retyping the same text in every model that carries the column, since most
    columns here flow unchanged through several layers (e.g. bet365_home_odds
    appears in 5 staging models, stg_matches, int_matches_enriched, and
    fact_matches with identical meaning throughout). #}

{% docs match_id %}
Surrogate key hashed from (league_code, season, match_date, home_team, away_team). Stable identifier for a single match, used to join team-form metrics back onto the match row.
{% enddocs %}

{% docs league_code %}
Source league code from football-data.co.uk (E0, D1, SP1, I1, F1).
{% enddocs %}

{% docs league_name %}
Human-readable league name (e.g. Premier League), attached from seed_league_lookup.
{% enddocs %}

{% docs country %}
Country the league is played in, attached from seed_league_lookup.
{% enddocs %}

{% docs season %}
Season in 'YYYY/YYYY' format, derived from match_date (matches from July-December belong to the season starting that calendar year; January-June belong to the season that started the previous year). Never derived from the source filename — see README "Known data quirks" for why.
{% enddocs %}

{% docs match_date %}
Date the match was played, parsed from the source's DD/MM/YY (through 2017/18) or DD/MM/YYYY (2018/19 onward) format.
{% enddocs %}

{% docs match_time %}
Kickoff time. NULL for all matches before the 2019/20 season — the source only started publishing kickoff times from that season onward, across all 5 leagues.
{% enddocs %}

{% docs home_team %}
Home team name, as published by the source.
{% enddocs %}

{% docs away_team %}
Away team name, as published by the source.
{% enddocs %}

{% docs referee %}
Match referee. Only ever populated for Premier League (E0) matches — the source never published referee names for the other 4 leagues, so this is NULL for Bundesliga/La Liga/Serie A/Ligue 1 in every season.
{% enddocs %}

{% docs source_file %}
Original CSV filename this row was loaded from (raw-layer lineage metadata, e.g. "E0 1617.csv"). Note: for Bundesliga, the "1617"/"1718" filenames are swapped relative to their actual season content — see README "Known data quirks". This column preserves that fact for traceability even though season is computed from match_date, not from this filename.
{% enddocs %}

{% docs full_time_home_goals %}
Goals scored by the home team at full time.
{% enddocs %}

{% docs full_time_away_goals %}
Goals scored by the away team at full time.
{% enddocs %}

{% docs full_time_result %}
Full-time result: H (home win), D (draw), A (away win).
{% enddocs %}

{% docs half_time_home_goals %}
Goals scored by the home team at half time.
{% enddocs %}

{% docs half_time_away_goals %}
Goals scored by the away team at half time.
{% enddocs %}

{% docs half_time_result %}
Half-time result: H (home leading), D (level), A (away leading).
{% enddocs %}

{% docs home_shots %}
Total shot attempts by the home team.
{% enddocs %}

{% docs away_shots %}
Total shot attempts by the away team.
{% enddocs %}

{% docs home_shots_on_target %}
Shots on target by the home team.
{% enddocs %}

{% docs away_shots_on_target %}
Shots on target by the away team.
{% enddocs %}

{% docs home_fouls %}
Fouls committed by the home team.
{% enddocs %}

{% docs away_fouls %}
Fouls committed by the away team.
{% enddocs %}

{% docs home_corners %}
Corners won by the home team.
{% enddocs %}

{% docs away_corners %}
Corners won by the away team.
{% enddocs %}

{% docs home_yellow_cards %}
Yellow cards shown to the home team.
{% enddocs %}

{% docs away_yellow_cards %}
Yellow cards shown to the away team.
{% enddocs %}

{% docs home_red_cards %}
Red cards shown to the home team.
{% enddocs %}

{% docs away_red_cards %}
Red cards shown to the away team.
{% enddocs %}

{% docs bet365_home_odds %}
Bet365 decimal odds for a home win, as published pre-match. Present in all 50 source files (verified), unlike most other bookmaker odds columns which vary by season.
{% enddocs %}

{% docs bet365_draw_odds %}
Bet365 decimal odds for a draw, as published pre-match.
{% enddocs %}

{% docs bet365_away_odds %}
Bet365 decimal odds for an away win, as published pre-match.
{% enddocs %}

{% docs total_goals %}
full_time_home_goals + full_time_away_goals.
{% enddocs %}

{% docs goal_difference %}
full_time_home_goals - full_time_away_goals. Positive means the home team won by that many goals, negative means the away team did.
{% enddocs %}

{% docs home_points %}
League points earned by the home team from this match (3 win / 1 draw / 0 loss).
{% enddocs %}

{% docs away_points %}
League points earned by the away team from this match (3 win / 1 draw / 0 loss).
{% enddocs %}

{% docs match_result %}
Human-readable match outcome: 'Home Win', 'Away Win', or 'Draw'.
{% enddocs %}

{% docs home_win %}
True if the home team won.
{% enddocs %}

{% docs away_win %}
True if the away team won.
{% enddocs %}

{% docs draw %}
True if the match was drawn.
{% enddocs %}

{% docs home_clean_sheet %}
True if the away team failed to score (home team kept a clean sheet).
{% enddocs %}

{% docs away_clean_sheet %}
True if the home team failed to score (away team kept a clean sheet).
{% enddocs %}

{% docs both_teams_to_score %}
True if both the home and away team scored at least one goal.
{% enddocs %}

{% docs over_2_5_goals %}
True if total_goals is 3 or more (i.e. the match went over the 2.5-goal betting line).
{% enddocs %}

{% docs home_shot_accuracy %}
home_shots_on_target / home_shots (SAFE_DIVIDE — NULL when home_shots is 0).
{% enddocs %}

{% docs away_shot_accuracy %}
away_shots_on_target / away_shots (SAFE_DIVIDE — NULL when away_shots is 0).
{% enddocs %}

{% docs home_goal_conversion_rate %}
full_time_home_goals / home_shots (SAFE_DIVIDE — NULL when home_shots is 0).
{% enddocs %}

{% docs away_goal_conversion_rate %}
full_time_away_goals / away_shots (SAFE_DIVIDE — NULL when away_shots is 0).
{% enddocs %}

{% docs implied_prob_home %}
Bet365 home-win odds converted to an implied probability (1 / bet365_home_odds). Not adjusted for bookmaker margin — see bookmaker_overround.
{% enddocs %}

{% docs implied_prob_draw %}
Bet365 draw odds converted to an implied probability (1 / bet365_draw_odds).
{% enddocs %}

{% docs implied_prob_away %}
Bet365 away-win odds converted to an implied probability (1 / bet365_away_odds).
{% enddocs %}

{% docs bookmaker_overround %}
implied_prob_home + implied_prob_draw + implied_prob_away - 1. The bookmaker's built-in margin — positive because the three implied probabilities are quoted to sum to slightly more than 100%.
{% enddocs %}

{% docs home_form_points_last5 %}
Home team's league points earned across its last 5 matches strictly before this one (ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING — this match's own result is never included). NULL/partial for a team's first few matches in the dataset. Not reset at season boundaries.
{% enddocs %}

{% docs home_form_goals_scored_avg_last5 %}
Home team's average goals scored across its last 5 matches strictly before this one.
{% enddocs %}

{% docs home_form_goals_conceded_avg_last5 %}
Home team's average goals conceded across its last 5 matches strictly before this one.
{% enddocs %}

{% docs away_form_points_last5 %}
Away team's league points earned across its last 5 matches strictly before this one (ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING — this match's own result is never included).
{% enddocs %}

{% docs away_form_goals_scored_avg_last5 %}
Away team's average goals scored across its last 5 matches strictly before this one.
{% enddocs %}

{% docs away_form_goals_conceded_avg_last5 %}
Away team's average goals conceded across its last 5 matches strictly before this one.
{% enddocs %}

{% docs team_match_log_team %}
Team name from this row's perspective (either the home or away team of the underlying match).
{% enddocs %}

{% docs team_match_log_opponent %}
The opposing team from this row's perspective.
{% enddocs %}

{% docs team_match_log_is_home %}
True if `team` was the home side in this match, false if away.
{% enddocs %}

{% docs team_match_log_points_earned %}
League points `team` earned from this match (3 win / 1 draw / 0 loss), from that team's perspective.
{% enddocs %}
