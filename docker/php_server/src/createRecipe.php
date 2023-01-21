<?php include './header.php';?>
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
<main class="p-6">
    <form class="bg-white p-6 rounded-lg">
        <h2 class="text-lg font-medium mb-4">Ajouter une nouvelle recette</h2>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="recipe-name">
                Nom de la recette:
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="text"
                    id="recipe-name"
                    name="recipe-name"
                    required
            >
        </div>
        <div class="mb-4 flex flex-col">
            <label class="block text-gray-700 font-medium mb-2" for="difficulty-slider">Difficulté:</label>
            <div class="relative">
                <input
                        class="w-full bg-gray-200 rounded-lg mb-2"
                        type="range"
                        id="difficulty-slider"
                        name="difficulty-slider"
                        min="0"
                        max="5"
                        step="1"
                        value="0"
                >
            </div>
            <div class="flex justify-between text-xs text-gray-700">
                <span>0</span>
                <span>1</span>
                <span>2</span>
                <span>3</span>
                <span>4</span>
                <span>5</span>
            </div>
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="beer-name">
                Nom de la bière :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="text"
                    id="beer-name"
                    name="beer-name"
                    required
            >
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="beer-color">
                Couleur de la bière :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="number"
                    id="beer-color"
                    name="beer-color"
                    step="1"
                    min="4"
                    max="138"
                    required
            >
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="alcohol-percentage">
                Pourcentage d'alcoolémie :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="number"
                    step="0.01"
                    min="0"
                    max="100"
                    id="alcohol-percentage"
                    name="alcohol-percentage"
                    placeholder="0.0"
            >
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="beer-bitterness">
                Amertume de la bière :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="number"
                    step="1"
                    min="0"
                    max="100"
                    id="beer-bitterness"
                    name="beer-bitterness"
                    required
            >
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="beer-pre-density">
                Densité avant ébullition de la bière :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="number"
                    min="0"
                    id="beer-pre-density"
                    name="beer-pre-density"
                    required
            >
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="beer-ini-density">
                Densité initiale de la bière :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="number"
                    min="0"
                    id="beer-ini-density"
                    name="beer-ini-density"
                    required
            >
        </div>
        <div class="mb-4">
            <label class="block text-gray-700 font-medium mb-2" for="beer-final-density">
                Densité finale de la bière :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="number"
                    min="0"
                    id="beer-final-density"
                    name="beer-final-density"
                    required
            >
        </div>
        <div id="steps">
        </div>
        <button type="button" onclick="addStep()" class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600">
            Ajouter une étape
        </button>
    <?php
    $actualStepNb = 1;

    ?>
        <button class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600">
            Ajouter la recette
        </button>
    </form>


    <script>
        function addStep() {
            const container = document.getElementById("steps");
            const newStep = document.createElement("div");
            let actualStepNb = container.childElementCount + 1;
            newStep.innerHTML = `
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${actualStepNb}-name">
                        Nom de l'étape ${actualStepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="text"
                            id="step-${actualStepNb}-name"
                            name="step-${actualStepNb}-name"
                            required
                    >
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${actualStepNb}-duration">
                        Durée de l'étape ${actualStepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="number"
                            min="0"
                            id="step-${actualStepNb}-duration"
                            name="step-${actualStepNb}-duration"
                            required
                    >
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${actualStepNb}-duration">
                        Description de l'étape ${actualStepNb} :
                    </label>
                    <textarea
                            class="border border-gray-400 p-2 w-full"
                            id="step-${actualStepNb}-description"
                            name="step-${actualStepNb}-description"
                            required
                    ></textarea>
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${actualStepNb}-category">
                        Catégorie de l'étape ${actualStepNb} :
                    </label>
                    <select
                            class="form-select py-2 px-3 block w-full leading-5appearance-none bg-white border border-gray-400 text-gray-700 py-2 px-3 pr-8 focus:outline-none focus:shadow-outline-blue focus:border-blue-300"
                            id="step-${actualStepNb}-category"
                            name="step-${actualStepNb}-category"
                            required
                    >
                        <option value="malt">Malt</option>
                        <option value="hops">Houblon</option>
                        <option value="yeast">Levure</option>
                        <option value="water">Eau</option>
                        <option value="other">Autre</option>
                    </select>
            `;
            <?php

            ?>
            container.appendChild(newStep);
        }
    </script>
</main>
<footer class="bg-white p-6">
    <p class="text-center text-gray-600">Copyright © Mon site</p>
</footer>
</body>
</html>