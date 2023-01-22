<?php include './header.php';?>
<?php
if(isset($_SESSION['username'])){

    $query = $db->prepare("SELECT get_customer_id_by_email(:email);");


    if (isset($_POST['recipe-name']) &&
    isset($_POST['difficulty-slider']) &&
    isset($_POST['beer-name']) &&
    isset($_POST['beer-color']) &&
    isset($_POST['alcohol-percentage']) &&
    isset($_POST['beer-number']) &&
    isset($_POST['beer-bitterness']) &&
    isset($_POST['beer-pre-density']) &&
    isset($_POST['beer-ini-density']) &&
    isset($_POST['beer-final-density']) &&
    isset($_POST['step-1-name']) &&
    isset($_POST['step-1-duration']) &&
    isset($_POST['step-1-category']) &&
    isset($_POST['step-1-description'])) {

        $query = $db->prepare("INSERT INTO beer VALUES (DEFAULT, :name, :color, :alcohol_percentage, :bitterness, :pre_density, :ini_density, :final_density);");
        $query->execute([
            'name' => $_POST['beer-name'],
            'color' => $_POST['beer-color'],
            'alcohol_percentage' => $_POST['alcohol-percentage'],
            'bitterness' => $_POST['beer-bitterness'],
            'pre_density' => $_POST['beer-pre-density'],
            'ini_density' => $_POST['beer-ini-density'],
            'final_density' => $_POST['beer-final-density']
        ]);

        $query = $db->prepare("INSERT INTO recipe VALUES (DEFAULT, :name, :difficulty,  :customer_id, :beer_id, :beer_nb);");

        $query->execute([
            'name' => $_POST['recipe-name'],
            'difficulty' => $_POST['difficulty-slider'],
            'customer_id' => $_SESSION['customer_id'],
            'beer_id' => $db->lastInsertId(),
            'beer_nb' => $_POST['beer-number']
        ]);

        $recipe_id = $db->lastInsertId();

        $step_count = 1;

        while(isset($_POST['step-' . $step_count . '-name']) &&
        isset($_POST['step-' . $step_count . '-duration']) &&
        isset($_POST['step-' . $step_count . '-category']) &&
        isset($_POST['step-' . $step_count . '-description'])) {
            $query = $db->prepare("INSERT INTO brewing_step VALUES (:id, :name, :duration, :description, :category, :recipe_id);");
            $query->execute([
                'id' => $step_count,
                'name' => $_POST['step-' . $step_count . '-name'],
                'duration' => $_POST['step-' . $step_count . '-duration'],
                'description' => $_POST['step-' . $step_count . '-description'],
                'category' => $_POST['step-' . $step_count . '-category'],
                'recipe_id' => $recipe_id
            ]);

            $ingredient_count = 1;

            while(isset($_POST['step-' . $step_count .'-ingredient-' . $ingredient_count]) &&
                isset($_POST['step-' . $step_count .'-ingredient-' . $ingredient_count . '-quantity'])) {
                if (preg_match('/^\d+$/', $_POST['step-' . $step_count .'-ingredient-' . $ingredient_count])) {
                    $ing_id = $_POST['step-' . $step_count .'-ingredient-' . $ingredient_count];
                } else {
                    echo "new ingredient";
                    $query = $db->prepare("SELECT add_ingredient(:name, :origin, :sub_origin, :specificity, :quantity_unit, :price_per_unit);");

                    $query->execute([
                        'name' => $_POST['step-' . $step_count .'-ingredient-' . $ingredient_count],
                        'origin' => $_POST['step-' . $step_count .'-ingredient-' . $ingredient_count . '-origin'],
                        'sub_origin' => null,
                        'specificity' => $_POST['step-' . $step_count .'-ingredient-' . $ingredient_count . '-specificity'],
                        'quantity_unit' => $_POST['step-' . $step_count .'-ingredient-' . $ingredient_count . '-unity'],
                        'price_per_unit' => null
                    ]);

                    $ing_id = $db->lastInsertId();
                }

                $query = $db->prepare("INSERT INTO ingredient_usage VALUES (:quantity, :step_id, :ingredient_id, :recipe_id);");

                $query->execute([
                    'quantity' => $_POST['step-' . $step_count .'-ingredient-' . $ingredient_count . '-quantity'],
                    'step_id' => $step_count,
                    'ingredient_id' => $ing_id,
                    'recipe_id' => $recipe_id
                ]);

                $ingredient_count++;
            }
            $step_count++;
        }

        echo "<script>window.location = './recipes.php'</script>";
    }

} else {
    echo "<script>window.location = './login.php'</script>";
}
?>
<main class="p-6">
    <form class="bg-white p-6 rounded-lg" method="post">
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
            <label class="block text-gray-700 font-medium mb-2" for="beer-number">
                Quantité de bière[l] :
            </label>
            <input
                    class="border border-gray-400 p-2 w-full"
                    type="number"
                    min="1"
                    step="1"
                    id="beer-number"
                    name="beer-number"
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
					step = "0.001"
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
					step = "0.001"
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
					step = "0.001"
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
        <div class="text-center mt-6">
            <input class="bg-indigo-500 text-white py-2 px-4 rounded-lg hover:bg-indigo-600"
                   type="submit" name="submit" value="Créer la recette">
        </div>
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
                    <label class="block text-gray-700 font-medium mb-2" for="step-${actualStepNb}-category">
                        Catégorie de l'étape ${actualStepNb} :
                    </label>
                    <select
                            class="form-select py-2 px-3 block w-full leading-5appearance-none bg-white border border-gray-400 text-gray-700 py-2 px-3 pr-8 focus:outline-none focus:shadow-outline-blue focus:border-blue-300"
                            id="step-${actualStepNb}-category"
                            name="step-${actualStepNb}-category"
                            required
                    >
                    </select>
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
                    <label class="block text-gray-700 font-medium mb-2">
                        Ingrédients de l'étape ${actualStepNb} :
                    </label>
                </div>
                <div class="mb-4" id="step-${actualStepNb}-ingredients">
                </div>
                <button type="button" onclick="addIngredient(${actualStepNb})" class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600">
                    Ajouter un ingrédient existant
                </button>
                <button type="button" onclick="addNewIngredient(${actualStepNb})" class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600">
                    Ajouter un nouvel ingrédient
                </button>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${actualStepNb}-description">
                        Description de l'étape ${actualStepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="text"
                            id="step-${actualStepNb}-description"
                            name="step-${actualStepNb}-description"
                            required
                    >
                </div>
            `;

            const xhr = new XMLHttpRequest();

            xhr.onreadystatechange = function () {
                let options = "";
                if (this.readyState === 4 && this.status === 200) {
                    const categories = JSON.parse(this.responseText);
                    categories.forEach(category => {
                        options += `<option value="${category[0]}">${category[0]}</option>`;
                    });
                    document.getElementById(`step-${actualStepNb}-category`).innerHTML = options;
                }
            };

            xhr.open('GET', 'getStepCategory.php', true);

            xhr.send();

            container.appendChild(newStep);
        }

        function addIngredient(stepNb) {

            const container = document.getElementById("step-"+ stepNb +"-ingredients");
            const newIngredient = document.createElement("div");
            let actualIngredientNb = container.childElementCount + 1;

            newIngredient.innerHTML = `
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${stepNb}-ingredient-${actualIngredientNb}">
                        Nom de l'ingrédient ${actualIngredientNb} de l'étape ${stepNb} :
                    </label>
                    <select
                            class="form-select py-2 px-3 block w-full leading-5appearance-none bg-white border border-gray-400 text-gray-700 py-2 px-3 pr-8 focus:outline-none focus:shadow-outline-blue focus:border-blue-300"
                            id="step-${stepNb}-ingredient-${actualIngredientNb}"
                            name="step-${stepNb}-ingredient-${actualIngredientNb}"
                            required
                    >
                    </select>
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${stepNb}-ingredient-${actualIngredientNb}-quantity">
                        Quantité de l'ingrédient ${actualIngredientNb} de l'étape ${stepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="number"
                            min="0"
                            step="0.1"
                            id="step-${stepNb}-ingredient-${actualIngredientNb}-quantity"
                            name="step-${stepNb}-ingredient-${actualIngredientNb}-quantity"
                            required
                    >
                </div>
            `;

            const xhr = new XMLHttpRequest();

            xhr.onreadystatechange = function () {
                let options = "";
                if (this.readyState === 4 && this.status === 200) {
                    const ingredients = JSON.parse(this.responseText);
                    ingredients.forEach(ingredient => {
                        options += `<option value="${ingredient[2]}">${ingredient[0]} [${ingredient[1]}]</option>`;
                    });
                    document.getElementById(`step-${stepNb}-ingredient-${actualIngredientNb}`).innerHTML = options;
                }
            };

            xhr.open('GET', 'getIngredients.php', true);

            xhr.send();

            container.appendChild(newIngredient);
        }

        function addNewIngredient(stepNb) {

            const container = document.getElementById("step-"+ stepNb +"-ingredients");
            const newIngredient = document.createElement("div");
            let actualIngredientNb = container.childElementCount + 1;

            newIngredient.innerHTML = `
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${stepNb}-ingredient-${actualIngredientNb}">
                        Nom de l'ingrédient ${actualIngredientNb} de l'étape ${stepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="text"
                            id="step-${stepNb}-ingredient-${actualIngredientNb}"
                            name="step-${stepNb}-ingredient-${actualIngredientNb}"
                            required
                    >
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${stepNb}-ingredient-${actualIngredientNb}-quantity">
                        Quantité de l'ingrédient ${actualIngredientNb} de l'étape ${stepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="number"
                            min="0"
                            step="0.1"
                            id="step-${stepNb}-ingredient-${actualIngredientNb}-quantity"
                            name="step-${stepNb}-ingredient-${actualIngredientNb}-quantity"
                            required
                    >
                </div>

                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${stepNb}-ingredient-${actualIngredientNb}-unity">
                        Unité de l'ingrédient ${actualIngredientNb} de l'étape ${stepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="text"
                            id="step-${stepNb}-ingredient-${actualIngredientNb}-unity"
                            name="step-${stepNb}-ingredient-${actualIngredientNb}-unity"
                            required
                    >
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${stepNb}-ingredient-${actualIngredientNb}-origin">
                        Origine de l'ingrédient ${actualIngredientNb} de l'étape ${stepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="text"
                            id="step-${stepNb}-ingredient-${actualIngredientNb}-origin"
                            name="step-${stepNb}-ingredient-${actualIngredientNb}-origin"
                            required
                    >
                </div>
                <div class="mb-4">
                    <label class="block text-gray-700 font-medium mb-2" for="step-${stepNb}-ingredient-${actualIngredientNb}-specificity">
                        Spécificité de l'ingrédient ${actualIngredientNb} de l'étape ${stepNb} :
                    </label>
                    <input
                            class="border border-gray-400 p-2 w-full"
                            type="text"
                            id="step-${stepNb}-ingredient-${actualIngredientNb}-specificity"
                            name="step-${stepNb}-ingredient-${actualIngredientNb}-specificity"
                            required
                    >
                </div>
            `;

            container.appendChild(newIngredient);
        }
    </script>
</main>
<?php include './footer.php';?>