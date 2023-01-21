<?php include './header.php';?>
<main class="p-6">
    <?php
		if(isset($_SESSION['username'])){
			$email = $_SESSION['username'];

			$query = $db->prepare("SELECT get_customer_id_by_email(:email);");
			$query->bindParam(':email', $email);
			$query->execute();
			$customerId = $query->fetchColumn();

			$query = $db->prepare("SELECT * FROM get_recipe_info_by_customer_id(?)");
			$query->execute([$customerId]);
			$recipes = $query->fetchAll();
			
			foreach ($recipes as $recipe) { ?>
			<div class="card">
				<a href="recipe.php?recipe_number=<?= $recipe['recipe_number'] ?>">
					<h3 class="card-title"><?= $recipe['name'] ?></h3>
					<p class="card-text">Difficulté: <?= $recipe['difficulty'] ?>/5</p>
					<p class="card-text">Numero de recette: <?= $recipe['recipe_number'] ?></p>
					<p class="card-text">Quantité: <?= $recipe['quantity'] ?>L</p>
				</a>
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
<footer class="bg-white p-6">
    <p class="text-center text-gray-600">Copyright © Mon site</p>
</footer>
</body>
</html>