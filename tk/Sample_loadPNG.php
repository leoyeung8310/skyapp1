<?php
    
require_once "include/DbConfig.php";

//header("Content-Type: application/json");
$outputs = array();

echo "This is an exmaple showing PNG file getting from the database (1st NoteID Thumbnail) with encrpyted base64 string format.<br>";

//input values
$NoteID = "1";
$Thumbnail = "";

//Error msgs return
$error_msg0 = "伺服器內部錯誤 \nInternal Server Error";

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
    
    //--------------------------------------query 1-----------------------------------------
    $stmt = $db->prepare("SELECT Thumbnail FROM ".DbTable::Note." WHERE NoteID = ?");
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
    //echo json_encode($rows);
    $Thumbnail = $rows[0]["Thumbnail"];

    define('UPLOAD_DIR', 'images/');
    $img = str_replace('%2B', '+', $Thumbnail); //* this is required based on the IOS requirment only
    $data = base64_decode($img);

    //---------save file into web server-------------------------

    //$file = UPLOAD_DIR . uniqid() . '.png';
    //$success = file_put_contents($file, $data);
    //print $success ? $file : 'Unable to save the file.';

    //----------print out file on page --------------------------
    
    echo '<img src="data:image/png;base64,' . $img . '" />';
    
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