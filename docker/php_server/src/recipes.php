<?php include './header.php';?>
<main class="p-6">
    <?php
		if(isset($_SESSION['username'])){
			$query = $db->prepare("SELECT * FROM get_recipe_info_by_customer_id(?)");
			$query->execute([$_SESSION['customer_id']]);
			$recipes = $query->fetchAll();
			
			foreach ($recipes as $recipe) { ?>
			<div class="card">
				<h2 class="text-lg font-medium"><a href="./index.php">Recettes</a></h2>
				<div class="card-grid">
					<div class="stepCard">
						<a href="recipe.php?recipe_number=<?= $recipe['recipe_number'] ?>">
							<h3 class="card-title"><?= $recipe['name'] ?></h3>
							<p class="card-text">Difficulté: <?= $recipe['difficulty'] ?>/5</p>
							<p class="card-text">Numero de recette: <?= $recipe['recipe_number'] ?></p>
							<p class="card-text">Quantité: <?= $recipe['quantity'] ?>L</p>
						</a>
					</div>
				</div>
			</div>
	<?php }
} else {
            echo "<script>window.location = './login.php'</script>";
}
	?>

    <button
            class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600"
            onclick="window.location.href='./createRecipe.php'"
    >
        Ajouter une recette
    </button>

</main>
<?php include './footer.php';?>