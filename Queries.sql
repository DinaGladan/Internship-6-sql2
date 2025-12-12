-- 1. Prikaži popis svih turnira
-- Prikazati naziv turnira, godinu održavanja, mjesto i ukupnog pobjednika.

SELECT TournamentName,
	YearOfMaintenance,
	PlaceOfMaintenance,
	WinnerTeamId 
FROM Tournaments t
LEFT JOIN Teams tm
ON t.WinnerTeamId = tm.TeamId

-- 2.Prikaži sve timove koji sudjeluju na određenom turniru
-- Za zadani turnir izlistati sve timove i predstavnika tima. 

SELECT TournamentId, TeamName, Representative
FROM TournamentsTeams tt
INNER JOIN Teams t
ON tt.TeamId = t.TeamId
WHERE  tt.TournamentId = 5

-- 3. Prikazi sve igrace iz odredjenog tima
-- Izvući popis svih igrača, njihove godine rođenja i ostale podatke.

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

-- 4. Prikazi sve utakmice odredjenog turnira
-- Prikazati datume, vrijeme, timove koji igraju, vrstu utakmice i rezultat. 

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
WHERE t.TournamentId = 5; --popravi vrijeme utakmice s vremenom turnira

-- 5. Prikazi sve utakmice određenog tima kroz sve turnire
-- Izvući sve utakmice u kojima je tim sudjelovao, s rezultatima i fazama natjecanja. 

SELECT MatchId, teh.TeamName, tea.TeamName, HomeScore, AwayScore, tt.ReachedStage 
	FROM Matches m
INNER JOIN Teams teh ON m.HomeTeamId = teh.TeamId
INNER JOIN Teams tea ON m.AwayTeamId = tea.TeamId
INNER JOIN Tournaments t ON m.TournamentId = t.TournamentId
INNER JOIN TournamentsTeams tt ON tt.TournamentId = m.TournamentId AND tt.TeamId = 5
WHERE m.HomeTeamId = 5 OR m.AwayTeamId = 5;

-- 6. Izlistati sve događaje (golovi, kartoni) za određenu utakmicu
-- Prikazati tip događaja, ime igrača koji ga je ostvario.

SELECT MatchId,
	EventType,
	p.PlayerFirstName,
	p.PlayerLastName
FROM Events e
INNER JOIN Players p ON e.PlayerId = p.PlayerId
WHERE MatchId = 5;

-- 7. Prikazi sve igrace koji su dobili zuti ili crveni karton na cijelom turniru
-- S navedenim timom, utakmicom i minutom. 

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

-- 8. Prikazi sve strijelce turnira
-- Izvući igrače koji su postigli pogodak, broj golova te tim. 

SELECT p.PlayerFirstName, p.PlayerLastName, COUNT(*), t.TeamName
FROM Events e
INNER JOIN Players p ON e.PlayerId = p.PlayerId
INNER JOIN Teams t ON p.TeamId = t.TeamId 
INNER JOIN Matches m ON e.MatchId = m.MatchId 
WHERE e.EventType = 'goal' 
	AND m.TournamentId = 5
GROUP BY p.PlayerId, t.TeamName

-- 9. Prikazi tablicu bodova za odredjeni turnir
-- Za svaki tim izlistati broj osvojenih bodova, gol razliku i plasman. 

SELECT t.TeamName,
	tt.Points,
	tt.ScoredGoals,
    tt.ConcededGoals,
	tt.ScoredGoals - tt.ConcededGoals,
	tt.ReachedStage
FROM TournamentsTeams tt
INNER JOIN Teams t ON tt.TeamId = t.TeamId
WHERE tt.TournamentId = 5;

-- 10. Prikaži sve finalne utakmice u povijesti
-- Izvući utakmice čija je faza “finale” i prikazati pobjednika. 

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

-- 11. Prikazi sve vrste utakmica
-- Npr. grupna faza, četvrtfinale, polufinale, finale – s brojem utakmica te vrste. 

SELECT mt.MatchTypeName, COUNT (*)
FROM Matches m
INNER JOIN MatchTypes mt  ON m.MatchTypeId = mt.MatchTypeId 
GROUP BY mt.MatchTypeId

-- 12. Prikazi sve utakmice odigrane na odredjeni datum
-- Prikazati timove, vrstu utakmice i rezultat.

SELECT Date, th.TeamName, ta.TeamName, mt.MatchTypeName, HomeScore, AwayScore
FROM Matches m
INNER JOIN Teams th ON m.HomeTeamId = th.TeamId
INNER JOIN Teams ta ON m.AwayTeamId = ta.TeamId
INNER JOIN MatchTypes mt ON m.MatchTypeId =mt.MatchTypeId
WHERE Date = '1968-08-26'

-- 13. Prikazi igrace koji su postigli najvise golova na odredjenom turniru
-- Sortirati po broju golova silazno. 

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

-- 14. Prikazi sve turnire na kojima je određeni tim sudjelovao
-- Za svaki turnir navesti godinu održavanja i ostvareni plasman. 

SELECT t.TournamentName,
	t.YearOfMaintenance,
	ReachedStage
FROM TournamentsTeams tt
INNER JOIN Tournaments t ON tt.TournamentId = t.TournamentId
WHERE TeamId = 5;

-- 15. Pronadji pobjednika turnira na temelju odigranih utakmica
-- Izvući tim s najviše bodova ili pobjednika finala, ovisno o strukturi turnira. 

SELECT t.TeamId, t.TeamName, Points
FROM TournamentsTeams tt
INNER JOIN Teams t ON tt.TeamId = t.TeamId
WHERE TournamentId = 5
ORDER BY Points DESC, 
	(ScoredGoals - ConcededGoals) DESC
LIMIT 1






