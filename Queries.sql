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

SELECT MatchId, mt.MatchTypeName, teh.TeamId, tea.TeamId, HomeScore, AwayScore  FROM Matches m
INNER JOIN Teams teh ON m.HomeTeamId = teh.TeamId
INNER JOIN Teams tea ON m.AwayTeamId = tea.TeamId
INNER JOIN MatchTypes mt ON m.MatchTypeId = mt.MatchTypeId
WHERE teh.TeamId = 5 OR tea.TeamId = 5;
















