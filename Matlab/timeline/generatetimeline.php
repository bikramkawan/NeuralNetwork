<?php

$jsonObj=$_GET["filtertimelinejson"];


$fp = fopen('filtertimelinejson.json', 'w');
fwrite($fp, json_encode($jsonObj));
fclose($fp);

$file = "../timeline/timelinejsondata.json";
if (!unlink($file))
  {
  echo ("Error deleting $file");
  }
else
  {
  echo ("Deleted $file");
  }


shell_exec('/Applications/MATLAB_R2015b.app/bin/matlab -nosplash -nodesktop -nodisplay -r timelinenew -logfile filename.log v=variant');

?>