# HEIG_BDR_JustBrewIt

## Creation du schema

```sql
CREATE SCHEMA justBrewIt;
SET search_path TO justBrewIt;

CREATE TYPE sex as ENUM('ms', 'mr', 'none');

CREATE TYPE category AS ENUM(
    'preparation',
    'beerMash',
    'mashOut',
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

CREATE TYPE hopType AS ENUM(
    'aromatic',
    'bittering'
    );

CREATE TYPE fermentation_type AS ENUM(
    'high',
    'low'
    );

CREATE TYPE address AS (
    street varchar(32),
    streetNumber varchar(32),
    cityCode varchar(16),
    cityName varchar(32));

CREATE TABLE customer (
    customerId integer,
    firstName varchar(32) NOT NULL ,
    lastName varchar(32) NOT NULL ,
    sex sex NOT NULL DEFAULT 'none',
    address address NOT NULL ,
    eMailAddress varchar(32) UNIQUE NOT NULL,
    password varchar(32) NOT NULL ,
    PRIMARY KEY (customerId));

CREATE TABLE beer(
    beerId integer,
    name varchar(32) NOT NULL,
    color integer,
    alcohol real,
    bitterness integer,
    PRIMARY KEY (beerId)
);

CREATE TABLE recipe(
    recipeNumber integer,
    name varchar(32) NOT NULL,
    difficulty integer CONSTRAINT diffRange CHECK ( difficulty > 0 AND difficulty < 6 ),
    customerId_fk integer,
    beerId_fk integer NOT NULL UNIQUE,
    quantity integer, --Association entity
    FOREIGN KEY (beerId_fk) REFERENCES beer(beerId),
    FOREIGN KEY (customerId_fk) REFERENCES customer(customerId),
    PRIMARY KEY (recipeNumber));

CREATE TABLE ingredient(
    ingredientId integer,
    name varchar(32) NOT NULL ,
    origin varchar(32),
    subOrigin varchar(32),
    specificity text,
    QuantityUnit varchar(8),
    pricePerUnit real,
    PRIMARY KEY (ingredientId)
);

CREATE TABLE brewingStep(
    stepNumber integer UNIQUE NOT NULL,
    stepName varchar(32) NOT NULL,
    duration real,
    stepDescription text,
    category category NOT NULL,
    recipeNumber_fk int UNIQUE NOT NULL,
    FOREIGN KEY (recipeNumber_fk) REFERENCES recipe(recipeNumber),
    PRIMARY KEY (recipeNumber_fk, stepNumber)
);

CREATE TABLE use_ingredient(
    quantity real NOT NULL,
    stepNumber_fk integer UNIQUE NOT NULL,
    ingredientId_fk integer UNIQUE NOT NULL,
    recipeNumber_fk integer UNIQUE NOT NULL,
    FOREIGN KEY (stepNumber_fk) REFERENCES brewingStep(stepNumber),
    FOREIGN KEY (recipeNumber_fk) REFERENCES recipe(recipeNumber),
    FOREIGN KEY (ingredientId_fk) REFERENCES ingredient(ingredientId),
    PRIMARY KEY (stepNumber_fk, ingredientId_fk, recipeNumber_fk)
);

CREATE TABLE progression(
    beginTime timestamp NOT NULL,
    customerId_fk integer UNIQUE,
    stepNumber_fk integer UNIQUE NOT NULL,
    recipeNumber integer UNIQUE,
    FOREIGN KEY (customerId_fk) REFERENCES customer(customerId),
    FOREIGN KEY (stepNumber_fk) REFERENCES brewingStep(stepNumber),
    FOREIGN KEY (recipeNumber) REFERENCES recipe(recipeNumber),
    PRIMARY KEY (customerId_fk, stepNumber_fk, recipeNumber)
);

CREATE TABLE usage(
    quantity real NOT NULL
);

CREATE TABLE "order"(
    orderNumber integer,
    total real NOT NULL,
    date date NOT NULL,
    ordered boolean NOT NULL,
    customerId_fk integer UNIQUE NOT NULL,
    FOREIGN KEY (customerId_fk) REFERENCES customer(customerId),
    PRIMARY KEY (orderNumber)
);

CREATE TABLE ingredient_quantity(
    --Each order can have multiple ingredients, but each one must be unique
    quantity real NOT NULL,
    orderNumber_fk integer UNIQUE NOT NULL,
    ingredientId_fk integer,
    FOREIGN KEY (orderNumber_fk) REFERENCES "order"(orderNumber),
    FOREIGN KEY (ingredientId_fk) REFERENCES ingredient(ingredientId),
    PRIMARY KEY (orderNumber_fk, ingredientId_fk)
);

CREATE TABLE malt(
    ingredientId_fk integer UNIQUE NOT NULL,
    ebcMin integer NOT NULL,
    ebcMax integer NOT NULL,
    type varchar(32) NOT NULL,
    cereal cereal NOT NULL,
    FOREIGN KEY (ingredientId_fk) REFERENCES ingredient(ingredientId)
);

CREATE TABLE water(
    ingredientId_fk integer UNIQUE NOT NULL,
    ph real,
    FOREIGN KEY (ingredientId_fk) REFERENCES ingredient(ingredientId)
);

CREATE TABLE hop(
    ingredientId_fk integer UNIQUE NOT NULL,
    type hoptype NOT NULL,
    alphaAcid real,
    FOREIGN KEY (ingredientId_fk) REFERENCES ingredient(ingredientId)
);

CREATE TABLE yeast(
    ingredientId_fk integer UNIQUE NOT NULL,
    beerType varchar(32),
    fermentation fermentation_type NOT NULL,
    maxTemperature integer,
    minTemperature integer,
    FOREIGN KEY (ingredientId_fk) REFERENCES ingredient(ingredientId)
);

```
