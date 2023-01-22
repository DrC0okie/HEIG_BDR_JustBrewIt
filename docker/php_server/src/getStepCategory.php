<?php
session_start();

try {
    $db = new PDO("pgsql:host=bdr-project-postgresql;dbname=just_brew_it", "bdr", "bdr");
    $db->exec("SET search_path TO justbrewit");
    $db->exec("SET client_encoding TO 'UTF8'");
} catch (PDOException $e) {
    echo $e->getMessage();
    die();
}

if(isset($_SESSION['logged_in']) && $_SESSION['logged_in']) {
    $query = $db->prepare("SELECT enum_range(NULL::category) as category");
    $query->execute();
    $stepCategories = $query->fetchAll();
    echo json_encode($stepCategories);
} else {
    header("Location: login.php");
}