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
$intInputArr = array("UserID","NoteID","GroupID");
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
$UserID = $_POST['UserID'];//UserID
$Location = $_POST['Location'];//
$NoteID = $_POST['NoteID'];//
$GroupID = $_POST['GroupID'];//
$GiftNo = $_POST['GiftNo'];//
$GiftSubNo = $_POST['GiftSubNo'];//
$NoOfAnsBox = $_POST['NoOfAnsBox'];//
$NoOfAns = $_POST['NoOfAns'];//
$DistributeType = $_POST['DistributeType'];//

$Subject = $_POST['Subject'];
$Topic = $_POST['Topic'];
$SubTopic= $_POST['SubTopic'];
$Keywords = $_POST['Keywords'];
$Remarks = $_POST['Remarks'];
$Difficulty= $_POST['Difficulty'];
$DifficultyPresentation= $_POST['DifficultyPresentation'];
$HighlightAns = $_POST['HighlightAns'];
$GiveGift = $_POST['GiveGift'];
$TimeLimit= $_POST['TimeLimit'];
$MaxTrial = $_POST['MaxTrial'];


//$Folder_Path = "upload/";
//$QuestionStatus = "normal";
//$newNoteStatus = $DistributeType . "Pre";
$newNoteStatus = $DistributeType;
//$NewQuestionID = "";
//$NewThumbnailName = "";
//$NewThumbnailPath = "";
$memberID = "";
$memberIDArr = array();
//$NewAnswerID = "";

    
//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";
//$error_msg1 = "沒有對應的用戶 \nNo existing account";
//$error_msg2 = "未能建立新問題 \nCannot create a new question";
//$error_msg3 = "群組沒有成員 \nNo members in this group";
//$error_msg4 = "發佈錯誤 \nCannot distribute notes";
//$error_msg5 = "更新錯誤 \nCannot update note status to postQuestion";
//$error_msg6 = "未能建立答案紀録 \nCannot make answer record";

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

    //--------------------------------------query 3-----------------------------------------
    $stmt = $db->prepare("SELECT MemberID FROM ".DbTable::GroupRelationship." WHERE GroupID=?");
    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("s", $GroupID);
    $stmt->bind_result($memberID);
    if (!$stmt->execute()){
        throw new OutputableException($db->errno, $db->error);
    }
    while ($stmt->fetch()) {
        $memberIDArr[] = $memberID;
    }
    $stmt->close();
    
    //--------------------------------------query 4,5,6-----------------------------------------
    for ($i = 0; $i<count($memberIDArr); $i++){
        $stmt = $db->prepare("INSERT into ".DbTable::Note." (UserID, NoteContent, Status, Thumbnail, BackgroundImage, FromUserID, CreationLocation, QuestionLines, QuestionID, AnswerID,Subject,Topic,SubTopic,Keywords,Remarks,CreationTime, Difficulty, DifficultyPresentation, HighlightAns, GiveGift, TimeLimit, MaxTrial) SELECT ?, NoteContent, ?, Thumbnail, BackgroundImage, ?, ?, QuestionLines,?, ?,Subject,Topic,SubTopic,Keywords,Remarks,?, Difficulty, DifficultyPresentation, HighlightAns, GiveGift, TimeLimit, MaxTrial FROM ".DbTable::Note." WHERE `NoteID`=?;");
        if ($stmt === false){
            throw new OutputableException($db->errno, $db->error);
        }
        $stmt->bind_param("ssssssss", $memberIDArr[$i], $newNoteStatus, $UserID, $Location, $NewQuestionID, $NewAnswerID, $CreationTime, $NoteID);
        if (!$stmt->execute()){
            throw new OutputableException($db->errno, $db->error);
        }
        $stmt->fetch();
        $stmt->close();
    }
    
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
    // An exception has been thrown
    $outputs['success'] = "ERROR";
    $outputs['error_msg'] = $e->getHumanMessage() === null ? $error_msg0 : $e->getHumanMessage();
    $outputs['system_error_msg'] = $e->getMessage();
    echo json_encode($outputs);
    
    //rollback the transaction
    $db->rollback();
    $db->autocommit(true); // i.e., end transaction
}

