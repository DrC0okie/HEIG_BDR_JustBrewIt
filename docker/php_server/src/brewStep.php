<?php include './header.php';?>

		
<main class="p-6">

	<?php
		if (isset($_GET['recipe_number'])) {
			$recipeNumber = $_GET['recipe_number'];
			$stepNumber = $_GET['step_number'];
			$stepCount = $_GET['step_count'];
			$nextStep = $stepNumber + 1;
			$previousStep = $stepNumber - 1;
			$query = $db->prepare("SELECT * FROM getStepInfo(:recipeNumber, :stepNumber)");
			$query->bindParam(':recipeNumber', $recipeNumber);
			$query->bindParam(':stepNumber', $stepNumber);
			$query->execute();
			$step = $query->fetch();
	?>
	<div class="card">
		<h2 class="text-lg font-medium">Etape n°<?= $stepNumber ?>: <?= $step['step_name'] ?></a></h2>
		<div class="stepCard">
			<h3 class="text-lg font-medium">Durée: <?= $step['duration']?> minutes,  Catégorie: <?= $step['category'] ?></a></h3>
			<p class="card-text">Description: <?= $step['description'] ?></p>
		</div>
	</div>
	

	<button class="button-class 
		<?php if ($stepNumber == 1) echo 'hide'; ?> bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600" 
		<?php if ($stepNumber == 1): ?> disabled <?php endif; ?> 
		onclick="window.location.href='./brewStep.php?recipe_number=<?= $recipeNumber ?>&step_count=<?= $stepCount ?>&step_number=<?= $previousStep ?>'">
		Étape précédente
	</button>
	<button class="button-class 
		<?php if ($stepCount == $stepNumber) echo 'hide'; ?> bg-indigo-500 text-white p-2 rounded-lg hover:bg-indigo-600" 
		<?php if ($stepCount == $stepNumber): ?> disabled <?php endif; ?>
		onclick="window.location.href='./brewStep.php?recipe_number=<?= $recipeNumber ?>&step_count=<?= $stepCount ?>&step_number=<?= $nextStep ?>'">
		Prochaine étape
	</button>


	<?php } else {
			header("Location: login.php");
		}
	?>
</main>
<?php include './footer.php';?>