<?php
session_start();

// Connexion à la base de données
try {
    $db = new PDO("pgsql:host=bdr-project-postgresql;dbname=just_brew_it", "bdr", "bdr");
    $db->exec("SET search_path TO justbrewit");
} catch (PDOException $e) {
    echo $e->getMessage();
    die();
}

// Vérifier si l'utilisateur a soumis les informations de connexion
if(isset($_POST['submit'])){
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Préparer une requête pour vérifier les informations d'identification contre la base de données
    $query = $db->prepare("SELECT * FROM customer WHERE e_mail_address = :username AND password = :password");
    $query->bindParam(':username', $username);
    $query->bindParam(':password', $password);
    $query->execute();

    // Vérifier si les informations d'identification sont valides
    if($query->rowCount() == 1){
        // Démarrer une session et rediriger vers la page protégée
        $_SESSION['logged_in'] = true;
        $_SESSION['username'] = $username;
        header("Location: index.php");
    }else{
        // Afficher un message d'erreur
        echo "Invalid username or password.";
    }
}
?>
<!DOCTYPE html>
<html lang="FR">
<head>
    <title>Just Brew It!</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss/dist/tailwind.min.css">
</head>
<body class="bg-gray-200">
<header class="bg-white p-6">
    <nav class="flex justify-between items-center">
        <h1 class="text-lg font-medium">Just Brew It!</h1>
        <ul class="flex">
            <li><a href="#" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Accueil</a></li>
            <li><a href="#" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Recettes</a></li>
            <li><a href="./login.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Login</a></li>
        </ul>
    </nav>
</header>
<main class="p-6">
    <form class="bg-white p-6 rounded-lg" method="post">
        <h2 class="text-lg font-medium mb-4">Connexion</h2>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="username">
                Email
            </label>
            <input
                class="w-full border border-gray-400 p-2 rounded-lg"
                type="text"
                id="username"
                name="username"
            />
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="password">
                Mot de passe
            </label>
            <input
                class="w-full border border-gray-400 p-2 rounded-lg"
                type="password"
                id="password"
                name="password"
            />
        </div>
        <div class="text-center mt-6">
            <input class="bg-indigo-500 text-white py-2 px-4 rounded-lg hover:bg-indigo-600"
                   type="submit" name="submit" value="Connexion">
        </div>
    </form>
</main>
<footer class="bg-white p-6">
    <p class="text-center text-gray-600">Copyright © Mon site</p>
</footer>
</body>
</html>