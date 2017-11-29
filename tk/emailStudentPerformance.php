
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
$intInputArr = array("NoteID");
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
$NoteID = $_POST['NoteID'];

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
	$stmt = $db->prepare ("select teacherNotes.NoteID as teacherNoteID, QuestionTable.QuestionID, QuestionTable.Subject, QuestionTable.NoOfAnsBox, QuestionTable.NoOfAns, QuestionTable.TimeLimit, QuestionTable.MaxTrial, QuestionTable.Topic, QuestionTable.SubTopic, QuestionTable.Difficulty, QuestionTable.DifficultyPresentation, QuestionTable.QuestionType, QuestionTable.GiveGift, GroupTable.GroupID, GroupTable.GroupName, UserTable.UserID, UserTable.UserName, AnswerTable.AnswerID, AnswerTable.Marks, AnswerTable.CountCorrect, AnswerTable.CountIncorrect, AnswerTable.CountHappy, AnswerTable.CountNoIdea, AnswerTable.CountTimesUp, AnswerTable.teacherCorrect, AnswerTable.teacherIncorrect, AnswerTable.NoOfTrial, AnswerTable.TimeTaken, studentNotes.NoteID as studentNoteID
	from NoteTable teacherNotes
	inner join QuestionTable on teacherNotes.NoteId = QuestionTable.FromNoteID
	inner join GroupTable on QuestionTable.ToGroupID = GroupTable.GroupID
	inner join GroupRelationshipTable on GroupTable.GroupID = GroupRelationshipTable.GroupID
	inner join UserTable on teacherNotes.UserID != UserTable.UserID and GroupRelationshipTable.MemberID = UserTable.UserID
	inner join AnswerTable on QuestionTable.QuestionID = AnswerTable.QuestionID and UserTable.UserID = AnswerTable.OwnerID
	inner join NoteTable studentNotes on AnswerTable.AnswerID = studentNotes.AnswerID
	where teacherNotes.NoteID = ?
	order by teacherNoteID, QuestionTable.QuestionID, GroupTable.GroupID, UserTable.UserID, AnswerTable.AnswerID, studentNoteID");

    if ($stmt === false){
        throw new OutputableException($db->errno, $db->error);
    }
    $stmt->bind_param("s", $NoteID);
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






