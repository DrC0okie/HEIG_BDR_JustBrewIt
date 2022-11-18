# HEIG_BDR_JustBrewIt

## Creation du schema

```sql
DROP SCHEMA IF EXISTS justBrewIt CASCADE;
CREATE SCHEMA justBrewIt;
SET search_path TO justBrewIt;

CREATE TYPE sex as ENUM('ms', 'mr', 'none');

CREATE TYPE category AS ENUM(
    'preparation',
    'beer_mash',
    'mash_out',
    'filtration',
    'measure',
    'boiling',
    'cooling',
    'fermentation',
    'bottling');

CREATE TYPE cereal AS ENUM(
    'barley',
    'wheat',
    'rye',
    'rice',
    'corn'
    );

CREATE TYPE hop_type AS ENUM(
    'aromatic',
    'bittering'
    );

CREATE TYPE fermentation_type AS ENUM(
    'high',
    'low'
    );

CREATE TYPE address AS (
    street varchar(32),
    street_number varchar(32),
    complement varchar(32),
    city_code varchar(16),
    city_name varchar(32));

CREATE TABLE customer (
    customer_id integer,
    first_name varchar(32) NOT NULL ,
    last_name varchar(32) NOT NULL ,
    sex sex NOT NULL DEFAULT 'none',
    address address NOT NULL ,
    e_mail_address varchar(32) UNIQUE NOT NULL,
    password varchar(32) NOT NULL ,
    PRIMARY KEY (customer_id));

CREATE TABLE beer(
    beer_id integer,
    name varchar(32) NOT NULL,
    color integer,
    alcohol real,
    bitterness integer,
    PRIMARY KEY (beer_id)
);

CREATE TABLE recipe(
    recipe_number integer,
    name varchar(32) NOT NULL,
    difficulty integer CONSTRAINT diffRange CHECK ( difficulty > 0 AND difficulty < 6 ),
    creator_id_fk integer NOT NULL,
    beer_id_fk integer UNIQUE NOT NULL,
    quantity integer, --Association entity
    FOREIGN KEY (beer_id_fk) REFERENCES beer(beer_id),
    FOREIGN KEY (creator_id_fk) REFERENCES customer(customer_id),
    PRIMARY KEY (recipe_number));

CREATE TABLE ingredient(
    ingredient_id integer,
    name varchar(32) NOT NULL ,
    origin varchar(32),
    sub_origin varchar(32),
    specificity text,
    quantity_unit varchar(8),
    price_per_unit real,
    PRIMARY KEY (ingredient_id)
);

CREATE TABLE brewing_step(
    step_number integer NOT NULL,
    step_name varchar(32) NOT NULL,
    duration real,
    step_description text,
    category category NOT NULL,
    recipe_number_fk int NOT NULL,
    FOREIGN KEY (recipe_number_fk) REFERENCES recipe(recipe_number),
    PRIMARY KEY (recipe_number_fk, step_number)
);

CREATE TABLE ingredient_usage(
    quantity real NOT NULL,
    step_number_fk integer NOT NULL,
    ingredient_id_fk integer,
    recipe_number_fk integer  NOT NULL,
    FOREIGN KEY (step_number_fk, recipe_number_fk) REFERENCES brewing_step(step_number, recipe_number_fk),
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id),
    PRIMARY KEY (step_number_fk, ingredient_id_fk, recipe_number_fk)
);

CREATE TABLE progression(
    begin_time timestamp,
    customer_id_fk integer,
    step_number_fk integer,
    recipe_number_fk integer,
    FOREIGN KEY (customer_id_fk) REFERENCES customer(customer_id),
    FOREIGN KEY (step_number_fk, recipe_number_fk) REFERENCES brewing_step(step_number, recipe_number_fk),
    PRIMARY KEY (customer_id_fk, step_number_fk, recipe_number_fk)
);

CREATE TABLE "order"(
    order_number integer,
    total real NOT NULL,
    date date NOT NULL,
    ordered boolean NOT NULL,
    customerId_fk integer NOT NULL,
    FOREIGN KEY (customerId_fk) REFERENCES customer(customer_id),
    PRIMARY KEY (order_number)
);

CREATE TABLE ingredient_quantity(
    --Each order can have multiple ingredients, but each one must be unique
    quantity real,
    order_number_fk integer,
    ingredient_id_fk integer,
    FOREIGN KEY (order_number_fk) REFERENCES "order"(order_number),
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id),
    PRIMARY KEY (order_number_fk, ingredient_id_fk)
);

CREATE TABLE malt(
    ingredient_id_fk integer NOT NULL,
    ebc_min integer NOT NULL,
    ebc_max integer NOT NULL,
    type varchar(32) NOT NULL,
    cereal cereal NOT NULL,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id)
);

CREATE TABLE water(
    ingredient_id_fk integer NOT NULL,
    ph real,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id)
);

CREATE TABLE hop(
    ingredient_id_fk integer NOT NULL,
    type hop_type NOT NULL,
    alpha_acid real,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id)
);

CREATE TABLE yeast(
    ingredient_id_fk integer NOT NULL,
    beer_type varchar(32),
    fermentation fermentation_type NOT NULL,
    max_temperature integer,
    min_temperature integer,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id)
);

```
