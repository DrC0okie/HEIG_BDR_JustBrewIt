SET search_path TO justBrewIt;

DROP FUNCTION IF EXISTS updateBeginTimeProgression;

CREATE OR REPLACE FUNCTION updateBeginTimeProgression()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.begin_time = now();
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_begin_time_progression ON progression;

CREATE OR REPLACE TRIGGER update_begin_time_progression
    AFTER UPDATE ON progression
    FOR EACH ROW
    EXECUTE PROCEDURE updateBeginTimeProgression();