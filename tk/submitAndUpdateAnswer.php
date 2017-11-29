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
$NoteID = $_POST['NoteID'];//NoteID
$UserID = $_POST['UserID'];
$QuestionID = $_POST['QuestionID'];
$AnswerID = $_POST['AnswerID'];

//$NoteContent = stripslashes($_POST['NoteContent']);//NoteContent
$NoteContent = $_POST['NoteContent'];//NoteContent

$Thumbnail = $_POST['Thumbnail'];//Thumbnail

$CountCorrect = $_POST['CountCorrect'];
$CountIncorrect = $_POST['CountIncorrect'];
$CountHappy = $_POST['CountHappy'];
$CountNoIdea = $_POST['CountNoIdea'];
$CountTimesup = $_POST['CountTimesup'];

$Location= $_POST['Location'];//Account or UserName
$Marks = $_POST['Marks'];
$TimeTakenOpen = $_POST['TimeTakenOpen'];
$TimeTakenTouchFirstAns = $_POST['TimeTakenTouchFirstAns'];

$NoteStatus = $_POST['NoteStatus'];
$checkIfAllAnswerCorrect = $_POST['checkIfAllAnswerCorrect'];
$allHaveAnswer = $_POST['allHaveAnswer'];
$HighlightAns = $_POST['HighlightAns'];
$GiveGift = $_POST['GiveGift'];
$TimeLimit = $_POST['TimeLimit'];
$MaxTrial = $_POST['MaxTrial'];

//$EventLog = stripslashes($_POST['EventLog']);
$EventLog = $_POST['EventLog'];

$countSubmit = 0;
$sumTime = 0;
$lastTime = NULL;
$NoOfAnsBox = NULL;

$alertType = NULL;
$alertHead = NULL;
$alertMsg = NULL;
$GiftNo = NULL;
$CheckGiftNo = NULL;
$NewNoteStatus = NULL;
$GotGiftNo = NULL;
$GotGiftSubNo = NULL;

//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";
$error_msg1 = "未能儲存筆紀 \nFail Saving Note";
$error_msg2 = "未能提交工作紙 \nFail Submit Worksheet";
    
try {
    //hard-coded v1.25 for userID 1136-1143 [ELCHK and fkyc]
	/*
    if ($UserID >= 1136 && $UserID <= 1143){
        
        $url = "http://i.cs.hku.hk/~cyyeung/tk/submitAndUpdateAnswer2.php";

        $postdata = http_build_query(
            array(
                'NoteID' => $_POST['NoteID'],
                'UserID' => $_POST['UserID'],
                'QuestionID' => $_POST['QuestionID'],
                'AnswerID' => $_POST['AnswerID'],

                'NoteContent' => $_POST['NoteContent'],

                'Thumbnail' => $_POST['Thumbnail'],

                'CountCorrect' => $_POST['CountCorrect'],
                'CountIncorrect' => $_POST['CountIncorrect'],
                'CountHappy' => $_POST['CountHappy'],
                'CountNoIdea' => $_POST['CountNoIdea'],
                'CountTimesup' => $_POST['CountTimesup'],

                'Location' => $_POST['Location'],//Account or UserName
                'Marks' => $_POST['Marks'],
                'TimeTakenOpen' => $_POST['TimeTakenOpen'],
                'TimeTakenTouchFirstAns' => $_POST['TimeTakenTouchFirstAns'],

                'NoteStatus' => $_POST['NoteStatus'],
                'checkIfAllAnswerCorrect' => $_POST['checkIfAllAnswerCorrect'],
                'allHaveAnswer' => $_POST['allHaveAnswer'],
                'HighlightAns' => $_POST['HighlightAns'],
                'GiveGift' => $_POST['GiveGift'],
                'TimeLimit' => $_POST['TimeLimit'],
                'MaxTrial' => $_POST['MaxTrial'],

                'EventLog' => $_POST['EventLog']
            )
        );

        $opts = array('http' =>
            array( 
                'method'  => 'POST',
                'header'  => 'Content-type: application/x-www-form-urlencoded',
                'content' => $postdata
            )
        );

        // create request context
        $context  = stream_context_create($opts);

        // do request    
        $result = file_get_contents($url, false, $context);
        echo $result;

    }else{
	*/
	
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
	$stmt = $db->prepare("UPDATE ".DbTable::Note." SET NoteContent=? , Thumbnail=?, UpdateSaveLocation=?, EventLog=? WHERE NoteID=?");
	if ($stmt === false){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->bind_param("sssss", $NoteContent, $Thumbnail, $Location, $EventLog, $NoteID);
	if (!$stmt->execute()){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->close();
	if ($db->affected_rows === 0) {
		throw new OutputableException($db->errno, "query 1 error", $error_msg1);
	}
	
	//--------------------------------------query 2-----------------------------------------
	$stmt = $db->prepare("insert into ".DbTable::Submit." (UserID, QuestionID, AnswerID, Marks, TimeTakenOpen, TimeTakenTouchFirstAns, EventLog, SubmittedNoteContent) values(?,?,?,?,?,?,?,?);");
	if ($stmt === false){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->bind_param("ssssssss", $UserID, $QuestionID, $AnswerID, $Marks, $TimeTakenOpen, $TimeTakenTouchFirstAns, $EventLog, $NoteContent);
	if (!$stmt->execute()){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->close();
	if ($db->affected_rows === 0) {
		throw new OutputableException($db->errno, "query 2 error", $error_msg2);
	}

	//--------------------------------------query 3-----------------------------------------
	$stmt = $db->prepare("SELECT COUNT(*) AS countSubmit, SUM(TimeTakenOpen) AS sumTime FROM ".DbTable::Submit." WHERE AnswerID=?");
	if ($stmt === false){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->bind_param("s", $AnswerID);
	$stmt->bind_result($countSubmit,$sumTime);
	$sumTime = 0;
	if (!$stmt->execute()){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->fetch(); 
	$stmt->close();
	if ($countSubmit === 0 || $sumTime === 0){
		throw new OutputableException($db->errno, "query 3 error", $error_msg2);
	}

	//--------------------------------------query 3q-----------------------------------------
	$stmt = $db->prepare("SELECT NoOfAnsBox FROM ".DbTable::Question." WHERE QuestionID=?");
	if ($stmt === false){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->bind_param("s", $QuestionID);
	$stmt->bind_result($NoOfAnsBox);
	if (!$stmt->execute()){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->fetch();
	$stmt->close();

	//--------------------------------------query 4-----------------------------------------
	$stmt = $db->prepare("UPDATE ".DbTable::Answer." SET NoOfTrial=?, Marks=?, TimeTaken=?, Location=?, Status='answered', CountCorrect=?, CountIncorrect=?, CountHappy=?, CountNoIdea=?, CountTimesup=? WHERE AnswerID=?");
	if ($stmt === false){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->bind_param("ssssssssss", $countSubmit, $Marks, $sumTime, $Location, $CountCorrect,$CountIncorrect,$CountHappy,$CountNoIdea,$CountTimesup,$AnswerID);
	if (!$stmt->execute()){
		throw new OutputableException($db->errno, $db->error);
	}
	$stmt->close();

	//--------------------------------------query 5-----------------------------------------
	//change note to Post - 1)all answer correct, 2) meet max trials, 3) timesup

	if (($NoOfAnsBox != 0 && $checkIfAllAnswerCorrect) || ($MaxTrial!=0 && $countSubmit >= $MaxTrial)){
		$NewNoteStatus = str_replace("Pre","Post",$NoteStatus);  //need return this value

		$stmt = $db->prepare("UPDATE ".DbTable::Note." SET Status=? WHERE NoteID=?");
		if ($stmt === false){
			throw new OutputableException($db->errno, $db->error);
		}
		$stmt->bind_param("ss", $NewNoteStatus, $NoteID);
		if (!$stmt->execute()){
			throw new OutputableException($db->errno, $db->error);
		}
		$stmt->fetch();
		$stmt->close();
		if ($db->affected_rows === 0) {
			throw new OutputableException($db->errno, "query 5 error", $error_msg2);
		}
	}

	if (!$allHaveAnswer && ($MaxTrial==0 || ($MaxTrial!=0 && $countSubmit < $MaxTrial))){
		$alertType = "noanswer";
		$alertHead = "沒有輸入答案 Answers are missing";
		$alertMsg = "請在所有答案欄輸入答案\nPlease input all answers and submit again";
	}else if (!$allHaveAnswer && ($MaxTrial!=0 && $countSubmit >= $MaxTrial)){
		$alertType = "noanswerandmaxtrial";
		$alertHead = "沒有輸入答案 Answers are missing";
		$alertMsg = "提交次數己達到上限\nThe quota of submit is met";        
	}else{
		if (!$checkIfAllAnswerCorrect && ($MaxTrial==0 || ($MaxTrial!=0 && $countSubmit < $MaxTrial))){
			$alertType = "wronganswer";
			$alertHead = "答錯了 Wrong Answer";
			$alertMsg = "請再努力嘗試\nPlease try again";
		}else if (!$checkIfAllAnswerCorrect && ($MaxTrial!=0 && $countSubmit >= $MaxTrial)){
			$alertType = "wronganswerandmaxtrial";
			$alertHead = "答錯了 Wrong Answer";
			$alertMsg = "提交次數己達到上限\nThe quota of submit is met";       
		}else{
			//give gift?
			if ($GiveGift == 1){
				$stmt = $db->prepare("SELECT GotGiftNo , GotGiftSubNo FROM ".DbTable::Answer." WHERE AnswerID=?");
				if ($stmt === false){
					throw new OutputableException($db->errno, $db->error);
				}
				$stmt->bind_param("s", $AnswerID);
				$stmt->bind_result($GotGiftNo, $GotGiftSubNo);
				if (!$stmt->execute()){
					throw new OutputableException($db->errno, $db->error);
				}
				$stmt->fetch();
				$stmt->close();

				//not yet got gift for this answer
				if ($GotGiftNo === NULL && $GotGiftSubNo === NULL){
					$GiftSubNo = 0;
					$ran = mt_rand(0,99); 
					if ($ran < 15)
						$GiftNo = 1;
					else if ($ran >= 15 && $ran < 30)
						$GiftNo = 2;
					else if ($ran >= 30 && $ran < 45)
						$GiftNo = 3;
					else if ($ran >= 45 && $ran < 60)
						$GiftNo = 4;
					else if ($ran >= 60 && $ran < 75)
						$GiftNo = 5;
					else if ($ran >= 75 && $ran < 90)
						$GiftNo = 6;
					else if ($ran >= 90 && $ran < 95)
						$GiftNo = 7;
					else if ($ran >= 95)
						$GiftNo = 8;

					//record this answer gets gift
					$stmt = $db->prepare("UPDATE ".DbTable::Answer." SET GotGiftNo=?, GotGiftSubNo=? WHERE AnswerID=?");
					if ($stmt === false){
						throw new OutputableException($db->errno, $db->error);
					}
					$stmt->bind_param("sss", $GiftNo, $GiftSubNo, $AnswerID);
					if (!$stmt->execute()){
						throw new OutputableException($db->errno, $db->error);
					}
					$stmt->close();
					if ($db->affected_rows === 0) {
						throw new OutputableException($db->errno, "query update answer table for gifts error", $error_msg2);
					}

					$stmt = $db->prepare("SELECT COUNT(*) as CheckGiftNo FROM ".DbTable::GiftOwning." WHERE UserID=? AND GiftNo=?");
					if ($stmt === false){
						throw new OutputableException($db->errno, $db->error);
					}
					$stmt->bind_param("ss", $UserID, $GiftNo);
					$stmt->bind_result($CheckGiftNo);
					if (!$stmt->execute()){
						throw new OutputableException($db->errno, $db->error);
					}
					$stmt->fetch();
					$stmt->close();

					if ($CheckGiftNo < 1){
						//insert gift owning table
						$stmt = $db->prepare("insert into ".DbTable::GiftOwning." (UserID, GiftNo, GiftSubNo, ByAnswerID) values(?,?,?,?);");
						if ($stmt === false){
							throw new OutputableException($db->errno, $db->error);
						}
						$stmt->bind_param("ssss", $UserID, $GiftNo, $GiftSubNo, $AnswerID);
						if (!$stmt->execute()){
							throw new OutputableException($db->errno, $db->error);
						}
						$stmt->close();
						if ($db->affected_rows === 0) {
							throw new OutputableException($db->errno, "query insert gift error", $error_msg2);
						}
					}
				}else{
					//got a gift already, show this gift again
					$GiftNo = $GotGiftNo;
					$GiftSubNo = $GotGiftSubNo;
				}
				
				if ($NoOfAnsBox != 0){
					$alertType = "correctanswer";
					$alertHead = "答對了 Correct Answer";
					$alertMsg = "你擭得以下的禮物\nThis is your gift";
				}else{
					$alertType = "submittedwithgift";
					$alertHead = "已提交 Submitted";
					$alertMsg = "你擭得以下的禮物\nThis is your gift";
				}
			}else{
				if ($NoOfAnsBox != 0){
					$alertType = "correctanswer";
					$alertHead = "答對了 Correct Answer";
					$alertMsg = "";
				}else{
					$alertType = "submittedwithoutgift";
					$alertHead = "已提交 Submitted";
					$alertMsg = "";
				}
			}
		}
	}

	//---------------------------END-------------------------

	//no query has failed, and we can commit the transaction
	$db->commit();
	$db->autocommit(true); // i.e., end transaction
	
	//---------------------------output-------------------------
	$outputs['success'] = "OK";
	$outputs['NewNoteStatus'] = $NewNoteStatus;
	$outputs['alertType'] = $alertType;
	$outputs['alertHead'] = $alertHead;
	$outputs['alertMsg'] = $alertMsg;
	$outputs['GiftNo'] = $GiftNo;
	$outputs['countSubmit'] = $countSubmit;
	$outputs['NoOfAnsBox'] = $NoOfAnsBox;
	echo json_encode($outputs);
	
	//-------------------------close connection-------------------------
	$db->close();
	
    //}
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