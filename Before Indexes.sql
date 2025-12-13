-- 1. Upit
EXPLAIN ANALYZE
SELECT TournamentName,
	YearOfMaintenance,
	PlaceOfMaintenance,
	WinnerTeamId 
FROM Tournaments t
LEFT JOIN Teams tm
ON t.WinnerTeamId = tm.TeamId
-- Vrsta pretrazivanja: Seq Scan
-- Cost: 0.00...4.00
--Rows: 1000
--ExecutionTime : 0.056ms

-- 2.Upit
EXPLAIN ANALYZE
SELECT TournamentId, TeamName, Representative
FROM TournamentsTeams tt
INNER JOIN Teams t
ON tt.TeamId = t.TeamId
WHERE  tt.TournamentId = 5
-- Index vec postoji zbog UNIQUE (TournamentId, TeamId)
--Vec se koristi index tournamentsteams_tournamentid_teamid_key
-- Vrsta pretrazivanja za tournamentsTeams: Bitmap Index Scan on TournamentsTeams
-- No za tablicu Teams je vrsta pretrazivanja: Seq Scan jer je brze od koristenja indexa
--ExecutionTime : 0.238ms
	
-- 3.Upit
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
-- Vrsta pretrazivanja: Seq Scan
-- Cost: 0.00...76.53
--Rows: 5
--ExecutionTime : 0.313ms
--filtrira kako bi pronasao podatke i mice 2997 redova
-- zbog toga indeks na Players(TeamId)
	
-- 4. Upit
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
-- Vrsta pretrazivanja: Seq Scan
-- Cost: 0.00...35.54
--Rows: 6
--ExecutionTime : 0.508ms
--filtrira kako bi pronasao podatke i mice 997 redova
-- zbog toga indeks na Matches(TournamentId)

-- 5. Upit
EXPLAIN ANALYZE
SELECT MatchId, teh.TeamName, tea.TeamName, HomeScore, AwayScore, tt.ReachedStage 
FROM Matches m
INNER JOIN Teams teh ON m.HomeTeamId = teh.TeamId
INNER JOIN Teams tea ON m.AwayTeamId = tea.TeamId
INNER JOIN Tournaments t ON m.TournamentId = t.TournamentId
INNER JOIN TournamentsTeams tt ON tt.TournamentId = m.TournamentId AND tt.TeamId = 5
WHERE m.HomeTeamId = 5 OR m.AwayTeamId = 5;
-- Vrsta pretrazivanja: Seq Scan za Matches, isti indeks kao prije za TournamentsTeams
-- Cost: 0.00...4.00
--Rows: 5
--ExecutionTime : 0.282ms
--filtrira kako bi pronasao podatke i mice 998 redova

-- 6. Upit
EXPLAIN ANALYZE
SELECT MatchId,
	EventType,
	p.PlayerFirstName,
	p.PlayerLastName
FROM Events e
INNER JOIN Players p ON e.PlayerId = p.PlayerId
WHERE MatchId = 5;
-- Vrsta pretrazivanja: Seq Scan za 
-- Cost: 0.00...657.00
--ExecutionTime : 3.403ms
--filtrira kako bi pronasao podatke i mice 31464 redova
-- zbog toga potreban indeks na Events(MatcId)

-- 7. Upit
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
-- Vrsta pretrazivanja: Seq Scan
-- Cost: 0.00...657.00
--ExecutionTime : 3.781ms
--filtrira kako bi pronasao podatke i mice 30508 redova
-- i za matches mice 995 redova 
-- zbog toga potreban indeks na Events(EventType) i na Matches(TournamentId)

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
-- Vrsta pretrazivanja: Seq Scan
-- Cost: 0.00...657.85
--ExecutionTime : 6.838ms
--filtrira kako bi pronasao podatke i mice 1000 redova
-- i za matches mice 997 redova 
	
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
--ExecutionTime : 1.230ms
-- Potreban index za filtriranje 'finala', mice 4 reda
-- zbog toga dodat indeks na Matches(MatchTypeId)

-- 11. Upit
EXPLAIN ANALYZE
SELECT mt.MatchTypeName, COUNT (*)
FROM Matches m
INNER JOIN MatchTypes mt  ON m.MatchTypeId = mt.MatchTypeId 
GROUP BY mt.MatchTypeId
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 0.549ms
-- nema where pa ni filtriranja, zbog toga index nece bit potreban 
	
-- 12. Upit
EXPLAIN ANALYZE
SELECT Date, th.TeamName, ta.TeamName, mt.MatchTypeName, HomeScore, AwayScore
FROM Matches m
INNER JOIN Teams th ON m.HomeTeamId = th.TeamId
INNER JOIN Teams ta ON m.AwayTeamId = ta.TeamId
INNER JOIN MatchTypes mt ON m.MatchTypeId =mt.MatchTypeId
WHERE Date = '1968-08-26'
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 0.476ms
-- Filtrira Matches  i mice 988 redova
-- zbog toga indeks na Matches(Date)
	
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
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 6.806ms
-- Filtrira eventType za 'goal', mice 1000 redova
	-- ode je isto potrebno na Events(EventType) i Matches(TournamentId)
	
-- 14. Upit
EXPLAIN ANALYZE
SELECT t.TournamentName,
	t.YearOfMaintenance,
	ReachedStage
FROM TournamentsTeams tt
INNER JOIN Tournaments t ON tt.TournamentId = t.TournamentId
WHERE TeamId = 5;
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 0.570ms
-- Filtrira TournamentsTeams  i odbacuje 1979 redaka
-- zbog toga potreban indeks TournamentsTeams(TeamId)

-- 15. Upit
EXPLAIN ANALYZE
SELECT t.TeamId, t.TeamName, Points
FROM TournamentsTeams tt
INNER JOIN Teams t ON tt.TeamId = t.TeamId
WHERE TournamentId = 5
ORDER BY Points DESC, 
	(ScoredGoals - ConcededGoals) DESC
LIMIT 1
--Vec se koristi index tournamentsteams_tournamentid_teamid_key
-- Vrsta pretrazivanja: Bitmap Index Scan on TournamentsTeams
--ExecutionTime : 0.281ms

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
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 6.623ms
-- Indeks ne bi pomoga jer nema where vec se preko group by mora sve proc
	
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
--ExecutionTime : 27.666ms
-- i ode je potreban indeks na Events(EventType)
	
-- 18. Upit
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
-- Vrsta pretrazivanja: Seq Scan
--ExecutionTime : 0.438ms
-- Filtrira Matches i mice 997 redova
-- zbog toga potreban indeks Matches(RefereeId)









