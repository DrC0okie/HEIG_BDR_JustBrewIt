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