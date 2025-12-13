-- 1. Upit
EXPLAIN ANALYZE
SELECT TournamentName,
	YearOfMaintenance,
	PlaceOfMaintenance,
	WinnerTeamId 
FROM Tournaments t
LEFT JOIN Teams tm
ON t.WinnerTeamId = tm.TeamId
-- isto

-- 2.Upit
EXPLAIN ANALYZE
SELECT TournamentId, TeamName, Representative
FROM TournamentsTeams tt
INNER JOIN Teams t
ON tt.TeamId = t.TeamId
WHERE  tt.TournamentId = 5
-- isto
	
-- 3.Upit
CREATE INDEX idx_team_id ON Players(TeamId);
	
EXPLAIN ANALYZE
SELECT PlayerId,
	PlayerFirstName, 
	PlayerLastName, 
	EXTRACT (YEAR FROM BirthDate),
	ShirtNumber,
	Position,
	p.Contact,
	TeamName
FROM Players p
INNER JOIN Teams t
ON p.TeamId = t.TeamId
WHERE t.TeamId = 5
-- Vrsta pretrazivanja: Bitmap Index Scan on idx_team_id
-- Cost=0.00..4.3
--Rows: 5
--ExecutionTime : 0.114ms
	
-- 4. Upit
CREATE INDEX idx_tournament_id ON Matches(TournamentId);
	
EXPLAIN ANALYZE
SELECT m.Date, 
	m.Time, 
	teh.TeamName, 
	tea.TeamName, 
	mt.MatchTypeName, 
	HomeScore, 
	AwayScore 
FROM Matches m
INNER JOIN Tournaments t ON m.TournamentId = t.TournamentId
INNER JOIN Teams teh ON m.HomeTeamId = teh.TeamId
INNER JOIN Teams tea ON m.AwayTeamId = tea.TeamId
INNER JOIN MatchTypes mt ON m.MatchTypeId = mt.MatchTypeId
WHERE t.TournamentId = 5;
-- Vrsta pretrazivanja: Bitmap Index Scan on idx_tournament_id
-- Cost=0.00..4.32
--Rows: 6
--ExecutionTime : 0.613ms
-- iako je execution time veci bolje je koristit index jer je cost manji

-- 5. Upit
--CREATE INDEX idx_home_team_id ON Matches(HomeTeamId);
--CREATE INDEX idx_away_team_id ON Matches(AwayTeamId);

EXPLAIN ANALYZE
SELECT MatchId, teh.TeamName, tea.TeamName, HomeScore, AwayScore, tt.ReachedStage 
FROM Matches m
INNER JOIN Teams teh ON m.HomeTeamId = teh.TeamId
INNER JOIN Teams tea ON m.AwayTeamId = tea.TeamId
INNER JOIN Tournaments t ON m.TournamentId = t.TournamentId
INNER JOIN TournamentsTeams tt ON tt.TournamentId = m.TournamentId AND tt.TeamId = 5
WHERE m.HomeTeamId = 5 OR m.AwayTeamId = 5;
-- isto
--indexi na Matches(HomeTeamId) i na Matches(AwayTeamId)
-- ne pomazu svejedno se uzme seq scan, vjv zbog OR

-- 6. Upit
CREATE INDEX idx_match_id ON Events(MatchId);
	
EXPLAIN ANALYZE
SELECT MatchId,
	EventType,
	p.PlayerFirstName,
	p.PlayerLastName
FROM Events e
INNER JOIN Players p ON e.PlayerId = p.PlayerId
WHERE MatchId = 5;
-- Vrsta pretrazivanja: Bitmap Index Scan on idx_match_id 
-- Cost=0.00..4.50
--ExecutionTime : 3.005ms

-- 7. Upit
CREATE INDEX idx_event_type ON Events(EventType);

EXPLAIN ANALYZE
SELECT t.TournamentId,
	e.MatchId,
	p.PlayerFirstName,
	p.PlayerLastName,
	te.TeamName,
	e.EventType,
	e.MinutesOfEvent
FROM Events e
INNER JOIN Players p on p.PlayerId = e.PlayerId 
INNER JOIN Teams te on te.TeamId = p.TeamId
INNER JOIN Matches m on m.MatchId = e.MatchId
INNER JOIN Tournaments t ON t.TournamentId = m.TournamentId
WHERE t.TournamentId = 5 
	AND e.EventType IN ('yellow card', 'red card');
-- Vrsta pretrazivanja: Bitmap Index Scan on idx_event_type i Bitmap Index Scan on idx_tournament_id
-- cost=0.00..16.03 za eventType
--ExecutionTime : 0.926ms

-- 8. Upit
EXPLAIN ANALYZE
SELECT p.PlayerFirstName, p.PlayerLastName, COUNT(*), t.TeamName
FROM Events e
INNER JOIN Players p ON e.PlayerId = p.PlayerId
INNER JOIN Teams t ON p.TeamId = t.TeamId 
INNER JOIN Matches m ON e.MatchId = m.MatchId 
WHERE e.EventType = 'goal' 
	AND m.TournamentId = 5
GROUP BY p.PlayerId, t.TeamName
-- Vrsta pretrazivanja: Koristi idx_tournament_id i idx_match_id
-- ali zbog group by nece puno pomoc indexe na eventtype
-- Cost: 0.00...657.85
--ExecutionTime : 1.615ms
	
-- 9.Upit
EXPLAIN ANALYZE
SELECT t.TeamName,
	tt.Points,
	tt.ScoredGoals,
    tt.ConcededGoals,
	tt.ScoredGoals - tt.ConcededGoals,
	tt.ReachedStage
FROM TournamentsTeams tt
INNER JOIN Teams t ON tt.TeamId = t.TeamId
WHERE tt.TournamentId = 5;
-- Vrsta pretrazivanja: Seq Scan za Teams i index za TournamentsTeams
--ExecutionTime : 0.280ms

-- 10. Upit
--CREATE INDEX idx_match_type_id ON Matches(MatchTypeId);

EXPLAIN ANALYZE
SELECT
    t.TournamentName,
    t.YearOfMaintenance,
    MatchId,
    th.TeamName AS HomeTeam,
    ta.TeamName AS AwayTeam,
    HomeScore,
    AwayScore,
    CASE
        WHEN m.HomeScore > m.AwayScore THEN th.TeamName
        WHEN m.AwayScore > m.HomeScore THEN ta.TeamName
        ELSE 'Draw' END
FROM Matches m
JOIN MatchTypes mt ON m.MatchTypeId = mt.MatchTypeId
JOIN Tournaments t ON m.TournamentId = t.TournamentId
JOIN Teams th ON m.HomeTeamId = th.TeamId
JOIN Teams ta ON m.AwayTeamId = ta.TeamId
WHERE MatchTypeName = 'final';
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 1.623ms
--index ne pomaze svejedno koristi seq scan

-- 11. Upit
EXPLAIN ANALYZE
SELECT mt.MatchTypeName, COUNT (*)
FROM Matches m
INNER JOIN MatchTypes mt  ON m.MatchTypeId = mt.MatchTypeId 
GROUP BY mt.MatchTypeId
-- isto
	
-- 12. Upit
CREATE INDEX idx_date ON Matches(Date);
	
EXPLAIN ANALYZE
SELECT Date, th.TeamName, ta.TeamName, mt.MatchTypeName, HomeScore, AwayScore
FROM Matches m
INNER JOIN Teams th ON m.HomeTeamId = th.TeamId
INNER JOIN Teams ta ON m.AwayTeamId = ta.TeamId
INNER JOIN MatchTypes mt ON m.MatchTypeId =mt.MatchTypeId
WHERE Date = '1968-08-26'
-- Vrsta pretrazivanja: Bitmap Index Scan on idx_date  
-- Cost=0.00..4.26 
-- ExecutionTime : 0.848ms
	
-- 13. Upit
EXPLAIN ANALYZE
SELECT m.TournamentId,
	p.PlayerFirstName,
	p.PlayerLastName,
	COUNT(*) AS Goals
FROM Events e
INNER JOIN Players p ON e.PlayerId = p.PlayerId
INNER JOIN Matches m ON e.MatchId = m.MatchId
WHERE m.TournamentId = 5 AND e.EventType = 'goal'
GROUP BY m.TournamentId, p.PlayerId
ORDER BY Goals DESC
-- Vrsta pretrazivanja: Bitmap Index Scan on idx_tournament_id i Index Scan using idx_match_id on events e  
-- ExecutionTime : 0.880 ms
-- EventType nema velik utjecaj
	
-- 14. Upit
CREATE INDEX idx_tournament_team_id ON TournamentsTeams(TeamId)
	
EXPLAIN ANALYZE
SELECT t.TournamentName,
	t.YearOfMaintenance,
	ReachedStage
FROM TournamentsTeams tt
INNER JOIN Tournaments t ON tt.TournamentId = t.TournamentId
WHERE TeamId = 5;
-- Vrsta pretrazivanja: Bitmap Index Scan on idx_tournament_team_id
--ExecutionTime : 0.303ms

-- 15. Upit
EXPLAIN ANALYZE
SELECT t.TeamId, t.TeamName, Points
FROM TournamentsTeams tt
INNER JOIN Teams t ON tt.TeamId = t.TeamId
WHERE TournamentId = 5
ORDER BY Points DESC, 
	(ScoredGoals - ConcededGoals) DESC
LIMIT 1
--istpo

-- 16. Upit
EXPLAIN ANALYZE
SELECT t.TournamentId,
	t.TournamentName,
	COUNT(DISTINCT tt.TeamId),
	COUNT(DISTINCT p.PlayerId) 
FROM Tournaments t
INNER JOIN TournamentsTeams tt ON t.TournamentId = tt.TournamentId
INNER JOIN Players p ON tt.TeamId = p.TeamId
GROUP BY t.TournamentId, t.TournamentName
-- isto
	
-- 17. Upit
EXPLAIN ANALYZE
SELECT DISTINCT ON (TeamId)
    TeamName,
    PlayerFirstName,
    PlayerLastName,
    GoalsScored
FROM (
	SELECT t.TeamId,
		TeamName,
		PlayerFirstName,
		PlayerLastName,
		COUNT(*) AS GoalsScored
	FROM Events e
	INNER JOIN Players p ON p.PlayerId = e.PlayerId
	INNER JOIN Teams t ON p.TeamId = t.TeamId
	WHERE EventType = 'goal'
	GROUP BY t.TeamId, t.TeamName, p.PlayerId, p.PlayerFirstName, p.PlayerLastName
) sub
ORDER BY TeamId, GoalsScored DESC
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 56.667
-- ne koristi index na eventtype
	
-- 18. Upit
CREATE INDEX idx_referee_id ON Matches(RefereeId);

EXPLAIN ANALYZE
SELECT r.RefereeFirstName,
	r.RefereeLastName,
	MatchId,
	th.TeamName,
	ta.TeamName,
	Date,
	Time
FROM Matches m
INNER JOIN Referees r ON m.RefereeId = r.RefereeId
INNER JOIN Teams th ON m.HomeTeamId = th.TeamId
INNER JOIN Teams ta ON m.AwayTeamId = ta.TeamId
WHERE m.RefereeId = 5;
-- Vrsta pretrazivanja: Index Scan using idx_referee_id  
-- Cost=0.28..8.38
--ExecutionTime : 0.866ms









