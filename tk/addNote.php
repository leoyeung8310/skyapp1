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
$intInputArr = array("UserID");
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
$UserID = $_POST["UserID"];
$Status = "normal";
$Location = $_POST['Location'];
$NoteContent = NULL;
$NewNoteID = "";
    
//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";
$error_msg1 = "未能建立新的天空板 \nConnect create a new skyboard";

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
    $db->autocommit(FALSE);
    
    //--------------------------------------query 1-----------------------------------------
    $stmt = $db->prepare("INSERT into ".DbTable::Note." (UserID, NoteContent, Status, FromUserID, CreationLocation) values(?, ?, ?, ?, ?)");
    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("dssds", $UserID, $NoteContent, $Status, $UserID, $Location);    
    if (!$stmt->execute()){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->close();
    if ($db->affected_rows === 0) {
        throw new OutputableException($db->errno, "query 1 error", $error_msg1);
    }
    
    $NewNoteID = $db->insert_id;
    
    //--------------------------------------query 2-----------------------------------------
    $stmt = $db->prepare("UPDATE ".DbTable::Note." SET CreationTime = LastUpdateTime WHERE NoteID = ?");
    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("d", $NewNoteID);
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
    $outputs['NewNoteID'] = $NewNoteID;
    //$outputs['count'] = count($rows);
    //$outputs['data'] = $rows;
    echo json_encode($outputs);
    
    //-------------------------close connection-------------------------
    $db->close();
    
} catch (OutputableException $e) {
    // An exception has been thrown
    $outputs['success'] = "ERROR";
    $outputs['error_msg'] = $e->getHumanMessage() === null ? $error_msg0 : $e->getHumanMessage();
    $outputs['system_error_msg'] = $e->getMessage();
    echo json_encode($outputs);
    
    //rollback the transaction
    $db->rollback();
    $db->autocommit(true); // i.e., end transaction
}

    
?>