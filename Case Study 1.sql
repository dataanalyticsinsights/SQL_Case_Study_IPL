SELECT * 
FROM N.IPLPlayers;

# Q1: Find the total spending on players for each team:
SELECT Team, SUM(price_in_cr) AS `Total Spending`
FROM IPLPlayers
GROUP BY Team
ORDER BY `Total Spending` DESC;

# Q2: Find the top 3 highest-paid 'ALL -rounders' across all teams: 
SELECT Player, Team, Price_in_cr
FROM IPLPlayers 
WHERE Role = 'All-rounder'
ORDER BY Price_in_cr DESC
LIMIT 3

# Q3: Find the highest-priced player in each team 
SELECT *
FROM IPLPlayers 
ORDER BY Price_in_cr DESC;

WITH CTE_MP AS (
    SELECT 
        Team, 
        MAX(Price_in_cr) AS MaxPrice
    FROM IPLPlayers
    GROUP BY Team
)

SELECT 
    i.Team,
    i.Player,
    c.MaxPrice
FROM IPLPlayers i
JOIN CTE_MP c 
    ON i.Team = c.Team
WHERE i.Price_in_cr = c.MaxPrice #Only keep players whose price equals team max
ORDER BY c.MaxPrice DESC;
# 'Lucknow Super Giants', 'Rishabh Pant', '27.00' 

# Q4: Rank players by their price within each team and list the top 2 for every team;
SELECT *
FROM IPLPlayers 
ORDER BY Team 

WITH RankedPlayers AS (
SELECT Player, Team, Price_in_cr,
ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Rank_Within_Team
FROM IPLPlayers
)
SELECT Player, Team, Price_in_cr, Rank_Within_Team
FROM RankedPlayers
WHERE  Rank_Within_Team <=2

# Find the most expensive player from the each team, along with the second most expensive player's name and peice 
# Data Format will be changed
# I want single raw for each team. Will use Group By
# I use case statement to create columns

WITH RankedPlayers AS (
	SELECT Player, Team, Price_in_cr,
	ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Rank_Within_Team
	FROM IPLPlayers
)

SELECT Team,
	MAX(CASE WHEN Rank_Within_Team = 1 THEN Player END) AS Most_Expensive_Player,
    MAX(CASE WHEN Rank_Within_Team = 1 THEN Price_in_cr END) AS Highest_Price,
    MAX(CASE WHEN Rank_Within_Team = 2 THEN Player END) AS Second_Expensive_Player,
    MAX(CASE WHEN Rank_Within_Team = 2 THEN Price_in_cr END) AS Second_Highest_Price
FROM RankedPlayers
GROUP BY Team

# Q6: Calculate the percentage contribution of each player's price to their team's total spending
SELECT 
    Player,
    Team,
    Price_in_cr,
    CAST(
        (Price_in_cr / SUM(Price_in_cr) OVER (PARTITION BY Team)) * 100
        AS DECIMAL(10,2)
    ) AS ContributionPercentage
FROM IPLPlayers;

-- Q7: Classify players as High, Medium, or Low priced
SELECT Team, Player, Price_in_cr,
	CASE
    WHEN Price_in_cr > 15 THEN 'High'
    WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
    ELSE 'Low'
   END AS PriceCategory
   FROM IPLPlayers
# Now for each of the player and each of the team, we have a PriceCate

-- High: Price > 15 crore
-- Medium: Price between 5 crore and 15 crore
-- Low: Price < 5 crore
WITH CTE_BR AS(
SELECT Team, Player, Price_in_cr,
	CASE
    WHEN Price_in_cr > 15 THEN 'High'
    WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
    ELSE 'Low'
   END AS PriceCategory
   FROM IPLPlayers
   )
   SELECT Team, PriceCategory
   FROM CTE_BR
GROUP BY Team, PriceCategory
# now we see 3 rows for each of the team because we have grouped by on the basis of the team and PriceCategory

-- Find the number of players in each bracket
WITH CTE_BR AS(
SELECT Team, Player, Price_in_cr,
	CASE
    WHEN Price_in_cr > 15 THEN 'High'
    WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
    ELSE 'Low'
    END AS PriceCategory
    FROM IPLPlayers
)
SELECT Team, PriceCategory, COUNT(*) AS `NoOfPlayers`
FROM CTE_BR
GROUP BY Team, PriceCategory
ORDER BY Team, PriceCategory
# Now in high category we have 3 players in the low 18. In the medium we have 5. Now all info is in a single block.

# Q8: Find the average price of Indian players and compare it with overseas players using a subquery: 
# Find which column is Indian and from which overseas

SELECT * FROM IPLPlayers

SELECT AVG(Price_in_cr) AS AVGPrice
FROM IPLPlayers
WHERE Type LIKE 'Indian%';


SELECT AVG(Price_in_cr) AS AVGPrice
FROM IPLPlayers
WHERE Type LIKE 'Overseas%';

# we need to use 'Union' function to see it clearly.
SELECT * FROM IPLPlayers

SELECT 
    'Indian' AS PlayerType,
    AVG(Price_in_cr) AS AVGPrice
FROM IPLPlayers
WHERE Type LIKE 'Indian%'

UNION ALL

SELECT 
    'Overseas' AS PlayerType,
    AVG(Price_in_cr) AS AVGPrice
FROM IPLPlayers
WHERE Type LIKE 'Overseas%';
# now we can see united table 

# Q9: Identify players who earn more than the average price in their team:
SELECT *
FROM IPLPlayers

SELECT 
	Player,
	Team,
	Price_in_cr
FROM IPLPlayers i
WHERE Price_in_cr > (
	SELECT AVG(Price_in_cr)
	FROM IPLPlayers
	WHERE Team = i.Team
);

# Q10: For each role, find the most expensive player and their price using a correlated subquery
SELECT *
FROM IPLPlayers

# I want to find the name of who is better and what is the price for that:
SELECT MAX(Price_in_cr)
FROM IPLPlayers
WHERE Role = 'Batter'

# Answer
SELECT Player, Team, Role, Price_in_cr
FROM IPLPlayers
WHERE Price_in_cr = (
					SELECT MAX(Price_in_cr)
					FROM IPLPlayers
					WHERE Role = 'Batter'
					)
                    
# we can find maximum price for this role                    
SELECT Player, Team, Role, Price_in_cr
FROM IPLPlayers i
WHERE Price_in_cr = (
					SELECT MAX(Price_in_cr)
					FROM IPLPlayers
					WHERE Role = i.Role
					)

