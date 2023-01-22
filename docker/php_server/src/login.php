<?php include './header.php';?>
<?php

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
		//Retreive the user ID and put it in the session
		$customer = $query->fetch();
		$_SESSION['customer_id'] = $customer['customer_id'];
		
        // Démarrer une session et rediriger vers la page protégée
        $_SESSION['logged_in'] = true;
        $_SESSION['username'] = $username;
        echo "<script>window.location = './index.php'</script>";
    }else{
        // Afficher un message d'erreur
        echo "Invalid username or password.";
    }
}
?>
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
<?php include './footer.php';?>