<?php
$nninputs = ($_POST['nninputs']);
$hiddenlayer = $_POST['hiddenlayer'];
$nntarget = ($_POST['nntarget']);



 
//  $nninputsarr= explode(",",$nninputs);
// $nntargetarr = explode(",", $nntarget);

//echo $str1[0].$str1[1];
//echo count($str1);
//echo $nninputs.$hiddenlayer.$nntarget;

?>



<table style="width:100%">
  
  <tr>
  <th> <img src="img/neuralpic.jpg"></th>
  
  </tr>
  <tr>

    <td><div class="inneural" style="padding-top: 0px; margin-top: -250px; margin-left: 34px;"><?php
  foreach($nninputs as $i){
     echo $i."<br>";
  }
  ?>
  </div></td>
    <td><div class="hidneural" style="margin-left: -645px; margin-top: -70px;"><?php echo $hiddenlayer;?></div></td> 
    <td> <div class="outneural" style="margin-left: -166px; margin-top: -250px;"><?php foreach($nntarget as $t){
     echo $t."<br>";
  }
?>
</div></td>
  </tr>
</table>

