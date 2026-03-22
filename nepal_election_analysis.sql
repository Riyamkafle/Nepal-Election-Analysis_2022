-- Create the main project database for Nepal Federal Election 2022 analysis
CREATE DATABASE nepal_federal_election_2022;

-- Create the main fact table that stores candidate-level election results
CREATE TABLE federal_results (
    province TEXT,
    district TEXT,
    constituency TEXT,
    candidate TEXT,
    gender TEXT,
    party TEXT,
    symbol TEXT,
    votes INTEGER,
    rank INTEGER,
    remarks TEXT,
    election_year INTEGER
);

-- Load cleaned candidate-level election data from CSV into federal_results table
-- Replace the file path below with the correct path on your computer/server
COPY federal_results (
    province,
    district,
    constituency,
    candidate,
    gender,
    party,
    symbol,
    votes,
    rank,
    remarks,
    election_year
)
FROM 'C:/your_path/federal_2022_fptp_results_clean.csv'
DELIMITER ','
CSV HEADER;

-- Check whether the candidate-level data was loaded successfully
SELECT COUNT(*) AS total_rows
FROM federal_results;

-- Preview the first 10 rows from the federal_results table
SELECT *
FROM federal_results
LIMIT 10;

-- Create a supporting table to store national party vote totals and vote share percentage
CREATE TABLE party_vote_share (
    party TEXT,
    votes INTEGER,
    vote_share_pct NUMERIC
);

-- Create a supporting table to store national party vote totals and vote share percentage
CREATE TABLE party_vote_share (
    party TEXT,
    votes INTEGER,
    vote_share_pct NUMERIC
);

-- Load party-level vote share summary from CSV into party_vote_share table
-- Replace the file path below with the correct path on your computer/server
COPY party_vote_share (
    party,
    votes,
    vote_share_pct
)
FROM 'C:/your_path/party_vote_share.csv'
DELIMITER ','
CSV HEADER;

-- Check whether the party_vote_share data was loaded successfully
SELECT COUNT(*) AS total_rows
FROM party_vote_share;

-- Create a supporting table to store seat counts by province and party
CREATE TABLE seats_by_province_party (
    province TEXT,
    party TEXT,
    seats INTEGER
);

-- Load province-party seat count summary from CSV into seats_by_province_party table
-- Replace the file path below with the correct path on your computer/server
COPY seats_by_province_party (
    province,
    party,
    seats
)
FROM 'C:/your_path/seats_by_province_party.csv'
DELIMITER ','
CSV HEADER;

-- Check whether the seats_by_province_party data was loaded successfully
SELECT COUNT(*) AS total_rows
FROM seats_by_province_party;

-- Create a supporting table to compare party vote share and seat share
CREATE TABLE vote_vs_seat_share (
    party TEXT,
    votes INTEGER,
    vote_share_pct NUMERIC,
    seats_won INTEGER,
    seat_share_pct NUMERIC
);

-- Load vote share versus seat share comparison data from CSV into vote_vs_seat_share table
-- Replace the file path below with the correct path on your computer/server
COPY vote_vs_seat_share (
    party,
    votes,
    vote_share_pct,
    seats_won,
    seat_share_pct
)
FROM 'C:/your_path/vote_vs_seat_share.csv'
DELIMITER ','
CSV HEADER;




-- Check whether the vote_vs_seat_share data was loaded successfully
SELECT COUNT(*) AS total_rows
FROM vote_vs_seat_share;

-- Question 1:
-- Show how many seats each party won in the election
SELECT
    party,
    COUNT(*) AS seats_won
FROM federal_results
WHERE LOWER(remarks) = 'elected'
GROUP BY party
ORDER BY seats_won DESC;

-- Question 2:
-- Show the top 5 candidates who received the highest number of votes across the country
SELECT
    candidate,
    party,
    province,
    district,
    constituency,
    votes
FROM federal_results
ORDER BY votes DESC
LIMIT 5;

-- Question 3:
-- Show how many candidates contested from each province
SELECT
    province,
    COUNT(*) AS total_candidates
FROM federal_results
GROUP BY province
ORDER BY total_candidates DESC;

-- Question 4:
-- Show how many seats were won by each party in each province
SELECT
    province,
    party,
    COUNT(*) AS seats_won
FROM federal_results
WHERE LOWER(remarks) = 'elected'
GROUP BY province, party
ORDER BY province, seats_won DESC;


-- Question 4:
-- Show how many seats were won by each party in each province
SELECT
    province,
    party,
    COUNT(*) AS seats_won
FROM federal_results
WHERE LOWER(remarks) = 'elected'
GROUP BY province, party
ORDER BY province, seats_won DESC;

-- Question 5:
-- Show the winner and runner-up in each constituency along with their vote counts
WITH ranked_candidates AS (
    SELECT
        province,
        district,
        constituency,
        candidate,
        party,
        votes,
        ROW_NUMBER() OVER (
            PARTITION BY constituency
            ORDER BY votes DESC
        ) AS position_rank
    FROM federal_results
)
SELECT
    province,
    district,
    constituency,
    MAX(CASE WHEN position_rank = 1 THEN candidate END) AS winner_name,
    MAX(CASE WHEN position_rank = 1 THEN party END) AS winner_party,
    MAX(CASE WHEN position_rank = 1 THEN votes END) AS winner_votes,
    MAX(CASE WHEN position_rank = 2 THEN candidate END) AS runner_up_name,
    MAX(CASE WHEN position_rank = 2 THEN party END) AS runner_up_party,
    MAX(CASE WHEN position_rank = 2 THEN votes END) AS runner_up_votes
FROM ranked_candidates
WHERE position_rank <= 2
GROUP BY province, district, constituency
ORDER BY province, district, constituency;

-- Question 6:
-- Show the 10 closest races based on vote margin between winner and runner-up
WITH ranked_candidates AS (
    SELECT
        province,
        district,
        constituency,
        candidate,
        party,
        votes,
        ROW_NUMBER() OVER (
            PARTITION BY constituency
            ORDER BY votes DESC
        ) AS position_rank
    FROM federal_results
),
top_two AS (
    SELECT
        province,
        district,
        constituency,
        MAX(CASE WHEN position_rank = 1 THEN candidate END) AS winner_name,
        MAX(CASE WHEN position_rank = 1 THEN party END) AS winner_party,
        MAX(CASE WHEN position_rank = 1 THEN votes END) AS winner_votes,
        MAX(CASE WHEN position_rank = 2 THEN candidate END) AS runner_up_name,
        MAX(CASE WHEN position_rank = 2 THEN party END) AS runner_up_party,
        MAX(CASE WHEN position_rank = 2 THEN votes END) AS runner_up_votes
    FROM ranked_candidates
    WHERE position_rank <= 2
    GROUP BY province, district, constituency
)
SELECT
    province,
    district,
    constituency,
    winner_name,
    winner_party,
    winner_votes,
    runner_up_name,
    runner_up_party,
    runner_up_votes,
    winner_votes - runner_up_votes AS victory_margin
FROM top_two
ORDER BY victory_margin ASC
LIMIT 10;

-- Question 7:
-- Show the 10 most dominant wins based on the highest victory margin
WITH ranked_candidates AS (
    SELECT
        province,
        district,
        constituency,
        candidate,
        party,
        votes,
        ROW_NUMBER() OVER (
            PARTITION BY constituency
            ORDER BY votes DESC
        ) AS position_rank
    FROM federal_results
),
top_two AS (
    SELECT
        province,
        district,
        constituency,
        MAX(CASE WHEN position_rank = 1 THEN candidate END) AS winner_name,
        MAX(CASE WHEN position_rank = 1 THEN party END) AS winner_party,
        MAX(CASE WHEN position_rank = 1 THEN votes END) AS winner_votes,
        MAX(CASE WHEN position_rank = 2 THEN candidate END) AS runner_up_name,
        MAX(CASE WHEN position_rank = 2 THEN party END) AS runner_up_party,
        MAX(CASE WHEN position_rank = 2 THEN votes END) AS runner_up_votes
    FROM ranked_candidates
    WHERE position_rank <= 2
    GROUP BY province, district, constituency
)
SELECT
    province,
    district,
    constituency,
    winner_name,
    winner_party,
    winner_votes,
    runner_up_name,
    runner_up_party,
    runner_up_votes,
    winner_votes - runner_up_votes AS victory_margin
FROM top_two
ORDER BY victory_margin DESC
LIMIT 10;

-- Question 8:
-- Show how many elected winners were male and how many were female
SELECT
    gender,
    COUNT(*) AS winners_count
FROM federal_results
WHERE LOWER(remarks) = 'elected'
GROUP BY gender
ORDER BY winners_count DESC;


-- Question 9:
-- Show each party's total votes along with its national vote share percentage
WITH total_votes_all AS (
    SELECT
        SUM(votes) AS grand_total_votes
    FROM federal_results
)
SELECT
    fr.party,
    SUM(fr.votes) AS total_votes,
    ROUND(100.0 * SUM(fr.votes) / tva.grand_total_votes, 2) AS vote_share_pct
FROM federal_results fr
CROSS JOIN total_votes_all tva
GROUP BY fr.party, tva.grand_total_votes
ORDER BY total_votes DESC;

-- Question 10:
-- Show each party's seats won along with its national seat share percentage
WITH total_seats_all AS (
    SELECT
        COUNT(*) AS grand_total_seats
    FROM federal_results
    WHERE LOWER(remarks) = 'elected'
)
SELECT
    fr.party,
    COUNT(*) AS seats_won,
    ROUND(100.0 * COUNT(*) / tsa.grand_total_seats, 2) AS seat_share_pct
FROM federal_results fr
CROSS JOIN total_seats_all tsa
WHERE LOWER(fr.remarks) = 'elected'
GROUP BY fr.party, tsa.grand_total_seats
ORDER BY seats_won DESC;

-- Question 11:
-- Compare each party's national vote share and seat share in one result
WITH party_votes AS (
    SELECT
        party,
        SUM(votes) AS total_votes
    FROM federal_results
    GROUP BY party
),
overall_votes AS (
    SELECT
        SUM(votes) AS grand_total_votes
    FROM federal_results
),
party_seats AS (
    SELECT
        party,
        COUNT(*) AS seats_won
    FROM federal_results
    WHERE LOWER(remarks) = 'elected'
    GROUP BY party
),
overall_seats AS (
    SELECT
        COUNT(*) AS grand_total_seats
    FROM federal_results
    WHERE LOWER(remarks) = 'elected'
)
SELECT
    pv.party,
    pv.total_votes,
    COALESCE(ps.seats_won, 0) AS seats_won,
    ROUND(100.0 * pv.total_votes / ov.grand_total_votes, 2) AS vote_share_pct,
    ROUND(100.0 * COALESCE(ps.seats_won, 0) / os.grand_total_seats, 2) AS seat_share_pct
FROM party_votes pv
CROSS JOIN overall_votes ov
CROSS JOIN overall_seats os
LEFT JOIN party_seats ps
    ON pv.party = ps.party
ORDER BY seat_share_pct DESC, vote_share_pct DESC;

-- Question 12:
-- Show which parties are over-represented or under-represented by comparing seat share and vote share
WITH party_votes AS (
    SELECT
        party,
        SUM(votes) AS total_votes
    FROM federal_results
    GROUP BY party
),
overall_votes AS (
    SELECT
        SUM(votes) AS grand_total_votes
    FROM federal_results
),
party_seats AS (
    SELECT
        party,
        COUNT(*) AS seats_won
    FROM federal_results
    WHERE LOWER(remarks) = 'elected'
    GROUP BY party
),
overall_seats AS (
    SELECT
        COUNT(*) AS grand_total_seats
    FROM federal_results
    WHERE LOWER(remarks) = 'elected'
)
SELECT
    pv.party,
    ROUND(100.0 * pv.total_votes / ov.grand_total_votes, 2) AS vote_share_pct,
    ROUND(100.0 * COALESCE(ps.seats_won, 0) / os.grand_total_seats, 2) AS seat_share_pct,
    ROUND(
        (100.0 * COALESCE(ps.seats_won, 0) / os.grand_total_seats) -
        (100.0 * pv.total_votes / ov.grand_total_votes),
        2
    ) AS representation_gap_pct
FROM party_votes pv
CROSS JOIN overall_votes ov
CROSS JOIN overall_seats os
LEFT JOIN party_seats ps
    ON pv.party = ps.party
ORDER BY representation_gap_pct DESC;

-- Question 13:
-- Show the top 3 highest vote-getting candidates in each province using a window function
WITH ranked_candidates AS (
    SELECT
        province,
        district,
        constituency,
        candidate,
        party,
        votes,
        DENSE_RANK() OVER (
            PARTITION BY province
            ORDER BY votes DESC
        ) AS province_rank
    FROM federal_results
)
SELECT
    province,
    district,
    constituency,
    candidate,
    party,
    votes,
    province_rank
FROM ranked_candidates
WHERE province_rank <= 3
ORDER BY province, province_rank, votes DESC;

-- Question 14:
-- Show each party's strike rate, defined as seats won divided by number of candidates fielded
WITH candidates_fielded AS (
    SELECT
        party,
        COUNT(*) AS candidates_contested
    FROM federal_results
    GROUP BY party
),
seats_won AS (
    SELECT
        party,
        COUNT(*) AS seats_won
    FROM federal_results
    WHERE LOWER(remarks) = 'elected'
    GROUP BY party
)
SELECT
    cf.party,
    cf.candidates_contested,
    COALESCE(sw.seats_won, 0) AS seats_won,
    ROUND(
        100.0 * COALESCE(sw.seats_won, 0) / cf.candidates_contested,
        2
    ) AS strike_rate_pct
FROM candidates_fielded cf
LEFT JOIN seats_won sw
    ON cf.party = sw.party
WHERE cf.candidates_contested >= 5
ORDER BY strike_rate_pct DESC, seats_won DESC;

-- Question 15:
-- For each province, identify the leading party by seats won and compare it with the second-ranked party
WITH province_party_seats AS (
    SELECT
        province,
        party,
        COUNT(*) AS seats_won
    FROM federal_results
    WHERE LOWER(remarks) = 'elected'
    GROUP BY province, party
),
ranked_parties AS (
    SELECT
        province,
        party,
        seats_won,
        ROW_NUMBER() OVER (
            PARTITION BY province
            ORDER BY seats_won DESC
        ) AS seat_rank
    FROM province_party_seats
),
top_two AS (
    SELECT
        province,
        MAX(CASE WHEN seat_rank = 1 THEN party END) AS leading_party,
        MAX(CASE WHEN seat_rank = 1 THEN seats_won END) AS leading_seats,
        MAX(CASE WHEN seat_rank = 2 THEN party END) AS second_party,
        MAX(CASE WHEN seat_rank = 2 THEN seats_won END) AS second_seats
    FROM ranked_parties
    WHERE seat_rank <= 2
    GROUP BY province
)
SELECT
    province,
    leading_party,
    leading_seats,
    second_party,
    second_seats,
    leading_seats - second_seats AS seat_gap
FROM top_two
ORDER BY seat_gap DESC, province;