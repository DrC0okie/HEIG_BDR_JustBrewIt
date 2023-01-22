<?php include './header.php';?>
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
			$stepCount = $steps[0]['step_count']
			?>

			<h2 class="text-lg font-medium">Bière produite</a></h2>
			<div class="beerCard">
				<h3 class="card-title"><?= $beer['nom'] ?></h3>
				<p class="card-text">Alcool: <?= $beer['alcool'] ?>%</p>
				<p class="card-text">Amertume: <?= $beer['amertume'] ?> IBU</p>
				<p class="card-text">Couleur: <?= $beer['couleur'] ?> EBC</p>
			</div>
			<div class="card">
				<h2 class="text-lg font-medium">Houblons</a></h2>
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
				<h2 class="text-lg font-medium">Malts</a></h2>
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
				<h2 class="text-lg font-medium">Levures</a></h2>
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
				<h2 class="text-lg font-medium">Autres ingrédients</a></h2>
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
				<h2 class="text-lg font-medium">Étapes de brassage</a></h2>
				<div class="card-grid">
					<?foreach ($steps as $step) { 
						?>
						<div class="stepCard">
							<h3 class="card-title"><?= $step['step_name'] ?></h3>
							<p class="card-text">Numéro étape: <?= $step['step_number'] ?></p>
							<p class="card-text">Durée: <?= $step['duration'] ?> minutes</p>
							<p class="card-text">Type d'étape: <?= $step['category'] ?></p>
						</div>
					<?php } ?>
				</div>
			</div>
	<?php } else {
			header("Location: login.php");
		}
	?>
    <button class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600"
            onclick="window.location.href='./brewStep.php?recipe_number=<?= $recipeNumber ?>&step_count=<?= $stepCount ?>&amp;step_number=1'">
        Commencer le brassage
    </button>
		
</main>
<?php include './footer.php';?>