<?php
require_once "include/DbConfig.php";

header("Content-Type: application/json");
$outputs = array();

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    header("HTTP/1.1 405 Method Not Allowed");
    header("Allow: POST");
    exit;
}


if (stripos($_SERVER["CONTENT_TYPE"], "multipart/form-data") !== 0) {
    header("HTTP/1.1 415 Unsupported Media Type");
    exit;
}
//----------------Avoid SQL Injection(Start)------------------
//Avoid all int/id input
$intInputArr = array("FromUserID","FromNoteID");
for($i = 0; $i < count($intInputArr); $i++) {
    if (empty($_POST[$intInputArr[$i]]) === true || preg_match("/^\d+$/", $_POST[$intInputArr[$i]]) !== 1) {
        header("HTTP/1.1 400 Bad Request");
        exit;
    }
}

//Replace all special characters
$stringInputArr = array();
for($i = 0; $i < count($stringInputArr); $i++) {
    if (empty($_POST[$stringInputArr[$i]]) === true || preg_match("/^[A-Za-z0-9 ]+$/", $_POST[$stringInputArr[$i]]) !== 1) {
        header("HTTP/1.1 400 Bad Request");
        exit;
    }
}

//check if it is a email format
$emailInputArr = array();
for($i = 0; $i < count($emailInputArr); $i++) {
    if (empty($_POST[$emailInputArr[$i]]) === true || preg_match("/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i", $_POST[$emailInputArr[$i]]) !== 1) {
        header("HTTP/1.1 400 Bad Request");
        exit;
    }
}

//--------------------Avoid SQL Injection(End)---------------------

//input values
$FromUserID = $_POST['FromUserID'];//UserID
$FromNoteID = $_POST['FromNoteID'];//NoteID
$ToAccount = $_POST['ToAccount'];//Account or UserName
    
$ToUserID = NULL;
$NewNoteID = NULL;
$Folder_Path = "upload/";
//$FromThumbnailName = NULL;
//$FromThumbnailPath = NULL;
//$ToThumbnailName = NULL;
//$ToThumbnailPath = NULL;

    
//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";
$error_msg1 = "沒有對應的用戶 \nNo existing account";
$error_msg2 = "沒有足夠儲存空間 \nNot enough storage";

try {
    //DB connection
    $db = new mysqli(DbConfig::Host, DbConfig::User, DbConfig::Password, DbConfig::Database);
    if ($db->connect_errno !== 0) {
        throw new OutputableException($db->connect_errno, $db->connect_error);
    }

    //Set UTF8
    if (!$db->set_charset("utf8")) {
        throw new OutputableException($db->errno, $db->error);
    }
    
    //Begin a transaction
    $db->autocommit(false);
    
    //--------------------------------------query 1-----------------------------------------
    /*
    $query1 = "SELECT ThumbnailName FROM ".DbTable::Note."  WHERE UserID=? AND NoteID=? LIMIT 1";
    
    if(!$stmt->prepare($query1)){
        throw new Exception($db->error);
    }
    $stmt->bind_param("ss", $FromUserID, $FromNoteID);
    $stmt->bind_result($FromThumbnailName);
    
    if (!$stmt->execute()){
        throw new Exception($db->error);
    }
    $stmt->fetch();
    
    //output
    if (mysqli_affected_rows($db) == 0){
        $outputs['success'] = "ERROR";
        $outputs['error_msg'] = $error_msg0;
        $outputs['system_error_msg'] = "query 1 error";
        
        //rollback the transaction
        mysqli_rollback($db);
        $db->autocommit(TRUE); // i.e., end transaction
        exit;
    }
    
    //for duplicate thumbnail
    $FromThumbnailPath = $Folder_Path . basename( $FromThumbnailName );
    */
    //--------------------------------------query 2-----------------------------------------
    $stmt = $db->prepare("SELECT UserID FROM ".DbTable::User." WHERE Account=? LIMIT 1");
    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("s", $ToAccount);
    $stmt->bind_result($ToUserID);
    if (!$stmt->execute()){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->fetch();
    $stmt->close();
    if ($ToUserID == NULL){
        throw new OutputableException($db->errno, "query 2error", $error_msg1);
    }
    
    //--------------------------------------query 3-----------------------------------------
    $stmt = $db->prepare("INSERT into ".DbTable::Note." (UserID, NoteContent, Status, Thumbnail, BackgroundImage, FromUserID, Subject, CreationLocation, QuestionLines) SELECT ?, NoteContent, Status, Thumbnail, BackgroundImage, ?, Subject, CreationLocation, QuestionLines FROM `".DbTable::Note."` WHERE `NoteID`=?");
    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("sss", $ToUserID, $FromUserID, $FromNoteID); 
    if (!$stmt->execute()){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->close();
    if ($db->affected_rows === 0) {
        throw new OutputableException($db->errno, "query 3 error", $error_msg1);
    }
    
    $NewNoteID = $db->insert_id;
    //create new thumbnail
    /*
    if ($FromThumbnailName != NULL){
        $ToThumbnailName = $NewNoteID.".png";
        $ToThumbnailPath = $Folder_Path . basename( $ToThumbnailName );
        if (!copy($FromThumbnailPath, $ToThumbnailPath)) {
            $outputs['success'] = "ERROR";
            $outputs['error_msg'] = $error_msg2;
            $outputs['system_error_msg'] = "no enough storage";
            echo json_encode($outputs);
            
            //rollback the transaction
            mysqli_rollback($db);
            $db->autocommit(TRUE); // i.e., end transaction
            exit;
        }else{
            chmod($ToThumbnailPath, 0755);
        }
    }
    */
    
    //--------------------------------------query 4-----------------------------------------

    $stmt = $db->prepare("UPDATE ".DbTable::Note." SET CreationTime = LastUpdateTime WHERE NoteID = ?");
    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("s", $NewNoteID);
    if (!$stmt->execute()){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->close();
    
    //no query has failed, and we can commit the transaction
    $db->commit();
    $db->autocommit(TRUE); // i.e., end transaction
    
    //---------------------------output-------------------------
    //$rows = array();
    //$rows = fetch($stmt);
    $outputs['success'] = "OK";
    //$outputs['count'] = count($rows);
    //$outputs['data'] = $rows;
    echo json_encode($outputs);
    
    //-------------------------close connection-------------------------
    $db->close();
    
} catch (OutputableException $e) {
    //if created new file, delete it
    /*
    if (file_exists ($ToThumbnailPath)){
        unlink($ToThumbnailPath);
    }
    */

    // An exception has been thrown
    $outputs['success'] = "ERROR";
    $outputs['error_msg'] = $e->getHumanMessage() === null ? $error_msg0 : $e->getHumanMessage();
    $outputs['system_error_msg'] = $e->getMessage();
    echo json_encode($outputs);
    
    //rollback the transaction
    $db->rollback();
    $db->autocommit(true); // i.e., end transaction
}

