DROP SCHEMA IF EXISTS justBrewIt CASCADE;
CREATE SCHEMA justBrewIt;
SET search_path TO justBrewIt;

CREATE TYPE sex as ENUM('ms', 'mr', 'none');

CREATE TYPE category AS ENUM(
    'Préparation',
    'Empâtage',
    'Mash-out',
    'Filtration',
    'Mesure',
    'Ébullition',
    'Refroidissement',
    'Fermentation',
    'Embouteillage');

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
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE,
    PRIMARY KEY (ingredient_id_fk)
);

CREATE TABLE hop(
    ingredient_id_fk integer NOT NULL,
    substitution_hop integer,
    type hop_type NOT NULL,
    low_alpha_acid real,
    high_alpha_acid real,
    FOREIGN KEY (substitution_hop) REFERENCES hop(ingredient_id_fk) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE,
    PRIMARY KEY (ingredient_id_fk)
);

CREATE TABLE yeast(
    ingredient_id_fk integer NOT NULL,
    beer_type varchar(32),
    fermentation fermentation_type NOT NULL,
    max_temperature integer,
    min_temperature integer,
    FOREIGN KEY (ingredient_id_fk) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE,
    PRIMARY KEY (ingredient_id_fk)
);
			
-- Create requests 

--Returns the primary key ID of the newly created ingredient
SET search_path TO justBrewIt;

CREATE OR REPLACE FUNCTION add_ingredient
    (
    i_name varchar(32),
    i_origin varchar(32),
    i_sub_origin varchar(32),
    i_specificity text,
    i_quantity_unit varchar(8),
    i_price_per_unit real
    )
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE p_key integer;
BEGIN
    INSERT INTO ingredient
    VALUES (DEFAULT, i_name, i_origin, i_sub_origin, i_specificity, i_quantity_unit, i_price_per_unit);
    SELECT MAX(ingredient_id) --Select the max id as it is the latest created
    INTO p_key
    FROM ingredient i;
    RETURN p_key;
END; $$;

-- adds a hop entity and it's linked ingredient
CREATE OR REPLACE PROCEDURE add_hop
    (
    h_name varchar(32),
    h_origin varchar(32),
    h_sub_origin varchar(32),
    h_specificity text,
    h_quantity_unit varchar(8),
    h_price_per_unit real,
    h_substitution integer,
    h_type hop_type,
    h_low_alpha real,
    h_high_alpha real
    )
LANGUAGE plpgsql
AS $$
DECLARE p_key integer;
BEGIN
    p_key = add_ingredient(h_name, h_origin,h_sub_origin, h_specificity, h_quantity_unit, h_price_per_unit);
    INSERT INTO hop
    VALUES(p_key, h_substitution, h_type, h_low_alpha, h_high_alpha);
END; $$;

-- adds a malt entity and it's linked ingredient
CREATE OR REPLACE PROCEDURE add_malt
    (
    m_name varchar(32),
    m_origin varchar(32),
    m_sub_origin varchar(32),
    m_specificity text,
    m_quantity_unit varchar(8),
    m_price_per_unit real,
    m_ebc_min integer,
    m_ebc_max integer,
    m_type varchar(32),
    m_cereal cereal
    )
LANGUAGE plpgsql
AS $$
DECLARE p_key integer;
BEGIN
    p_key = add_ingredient(m_name, m_origin,m_sub_origin, m_specificity, m_quantity_unit, m_price_per_unit);
    INSERT INTO malt
    VALUES(p_key, m_ebc_min, m_ebc_max, m_type, m_cereal);
END; $$;

-- adds a yeast entity and it's linked ingredient
CREATE OR REPLACE PROCEDURE add_yeast
    (
    y_name varchar(32),
    y_origin varchar(32),
    y_sub_origin varchar(32),
    y_specificity text,
    y_quantity_unit varchar(8),
    y_price_per_unit real,
    y_beer_type varchar(32),
    y_fermentation fermentation_type,
    y_min_temp integer,
    y_max_temp integer
    )
LANGUAGE plpgsql
AS $$
DECLARE p_key integer;
BEGIN
    p_key = add_ingredient(y_name, y_origin,y_sub_origin, y_specificity, y_quantity_unit, y_price_per_unit);
    INSERT INTO yeast
    VALUES(p_key, y_beer_type, y_fermentation, y_max_temp, y_min_temp);
END; $$;

-- obtenir les ingrédients qui ne sont ni des malts, ni des levures, ni des houblons d'une recette donnée

DROP FUNCTION IF EXISTS getMiscIngredientsFromRecipe;

CREATE OR REPLACE FUNCTION getMiscIngredientsFromRecipe
(
    recipeId integer
)
RETURNS TABLE(step_name varchar, name varchar, quantity real, quantity_unit varchar, specificity text, origin varchar, ingredient_id integer)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT m.step_name, m.name, m.quantity, m.quantity_unit, m.specificity, m.origin, m.ingredient_id
        FROM miscIngredientsFromRecipes AS m
    WHERE m.recipe_number = recipeId;
    END;
$$;

-- obtenir les houblons d'une recette donnée

DROP FUNCTION IF EXISTS getHopsFromRecipes;

CREATE OR REPLACE FUNCTION getHopsFromRecipes(recipeId integer)
RETURNS TABLE(step_name varchar, name varchar, quantity real, quantity_unit varchar, specificity text, origin varchar, ingredient_id integer, type hop_type, low_alpha_acid real, high_alpha_acid real)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT h.step_name, h.name, h.quantity, h.quantity_unit, h.specificity, h.origin, h.ingredient_id, h.type, h.low_alpha_acid, h.high_alpha_acid
        FROM hopsFromRecipes AS h
    WHERE h.recipe_number = recipeId;
    END;
$$;

-- obtenir les malts d'une recette donnée

DROP FUNCTION IF EXISTS getMaltsFromRecipes;

CREATE OR REPLACE FUNCTION getMaltsFromRecipes(recipeId integer)
RETURNS TABLE(step_name varchar, name varchar, quantity real, quantity_unit varchar, specificity text, origin varchar, ingredient_id integer, ebc_min integer, ebc_max integer, type varchar, cereal cereal)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT m.step_name, m.name, m.quantity, m.quantity_unit, m.specificity, m.origin, m.ingredient_id, m.ebc_min, m.ebc_max, m.type, m.cereal
        FROM maltsFromRecipes AS m
    WHERE m.recipe_number = recipeId;
    END;
$$;

-- obtenir les levures d'une recette donnée

DROP FUNCTION IF EXISTS getYeastFromRecipes;

CREATE OR REPLACE FUNCTION getYeastFromRecipes(recipeId integer)
RETURNS TABLE(step_name varchar, name varchar, quantity real, quantity_unit varchar, specificity text, origin varchar, ingredient_id integer, beer_type varchar, fermentation fermentation_type, min_temperature integer, max_temperature integer)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT y.step_name, y.name, y.quantity, y.quantity_unit, y.specificity, y.origin, y.ingredient_id, y.beer_type, y.fermentation, y.min_temperature, y.max_temperature
        FROM yeastFromRecipes AS y
    WHERE y.recipe_number = recipeId;
    END;
$$;

-- obtenir les ingrédients d'une étape donnée

DROP FUNCTION IF EXISTS getIngredientsFromStep;

CREATE OR REPLACE FUNCTION getIngredientsFromStep
(
    recipeId integer,
    stepId integer
)
RETURNS TABLE (nom varchar, quantite real, unite varchar)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT name, quantity, quantity_unit
        FROM ingredientsfromrecipes
    WHERE recipe_number = recipeId
    AND step_number = stepId;
    END;
$$;

-- obtenir la bière issue d'une recette

DROP FUNCTION IF EXISTS getBeerFromRecipe;

CREATE OR REPLACE FUNCTION getBeerFromRecipe
(
    recipeId integer
)
RETURNS TABLE (nom varchar, couleur integer, alcool real, amertume integer)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT name, color, alcohol, bitterness
        FROM beersfromrecipes
    WHERE recipe_number = recipeId;
    END;
$$;

-- obtenir le panier actuel d'un utilisateur

DROP FUNCTION IF EXISTS getCartFromCustomer;

CREATE OR REPLACE FUNCTION getCartFromCustomer
(
    customerId integer
)
RETURNS TABLE (nom varchar, quantite real, unite varchar)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT name, quantity, quantity_unit
        FROM ordersfromcustomers
    WHERE customer_id = customerId
    AND ordered = false;
    END;
$$;


-- obtenir les commandes d'un utilisateur
DROP FUNCTION IF EXISTS getOrdersFromCustomer;

CREATE OR REPLACE FUNCTION getOrdersFromCustomer
(
    customerId integer
)
RETURNS TABLE (numero integer, nom varchar, quantite real, unite varchar)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT order_number, name, quantity, quantity_unit
        FROM ordersfromcustomers
    WHERE customer_id = customerId
    AND ordered = true;
    END;
$$;

-- obtenir prochaine étape

DROP FUNCTION IF EXISTS getNextStep;

CREATE OR REPLACE FUNCTION getNextStep
(
    recipeId integer,
    stepNumber integer
)
RETURNS TABLE(recette integer, etape integer)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT recipe_number, step_number
        FROM stepsfromrecipe
    WHERE recipe_number = recipeId
    AND step_number = stepNumber + 1;
    END;
$$;

-- obtenir la durée totale d'une recette
DROP FUNCTION IF EXISTS getDurationOfRecipe;

CREATE OR REPLACE FUNCTION getDurationOfRecipe
(
    recipeId integer
)
RETURNS real
language plpgsql
AS
$$
    DECLARE
        dur real;
    BEGIN
    SELECT SUM(duration) INTO dur
        FROM stepsfromrecipe
    WHERE recipe_number = recipeId;
    RETURN dur;
    END;
$$;


-- Obtenir le userId à partir de l'adresse email
CREATE OR REPLACE FUNCTION get_customer_id_by_email(email varchar(32))
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (SELECT customer_id FROM customer WHERE e_mail_address = email);
END; $$;

-- obtenir les recettes liées à un utilisateur
CREATE OR REPLACE FUNCTION get_recipe_info_by_customer_id(c_id integer)
RETURNS TABLE (recipe_number integer, name varchar(32), difficulty integer, creator_id_fk integer, beer_id_fk integer, quantity integer)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT r.recipe_number, r.name, r.difficulty, r.creator_id_fk, r.beer_id_fk, r.quantity 
		FROM recipe AS r 
	WHERE r.creator_id_fk = c_id;
END; $$;



-- obtenir les informations concernant une recette donnée
DROP FUNCTION IF EXISTS getRecipeInfo;

CREATE OR REPLACE FUNCTION getRecipeInfo
(
    recipeId integer
)
RETURNS TABLE(nom varchar, description varchar, difficulte integer, duree real, cout real)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT recipe.name, description, difficulty, getDurationOfRecipe(recipeId), SUM(i.price_per_unit * i.quantity)
        FROM recipe
        INNER JOIN ingredientsfromrecipes i
            ON recipe.recipe_number = i.recipe_number
    WHERE recipe.recipe_number = recipeId
    GROUP BY recipe.name, description, difficulty;
    END;
$$;

-- obtenir le prix d'une commande

DROP FUNCTION IF EXISTS getPriceOfOrder;

CREATE OR REPLACE FUNCTION getPriceOfOrder
(
    orderId integer
)
RETURNS real
language plpgsql
AS
$$
    DECLARE
        pri real;
    BEGIN
    SELECT SUM(price_per_unit * quantity) INTO pri
        FROM ordersfromcustomers
    WHERE order_number = orderId;
    RETURN pri;
    END;
$$;

-- obtenir toutes les étapes d'une recette
CREATE OR REPLACE FUNCTION getStepsFromRecipe(recipeId integer)
RETURNS TABLE(step_number integer, step_name varchar, description text, duration real, category category, step_count bigint)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT s.step_number, s.step_name, s.step_description, s.duration, s.category,
			(SELECT COUNT(*) 
				FROM brewing_step 
			WHERE recipe_number_fk = recipeId) AS step_count
        FROM stepsFromRecipe s
    WHERE s.recipe_number = recipeId;
    END;
$$;


-- obtenir les informations concernant une étape
DROP FUNCTION IF EXISTS getStepInfo;

CREATE OR REPLACE FUNCTION getStepInfo(recipeId integer, stepId integer)
RETURNS TABLE(step_name varchar, description text, duration real, category category)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT s.step_name, s.step_description, s.duration, s.category
        FROM stepsFromRecipe s
    WHERE s.recipe_number = recipeId AND s.step_number = stepId;
    END;
$$;

-- ajouter bière

DROP FUNCTION IF EXISTS addBeer;

CREATE OR REPLACE FUNCTION addBeer
(
    beerName varchar,
    beerColor integer,
    beerAlcohol real,
    beerBitterness integer
)
RETURNS void
language plpgsql
AS
$$
    BEGIN
    INSERT INTO beer (name, color, alcohol, bitterness)
    VALUES (beerName, beerColor, beerAlcohol, beerBitterness);
    END;
$$;

-- ajouter une recette

DROP FUNCTION IF EXISTS addRecipe;

CREATE OR REPLACE FUNCTION addRecipe
(
    recipeName varchar,
    recipeDifficulty integer,
    recipeBeer integer,
    creator integer,
    quanti integer
)
RETURNS void
language plpgsql
AS
$$
    BEGIN
    INSERT INTO recipe (name, difficulty, creator_id_fk ,beer_id_fk, quantity)
    VALUES (recipeName, recipeDifficulty, creator ,recipeBeer, quanti);
    END
$$;

-- ajouter étape _> TODO 1 seule requête avec insert + select

DROP FUNCTION IF EXISTS addStep;

CREATE OR REPLACE FUNCTION addStep
(
    recipeId integer,
    stepName varchar,
    stepDescription varchar,
    stepDuration real,
    cat integer
)
RETURNS void
language plpgsql
AS
$$
    DECLARE stepNb integer;
    BEGIN
    SELECT max(step_number) INTO stepNb
        FROM brewing_step
    WHERE recipe_number_fk = recipeId;
    INSERT INTO brewing_step (recipe_number_fk, step_number ,step_name, step_description, duration, category)
    VALUES (recipeId, (stepNb + 1), stepName, stepDescription, stepDuration, cat);
    END;
$$;



-- ajouter utilisation ingrédient

DROP FUNCTION IF EXISTS addIngredientUse;

CREATE OR REPLACE FUNCTION addIngredientUse
(
    recipeId integer,
    stepId integer,
    ingredientId integer,
    quant real
)
RETURNS void
language plpgsql
AS
$$
BEGIN
    INSERT INTO ingredient_usage (recipe_number_fk, step_number_fk, ingredient_id_fk, quantity)
    VALUES (recipeId, stepId, ingredientId, quant);
END;
$$;


-- modifier une recette

DROP FUNCTION IF EXISTS modifyRecipe;

CREATE OR REPLACE FUNCTION modifyRecipe
(
    recipeId integer,
    recipeName varchar,
    recipeDifficulty integer,
    recipeBeer integer,
    creator integer,
    quanti integer
)
RETURNS void
language plpgsql
AS
$$
    BEGIN
    UPDATE recipe
    SET name = recipeName, difficulty = recipeDifficulty, creator_id_fk = creator, beer_id_fk = recipeBeer, quantity = quanti
    WHERE recipe_number = recipeId;
    END;
$$;

-- modifier une étape

DROP FUNCTION IF EXISTS modifyStep;

CREATE OR REPLACE FUNCTION modifyStep
(
    recipeId integer,
    stepId integer,
    stepName varchar,
    stepDescription varchar,
    stepDuration real,
    cat integer
)
RETURNS void
language plpgsql
AS
$$
    BEGIN
    UPDATE brewing_step
    SET step_name = stepName, step_description = stepDescription, duration = stepDuration, category = cat
    WHERE recipe_number_fk = recipeId
    AND step_number = stepId;
    END;
$$;

-- modifier utilisation ingrédient

DROP FUNCTION IF EXISTS modifyIngredientUse;

CREATE OR REPLACE FUNCTION modifyIngredientUse
(
    recipeId integer,
    stepId integer,
    ingredientId integer,
    quant real
)
RETURNS void
language plpgsql
AS
$$
BEGIN
    UPDATE ingredient_usage
    SET quantity = quant
    WHERE recipe_number_fk = recipeId
    AND step_number_fk = stepId
    AND ingredient_id_fk = ingredientId;
END;
$$;

-- supprimer une recette

DROP FUNCTION IF EXISTS deleteRecipe;

CREATE OR REPLACE FUNCTION deleteRecipe
(
    recipeId integer
)
RETURNS void
language plpgsql
AS
$$
    BEGIN
    DELETE FROM recipe
    WHERE recipe_number = recipeId;
    END;
$$;

-- calculer le temps restant à une étape en cours

DROP FUNCTION IF EXISTS getRemainingTime;

CREATE OR REPLACE FUNCTION getRemainingTime
(
    recipeId integer,
    stepId integer,
    customerId integer
)
RETURNS real
language plpgsql
AS
$$
    DECLARE
        time real;
        timeStamp timestamp;
        dur real;
    BEGIN
    SELECT begin_time into timeStamp
        FROM progression
    WHERE recipe_number_fk = recipeId
    AND step_number_fk = stepId
    AND customer_id_fk = customerId;
    SELECT duration into dur
        FROM brewing_step
    WHERE recipe_number_fk = recipeId
    AND step_number = stepId;
    time = (EXTRACT(EPOCH FROM (now() - timeStamp)) / 60);
    RETURN dur - time;
    END;
$$;

-- commencer une étape

DROP FUNCTION IF EXISTS startStep;

CREATE OR REPLACE FUNCTION startStep
(
    recipeId integer,
    stepId integer,
    customerId integer
)
RETURNS void
language plpgsql
AS
$$
    BEGIN
    INSERT INTO progression (recipe_number_fk, step_number_fk, customer_id_fk, begin_time)
    VALUES (recipeId, stepId, customerId, now());
    END;
$$;

-- prochaine étape

DROP FUNCTION IF EXISTS nextStep;

CREATE OR REPLACE FUNCTION nextStep
(
    recipeId integer,
    stepId integer,
    customerId integer
)
RETURNS void
language plpgsql
AS
$$
    BEGIN
    UPDATE progression
    SET step_number_fk = stepId + 1
    WHERE recipe_number_fk = recipeId
    AND step_number_fk = stepId
    AND customer_id_fk = customerId;
    END;
$$;

--Create Triggers

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
	
--Create views
DROP VIEW IF EXISTS ingredientsFromRecipes;

CREATE OR REPLACE VIEW ingredientsFromRecipes AS
    SELECT r.recipe_number, bs.step_name, i.name, iu.quantity, i.quantity_unit, i.price_per_unit, i.specificity, i.origin, i.ingredient_id
    FROM recipe r
        INNER JOIN brewing_step bs
            ON r.recipe_number = bs.recipe_number_fk
        INNER JOIN ingredient_usage iu
            ON bs.step_number = iu.step_number_fk
                   AND bs.recipe_number_fk = iu.recipe_number_fk
        INNER JOIN ingredient i
            ON i.ingredient_id = iu.ingredient_id_fk;
			
	
DROP VIEW IF EXISTS hopsFromRecipes;

CREATE OR REPLACE VIEW hopsFromRecipes AS
    SELECT i.recipe_number, i.step_name, i.name, i.quantity, i.quantity_unit, i.specificity, i.origin, i.ingredient_id, h.type, h.low_alpha_acid, h.high_alpha_acid
    FROM ingredientsFromRecipes i
		INNER JOIN hop h
			ON h.ingredient_id_fk = i.ingredient_id;

DROP VIEW IF EXISTS maltsFromRecipes;

CREATE OR REPLACE VIEW maltsFromRecipes AS
    SELECT i.recipe_number, i.step_name, i.name, i.quantity, i.quantity_unit, i.specificity, i.origin, i.ingredient_id, m.ebc_min, m.ebc_max, m.type, m.cereal
    FROM ingredientsFromRecipes i
		INNER JOIN malt m
			ON m.ingredient_id_fk = i.ingredient_id;

DROP VIEW IF EXISTS yeastFromRecipes;

CREATE OR REPLACE VIEW yeastFromRecipes AS
    SELECT i.recipe_number, i.step_name, i.name, i.quantity, i.quantity_unit, i.specificity, i.origin, i.ingredient_id, y.beer_type, y.fermentation, y.min_temperature, y.max_temperature
    FROM ingredientsFromRecipes i
		INNER JOIN yeast y
			ON y.ingredient_id_fk = i.ingredient_id;
			
DROP VIEW IF EXISTS miscIngredientsFromRecipes;

CREATE OR REPLACE VIEW miscIngredientsFromRecipes AS
    SELECT * FROM ingredientsFromRecipes i
	WHERE i.ingredient_id NOT IN(
	SELECT ingredient_id FROM yeastFromRecipes
    UNION
    SELECT ingredient_id FROM hopsFromRecipes
    UNION
    SELECT ingredient_id FROM maltsFromRecipes
	);
			
DROP VIEW IF EXISTS recipesFromCustomers;

CREATE OR REPLACE VIEW recipesFromCustomers AS
    SELECT customer_id, recipe_number
    FROM customer
        INNER JOIN recipe r ON customer.customer_id = r.creator_id_fk;

DROP VIEW IF EXISTS ordersFromCustomers;

CREATE OR REPLACE VIEW ordersFromCustomers AS
    SELECT customer_id, o.order_number
    FROM customer
        INNER JOIN "order" o
            ON customer.customer_id = o.customerid_fk;

DROP VIEW IF EXISTS beersFromRecipes;

CREATE OR REPLACE VIEW beersFromRecipes AS
    SELECT recipe_number, b.name, b.color, b.alcohol, b.bitterness
        FROM recipe
            INNER JOIN beer b
                ON b.beer_id = recipe.beer_id_fk;

DROP VIEW IF EXISTS ordersFromCustomers;

CREATE OR REPLACE VIEW ordersFromCustomers AS
    SELECT customer_id, order_number, ordered, i.name, iq.quantity, i.quantity_unit, i.price_per_unit
    FROM "order"
        INNER JOIN customer c
            ON c.customer_id = "order".customerid_fk
        INNER JOIN ingredient_quantity iq
            ON "order".order_number = iq.order_number_fk
        INNER JOIN ingredient i
            ON i.ingredient_id = iq.ingredient_id_fk;

CREATE OR REPLACE VIEW stepsFromRecipe AS
    SELECT r.recipe_number, bs.step_number, bs.duration, bs.step_name, bs.step_description, bs.category
    FROM recipe r
        INNER JOIN brewing_step bs
            ON r.recipe_number = bs.recipe_number_fk;
	
-- import data
-- Hop insertion
CALL add_hop('Bramling Cross', 'Angleterre', null, 'Herbacé, épicé, herbeux', 'gr', null, null, 'mixed', 5.0, 8.0);
CALL add_hop('Brewer''s Gold', 'Angleterre', null, 'Épicé, fruité (cassis)', 'gr', null, null, 'mixed', 4.0, 9.0);
CALL add_hop('Challenger', 'Angleterre', null, 'Épicé, fruité', 'gr', null, null, 'mixed', 6.0, 9.0);
CALL add_hop('East Kent Goldings', 'Angleterre', null, 'Terreux, agrumes', 'gr', null, null, 'aromatic', 4.0, 6.0);
CALL add_hop('Fuggle', 'Angleterre', null, 'Herbacé, boisé, épicé', 'gr', null, null, 'aromatic', 3.5, 5.0);
CALL add_hop('Goldings', 'Angleterre', null, 'Floral, herbacé, épicé', 'gr', null, null, 'aromatic', 4.0, 6.0);
CALL add_hop('Northern Brewer', 'Angleterre', null, 'Agrumes, herbacé, boisé', 'gr', null, null, 'mixed', 7.0, 10.0);
CALL add_hop('Pilgrim', 'Angleterre', null, 'Herbacé', 'gr', null, null, 'mixed', 9.0, 13.0);
CALL add_hop('Target', 'Angleterre', null, 'Agrumes épicé', 'gr', null, null, 'mixed', 8.0, 13.0);
CALL add_hop('Whitbread Golding', 'United Kingdoms', null, 'Boisé, herbacé, fruité', 'gr', null, null, 'mixed', 5.0, 8.0);
CALL add_hop('Aurora', 'Slovénie', null, 'Floral, herbacé', 'gr', null, null, 'mixed', 6.0, 10.0);
CALL add_hop('Hallertau', 'Allemagne', null, 'Floral, fruité (raisin)', 'gr', null, null, 'mixed', 9.0, 12.0);
CALL add_hop('Hersbrucker', 'Allemagne', null, 'Fruité, floral, épicé', 'gr', null, null, 'aromatic', 2.0, 5.0);
CALL add_hop('Marynka', 'Pologne', null, 'Herbacé, terreux', 'gr', null, null, 'mixed', 9.0, 12.0);
CALL add_hop('Opal', 'Allemagne', null, 'Agrumes, épicé', 'gr', null, null, 'mixed', 5.0, 8.0);
CALL add_hop('Pearl', 'Allemagne', null, 'Herbacé, épicé, fruité', 'gr', null, null, 'mixed', 6.0, 9.0);
CALL add_hop('Saaz', 'Rép. Tchèque', null, 'Floral, fruité, herbacé', 'gr', null, null, 'aromatic', 2.0, 6.0);
CALL add_hop('Saphir', 'Allemagne', null, 'Agrumes, fruité', 'gr', null, null, 'aromatic', 2.0, 5.0);
CALL add_hop('Smaragd', 'Allemagne', null, 'Boisé, épicé, herbacé', 'gr', null, null, 'aromatic', 4.0, 6.0);
CALL add_hop('Styrian Golding', 'Autriche', null, 'Épicé', 'gr', null, null, 'aromatic', 4.0, 6.0);
CALL add_hop('Tettnanger', 'Allemagne', null, 'Épicé, herbacé', 'gr', null, null, 'aromatic', 3.0, 6.0);
CALL add_hop('Aramis', 'France', null, 'Épicé, herbacé, agrumes', 'gr', null, null, 'mixed', 8.0, 8.5);
CALL add_hop('Bouclier', 'France', null, 'Fruité, agrumes, herbacé', 'gr', null, null, 'mixed', 8.0, 9.0);
CALL add_hop('Strisselspalt', 'France', null, 'Fruité (citron), épicé', 'gr', null, null, 'aromatic', 3.0, 5.0);
CALL add_hop('Triskel', 'France', null, 'Fruité, floral, agrumes', 'gr', null, null, 'aromatic', 4.5, 7.0);
CALL add_hop('Amarillo', 'USA', null, 'Floral, agrumes', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Cascade', 'USA', null, 'Agrumes, résineux', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Centennial', 'USA', null, 'Floral, agrumes', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Chinook', 'USA', null, 'Épicé, agrumes, résineux', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Colombus', 'USA', null, 'Herbacé, résineux, agrumes', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Galena', 'USA', null, 'Fruité (pêche), boisé, herbacé', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Nugget', 'USA', null, 'Herbacé, boisé, résineux', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Simcoe', 'USA', null, 'Fruité (abricot), herbacé, résineux', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Ahtanum', 'USA', null, 'Floral, agrumes, résineux', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Citra', 'USA', null, 'Fruité (pêche), agrumes', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Crystal', 'USA', null, 'Fruité (tropical), boisé, herbacé', 'gr', null, null, 'aromatic', 5.0, 8.0);
CALL add_hop('Willamette', 'USA', null, 'Fruité, herbacé, épicé', 'gr', null, null, 'aromatic', 5.0, 8.0);

CALL add_malt('Pilsner', null, null, 'Bières de type Pilsner, pils aux couleurs extra claires et toutes les lager, ale demandant une base de malt pale','kg', 15.5, 2, 3, 'Pilsen', 'barley');
CALL add_malt('Pilsner', null, null, 'Bières de type Pilsen et tout autre type de bière lager, ale','kg', 15.5, 2, 4, 'Pilsen', 'barley');
CALL add_malt('Pale Ale', null, null, 'Approprié pour toutes les bières Ale, Stout, Porter','kg', 15.0, 5, 7, 'Pale Ale', 'barley');
CALL add_malt('Vienne', null, null, 'Type « Export » bières de fête, bières de type Vienne, bières de type Octobre','kg', 15.4, 6, 9, 'Vienne', 'barley');
CALL add_malt('Munich', null, null, 'Type « Export » bières de fête, bières de type Vienne, bières ambrée, Stout','kg', 15.3, 12, 17, 'Munich', 'barley');
CALL add_malt('Munich', null, null, 'Type « Export » bières de fête, bières de type Vienne, bières ambrée, Stout','kg', 15.2, 20, 25, 'Munich', 'barley');
CALL add_malt('Acidulé', null, null, 'Bières type Pilsen, bières légères, bières pression, bières blanches','kg', 17.9, 3, 6, 'Acidulé', 'barley');
CALL add_malt('Mélanoïdé', null, null, 'Bières blanches, bières Bock, bières brunes, bières rousses, bières ambrées','kg', 15.5, 60, 80, 'Spécial', 'barley');
CALL add_malt('de blé', null, null, 'Bières haute fermentation, bières sombres','kg', 15.9, 100, 140, 'Blé', 'wheat');
CALL add_malt('Carapils', null, null, 'Bières type Pilsen, bières sans alcool, bières légères, lager','kg', 15.5, 25, 65, 'Pilsen', 'barley');
CALL add_malt('Carahell', null, null, 'Bières blondes, type « Export », bières de fête, boissons maltées','kg', 15.6, 20, 30, 'Pilsen', 'barley');
CALL add_malt('Carared', null, null, 'Bières brunes, bières Bock, bières ambrées, bières Alt, bières blanches, Red Ales, Scottish Ales','kg', 16.1, 40, 60, 'Roux', 'barley');
CALL add_malt('Caraamber', null, null, 'Bières Bock, bières brunes, bières rousses, bières ambrées, Amber Lagers, Amber Ales','kg', 15.5, 60, 80, 'Ambré', 'barley');
CALL add_malt('Caramunich', null, null, 'Bières brunes, bières de fête, bières de malt, boissons maltées, bières pression, bières légères','kg', 15.2, 80, 100, 'Munich', 'barley');
CALL add_malt('Caramunich', null, null, 'Bières brunes, bières de fête, bières de malt, boissons maltées, bières pression, bières légères','kg', 15.5, 110, 130, 'Munich', 'barley');
CALL add_malt('Caramunich', null, null, 'Bières brunes, bières de fête, bières de malt, boissons maltées, bières pression, bières légères','kg', 15.7, 140, 160, 'Munich', 'barley');
CALL add_malt('Caraaroma', null, null, 'Bières brunes, bières Bock, bières ambrées, bières de garde brunes, Dark Ales, Stouts, Porters','kg', 15.8, 350, 450, 'Spécial', 'barley');
CALL add_malt('Carabelge', null, null, 'Bières spéciales belges, bières blondes belges, Bruin belges, bières ambrées belges, Triple, Dubbel','kg', 15.8, 30, 35, 'Belge', 'barley');
CALL add_malt('caramélisé', null, null, 'Lager de Bohème, Bock de Bohème, bières spéciales de Bohème, Porter, Stout, Ale','kg', 15.8, 170, 220, 'Caramel', 'barley');
CALL add_malt('Pilsner Bohème', null, null, 'Bières type Pilsen, tout autre type de bière','kg', 15.5, 3, 4, 'Pilsen / Bohème', 'barley');
CALL add_malt('de Bohème', null, null, 'Bières type Pilsen selon la méthode de Bohème, Bières européennes de basse fermentation','kg', 15.8, 3, 5, 'Bohème', 'barley');
CALL add_malt('d''abbaye', null, null, 'Bières d’abbaye traditionnelles, bières trappistes, bières spéciales belges, bières blondes belges, Bruin belges','kg', 15.6, 40, 50, 'Belge', 'barley');
CALL add_malt('torréfié', null, null, 'Bières fortes, Altbiere, bières Bock, bières très foncées','kg', 19.0, 1100, 1200, 'Torréfié / Chocolat', 'barley');
CALL add_malt('torréfié', null, null, 'Bières fortes, Altbiere, bières Bock, bières très foncées','kg', 18.5, 1300, 1500, 'Torréfié / Chocolat', 'barley');
CALL add_malt('de seigle torréfié', null, null, 'Bières spéciales de haute fermentation','kg', 19.5, 500, 800, 'Seigle / Torréfié', 'barley');
CALL add_malt('d''épeautre torréfié', null, null, 'Bières à plusieurs grains, produits de boulangerie','kg', 41.0, 450, 650, 'Epeautre / Torréfié', 'barley');
CALL add_malt('spécial W', null, null, 'Bruin belges, bières belges ambrées, bières spéciales belges, bières blondes belges, bières ambrées belges','kg', 20.0, 280, 320, 'Spécial', 'barley');
CALL add_malt('Barke vienne', null, null, 'Bavarian dunkel, bières de fêtes, pale ale, IPA, stout, lager','kg', 18.5, 6, 9, 'Vienne', 'barley');
CALL add_malt('Barke Munich', null, null, 'Bières de fêtes, bières bock, bières sombres, stout, bières Münich','kg', 17.0, 17, 22, 'Munich', 'barley');

CALL add_yeast('SAFALE BE-256 (abbaye)', null, null, 'Fermente très rapidement et révèle des arômes subtils et bien équilibrés',
'Sachet', 4.8, 'Abbaye / Belge', 'high', 15, 25);

CALL add_yeast('SAFALE F-2', null, null, 'Se caractérise par un profil aromatique neutre qui respecte les caractéristiques de la bière de base',
'Sachet', 4.3, 'Refermentation', 'low', 15, 25);

CALL add_yeast('SAFALE S-04', null, null, 'Excellentes propriétés de sédimentation, favorise une fermentation rapide',
'Sachet', 3.3, 'Ale', 'high', 18, 24);

CALL add_yeast('SAFLAGER S-23', null, null, 'Fournit des bières Pils fruitées et riches en ester',
'Sachet', 4.4, 'Lager / Pilsner', 'low', 9, 15);

CALL add_yeast('SAFALE US-05', null, null, 'Pour des bières balancées avec peu de diacétyle et un après-goût pur et rafraîchissant',
'Sachet', 3.4, 'Ale', 'high', 15, 24);

CALL add_yeast('SAFALE T-58', null, null, 'Développe des arômes poivrés et épicés',
'Sachet', 2.7, 'Saison', 'high', 18, 24);

CALL add_yeast('LalBrew Windsor', null, null, 'Levure de fermentation haute universelle fruitée',
'Sachet', 4.5, 'Ale', 'high', 15, 25);

CALL add_yeast('Bavarian Wheat M20', null, null, 'Sensation soyeuse en bouche et de délicieux arômes de banane et de clou de girofle',
'Sachet', 3.2, 'Weizen', 'high', 18, 30);

CALL add_yeast('Hophead Ale M66', null, null, 'Un mélange d''enzymes de levure qui renforce les arômes et les esters, parfait pour les NEIPA',
'Sachet', 4.5, 'IPA / NEIPA', 'high', 18, 22);

CALL add_yeast('Belgian Tripel M31', null, null, 'Offre une grande tolérance à l''alcool, ce qui la rend idéale pour un éventail de bières belges',
'Sachet', 4.6, 'Abbaye / Belge', 'high', 18, 28);

CALL add_yeast('New World Strong M42', null, null, 'Convient notamment aux Porters et Russian Imperial Stouts',
'Sachet', 3.3, 'Porter / Stout', 'high', 16, 22);

SELECT add_ingredient('Sucre de canne', null, null, null,'gr', null);
SELECT add_ingredient('Miel', null, null, null,'gr', null);
SELECT add_ingredient('Café', null, null, null,'gr', null);
SELECT add_ingredient('Lait', null, null, null,'l', null);
SELECT add_ingredient('Eau', null, null, null, 'l', null);

INSERT INTO customer
VALUES (DEFAULT, 'Timothée', 'Van Hove', 'mr', 'Les Sorbiers', '5', null, '1530', 'Payerne', 'timothee.vanhove@heig-vd.ch', '1234');

INSERT INTO customer
VALUES (DEFAULT, 'Thomas', 'Germano', 'mr', 'Rue des Germano', '0', null, '0000', 'Somewhere', 'thomas.germano@heig-vd.ch', '1234');

INSERT INTO beer
VALUES(DEFAULT, 'Frida la brune', 42, 7.7, 38, 1.07, 1.075, 1.022);

INSERT INTO beer
VALUES(DEFAULT, 'Brigit la blanche', 8, 5.5, 15, 1.05, 1.054, 1.012);

INSERT INTO recipe
VALUES(DEFAULT, 'Frida la Brune', 3, 1, 1, 20);

INSERT INTO recipe
VALUES(DEFAULT, 'Brigit la blanche', 3, 2, 2, 20);

INSERT INTO brewing_step
VALUES(1, 'Préparation', 0, '', 'Préparation', 1);

INSERT INTO brewing_step
VALUES(2, 'Empâtage', 60, '', 'Empâtage', 1);

INSERT INTO brewing_step
VALUES(3, 'Mash-out', 15, '', 'Mash-out', 1);

INSERT INTO brewing_step
VALUES(4, 'Filatration des drêches', 0, '', 'Filtration', 1);

INSERT INTO brewing_step
VALUES(5, 'Mesure de la densité', 0, '', 'Mesure', 1);

INSERT INTO brewing_step
VALUES(6, 'Ébullition', 60, '', 'Ébullition', 1);

INSERT INTO brewing_step
VALUES(7, 'Refroidissement', 0, '', 'Refroidissement', 1);

INSERT INTO brewing_step
VALUES(8, 'Fermentation', 120, '', 'Fermentation', 1);

INSERT INTO brewing_step
VALUES(9, 'Mise en bouteille', 500, '', 'Embouteillage', 1);

INSERT INTO brewing_step
VALUES(1, 'Préparation', 0, '', 'Préparation', 2);

INSERT INTO brewing_step
VALUES(2, 'Empâtage', 60, '', 'Empâtage', 2);

INSERT INTO brewing_step
VALUES(3, 'Mash-out', 15, '', 'Mash-out', 2);

INSERT INTO brewing_step
VALUES(4, 'Filatration des drêches', 0, '', 'Filtration', 2);

INSERT INTO brewing_step
VALUES(5, 'Mesure de la densité', 0, '', 'Mesure', 2);

INSERT INTO brewing_step
VALUES(6, 'Ébullition', 60, '', 'Ébullition', 2);

INSERT INTO brewing_step
VALUES(7, 'Refroidissement', 0, '', 'Refroidissement', 2);

INSERT INTO brewing_step
VALUES(8, 'Fermentation', 120, '', 'Fermentation', 2);

INSERT INTO brewing_step
VALUES(9, 'Mise en bouteille', 500, '', 'Embouteillage', 2);

-- Recette 1 (Frida la brune)
-- 4kg Malt pilsner / étape 2
INSERT INTO ingredient_usage
VALUES (4.0, 2, 38, 1);

-- 1kg Malt carapils / étape 2
INSERT INTO ingredient_usage
VALUES (1.0, 2, 47, 1);

-- 1kg Malt carared / étape 2
INSERT INTO ingredient_usage
VALUES (1.0, 2, 49, 1);

-- 0.5 kg Malt Spécial / étape 2
INSERT INTO ingredient_usage
VALUES (0.5, 2, 64, 1);

-- 150g sucre de canne étape 2
INSERT INTO ingredient_usage
VALUES (150.0, 2, 78, 1);

-- 30g Target étape 6
INSERT INTO ingredient_usage
VALUES (30.0, 6, 9, 1);

-- 25g Brewer's Gold étape 6
INSERT INTO ingredient_usage
VALUES (25.0, 6, 2, 1);

-- 25g Saaz étape 6
INSERT INTO ingredient_usage
VALUES (25.0, 6, 17, 1);

-- Levure BE-256 étape 8
INSERT INTO ingredient_usage
VALUES (1, 8, 67, 1);

-- 8.5g sucre de canne / litre de bière obtenue étape 9
INSERT INTO ingredient_usage
VALUES (8.5, 9, 78, 1);


-- Recette 1 (Brigit la blanche)
-- 2kg Malt pilsner / étape 2
INSERT INTO ingredient_usage
VALUES (2.0, 2, 38, 2);

-- 2kg malt de blé / étape 2
INSERT INTO ingredient_usage
VALUES (2.0, 2, 46, 2);

-- 200g sucre de canne étape 2
INSERT INTO ingredient_usage
VALUES (200.0, 2, 78, 2);

-- 30g houblon Pearl étape 6
INSERT INTO ingredient_usage
VALUES (30.0, 6, 16, 2);

-- 20g houblon Opal étape 6
INSERT INTO ingredient_usage
VALUES (20.0, 6, 15, 2);

-- 1 sachet de levure Bavarian Wheat étape 8
INSERT INTO ingredient_usage
VALUES (1, 8, 74, 2);

-- 7.5g sucre de canne / litre de bière obtenue étape 9
INSERT INTO ingredient_usage
VALUES (7.5, 9, 78, 2);

INSERT INTO progression
VALUES (now(), 1, DEFAULT, 1);

INSERT INTO progression
VALUES (now(), 1, DEFAULT, 2);