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

<form method="post">
    <label for="username">Username:</label>
    <input type="text" id="username" name="username"><br>
    <label for="password">Password:</label>
    <input type="password" id="password" name="password"><br>
    <input type="submit" name="submit" value="Log in">
</form>