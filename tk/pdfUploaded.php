<?php

require_once "include/DbConfig.php";

//header("Content-Type: application/json");
header("Content-Type:text/html; charset=utf-8");

//input values
$UserID = $_POST["UserID"];
$School = $_POST["School"];
$target_dir = "pdf/";
$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
$uploadOk = 1;
$pdfFileType = pathinfo($target_file,PATHINFO_EXTENSION);
$fCode="00";
$sCode = "0000";

// Check if pdf file
if(isset($_POST["submitted"])) {
	//first two digits setting
	if ($School == "lmc"){
		$fCode = "01";
	}else if ($School == "tycy"){
		$fCode = "02";
	}else if ($School == "HKU"){
		$fCode = "03";
	}
	
	if($pdfFileType != "pdf" ) {
		echo "Sorry, only PDF files are allowed.<br>";
		$uploadOk = 0;
	}else{
		//random 4 digits
		$digits = 4;

		// Check if file already exists
		$try = 1000;
		while($try>0){
			$try = $try - 1;
			$sCode = str_pad(rand(0, pow(10, $digits)-1), $digits, '0', STR_PAD_LEFT);
			$baseName = $fCode.$sCode.".".$pdfFileType;
			$target_file = $target_dir . $baseName;
			if (file_exists($target_file)) {
				//delete old file if exists more than two days
				if ((time()-filectime($target_file)) > 172800){
					unlink($target_file);
					$uploadOk = 1;
				}else{
					$uploadOk = 0;
				}
			}else{
				$uploadOk = 1;
				break;
			}
		}
	}
}

// Check file size
if ($_FILES["fileToUpload"]["size"] > 10000000) {
    echo "Sorry, your file is too large.<br>";
    $uploadOk = 0;
}

// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    echo "Sorry, your file was not uploaded.<br>";
// if everything is ok, try to upload file
} else {
    if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
    	chmod($target_file, 0755);
        echo "The file <b>". basename( $_FILES["fileToUpload"]["name"]). "</b> has been uploaded.<br>";
		echo "To retrieve the file in Skyapp, you can input the code <b><font size='24' color='red'>".$fCode.$sCode."</font></b> as the url input of the in-app browser<br>";
		echo '<img src="url.png" alt="url" width="720"><br>';
    } else {
        echo "Sorry, there was an error uploading your file.<br>";
    }
}

?>



