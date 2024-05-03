-- View all the tables
SELECT * FROM IPL_ball_by_ball;
SELECT * FROM IPL_Matches;
SELECT * FROM IPL1;
SELECT * FROM IPL2;
SELECT * FROM IPL3;
SELECT * FROM IPL4;

-- Create a temporary table that is union of all the four datasets
SELECT * INTO #IPLS FROM
(SELECT * FROM IPL1 
UNION 
SELECT * FROM IPL2 
UNION
SELECT * FROM IPL3
UNION
SELECT * FROM IPL4) AS A;

-- Print the temporary table
SELECT* FROM #IPLS
SELECT COUNT(*) FROM #IPLS;

-- Matches per season
SELECT YEAR(CAST(match_date AS DATE)),COUNT(DISTINCT id) AS no_of_matches FROM IPL_Matches GROUP BY YEAR(CAST(match_date AS DATE));

-- Most player of match
SELECT player_of_match,COUNT(player_of_match) AS no_of_player_of_match FROM IPL_Matches GROUP BY player_of_match ORDER BY COUNT(player_of_match) DESC;

-- Most player of match per season
SELECT player_of_match , YEAR(CAST(match_date AS DATE)) , COUNT(player_of_match) FROM IPL_Matches GROUP BY player_of_match,YEAR(CAST(match_Date AS DATE)) ORDER BY COUNT(player_of_match) DESC;

-- Most wins by any team 
SELECT winner,COUNT(winner) AS team_wins FROM IPL_Matches GROUP BY winner ORDER BY COUNT(winner) DESC;

-- Top 5 venues where match is played
SELECT TOP 5 venue,COUNT(venue) AS top_venue FROM IPL_Matches GROUP BY venue ORDER BY COUNT(venue) DESC;

-- Most runs by any batsman
SELECT TOP 1 batsman,SUM(batsman_runs) AS total_runs FROM IPL_BALL_by_BALL GROUP BY batsman ORDER BY SUM(batsman_runs) DESC;

-- Total runs scored in IPL
SELECT SUM(total_runs) AS total_runs FROM #IPLS;

-- % of total runs scored by each batsman
SELECT batsman,(SUM(total_runs)/(SELECT SUM(total_runs) FROM IPL_Matches))*100 AS total_runs_percent FROM #IPLS GROUP BY batsman;

-- most sixes by any batsman
SELECT TOP 1 batsman,COUNT(batsman_runs) AS total_no_of_sixes FROM #IPLS WHERE batsman_runs=6 GROUP BY batsman ORDER BY COUNT(batsman_runs) DESC;

-- Most fours by any batsman
SELECT TOP 1 batsman,COUNT(batsman_runs) AS total_no_of_fours FROM #IPLS WHERE batsman_runs=4 GROUP BY batsman ORDER BY COUNT(batsman_runs) DESC;

-- 3000 runs club and highest strike rate
SELECT batsman,(SUM(total_runs)/COUNT(ball))*100 AS strike_rate FROM #IPLS GROUP BY batsman HAVING SUM(total_runs) >= 3000 ORDER BY strike_rate DESC ;

-- bowler with least economy rate and bowled 50 overs
SELECT bowler,SUM(batsman_runs)*1.0*6/COUNT(ball) AS economy FROM IPL_Ball_by_Ball GROUP BY bowler HAVING COUNT(ball) >= 300 ORDER BY economy ASC ;

-- Total number of matches till 2020
SELECT YEAR(CAST(match_date) AS DATE) , COUNT(id) AS no_of_matches FROM IPL_Matches WHERE YEAR(CAST(match_date) AS DATE) BETWEEN 2008 AND 2020  GROUP BY  YEAR(CAST(match_date) AS DATE);

-- Total number of matches win by each team
SELECT winner,COUNT(winner) AS win FROM IPL_Matches GROUP BY winner;

-- Does toss winning affect match winner 
SELECT COUNT(*) AS normal_count,(SELECT COUNT(*) FROM IPL_Matches WHERE toss_winner=winner) AS toss_and_match_win,(SELECT COUNT(*) FROM IPL_Matches WHERE toss_winner=winner)*1.0/(SELECT COUNT(*) FROM IPL_Matches)*100  AS favourable_percent FROM IPL_Matches; 

-- Average scores of each team per season
SELECT batting_team,YEAR(CAST(match_date) AS DATE),AVG(total_runs) AS avg_Score FROM #IPLS GROUP BY batting_team,YEAR(CAST(match_date) AS DATE);

-- How many times each team scored above 200 
SELECT batting_team,COUNT(id) AS no_of_times_Above_200 FROM (SELECT batting_team ,id FROM #IPLS GROUP BY batting_team,id HAVING SUM(total_runs)>200) AS A GROUP BY batting_team ORDER BY COUNT(id) DESC;

-- Top 10 players with most runs
SELECT TOP 10 batsman,SUM(batsman_runs) FROM #IPLS GROUP BY batsman ORDER BY SUM(batsman_runs) DESC;

-- TOP 10 bowlers till 2020
SELECT TOP 10 B.bowler,SUM(B.batsman_runs)*1.0*6/COUNT(B.ball) AS economy FROM IPL_Ball_by_Ball AS B INNER JOIN IPL_Matches AS M ON B.id = M.id WHERE YEAR(CAST(M.match_date AS DATE)) BETWEEN 2008 AND 2020 GROUP BY bowler HAVING COUNT(ball) >= 300 ORDER BY economy ASC;

-- Count of matches played in each season
SELECT YEAR(CAST(match_date AS DATE)) , COUNT(id) FROM IPL_Matches GROUP BY YEAR(CAST(match_date AS DATE));

-- How many runs were scored in each season
SELECT YEAR(CAST(B.match_date) AS DATE),SUM(A.total_runs) AS total_runs FROM #IPLS AS A INNER JOIN IPL_Matches AS B ON A.id = B.id GROUP BY YEAR(CAST(B.match_date AS DATE)) ORDER BY YEAR(CAST(B.match_date AS DATE)) ASC;

-- Runs sccored per match in different seasons
SELECT YEAR(CAST(B.match_date) AS DATE),id,SUM(A.total_runs) AS total_runs FROM #IPLS AS A INNER JOIN IPL_Matches AS B ON A.id = B.id GROUP BY YEAR(CAST(B.match_date AS DATE)),id;

-- Who has umpired the most 
SELECT TOP 1 COUNT(id) AS total_matches , umpire1 FROM
(SELECT id,umpire1 FROM IPL_Matches
UNION ALL
SELECT id,umpire2 FROM IPL_Matches) AS A GROUP BY umpire1 ORDER BY COUNT(id) DESC;

-- Which team has won most tosses
SELECT TOP 1 toss_winner,COUNT(toss_winner) AS most_toss_win FROM IPL_Matches GROUP BY toss_winner ORDER BY COUNT(toss_winner) DESC;

-- What team decides after winning the toss
SELECT toss_winner,toss_decision,COUNT(toss_decision) AS desicion_count FROM
(SELECT toss_winner,toss_decision FROM IPL_Matches) AS A GROUP BY toss_winner,toss_decision;

-- How toss decisions varies across seasons
SELECT toss_winner,toss_decision,YEAR(CAST(match_Date AS DATE)) AS season , COUNT(toss_decision) AS decision_count FROM
(SELECT toss_winner,toss_decision,YEAR(CAST(match_date AS DATE)) AS season FROM IPL_Matches) AS A GROUP BY toss_winner,toss_decision,YEAR(CAST(match_date AS DATE));

-- Does winning the toss implies winning the game 
SELECT COUNT(toss_winner) AS toss_winner,(SELECT COUNT(winner) FROM IPL_Matches WHERE toss_winner=winner) AS toss_and_match_winner ,((SELECT COUNT(winner) FROM IPL_Matches WHERE toss_winner=winner)*1.0/(SELECT COUNT(toss_winner) FROM IPL_Matches))*100 AS percent_of_toss_and_match_win FROM IPL_Matches;

-- How many times chasing team has won the match
SELECT result,COUNT(result) AS total_wins FROM IPL_Matches WHERE result='wickets' GROUP BY result;

-- Which team played most matches
SELECT TOP 1 COUNT(id) AS total_matches , team1 FROM
(SELECT id,team1 FROM IPL_Matches
UNION ALL
SELECT id,team2 FROM IPL_Matches) AS A GROUP BY team1 ORDER BY COUNT(id) DESC;

-- Which team has won most number of times
SELECT winner,COUNT(winner) FROM IPL_Matches GROUP BY winner ORDER BY COUNT(winner) DESC;

-- Which team has highest winning percentage 


-- Is there any lucky venue for a particular team
SELECT *  FROM
(SELECT winner,venue,COUNT(winner) AS no_of_wins,DENSE_RANK() OVER(PARTITION BY winner ORDER BY COUNT(winner) DESC) AS rank_val FROM IPL_Matches GROUP BY winner,venue) AS A WHERE rank_val=1;


-- Which team scored 200+ score the most 
SELECT batting_team,COUNT(batting_team) AS total_matches FROM
(SELECT batting_team,id FROM #IPLS GROUP BY batting_team,id HAVING SUM(total_runs) >200) AS A GROUP BY batting_team ORDER BY COUNT(batting_team) DESC;

-- Which team conceded 200+ runs the most
SELECT bowling_team ,COUNT(id) FROM
(SELECT bowling_team,id FROM #IPLS GROUP BY bowling_team,id HAVING SUM(total_runs) >200) AS A GROUP BY bowling_team ORDER BY COUNT(id) DESC;

-- What was highest runs scored by a single team in a match
SELECT batting_Team,id,SUM(total_runs) AS total_runs FROM #IPLS GROUP BY batting_team,id ORDER BY SUM(total_runs) DESC;

-- What is the biggest win in terms of win margin 
SELECT result,result_margin FROM IPL_Matches WHERE result='runs' ORDER BY result_margin DESC;

-- Which batsman have played the most number of balls
SELECT TOP 1 batsman,COUNT(ball) AS most_balls_played FROM IPL_Ball_by_Ball GROUP BY batsman ORDER BY COUNT(ball) DESC;

-- Who are the leading run scorers of all time
SELECT TOP 1 batsman,SUM(batsman_runs) AS total_runs FROM IPL_Ball_by_Ball GROUP BY batsman ORDER BY SUM(batsman_runs) DESC;

-- Who hit the most number of fours
SELECT batsman,COUNT(batsman_runs) FROM IPL_Ball_by_Ball WHERE batsman_runs=4 GROUP BY batsman ORDER BY COUNT(batsman_runs) DESC;

-- Who hit most number of sixes
SELECT batsman,COUNT(batsman_runs) FROM IPL_Ball_by_Ball WHERE batsman_runs=6 GROUP BY batsman ORDER BY COUNT(batsman_runs) DESC;

-- Who is leading wicket taker
SELECT TOP 1 bowler,COUNT(is_wicket) AS total_wickets FROM IPL_Ball_by_Ball WHERE is_wicket=1 GROUP BY bowler ORDER BY COUNT(is_wicket) DESC;

-- Which stadium has hosted most number of matches
SELECT venue,COUNT(id) AS total_matches_hosted FROM IPL_Matches GROUP BY venue ORDER BY COUNT(id) DESC;

-- Who has won most MOM awards 


-- What is count of fours hit in each season
SELECT YEAR(CAST(match_date AS DATE)), COUNT(batsman_runs) FROM IPL_Ball_by_Ball WHERE batsman_runs=4 GROUP BY YEAR(CAST(match_date AS DATE)) ORDER BY COUNT(batsman_runs) DESC;

-- What is count of fours hit in each season
SELECT YEAR(CAST(match_date AS DATE)), COUNT(batsman_runs) FROM IPL_Ball_by_Ball WHERE batsman_runs=6 GROUP BY YEAR(CAST(match_date AS DATE)) ORDER BY COUNT(batsman_runs) DESC;

-- What is count of runs scored from boundaries in each season avg and total runs 
SELECT YEAR(CAST(match_date AS DATE)),SUM(batsman_runs) AS runs , (SELECT SUM(batsman_runs) FROM IPL_Ball_by_Ball) FROM IPL_Ball_by_Ball WHERE batsman_runs IN (4,6) GROUP BY YEAR(CAST(match_date AS DATE)) ORDER BY SUM(batsman_runs) DESC;

-- Runs per over of each team 
SELECT batting_team,overs,SUM(total_runs) AS runs_per_over FROM IPL_Ball_by_Ball GROUP BY batting_team,overs ORDER BY overs ASC,SUM(total_runs) DESC;

-- Runs in powerplay of each match
SELECT id,SUM(total_runs) AS runs_in_powerplay_of_each_match FROM IPL_Ball_by_Ball WHERE OVERS IN (0,1,2,3,4,5) GROUP BY id ORDER BY SUM(total_runs) DESC;

-- Highest average and strike rate for > 50 matches.
SELECT batsman,(SUM(batsman_runs)/COUNT(ball))*100 AS strike_rate FROM IPL_Ball_by_Ball GROUP BY batsman HAVING COUNT(id)>50 ORDER BY (SUM(batsman_runs)/COUNT(ball))*100 DESC;

-- Top 10 batsman in each run category
SELECT batsman , batsman_runs , SUM(batsman_runs) AS runs_in_each_category , DENSE_RANK () OVER(PARTITION BY batsman_runs ORDER BY SUM(batsman_runs) DESC) AS rank FROM IPL_Ball_by_Ball WHERE batsman_runs != 0  GROUP BY batsman,batsman_runs ORDER BY batsman_runs ASC , SUM(batsman_runs) DESC;

-- Orange cap holders
SELECT B.batsman,YEAR(CAST(M.match_date AS DATE)),SUM(B.batsman_runs) FROM IPL_Ball_by_Ball AS B INNER JOIN IPL_Matches AS M ON B.id=M.id GROUP BY B.batsman,YEAR(CAST(M.match_date AS DATE)) ORDER BY SUM(B.batsman_runs) DESC;

-- Purple cap holders 
SELECT B.bowler,YEAR(CAST(M.match_date AS DATE)),SUM(B.is_wicket) FROM IPL_Ball_by_Ball AS B INNER JOIN IPL_Matches AS M ON B.id=M.id GROUP BY B.bowler,YEAR(CAST(M.match_date AS DATE)) ORDER BY COUNT(B.is_wicket) DESC;

