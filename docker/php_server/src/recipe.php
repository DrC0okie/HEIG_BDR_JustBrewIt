<?php
	session_start();
	try {
		$db = new PDO("pgsql:host=bdr-project-postgresql;dbname=just_brew_it", "bdr", "bdr");
		$db->exec("SET search_path TO justbrewit");
	} catch (PDOException $e) {
		echo $e->getMessage();
		die();
	}
?>

<!DOCTYPE html>
<html lang="FR">
  <head>
    <title>Just Brew It!</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss/dist/tailwind.min.css">
	<link rel="stylesheet" href="cards/style.css">
  </head>
  <body class="bg-gray-200">
    <header class="bg-white p-6">
      <nav class="flex justify-between items-center">
          <h1 class="text-lg font-medium"><a href="./index.php">Just Brew It!</a></h1>
        <ul class="flex">
          <li><a href="./index.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Accueil</a></li>
          <li><a href="./recipes.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Recettes</a></li>
          <li><a href="./login.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Login</a></li>
        </ul>
      </nav>
    </header>
    <main class="p-6">
	<?php
		if (isset($_GET['recipe_number'])) {
    $recipeNumber = $_GET['recipe_number'];

    $query = $db->prepare("SELECT * FROM getBeerFromRecipe(?)");
    $query->execute([$recipeNumber]);
    $beer = $query->fetch();
	
	$query = $db->prepare("SELECT * FROM getHopsFromRecipes(?)");
    $query->execute([$recipeNumber]);
    $hops = $query->fetchAll();
	
	$query = $db->prepare("SELECT * FROM getMaltsFromRecipes(?)");
    $query->execute([$recipeNumber]);
    $malts = $query->fetchAll();
	
	$query = $db->prepare("SELECT * FROM getYeastFromRecipes(?)");
    $query->execute([$recipeNumber]);
    $yeasts = $query->fetchAll();
	
	$query = $db->prepare("SELECT * FROM getMiscIngredientsFromRecipe(?)");
    $query->execute([$recipeNumber]);
    $ingredients = $query->fetchAll();
	
	$query = $db->prepare("SELECT * FROM getStepsFromRecipe(?)");
    $query->execute([$recipeNumber]);
    $steps = $query->fetchAll();
	?>

			<h2 class="text-lg font-medium"><a href="./index.php">Bière produite</a></h2>
			<div class="beerCard">
				<h3 class="card-title"><?= $beer['nom'] ?></h3>
				<p class="card-text">Alcool: <?= $beer['alcool'] ?>%</p>
				<p class="card-text">Amertume: <?= $beer['amertume'] ?> IBU</p>
				<p class="card-text">Couleur: <?= $beer['couleur'] ?> EBC</p>
			</div>

	<div class="card">
		<h2 class="text-lg font-medium"><a href="./index.php">Houblons</a></h2>
		<div class="card-grid">
			<?foreach ($hops as $hop) { 
				?>
				<div class="hopsCard">
					<h3 class="card-title"><?= $hop['name'] ?></h3>
					<p class="card-text">Étape: <?= $hop['step_name'] ?></p>
					<p class="card-text">Quantité: <?= $hop['quantity'] ?><?= $hop['quantity_unit'] ?></p>
					<p class="card-text">Origine: <?= $hop['origin'] ?></p>
					<p class="card-text">Type: <?= $hop['type'] ?></p>
					<p class="card-text">Acide alpha: <?= $hop['low_alpha_acid'] ?> - <?= $hop['high_alpha_acid'] ?>%</p>
					<p class="card-text">Description: <?= $hop['specificity'] ?></p>
				</div>
			<?php } ?>
		</div>
	</div>
	<div class="card">
		<h2 class="text-lg font-medium"><a href="./index.php">Malts</a></h2>
		<div class="card-grid">
			<?foreach ($malts as $malt) { 
				?>
				<div class="maltsCard">
					<h3 class="card-title"><?= $malt['name'] ?></h3>
					<p class="card-text">Étape: <?= $malt['step_name'] ?></p>
					<p class="card-text">Quantité: <?= $malt['quantity'] ?><?= $malt['quantity_unit'] ?></p>
					<p class="card-text">Origine: <?= $malt['origin'] ?></p>
					<p class="card-text">Type: <?= $malt['type'] ?></p>
					<p class="card-text">Céréale: <?= $malt['cereal'] ?></p>
					<p class="card-text">EBC: <?= $malt['ebc_min'] ?> - <?= $malt['ebc_max'] ?></p>
					<p class="card-text">Description: <?= $malt['specificity'] ?></p>
				</div>
			<?php } ?>
		</div>
	</div>
	<div class="card">
		<h2 class="text-lg font-medium"><a href="./index.php">Levures</a></h2>
		<div class="card-grid">
			<?foreach ($yeasts as $yeast) { 
				?>
				<div class="yeastsCard">
					<h3 class="card-title"><?= $yeast['name'] ?></h3>
					<p class="card-text">Étape: <?= $yeast['step_name'] ?></p>
					<p class="card-text">Quantité: <?= $yeast['quantity'] ?><?= $yeast['quantity_unit'] ?></p>
					<p class="card-text">Origine: <?= $yeast['origin'] ?></p>
					<p class="card-text">Type de bière: <?= $yeast['beer_type'] ?></p>
					<p class="card-text">Type de bière: <?= $yeast['fermentation'] ?></p>
					<p class="card-text">Température de fermentation: <?= $yeast['min_temperature'] ?> - <?= $yeast['max_temperature'] ?>°c</p>
					<p class="card-text">Description: <?= $yeast['specificity'] ?></p>
				</div>
			<?php } ?>
		</div>
	</div>
	<div class="card">
		<h2 class="text-lg font-medium"><a href="./index.php">Autres ingrédients</a></h2>
		<div class="card-grid">
			<?foreach ($ingredients as $ingredient) { 
				?>
				<div class="miscCard">
					<h3 class="card-title"><?= $ingredient['name'] ?></h3>
					<p class="card-text">Étape: <?= $ingredient['step_name'] ?></p>
					<p class="card-text">Quantité: <?= $ingredient['quantity'] ?><?= $ingredient['quantity_unit'] ?></p>
					<p class="card-text">Origine: <?= $ingredient['origin'] ?></p>
					<p class="card-text">Description: <?= $ingredient['specificity'] ?></p>
				</div>
			<?php } ?>
		</div>
	</div>
	<div class="card">
		<h2 class="text-lg font-medium"><a href="./index.php">Étapes de brassage</a></h2>
		<div class="card-grid">
			<?foreach ($steps as $step) { 
				?>
				<div class="stepCard">
					<h3 class="card-title"><?= $step['step_name'] ?></h3>
					<p class="card-text">Numéro étape: <?= $step['step_number'] ?></p>
					<p class="card-text">Durée: <?= $step['duration'] ?> minutes</p>
					<p class="card-text">Type d'étape: <?= $step['category'] ?></p>
					<p class="card-text">Description: <?= $step['description'] ?></p>
				</div>
			<?php } ?>
		</div>
	</div>
	<?php } else {
			header("Location: recipes.php");
		}
	?>
				
    </main>
    <footer class="bg-white p-6">
      <p class="text-center text-gray-600">Copyright © Mon site</p>
    </footer>
  </body>
</html>