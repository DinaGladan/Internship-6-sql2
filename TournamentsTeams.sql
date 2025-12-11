
INSERT INTO TournamentsTeams (TournamentId, TeamId)
	SELECT TournamentId, HomeTeamId FROM Matches
	UNION
	SELECT TournamentId, AwayTeamId FROM Matches;

UPDATE TournamentsTeams tt
	SET ScoredGoals =(
		SELECT COUNT(*) FROM Events e
		JOIN Matches m ON m.MatchId = e.MatchId
		WHERE e.EventType = 'goal'
		AND (m.TournamentId = tt.TournamentId
			AND (m.HomeTeamId = tt.TeamId AND e.PlayerId IN 
			(SELECT PlayerId FROM Players p WHERE p.TeamId = tt.TeamId))
		OR
			(m.AwayTeamId = tt.TeamId AND e.PlayerId IN
			(SELECT PlayerId FROM Players p WHERE p.TeamId = tt.TeamId))
		)
);

UPDATE TournamentsTeams tt
	SET ConcededGoals =(
		SELECT COUNT(*) FROM Events e
		JOIN Matches m ON m.MatchId = e.MatchId
		WHERE e.EventType = 'goal'
		AND (m.TournamentId = tt.TournamentId
			AND (m.HomeTeamId = tt.TeamId AND e.PlayerId IN 
			(SELECT PlayerId FROM Players p WHERE p.TeamId <> tt.TeamId))
		OR
			(m.AwayTeamId = tt.TeamId AND e.PlayerId IN
			(SELECT PlayerId FROM Players p WHERE p.TeamId <> tt.TeamId))
		)
);

UPDATE TournamentsTeams tt
	SET Points = (
	SELECT SUM(
		CASE 
			WHEN(m.HomeTeamId = tt.TeamId AND m.HomeScore>m.AwayScore) THEN 3
			WHEN(m.AwayTeamId = tt.TeamId AND m.HomeScore<m.AwayScore) THEN 3
			WHEN(m.HomeScore=m.AwayScore) THEN 1
			ELSE 0 END
	)
	FROM Matches m
	WHERE m.TournamentId = tt.TournamentId
	AND (m.HomeTeamId = tt.TeamId OR m.AwayTeamId = tt.TeamId)
);

UPDATE TournamentsTeams tt
	SET ReachedStage = (ARRAY['grupa','osmina','četvrtfinale','polufinale','finale'])[floor(random()*5)+1];
	
SELECT e.eventid, e.playerid, p.teamid, m.hometeamid, m.awayteamid
FROM events e
JOIN players p ON p.playerid = e.playerid
JOIN matches m ON m.matchid = e.matchid




