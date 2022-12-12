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
    'bittering',
    'mixed'
    );

CREATE TYPE fermentation_type AS ENUM(
    'high',
    'low'
    );

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name varchar(32) NOT NULL ,
    last_name varchar(32) NOT NULL ,
    sex sex NOT NULL DEFAULT 'none',
    street varchar(32),
    street_number varchar(32),
    complement varchar(32),
    city_code varchar(16),
    city_name varchar(32),
    e_mail_address varchar(32) UNIQUE NOT NULL,
    password varchar(32) NOT NULL);

CREATE TABLE beer(
    beer_id SERIAL PRIMARY KEY,
    name varchar(32) NOT NULL,
    color integer,
    alcohol real,
    bitterness integer,
    pre_boil_density real,
    initial_density real,
    final_density real);

CREATE TABLE recipe(
    recipe_number SERIAL PRIMARY KEY,
    name varchar(32) NOT NULL,
    difficulty integer CONSTRAINT diffRange CHECK ( difficulty > 0 AND difficulty < 6 ),
    creator_id_fk integer NOT NULL,
    beer_id_fk integer UNIQUE NOT NULL,
    quantity integer, --Association entity
    FOREIGN KEY (beer_id_fk) REFERENCES beer(beer_id) ON DELETE CASCADE,
    FOREIGN KEY (creator_id_fk) REFERENCES customer(customer_id) ON DELETE CASCADE);

CREATE TABLE ingredient(
    ingredient_id SERIAL PRIMARY KEY,
    name varchar(32) NOT NULL ,
    origin varchar(32),
    sub_origin varchar(32),
    specificity text,
    quantity_unit varchar(8),
    price_per_unit real);

CREATE TABLE brewing_step(
    step_number integer NOT NULL,
    step_name varchar(32) NOT NULL,
    duration real,
    step_description text,
    category category NOT NULL,
    recipe_number_fk int NOT NULL,
    FOREIGN KEY (recipe_number_fk) REFERENCES recipe(recipe_number) ON DELETE CASCADE,
    PRIMARY KEY (recipe_number_fk, step_number)
);

CREATE TABLE ingredient_usage(
    quantity real NOT NULL,
    step_number_fk integer NOT NULL,
    ingredient_id_fk integer,
    recipe_number_fk integer  NOT NULL,
    FOREIGN KEY (step_number_fk, recipe_number_fk) REFERENCES brewing_step(step_number, recipe_number_fk) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE,
    PRIMARY KEY (step_number_fk, ingredient_id_fk, recipe_number_fk)
);

CREATE TABLE progression(
    begin_time timestamp,
    customer_id_fk integer,
    step_number_fk integer DEFAULT 1,
    recipe_number_fk integer,
    FOREIGN KEY (customer_id_fk) REFERENCES customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (step_number_fk, recipe_number_fk) REFERENCES brewing_step(step_number, recipe_number_fk) ON DELETE CASCADE,
    PRIMARY KEY (customer_id_fk, step_number_fk, recipe_number_fk)
);

CREATE TABLE "order"(
    order_number SERIAL PRIMARY KEY,
    total real NOT NULL,
    date date NOT NULL,
    ordered boolean NOT NULL,
    customerId_fk integer NOT NULL,
    FOREIGN KEY (customerId_fk) REFERENCES customer(customer_id) ON DELETE CASCADE);

CREATE TABLE ingredient_quantity(
    --Each order can have multiple ingredients, but each one must be unique
    quantity real,
    order_number_fk integer,
    ingredient_id_fk integer,
    FOREIGN KEY (order_number_fk) REFERENCES "order"(order_number) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE,
    PRIMARY KEY (order_number_fk, ingredient_id_fk)
);

CREATE TABLE malt(
    ingredient_id_fk integer NOT NULL,
    ebc_min integer NOT NULL,
    ebc_max integer NOT NULL,
    type varchar(32) NOT NULL,
    cereal cereal NOT NULL,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id),
    PRIMARY KEY (ingredient_id_fk)
);

CREATE TABLE hop(
    ingredient_id_fk integer NOT NULL,
    substitution_hop integer,
    type hop_type NOT NULL,
    low_alpha_acid real,
    high_alpha_acid real,
    FOREIGN KEY (substitution_hop) REFERENCES hop(ingredient_id_fk),
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id),
    PRIMARY KEY (ingredient_id_fk)
);

CREATE TABLE yeast(
    ingredient_id_fk integer NOT NULL,
    beer_type varchar(32),
    fermentation fermentation_type NOT NULL,
    max_temperature integer,
    min_temperature integer,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id),
    PRIMARY KEY (ingredient_id_fk)
);