<?php  

$jsonObj=$_GET["neuralnetjson"];


$fp = fopen('neuraljsonObj.json', 'w');
fwrite($fp, json_encode($jsonObj));
fclose($fp);

shell_exec('/Applications/MATLAB_R2015b.app/bin/matlab -nosplash -nodesktop -nodisplay -r neuralnetmodeling -logfile filename.log v=variant');



  ?>
