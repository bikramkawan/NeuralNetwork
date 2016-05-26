<?php
// $a=`/Applications/MATLAB_R2015b.app/bin/matlab -nosplash -nodesktop -nodisplay -r tmpscript`;

// $out=shell_exec($a);
// echo $out;

$output = shell_exec('/Applications/MATLAB_R2015b.app/bin/matlab -nosplash -nodesktop -nodisplay -r corrtest -logfile filename.log v=variant');
//echo "<pre>$output</pre>";
//echo gettype($output);
$oparray = explode(" ", trim($output));

$readyout= (array_slice($oparray,106));

print_r($readyout);

echo "<br>";
echo "This is index";
echo "2=".($readyout1[3]);
?>