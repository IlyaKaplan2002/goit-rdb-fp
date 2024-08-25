-- CREATE SCHEMA pandemic;

USE pandemic;

SELECT * FROM infectious_cases LIMIT 50;

SELECT * FROM infectious_cases LIMIT 50;

SELECT max(Length(Entity)), max(Length(Code)) FROM infectious_cases;

CREATE TABLE IF NOT EXISTS country (
    id int auto_increment primary key,
    entity varchar(34) not null,
    code varchar(8) not null
);

-- insert into country (entity, code)
-- SELECT DISTINCT entity, code FROM infectious_cases;

SELECT count(*), count(distinct entity, code) FROM country;

SELECT count(distinct entity, code) FROM infectious_cases;

CREATE TABLE infectious_cases_norm LIKE infectious_cases;

ALTER TABLE infectious_cases_norm ADD COLUMN country_id int first;

ALTER TABLE infectious_cases_norm
DROP COLUMN Entity,
DROP COLUMN Code;

ALTER TABLE infectious_cases_norm
ADD CONSTRAINT infectious_cases_norm_country_fk FOREIGN KEY (country_id) REFERENCES country (id);

ALTER TABLE infectious_cases_norm
ADD COLUMN inf_id int auto_increment primary key first;

INSERT INTO
    infectious_cases_norm (
        country_id,
        Year,
        Number_yaws,
        polio_cases,
        cases_guinea_worm,
        Number_rabies,
        Number_malaria,
        Number_hiv,
        Number_tuberculosis,
        Number_smallpox,
        Number_cholera_cases
    ) (
        SELECT
            id,
            Year,
            Number_yaws,
            polio_cases,
            cases_guinea_worm,
            Number_rabies,
            Number_malaria,
            Number_hiv,
            Number_tuberculosis,
            Number_smallpox,
            Number_cholera_cases
        FROM
            infectious_cases as ic
            INNER JOIN country as c on ic.Entity = c.entity
            and ic.Code = c.Code
    );
-- truncate infectious_cases_norm;
SELECT * FROM infectious_cases_norm;

SELECT
    country_id,
    AVG(Number_rabies) average,
    MIN(Number_rabies) minimum,
    MAX(Number_rabies) maximum,
    SUM(Number_rabies) summ
FROM infectious_cases_norm
WHERE
    Number_rabies IS NOT NULL
    AND Number_rabies <> ''
GROUP BY
    country_id
ORDER BY average desc
LIMIT 10;

SELECT
    Year,
    makedate(Year, 1) first_day1,
    curdate() cur_day1,
    TIMESTAMPDIFF(
        Year,
        makedate(Year, 1),
        curdate()
    ) as diff_years1
FROM infectious_cases_norm;

ALTER TABLE infectious_cases_norm
ADD COLUMN first_day DATE,
ADD COLUMN cur_day DATE,
ADD COLUMN diff_years INT;

SELECT year, first_day, cur_day, diff_years
FROM infectious_cases_norm;

SELECT @@sql_safe_updates;

SET @@sql_safe_updates = 0;

UPDATE infectious_cases_norm SET first_day = makedate(Year, 1);

SELECT year, first_day, cur_day, diff_years
FROM infectious_cases_norm;

UPDATE infectious_cases_norm SET cur_day = curdate();

SELECT year, first_day, cur_day, diff_years
FROM infectious_cases_norm;

UPDATE infectious_cases_norm
SET
    diff_years = TIMESTAMPDIFF(
        Year,
        makedate(Year, 1),
        curdate()
    );

SELECT year, first_day, cur_day, diff_years
FROM infectious_cases_norm;

DROP FUNCTION IF EXISTS diff_years;

delimiter / /

CREATE FUNCTION diff_years(num year)
RETURNS INT 
DETERMINISTIC 
NO SQL

BEGIN
 RETURN TIMESTAMPDIFF(Year, makedate(num, 1), curdate());
END //

delimiter;

SELECT year, diff_years (year) FROM infectious_cases_norm;

ALTER TABLE infectious_cases_norm ADD COLUMN diff_years1 INT;

UPDATE infectious_cases_norm SET diff_years1 = diff_years (year);

SELECT year, diff_years, diff_years1 FROM infectious_cases_norm;