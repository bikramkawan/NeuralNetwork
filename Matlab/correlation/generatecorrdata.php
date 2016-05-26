<?php  

  $id=$_GET["cleaningid"];

$headindex=9;

shell_exec('/Applications/MATLAB_R2015b.app/bin/matlab -nosplash -nodesktop -nodisplay -r correl -logfile filename.log v=variant');
//echo "<pre>$output</pre>";
//echo gettype($output);
//$str = file_get_contents('corrdata.json');

//$jsonTable = json_encode($str);
//echo $str;
  ?>
