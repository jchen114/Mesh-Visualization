﻿
CREATE FUNCTION update_db(key INT, n_type INT, n_status boolean, loc location) RETURNS VOID AS
$$
BEGIN
    LOOP
        -- first try to update the key
        UPDATE current_table SET (node_status, location) = (n_status, loc) WHERE node_id = key;
        IF FOUND THEN
            RETURN;
        END IF;
        -- not there, so try to insert the key
        -- if someone else inserts the same key concurrently,
        -- we could get a unique-key failure
        BEGIN
            INSERT INTO current_table (node_id, node_status,location) VALUES (key, n_status, loc);
            RETURN;
        EXCEPTION WHEN unique_violation THEN
            -- do nothing, and loop to try the UPDATE again
        END;
    END LOOP;
END;
$$
LANGUAGE plpgsql;