<?php
$file = "../neuralnetmodel/trainingandtestidjson.json";
if (!unlink($file))
  {
  echo ("Error deleting $file");
  }
else
  {
  echo ("Deleted $file");
  }


$jsonObj=$_GET["trainingandtestidjson"];


$fp = fopen('../neuralnetmodel/trainingandtestidjson.json', 'w');
fwrite($fp, json_encode($jsonObj));
fclose($fp);


?>