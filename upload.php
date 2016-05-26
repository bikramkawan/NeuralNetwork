<!--
Author URL: http://bikramkawan.com.np
Email : bikramkawan@gmail.com
Version: 18.03.2016
-->
<?php
  // Set the upload target directory
  $target_path = "Matlab/";

  for($i=1;$i<=5;$i++) {
    $attachments = 'attachment_'.$i;
    $attachmentdiv = 'attachmentdiv_'.$i;
    $FileName = $_FILES[$attachments]['name'];
    // Check if filename is empty
    if($FileName != "") {
      $FileType = $_FILES[$attachments]['type'];
      $FileExtension = strtolower(substr($FileName,strrpos($FileName,'.')+1));
      // Check for supported file formats
      if($FileExtension != "gif" && $FileExtension != "jpg" && $FileExtension != "png" && $FileExtension != "txt") {
        echo "<script type='text/javascript'>parent.document.getElementById('typeerrormessage').style.display = 'inline';</script>";
      }
      else {
        $FileSize = round($_FILES[$attachments]['size']/1024);
        // Check for file size
        if($FileSize > 4000) {
          echo "<script type='text/javascript'>parent.document.getElementById('sizeerrormessage').style.display = 'inline';</script>";
        }
        else {
          $FileTemp = $_FILES[$attachments]['tmp_name'];
          $FileLocation = $target_path.basename($FileName);
          // Finally Upload
          if(move_uploaded_file($FileTemp,$FileLocation)) {
            // On successful upload send a message to corresponding attachmentdiv from which the file came from
            echo "<script type='text/javascript'>parent.document.getElementById('".$attachmentdiv."').innerHTML = '<input CHECKED type=\"checkbox\"><a href=\"http://abhinavsingh.com/webdemos/upload/".$FileName."\" target=\"_blank\"><font size=2><b>".$FileName."</b> <i>(".$FileType.")</i> ".$FileSize." Kb</font>';</script>";
            echo "<script type='text/javascript'>parent.document.getElementById('typeerrormessage').style.display = 'none';</script>";
            echo "<script type='text/javascript'>parent.document.getElementById('sizeerrormessage').style.display = 'none';</script>";
            echo "<script type='text/javascript'>alert('".$FileName."' + '  uploaded Successfully');</script>";
            $fp = fopen('Matlab/datasetfilename.json', 'w');
            fwrite($fp, json_encode([$FileName]));
            fclose($fp);
           
          } 
          else {
            echo "There was an error uploading the file, please try again!";
          }
        }
      }
    }
  }
?>
