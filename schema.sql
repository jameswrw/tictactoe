-- 1. Clean up existing tables if resetting (Optional)
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS matches CASCADE;

-- 2. Create tables with proper constraints
CREATE TABLE players (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    player_1_id INT NOT NULL REFERENCES players(user_id),
    player_2_id INT NOT NULL REFERENCES players(user_id),
    winner_id INT NOT NULL REFERENCES players(user_id),
    created_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT different_players
        CHECK (player_1_id <> player_2_id),

    CONSTRAINT winner_is_participant
        CHECK (winner_id IN (player_1_id, player_2_id))
);


-- 3. Add Indexes for Query Performance
-- CREATE INDEX idx_player_1_id ON orders(player_1_id);
