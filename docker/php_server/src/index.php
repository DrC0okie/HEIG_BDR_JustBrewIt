<!DOCTYPE html>
<html lang="FR">
  <head>
    <title>Just Brew It!</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss/dist/tailwind.min.css">
  </head>
  <body class="bg-gray-200">
    <header class="bg-white p-6">
      <nav class="flex justify-between items-center">
          <h1 class="text-lg font-medium"><a href="./index.php">Just Brew It!</a></h1>
        <ul class="flex">
          <li><a href="./index.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Accueil</a></li>
          <li><a href="./recipes.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Recettes</a></li>
          <li><a href="./login.php" class="px-4 py-2 text-gray-800 hover:text-indigo-500">Login</a></li>
        </ul>
      </nav>
    </header>
    <main class="p-6">
      <h2 class="text-2xl font-medium mb-4">Bienvenue sur mon site</h2>
      <p class="text-gray-700">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed auctor, magna eget tincidunt bibendum, augue est molestie diam, at auctor magna massa ut augue.</p>
    </main>
    <footer class="bg-white p-6">
      <p class="text-center text-gray-600">Copyright © Mon site</p>
    </footer>
  </body>
</html>
<?php
// connect to the database