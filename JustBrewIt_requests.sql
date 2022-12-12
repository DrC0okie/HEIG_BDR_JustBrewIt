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

-- obtenir les informations concernant une recette donnée

-- obtenir les informations concernant une étape donnée

-- calculer le temps restant à une étape

-- ajouter une recette

-- modifier une recette