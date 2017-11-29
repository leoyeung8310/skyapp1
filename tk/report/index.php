<?php
    
require_once "../include/DbConfig.php";

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
$intInputArr = array();
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
$UserID = $_POST['UserID'];
$NoteID = $_POST['NoteID'];
//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";

try {
    //---------------------------output-------------------------
    $outputs['success'] = "OK";
    $outputs['UserID'] = $UserID;
    $outputs['NoteID'] = $NoteID ;
    echo json_encode($outputs);
    
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
