
INSERT INTO TournamentsTeams (TournamentId, TeamId)
	SELECT TournamentId, HomeTeamId FROM Matches
	UNION
	SELECT TournamentId, AwayTeamId FROM Matches;

UPDATE TournamentsTeams tt
	SET ScoredGoals =(
		SELECT COUNT(*) FROM Events e
		JOIN Matches m ON m.MatchId = e.MatchId
		WHERE e.EventType = 'goal'
		AND m.TournamentId = tt.TournamentId
		AND ((m.HomeTeamId = tt.TeamId AND e.PlayerId IN 
			(SELECT PlayerId FROM Players p WHERE p.TeamId = tt.TeamId))
		OR
			(m.AwayTeamId = tt.TeamId AND e.PlayerId IN
			(SELECT PlayerId FROM Players p WHERE p.TeamId = tt.TeamId))
		)
);

UPDATE TournamentsTeams tt
	SET ReachedStage = (ARRAY['grupa','osmina','četvrtfinale','polufinale','finale'])[floor(random()*5)+1];
	

---treba promijenit i events kako bi se izracunali postignuti golovi

INSERT INTO Events (PlayerId, MatchId, EventType, MinutesOfEvent)
	SELECT
		(SELECT PlayerId FROM Players WHERE TeamId = m.HomeTeamId ORDER BY random() LIMIT 1),
		m.MatchId, 'goal', floor(random()*90)+1
FROM Matches m,
	generate_series(1,m.HomeScore);

INSERT INTO Events (PlayerId, MatchId, EventType, MinutesOfEvent)
	SELECT
		(SELECT PlayerId FROM Players WHERE TeamId = m.AwayTeamId ORDER BY random() LIMIT 1),
		m.MatchId, 'goal', floor(random()*90)+1
FROM Matches m,
	generate_series(1,m.AwayScore);

--izracun golova naknadno

UPDATE TournamentsTeams tt
	SET ConcededGoals =(
		SELECT COUNT(*) FROM Events e
		JOIN Matches m ON m.MatchId = e.MatchId
		WHERE e.EventType = 'goal'
		AND m.TournamentId = tt.TournamentId
			AND ((m.HomeTeamId = tt.TeamId AND e.PlayerId IN 
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
-- odlucivanje winnerTeamId

UPDATE Tournaments t
SET WinnerTeamId = (
	CASE
		WHEN t.YearOfMaintenance > EXTRACT(Year FROM CURRENT_DATE) THEN Null
		ELSE(
			SELECT tt.TeamId
			FROM TournamentsTeams tt
			WHERE t.TournamentId = tt.TournamentId
			ORDER BY tt.Points DESC 
			LIMIT 1)
		END
);

-- kako bi se ispunio min broj redaka
INSERT INTO TournamentsTeams (TournamentId,
	TeamId,
	Points,
	ScoredGoals,
	ConcededGoals,
	ReachedStage)
	VALUES
	(3, 5, 10, 8, 3, 'polufinale'),
	(7, 5, 7, 5, 4, 'četvrtfinale'),
	(12, 5, 12, 11, 2, 'finale');







