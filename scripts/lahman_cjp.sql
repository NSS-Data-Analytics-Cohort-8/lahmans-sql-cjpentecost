SELECT *
FROM people;

SELECT *
FROM batting;

SELECT *
FROM pitching;

SELECT *
FROM fielding;

SELECT *
FROM teams;

SELECT *
FROM teamsfranchises;

SELECT *
FROM appearances;

SELECT *
FROM collegeplaying;

SELECT *
FROM schools;

SELECT *
FROM salaries;

SELECT *
FROM homegames;

-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(yearid) AS min_yearid, MAX(yearid) AS max_yearid
FROM pitching;
--1871 to 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT namegiven, namelast, g_all, t.name, MIN(height) AS shortest
FROM people AS p
LEFT JOIN appearances AS a
USING (playerid)
LEFT JOIN teams AS t
ON a.teamid = t.teamid
GROUP BY namegiven, namelast,g_all, t.name
ORDER BY shortest ASC
LIMIT 1;
--Edward C Gaedel, played 1 game for ST Louis Browns 
--takes a sec for this to run, could try using ON in both places instead or try a subquery


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT namegiven, namelast, SUM(salary) AS total_salary
FROM people
LEFT JOIN salaries
USING (playerid)
LEFT JOIN collegeplaying
USING (playerid)	
WHERE playerid IN 
(SELECT DISTINCT(playerid)
	FROM collegeplaying
	LEFT JOIN schools
	USING (schoolid)
	WHERE schoolname = 'Vanderbilt University')
	GROUP BY namegiven, namelast
ORDER BY total_salary DESC;
--David Taylor Price, really large # - not convinced this is correct (bc i have not checked it) but want to move on. 


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT SUM(po), 
CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
	WHEN pos IN ('P','C') THEN 'Battery'
	END AS Position
FROM fielding
WHERE yearid = '2016'
GROUP BY position;
  
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
--Strikeouts
SELECT ROUND(CAST(SUM(so) AS numeric)/CAST(SUM(g)/2 AS numeric),2) AS avg_strikeout_per_game, 
CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
	END AS decade
FROM teams
GROUP BY decade
ORDER BY decade;

-- HomeRuns 
SELECT ROUND(CAST(SUM(hr) AS numeric)/CAST(SUM(g)/2 AS numeric),2) AS avg_HR_per_game,
CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
	END AS decade
FROM teams
GROUP BY decade
ORDER BY decade;
--Avg HR peaked in 2000's, avg SO significatntly higher and peaked in 2010's but for the most part has upward trend since the 60s.

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT p.namefirst, p.namelast,
       CAST(b.sb AS FLOAT) / (b.sb + b.cs ) AS success_rate
FROM batting b
JOIN people p ON b.playerid = p.playerid
WHERE b.yearid = 2016 AND b.sb >= 20
ORDER BY success_rate DESC;
	

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT yearid, team,t.name, t.wswin, t.w AS wins
FROM homegames AS hg
LEFT JOIN teams AS t
ON hg.team = t.teamid
WHERE t.wswin = 'N' AND t.yearid BETWEEN 1970 AND 2016
ORDER BY wins DESC;
--largest # of wins for team that did not make it to WS, Seattle Mariners with 116

SELECT yearid,team, t.name, t.wswin, t.w AS wins
FROM homegames AS hg
INNER JOIN teams AS t
ON hg.team = t.teamid
WHERE t.wswin = 'Y' AND t.yearid BETWEEN 1970 AND 2016
ORDER BY wins;
--smallest # of wins for team that did make it to WS, LA Dodgers, 63 wins - reapeating data not sure why yet. Could have turned the where into a subquery.


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  