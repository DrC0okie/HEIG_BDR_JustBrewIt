<?php include './header.php';?>

		
<main class="p-6">

	<?php
		if (isset($_GET['recipe_number'])&& isset($_SESSION['username'])) {
			$recipeNumber = $_GET['recipe_number'];
			$stepNumber = $_GET['step_number'];
			$stepCount = $_GET['step_count'];
			$nextStep = $stepNumber + 1;
			$previousStep = $stepNumber - 1;
			
			//Get the remaining time of this step for the given user and recipe
			$remTime = $db->prepare("SELECT * FROM getRemainingTime(:recipeId, :stepId, :userId)");
			$remTime->bindParam(':recipeId', $recipeNumber);
			$remTime->bindParam(':stepId', $stepNumber);
			$remTime->bindParam(':userId', $_SESSION['customer_id']);
			$remTime->execute();
			$remainingTime = $remTime->fetch();
			
			//Get the current step information
			$query = $db->prepare("SELECT * FROM getStepInfo(:recipeNumber, :stepNumber)");
			$query->bindParam(':recipeNumber', $recipeNumber);
			$query->bindParam(':stepNumber', $stepNumber);
			$query->execute();
			$step = $query->fetch();
			
			//Sets the timer to the remaining time, or the default step duration
			if($remainingTime[0] == 0 || is_null($remainingTime[0])){
				$duration = $step['duration'];
			}else{
				$duration = $remainingTime[0];
			}
			$durationInSeconds = $duration * 60;
			$durationFormatted = date("H:i:s", $durationInSeconds);
	?>
	<div class="card">
		<h2 class="text-lg font-medium">Etape n°<?= $stepNumber ?>: <?= $step['step_name'] ?></a></h2>
		<div class="stepCard">
			<h3 class="text-lg font-medium">Durée: <?= $step['duration']?> minutes,  Catégorie: <?= $step['category'] ?></a></h3>
			<p class="card-text">Description: <?= $step['description'] ?></p>
			<p class="card-text">remainingTime: <?= $remainingTime[0] ?></p>
		</div>
		<div class="beerCard">
			<div id="timer">
				<p id="time">Durée: <?= $durationFormatted ?></p>
				<button class="bg-green-300 text-black p-1 rounded-lg hover:bg-green-400" id="start" onclick="startTimer()">Commencer</button>
				<button class="bg-yellow-300 text-black p-1 rounded-lg hover:bg-yellow-400"id="pause" onclick="pauseTimer()">Pause</button>
				<button class="bg-red-300 text-black p-1 rounded-lg hover:bg-red-400"id="reset" onclick="resetTimer()">Mise à 0</button>
			</div>
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
			echo "<script>window.location = './login.php'</script>";
		}
	?>
</main>
<?php include './footer.php';

    function startStep($recipeId, $stepId, $customerId) {
        $query = $db->prepare("SELECT startStep(:recipeId, :stepId, :customerId)");
        $query->bindParam(':recipeId', $recipeId);
        $query->bindParam(':stepId', $stepId);
        $query->bindParam(':customerId', $customerId);
        $query->execute();
	}
?>
<script>
  var duration = <?= $step['duration']*60 ?>;
  var intervalId;

  function startTimer() {
    intervalId = setInterval(function() {
      duration--;
      document.getElementById("time").innerHTML = toHHMMSS();
      if (duration == 0) {
        clearInterval(intervalId);
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