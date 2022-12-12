SET search_path TO justBrewIt;

-- obtenir les ingrédients d'une recette donnée

DROP FUNCTION IF EXISTS getIngredientsFromRecipes;

CREATE OR REPLACE FUNCTION getIngredientsFromRecipes
(
    recipeId integer
)
RETURNS TABLE(nom varchar, quantite real, unite varchar)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT name, quantity, quantity_unit
        FROM ingredientsfromrecipes
    WHERE recipe_number = recipeId;
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

-- obtenir les informations concernant une étape
DROP FUNCTION IF EXISTS getStepInfo;

CREATE OR REPLACE FUNCTION getStepInfo
(
    recipeId integer,
    stepId integer
)
RETURNS TABLE(nom varchar, description varchar, duree real)
language plpgsql
AS
$$
    BEGIN
    RETURN QUERY SELECT step_name, description, duration
        FROM recipe
        INNER JOIN brewing_step bs
            ON recipe.recipe_number = bs.recipe_number_fk
    WHERE recipe_number = recipeId
    AND step_number = stepId;
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

-- ajouter étape

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