﻿<?php
    
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
$UserID = $_POST['UserID'];

//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";
//$error_msg1 = "帳戶或密碼不正確 \nAccount and/or password is invalid";

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

    //prepare query
    //$stmt = $db->prepare("SELECT Topic, SubTopic, Difficulty, DifficultyPresentation, NoteID, Thumbnail, Status, QuestionID, FromUserID FROM ".DbTable::Note." WHERE UserID=? AND Deleted='0' ORDER BY NoteID");
    
    $stmt = $db->prepare("SELECT noteT.Topic,noteT.SubTopic, noteT.Difficulty, noteT.DifficultyPresentation, noteT.NoteID, noteT.Thumbnail, noteT.Status, noteT.QuestionID, noteT.FromUserID, userT.UserName
    FROM ".DbTable::Note." noteT 
    left join ".DbTable::User." userT 
    on noteT.FromUserID = userT.UserID 
    WHERE noteT.UserID=? AND noteT.Deleted='0' ORDER BY noteT.NoteID");

    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("s", $UserID);
    if (!$stmt->execute()){
        throw new OutputableException($db->errno, $db->error);
    }
    //---------------------------output-------------------------
    $rows = array();
    $rows = fetch($stmt);
    
    $outputs['success'] = "OK";
    $outputs['count'] = count($rows);
    $outputs['data'] = $rows;
    echo json_encode($outputs);
    
    $stmt->close();

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
