SET search_path TO justBrewIt;

DROP VIEW ingredientsFromRecipes;

CREATE OR REPLACE VIEW ingredientsFromRecipes AS
    SELECT r.recipe_number, bs.step_number, i.name, iu.quantity, i.quantity_unit
    FROM recipe r
        INNER JOIN brewing_step bs
            ON r.recipe_number = bs.recipe_number_fk
        INNER JOIN ingredient_usage iu
            ON bs.step_number = iu.step_number_fk
                   AND bs.recipe_number_fk = iu.recipe_number_fk
        INNER JOIN ingredient i
            ON i.ingredient_id = iu.ingredient_id_fk;

DROP VIEW recipesFromCustomers;

CREATE OR REPLACE VIEW recipesFromCustomers AS
    SELECT customer_id, recipe_number
    FROM customer
        INNER JOIN recipe r ON customer.customer_id = r.creator_id_fk;

DROP VIEW ordersFromCustomers;

CREATE OR REPLACE VIEW ordersFromCustomers AS
    SELECT customer_id, o.order_number
    FROM customer
        INNER JOIN "order" o
            ON customer.customer_id = o.customerid_fk;

DROP VIEW beersFromRecipes;

CREATE OR REPLACE VIEW beersFromRecipes AS
    SELECT recipe_number, b.name, b.color, b.alcohol, b.bitterness
        FROM recipe
            INNER JOIN beer b
                ON b.beer_id = recipe.beer_id_fk;

DROP VIEW ordersFromCustomers;

CREATE OR REPLACE VIEW ordersFromCustomers AS
    SELECT customer_id, order_number, ordered, i.name, iq.quantity, i.quantity_unit
    FROM "order"
        INNER JOIN customer c
            ON c.customer_id = "order".customerid_fk
        INNER JOIN ingredient_quantity iq
            ON "order".order_number = iq.order_number_fk
        INNER JOIN ingredient i
            ON i.ingredient_id = iq.ingredient_id_fk;