<?php

require_once "include/DbConfig.php";

//header("Content-Type: application/json");
header("Content-Type:text/html; charset=utf-8");

//input values
$Account = $_POST["Account"];
$Password = $_POST["Password"];

//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";
$error_msg1 = "帳戶或密碼不正確 \nAccount and/or password is invalid";

try{
    //DB connection
    $db = new mysqli(DbConfig::Host, DbConfig::User, DbConfig::Password, DbConfig::Database);
    if ($db->connect_errno !== 0) {
        throw new OutputableException($db->connect_errno, $db->connect_error);
    }

    //Set UTF8
    if (!$db->set_charset("utf8")) {
        throw new OutputableException($db->errno, $db->error);
    }
	
    //--------------------------------------query 1-----------------------------------------
    $stmt = $db->prepare("SELECT `Password` FROM ".DbTable::User." WHERE Account = ? LIMIT 1");
    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("s", $Account);
    $stmt->bind_result($returnPassword);
    if (!$stmt->execute()){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->fetch(); //get $returnPassword
    $stmt->close();
    // Hashing the password with its hash as the salt returns the same hash
    if ($returnPassword === crypt($Password,$returnPassword) ) {
        $stmt = $db->prepare("SELECT `UserID`, `UserType`, `UserName`, `Account`, `Email`, `School`, `Server` FROM ".DbTable::User." WHERE Account = ? LIMIT 1");
        if ($stmt === false){
            throw new OutputableException($db->errno, $db->error);
        }
        $stmt->bind_param("s", $Account);
        if (!$stmt->execute()){
            throw new OutputableException($db->errno, $db->error);
        }
        
        //---------------------------output-------------------------
        $rows = array();
        $rows = fetch($stmt);
		$UserID = $rows[0]["UserID"];
		$UserName = $rows[0]["UserName"];
		$School = $rows[0]["School"];
		
		//echo $UserID."<br>";
		//echo $UserName."<br>";
		//echo $School."<br>";
		echo '<form action="pdfUploaded.php" enctype="multipart/form-data" method="post">';
		echo '<input type="hidden" name="UserID" value="'.$UserID.'">';
		echo '<input type="hidden" name="School" value="'.$School.'">';
		echo '<input type="hidden" name="submitted" value="submitted">';
		echo 'Select pdf to upload: <input type="file" name="fileToUpload" id="fileToUpload">';
		echo '<input type="submit" value="Submit">';
		echo '</form>';

        $stmt->close();
    }else{
        throw new OutputableException($db->errno, "login fail", $error_msg1);
    }

    //-------------------------close connection-------------------------
    $db->close();
    
} catch (OutputableException $e) {
    // An exception has been thrown
    $error_msg = $e->getHumanMessage() === null ? $error_msg0 : $e->getHumanMessage();
    $system_error_msg = $e->getMessage();
    echo $error_msg."<br>";
	//echo $system_error_msg."<br>";
	
    //rollback the transaction
    $db->rollback();
    $db->autocommit(true); // i.e., end transaction
}

?>



