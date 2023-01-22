<?php include './header.php';?>

<main class="p-6">

    <?php
    if (isset($_GET['recipe_number'])&& isset($_SESSION['username'])) {

        $recipeNumber = $_GET['recipe_number'];

        $query = $db->prepare("SELECT * FROM recipe WHERE recipe_number = ?");
        $query->execute([$recipeNumber]);
        $recipe = $query->fetch();

        $query = $db->prepare("SELECT beer_id_fk from recipe where recipe_number = ?");

        $query->execute([$recipeNumber]);
        $beerId = $query->fetch();

        $query = $db->prepare("SELECT * FROM beer WHERE beer_id = ?");
        $query->execute([$beerId['beer_id_fk']]);
        $beer = $query->fetch();

        $query = $db->prepare("SELECT * FROM brewing_step WHERE recipe_number_fk = ?");
        $query->execute([$recipeNumber]);
        $steps = $query->fetchAll();

        $query = $db->prepare("SELECT unnest(enum_range(NULL::category)) as category");
        $query->execute();
        $stepCategories = $query->fetchAll();

        $query = $db->prepare("SELECT name, quantity_unit, ingredient_id from ingredient");
        $query->execute();
        $ingredientsName = $query->fetchAll();

    }
    else {
        echo "<script>window.location = './login.php'</script>";
    }
    ?>

    <main class="p-6">
        <form class="bg-white p-6 rounded-lg" method="post">
            <input type="hidden" name="recipe-number" id="recipe-number" value="<?php echo $recipe['recipe_number'] ?>">
            <h2 class="text-lg font-medium mb-4">Modifier une recette</h2>
            <div class="mb-4">
                <label class="block text-gray-700 font-medium mb-2" for="recipe-name">
                    Nom de la recette :
                </label>
                <input
                        class="border border-gray-400 p-2 w-full"
                        type="text"
                        id="recipe-name"
                        name="recipe-name"
                        value="<?php echo $recipe['name'] ?>"
                        required
                >
            </div>
            <div class="mb-4 flex flex-col">
                <label class="block text-gray-700 font-medium mb-2" for="difficulty-slider">Difficulté :</label>
                <div class="relative">
                    <input
                            class="w-full bg-gray-200 rounded-lg mb-2"
                            type="range"
                            id="difficulty-slider"
                            name="difficulty-slider"
                            min="0"
                            max="5"
                            step="1"
                            value="<?php echo $recipe['difficulty'] ?>"
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
                        value="<?php echo $beer['name'] ?>"
                        required
                >
            </div>
            <div class="mb-4">
                <label class="block text-gray-700 font-medium mb-2" for="beer-number">
                    Nombre de bières :
                </label>
                <input
                        class="border border-gray-400 p-2 w-full"
                        type="number"
                        min="1"
                        step="1"
                        id="beer-number"
                        name="beer-number"
                        value="<?php echo $recipe['quantity'] ?>"
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
                        value="<?php echo $beer['color'] ?>"
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
                        value="<?php echo $beer['alcohol'] ?>"
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
                        value="<?php echo $beer['bitterness'] ?>"
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
                        value="<?php echo $beer['pre_boil_density'] ?>"
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
                        value="<?php echo $beer['initial_density'] ?>"
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
                        value="<?php echo $beer['final_density'] ?>"
                        required
                >
            </div>
            <div id="steps">
                <?php
                $i = 1;
                foreach ($steps as $step) {
                    echo '<div><div class="mb-4">
                            <label class="block text-gray-700 font-medium mb-2" for="step-' . $i . '-name">
                                Nom de l\'étape ' . $i . ' :
                            </label>
                            <input
                                class="border border-gray-400 p-2 w-full"
                                type="text"
                                id="step-' . $i . '-name"
                                name="step-' . $i . '-name"
                                value="' . $step['step_name'] . '"
                                required
                            >
                        </div>
                        <div class="mb-4">
                        <label class="block text-gray-700 font-medium mb-2" for="step-' . $i . '-category">
                            Catégorie de l\'étape ' . $i . ' :
                        </label>
                        <select
                            class="form-select py-2 px-3 block w-full leading-5appearance-none bg-white border border-gray-400 text-gray-700 py-2 px-3 pr-8 focus:outline-none focus:shadow-outline-blue focus:border-blue-300"
                            id="step-' . $i . '-category"
                            name="step-' . $i . '-category"
                            value="' . $step['category'] . '"
                            required
                        >
                        ';
                    foreach ($stepCategories as $category) {
                        echo '<option value="' . $category['category'] . '">' . $category['category'] . '</option>';
                    }
                    echo '</select>
                        </div>
                        <div class="mb-4">
                            <label class="block text-gray-700 font-medium mb-2" for="step-' . $i . '-duration">
                                Durée de l\'étape ' . $i . ' :
                            </label>
                            <input
                                class="border border-gray-400 p-2 w-full"
                                id="step-' . $i . '-duration"
                                name="step-' . $i . '-duration"
                                type="number"
                                min="0"
                                value="' . $step['duration'] . '"
                                required
                            >
                        </div>
                        <div class="mb-4">
                            <label class="block text-gray-700 font-medium mb-2">
                                Ingrédients de l\'étape ' . $i . ' :
                            </label>
                        </div>
                        <div class="mb-4" id="step-' . $i . '-ingredients">';

                        $ingredientNb = 1;

                        $query = $db->prepare("SELECT ingredient_id_fk, quantity FROM ingredient_usage 
                                WHERE step_number_fk = :step_number AND recipe_number_fk = :recipe_number");

                        $query->execute(
                            [
                                'step_number' => $step['step_number'],
                                'recipe_number' => $step['recipe_number_fk']
                            ]
                        );

                        $ingredients = $query->fetchAll();

                        foreach ($ingredients as $ingredient) {

                            echo '<div><div class="mb-4">
                                <label class="block text-gray-700 font-medium mb-2" for="step-' . $i . '-ingredient-' . $ingredientNb . '">
                                    Nom de l\'ingrédient ' . $ingredientNb . ' de l\'étape ' . $i . ' :
                                </label>
                                <select
                                        class="form-select py-2 px-3 block w-full leading-5appearance-none bg-white border border-gray-400 text-gray-700 py-2 px-3 pr-8 focus:outline-none focus:shadow-outline-blue focus:border-blue-300"
                                        id="step-' . $i . '-ingredient-' . $ingredientNb . '"
                                        name="step-' . $i . '-ingredient-' . $ingredientNb . '"
                                        value="' . $ingredient['ingredient_id_fk'] . '"
                                        required
                                >';
                            foreach ($ingredientsName as $ingredientName) {
                                echo '<option value="' . $ingredientName['ingredient_id'] . '">' . $ingredientName['name'] . ' [' . $ingredientName['quantity_unit'] . ']</option>';
                            }

                                echo '</select>
                            </div>
                            <div class="mb-4">
                                <label class="block text-gray-700 font-medium mb-2" for="step-' . $i . '-ingredient-' . $ingredientNb . '-quantity">
                                    Quantité de l\'ingrédient ' . $ingredientNb . ' de l\'étape ' . $i . ' :
                                </label>
                                <input
                                        class="border border-gray-400 p-2 w-full"
                                        type="number"
                                        min="0"
                                        step="0.1"
                                        id="step-' . $i . '-ingredient-' . $ingredientNb . '-quantity"
                                        name="step-' . $i . '-ingredient-' . $ingredientNb . '-quantity"
                                        value="' . $ingredient['quantity'] . '"
                                        required
                                >
                            </div></div>';
                            $ingredientNb++;
                        }
                        echo '</div>
                        <button type="button" onclick="addIngredient('. $i . ')" class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600">
                            Ajouter un ingrédient existant
                        </button>
                        <button type="button" onclick="addNewIngredient('. $i . ')" class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600">
                            Ajouter un nouvel ingrédient
                        </button>
                        
                        <div class="mb-4">
                            <label class="block text-gray-700 font-medium mb-2" for="step-' . $i . '-description">
                                Description de l\'étape ' . $i . ' :
                            </label>
                            <input
                                    class="border border-gray-400 p-2 w-full"
                                    type="text"
                                    id="step-' . $i . '-description"
                                    name="step-' . $i . '-description"
                                    required
                                    >
                        </div></div>';
                    $i++;
                }
                ?>
            </div>
            <button type="button" onclick="addStep()" class="bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600">
                Ajouter une étape
            </button>
            <div class="text-center mt-6">
                <input class="bg-indigo-500 text-white py-2 px-4 rounded-lg hover:bg-indigo-600"
                       type="submit" name="submit" value="Modifier la recette">
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
