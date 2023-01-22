<?php include './header.php';?>

		
<main class="p-6">
	<?php
		if (isset($_GET['recipe_number'])&& isset($_SESSION['username'])) {
			//Récupération des informations de la source
			$recipeNumber = $_GET['recipe_number'];
			$stepNumber = $_GET['step_number'];
			$stepCount = $_GET['step_count'];
			
			//Initialisation des valeurs des étapes précédentes/suivantes
			$nextStep = $stepNumber + 1;
			$previousStep = $stepNumber - 1;
			
			//Récupération des informations de la recette actuelle
			$query = $db->prepare("SELECT * FROM getStepInfo(:recipeNumber, :stepNumber)");
			$query->bindParam(':recipeNumber', $recipeNumber);
			$query->bindParam(':stepNumber', $stepNumber);
			$query->execute();
			$step = $query->fetch();
			
			//Formattage de la durée
			$duration = $step['duration'];
			$durationInSeconds = $duration * 60;
			$durationFormatted = date("H:i:s", $durationInSeconds);
	?>
	<!-- Affichage de la première carte (étape) -->
	<div class="card">
		<h2 class="text-lg font-medium">Etape n°<?= $stepNumber ?>: <?= $step['step_name'] ?></a></h2>
		<div class="stepCard">
			<h3 class="text-lg font-medium">Durée: <?= $step['duration']?> minutes,  Catégorie: <?= $step['category'] ?></a></h3>
			<p class="card-text">Description: <?= $step['description'] ?></p>
		</div>
		<!-- Affichage de la carte avec le timer -->
		<?php if ($duration > 0): ?>
			<div class="beerCard">
				<div id="timer">
					<p id="time">Durée: <?= $durationFormatted ?></p>
					<button id="startButton" class="bg-green-300 text-black p-1 rounded-lg hover:bg-green-400" id="start" onclick="startTimer()">Commencer</button>
					<button id="pauseButton" class="bg-yellow-300 text-black p-1 rounded-lg hover:bg-yellow-400"id="pause" onclick="pauseTimer()">Pause</button>
					<button class="bg-red-300 text-black p-1 rounded-lg hover:bg-red-400"id="reset" onclick="resetTimer()">Mise à 0</button>
				</div>
			</div>
		<?php endif; ?>
	</div>
	
	<!-- Boutons de navigation entre les étapes -->
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
			echo "<script>window.location = './login.php'</script>";
		}
	?>
</main>
<?php include './footer.php';?>
<script>
//js scripts de gestion du timer
  var duration = <?= $step['duration']*60 ?>;
  var intervalId;

  function startTimer() {
    intervalId = setInterval(function() {
	 if (duration >= 0) {
      duration--;
	 }
      document.getElementById("time").innerHTML = toHHMMSS();
      if (duration <= 0) {
        clearInterval(intervalId);
		document.getElementById("time").innerHTML = 'Temps écoulé!'
		document.getElementById("startButton").style.display = "none"; 
		document.getElementById("pauseButton").style.display = "none"; 
      }
    }, 1000);
  }

  function pauseTimer() {
    clearInterval(intervalId);
  }

  function resetTimer() {
    clearInterval(intervalId);
    duration = <?= $step['duration']*60 ?>;
    document.getElementById("time").innerHTML = toHHMMSS();
	document.getElementById("startButton").style.display = "inline"; 
	document.getElementById("pauseButton").style.display = "inline"; 
  }
  
  function toHHMMSS() {
    var hours   = Math.floor(duration / 3600);
    var minutes = Math.floor((duration - (hours * 3600)) / 60);
    var seconds = duration - (hours * 3600) - (minutes * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    if (seconds < 10) {seconds = "0"+seconds;}
    return hours+'h '+minutes+'m '+seconds+'s';
  }
</script>
