--Returns the primary key ID of the newly created ingredient
CREATE OR REPLACE FUNCTION add_ingredient(i_name varchar(32), i_origin varchar(32), i_sub_origin varchar(32), i_specificity text,
i_quantity_unit varchar(8), i_price_per_unit real)
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
CREATE OR REPLACE PROCEDURE add_hop(h_name varchar(32), h_origin varchar(32), h_sub_origin varchar(32), h_specificity text,
h_quantity_unit varchar(8), h_price_per_unit real, h_type hop_type, h_low_alpha real, h_high_alpha real)
LANGUAGE plpgsql
AS $$
DECLARE p_key integer;
BEGIN
    p_key = add_ingredient(h_name, h_origin,h_sub_origin, h_specificity, h_quantity_unit, h_price_per_unit);
    INSERT INTO hop
    VALUES(p_key, h_type, h_low_alpha, h_high_alpha);
END; $$;

-- adds a malt entity and it's linked ingredient
CREATE OR REPLACE PROCEDURE add_malt(m_name varchar(32), m_origin varchar(32), m_sub_origin varchar(32), m_specificity text,
m_quantity_unit varchar(8), m_price_per_unit real, m_ebc_min integer, m_ebc_max integer, m_type varchar(32), m_cereal cereal)
LANGUAGE plpgsql
AS $$
DECLARE p_key integer;
BEGIN
    p_key = add_ingredient(m_name, m_origin,m_sub_origin, m_specificity, m_quantity_unit, m_price_per_unit);
    INSERT INTO malt
    VALUES(p_key, m_ebc_min, m_ebc_max, m_type, m_cereal);
END; $$;

-- adds a yeast entity and it's linked ingredient
CREATE OR REPLACE PROCEDURE add_yeast(y_name varchar(32), y_origin varchar(32), y_sub_origin varchar(32), y_specificity text,
y_quantity_unit varchar(8), y_price_per_unit real, y_beer_type varchar(32), y_fermentation fermentation_type, y_min_temp integer, y_max_temp integer)
LANGUAGE plpgsql
AS $$
DECLARE p_key integer;
BEGIN
    p_key = add_ingredient(y_name, y_origin,y_sub_origin, y_specificity, y_quantity_unit, y_price_per_unit);
    INSERT INTO yeast
    VALUES(p_key, y_beer_type, y_fermentation, y_max_temp, y_min_temp);
END; $$;

-- Hop insertion

CALL add_hop('Bramling Cross', 'Angleterre', null, 'Herbacé, épicé, herbeux', 'gr', null, 'mixed', 5.0, 8.0);
CALL add_hop('Brewer\''s Gold', 'Angleterre', null, 'Épicé, fruité (cassis)', 'gr', null, 'mixed', 4.0, 9.0);
CALL add_hop('Challenger', 'Angleterre', null, 'Épicé, fruité', 'gr', null, 'mixed', 6.0, 9.0);
CALL add_hop('East Kent Goldings', 'Angleterre', null, 'Terreux, agrumes', 'gr', null, 'aromatic', 4.0, 6.0);
CALL add_hop('Fuggle', 'Angleterre', null, 'Herbacé, boisé, épicé', 'gr', null, 'aromatic', 3.5, 5.0);
CALL add_hop('Goldings', 'Angleterre', null, 'Floral, herbacé, épicé', 'gr', null, 'aromatic', 4.0, 6.0);
CALL add_hop('Northern Brewer', 'Angleterre', null, 'Agrumes, herbacé, boisé', 'gr', null, 'mixed', 7.0, 10.0);
CALL add_hop('Pilgrim', 'Angleterre', null, 'Herbacé', 'gr', null, 'mixed', 9.0, 13.0);
CALL add_hop('Target', 'Angleterre', null, 'Agrumes épicé', 'gr', null, 'mixed', 8.0, 13.0);
CALL add_hop('Whitbread Golding', 'United Kingdoms', null, 'Boisé, herbacé, fruité', 'gr', null, 'mixed', 5.0, 8.0);
CALL add_hop('Aurora', 'Slovénie', null, 'Floral, herbacé', 'gr', null, 'mixed', 6.0, 10.0);
CALL add_hop('Hallertau', 'Allemagne', null, 'Floral, fruité (raisin)', 'gr', null, 'mixed', 9.0, 12.0);
CALL add_hop('Hersbrucker', 'Allemagne', null, 'Fruité, floral, épicé', 'gr', null, 'aromatic', 2.0, 5.0);
CALL add_hop('Marynka', 'Pologne', null, 'Herbacé, terreux', 'gr', null, 'mixed', 9.0, 12.0);
CALL add_hop('Opal', 'Allemagne', null, 'Agrumes, épicé', 'gr', null, 'mixed', 5.0, 8.0);
CALL add_hop('Pearl', 'Allemagne', null, 'Herbacé, épicé, fruité', 'gr', null, 'mixed', 6.0, 9.0);
CALL add_hop('Saaz', 'Rép. Tchèque', null, 'Floral, fruité, herbacé', 'gr', null, 'aromatic', 2.0, 6.0);
CALL add_hop('Saphir', 'Allemagne', null, 'Agrumes, fruité', 'gr', null, 'aromatic', 2.0, 5.0);
CALL add_hop('Smaragd', 'Allemagne', null, 'Boisé, épicé, herbacé', 'gr', null, 'aromatic', 4.0, 6.0);
CALL add_hop('Styrian Golding', 'Autriche', null, 'Épicé', 'gr', null, 'aromatic', 4.0, 6.0);
CALL add_hop('Tettnanger', 'Allemagne', null, 'Épicé, herbacé', 'gr', null, 'aromatic', 3.0, 6.0);
CALL add_hop('Aramis', 'France', null, 'Épicé, herbacé, agrumes', 'gr', null, 'mixed', 8.0, 8.5);
CALL add_hop('Bouclier', 'France', null, 'Fruité, agrumes, herbacé', 'gr', null, 'mixed', 8.0, 9.0);
CALL add_hop('Strisselspalt', 'France', null, 'Fruité (citron), épicé', 'gr', null, 'aromatic', 3.0, 5.0);
CALL add_hop('Triskel', 'France', null, 'Fruité, floral, agrumes', 'gr', null, 'aromatic', 4.5, 7.0);
CALL add_hop('Amarillo', 'USA', null, 'Floral, agrumes', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Cascade', 'USA', null, 'Agrumes, résineux', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Centennial', 'USA', null, 'Floral, agrumes', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Chinook', 'USA', null, 'Épicé, agrumes, résineux', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Colombus', 'USA', null, 'Herbacé, résineux, agrumes', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Galena', 'USA', null, 'Fruité (pêche), boisé, herbacé', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Nugget', 'USA', null, 'Herbacé, boisé, résineux', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Simcoe', 'USA', null, 'Fruité (abricot), herbacé, résineux', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Ahtanum', 'USA', null, 'Floral, agrumes, résineux', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Citra', 'USA', null, 'Fruité (pêche), agrumes', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Crystal', 'USA', null, 'Fruité (tropical), boisé, herbacé', 'gr', null, 'aromatic', 5.0, 8.0);
CALL add_hop('Willamette', 'USA', null, 'Fruité, herbacé, épicé', 'gr', null, 'aromatic', 5.0, 8.0);

CALL add_malt('Malt Pilsner', null, null, 'Malté','kg', 15.5, 2, 3, 'Pilsen', 'barley');
CALL add_malt('Malt Pilsner', null, null, 'Malté','kg', 15.5, 2, 4, 'Pilsen', 'barley');
CALL add_malt('Malt Pale Ale', null, null, 'Malté','kg', 15.0, 5, 7, 'Pale Ale', 'barley');
CALL add_malt('Malt Vienne', null, null, 'Malté','kg', 15.4, 6, 9, 'Vienne', 'barley');
CALL add_malt('Malt Munich', null, null, 'Malté','kg', 15.3, 12, 17, 'Munich', 'barley');
CALL add_malt('Malt Munich', null, null, 'Malté','kg', 15.2, 20, 25, 'Munich', 'barley');
CALL add_malt('Malt Acidulé', null, null, 'Malté','kg', 17.9, 3, 6, 'Acidulé', 'barley');
CALL add_malt('Malt Mélanoïdé', null, null, 'Malté','kg', 15.5, 60, 80, 'Spécial', 'barley');
CALL add_malt('Malt de blé', null, null, 'Malté','kg', 15.9, 100, 140, 'Blé', 'wheat');
CALL add_malt('Malt Carapils', null, null, 'Malté','kg', 15.5, 25, 65, 'Pilsen', 'barley');
CALL add_malt('Malt Carahell', null, null, 'Malté','kg', 15.6, 20, 30, 'Pilsen', 'barley');
CALL add_malt('Malt Carared', null, null, 'Malté','kg', 16.1, 40, 60, 'Roux', 'barley');
CALL add_malt('Malt Caraamber', null, null, 'Malté','kg', 15.5, 60, 80, 'Ambré', 'barley');
CALL add_malt('Malt Caramunich', null, null, 'Malté','kg', 15.2, 80, 100, 'Munich', 'barley');
CALL add_malt('Malt Caramunich', null, null, 'Malté','kg', 15.5, 110, 130, 'Munich', 'barley');
CALL add_malt('Malt Caramunich', null, null, 'Malté','kg', 15.7, 140, 160, 'Munich', 'barley');
CALL add_malt('Malt Caraaroma', null, null, 'Malté','kg', 15.8, 350, 450, 'Spécial', 'barley');
CALL add_malt('Malt Carabelge', null, null, 'Malté','kg', 15.8, 30, 35, 'Belge', 'barley');
CALL add_malt('Malt caramélisé', null, null, 'Malté','kg', 15.8, 170, 220, 'Caramel', 'barley');
CALL add_malt('Malt Pilsner Bohème', null, null, 'Malté','kg', 15.5, 3, 4, 'Pilsen / Bohème', 'barley');
CALL add_malt('Malt de Bohème', null, null, 'Malté','kg', 15.8, 3, 5, 'Bohème', 'barley');
CALL add_malt('Malt d''abbaye', null, null, 'Malté','kg', 15.6, 40, 50, 'Belge', 'barley');
CALL add_malt('Malt torréfié', null, null, 'Malté','kg', 19.0, 1100, 1200, 'Torréfié / Chocolat', 'barley');
CALL add_malt('Malt torréfié', null, null, 'Malté','kg', 18.5, 1300, 1500, 'Torréfié / Chocolat', 'barley');
CALL add_malt('Malt de seigle torréfié', null, null, 'Malté','kg', 19.5, 500, 800, 'Seigle / Torréfié', 'barley');
CALL add_malt('Malt d''épeautre torréfié', null, null, 'Malté','kg', 41.0, 450, 650, 'Epeautre / Torréfié', 'barley');
CALL add_malt('Malt spécial W', null, null, 'Malté','kg', 20.0, 280, 320, 'Spécial', 'barley');
CALL add_malt('Malt Barke vienne', null, null, 'Malté','kg', 18.5, 6, 9, 'Vienne', 'barley');
CALL add_malt('Malt Barke Munich', null, null, 'Malté','kg', 17.0, 17, 22, 'Munich', 'barley');

CALL add_yeast('SAFALE BE-256 (abbaye)', null, null, 'Fermente très rapidement et révèle des arômes subtils et bien équilibrés',
'Sachet', 4.8, 'Abbaye / Belge', 'high', 15, 25);

CALL add_yeast('SAFALE F-2', null, null, 'Se caractérise par un profil aromatique neutre qui respecte les caractéristiques de la bière de base.',
'Sachet', 4.3, 'Refermentation', 'low', 15, 25);

CALL add_yeast('SAFALE S-04', null, null, 'Excellentes propriétés de sédimentation, favorise une fermentation rapide',
'Sachet', 3.3, 'Ale', 'high', 18, 24);

CALL add_yeast('SAFLAGER S-23', null, null, 'Fournit des bières Pils fruitées et riches en ester',
'Sachet', 4.4, 'Lager / Pilsner', 'low', 9, 15);

CALL add_yeast('SAFALE US-05', null, null, 'Pour des bières balancées avec peu de diacétyle et un après-goût pur et rafraîchissant',
'Sachet', 3.4, 'Ale', 'high', 15, 24);

CALL add_yeast('SAFALE T-58', null, null, 'Développe des arômes poivrés et épicés.',
'Sachet', 2.7, 'Saison', 'high', 18, 24);

CALL add_yeast('LalBrew Windsor', null, null, 'Levure de fermentation haute universelle fruitée',
'Sachet', 4.5, 'Ale', 'high', 15, 25);

CALL add_yeast('Bavarian Wheat M20', null, null, 'Sensation soyeuse en bouche et de délicieux arômes de banane et de clou de girofle.',
'Sachet', 3.2, 'Weizen', 'high', 18, 30);

CALL add_yeast('Hophead Ale M66', null, null, 'Un mélange d''enzymes de levure qui renforce les arômes et les esters, parfait pour les NEIPA',
'Sachet', 4.5, 'IPA / NEIPA', 'high', 18, 22);

CALL add_yeast('Belgian Tripel M31', null, null, 'Offre une grande tolérance à l''alcool, ce qui la rend idéale pour un éventail de bières belges',
'Sachet', 4.6, 'Abbaye / Belge', 'high', 18, 28);

CALL add_yeast('New World Strong M42', null, null, 'Convient notamment aux Porters et Russian Imperial Stouts.',
'Sachet', 3.3, 'Porter / Stout', 'high', 16, 22);

SELECT add_ingredient('Sucre de canne', null, null, null,'gr', null);
SELECT add_ingredient('Miel', null, null, null,'gr', null);
SELECT add_ingredient('Café', null, null, null,'gr', null);
SELECT add_ingredient('Lait', null, null, null,'l', null);

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
VALUES(1, 'Préparation', 0, '', 'preparation', 1);

INSERT INTO brewing_step
VALUES(2, 'Empâtage', 60, '', 'beer_mash', 1);

INSERT INTO brewing_step
VALUES(3, 'Mash-out', 15, '', 'mash_out', 1);

INSERT INTO brewing_step
VALUES(4, 'Filatration des drêches', 0, '', 'filtration', 1);

INSERT INTO brewing_step
VALUES(5, 'Mesure de la densité', 0, '', 'measure', 1);

INSERT INTO brewing_step
VALUES(6, 'Ébullition', 60, '', 'boiling', 1);

INSERT INTO brewing_step
VALUES(7, 'Refroidissement', 0, '', 'cooling', 1);

INSERT INTO brewing_step
VALUES(8, 'Fermentation', 120, '', 'fermentation', 1);

INSERT INTO brewing_step
VALUES(9, 'Mise en bouteille', 500, '', 'bottling', 1);

INSERT INTO brewing_step
VALUES(1, 'Préparation', 0, '', 'preparation', 2);

INSERT INTO brewing_step
VALUES(2, 'Empâtage', 60, '', 'beer_mash', 2);

INSERT INTO brewing_step
VALUES(3, 'Mash-out', 15, '', 'mash_out', 2);

INSERT INTO brewing_step
VALUES(4, 'Filatration des drêches', 0, '', 'filtration', 2);

INSERT INTO brewing_step
VALUES(5, 'Mesure de la densité', 0, '', 'measure', 2);

INSERT INTO brewing_step
VALUES(6, 'Ébullition', 60, '', 'boiling', 2);

INSERT INTO brewing_step
VALUES(7, 'Refroidissement', 0, '', 'cooling', 2);

INSERT INTO brewing_step
VALUES(8, 'Fermentation', 120, '', 'fermentation', 2);

INSERT INTO brewing_step
VALUES(9, 'Mise en bouteille', 500, '', 'bottling', 2);

-- Là ça devient compliqué de retrouver les ID des ingrédients à la main =)
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