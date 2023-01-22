<?php
session_start();
header('Content-type: text/plain; charset=utf-8');

try {
    $db = new PDO("pgsql:host=bdr-project-postgresql;dbname=just_brew_it", "bdr", "bdr");
    $db->exec("SET search_path TO justbrewit");
    $db->exec("SET client_encoding TO 'UTF8'");
} catch (PDOException $e) {
    echo $e->getMessage();
    die();
}

if(isset($_SESSION['logged_in']) && $_SESSION['logged_in']) {
    $query = $db->prepare("SELECT name, quantity_unit, ingredient_id from ingredient");
    $query->execute();
    $stepCategories = $query->fetchAll();
    echo json_encode($stepCategories, JSON_UNESCAPED_UNICODE);
} else {
    header("Location: login.php");
}