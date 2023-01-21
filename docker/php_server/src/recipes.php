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
    <link rel="icon" type="image/x-icon" href="./favicon.ico">
</head>
<body class="bg-gray-200">
<header class="bg-white p-6">
    <nav class="flex justify-between items-center">
        <h1 class="text-lg font-medium"><a href="./index.php">Just Brew It!</a></h1>
        <ul class="flex">
            <li><a href="./index.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Accueil</a></li>
            <li><a href="./recipes.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Recettes</a></li>
            <?php
            if(isset($_SESSION['logged_in']) && $_SESSION['logged_in']) {
                echo '<li><a href="./logout.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Logout</a></li>';
            } else {
                echo '<li><a href="./login.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Login</a></li>';
            }
            ?>
        </ul>
    </nav>
</header>
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
			<h3 class="card-title"><?= $recipe['name'] ?></h3>
			<p class="card-text">Difficulté: <?= $recipe['difficulty'] ?>/5</p>
			<p class="card-text">Numero de recette: <?= $recipe['recipe_number'] ?></p>
			<p class="card-text">Quantité: <?= $recipe['quantity'] ?>L</p>
			</div>
	<?php }
} else {
    header("Location: login.php");
}
	?>
</main>
<footer class="bg-white p-6">
    <p class="text-center text-gray-600">Copyright © Mon site</p>
</footer>
</body>
</html>