<?php
require_once "include/DbConfig.php";

header("Content-Type: application/json");

echo "hi1";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
	header("HTTP/1.1 405 Method Not Allowed");
	header("Allow: POST");
	exit;
}


if (stripos($_SERVER["CONTENT_TYPE"], "application/x-www-form-urlencoded") !== 0) {
	header("HTTP/1.1 415 Unsupported Media Type");
	exit;

}

//--------------------------------------------Avoid SQL Injection(Start)-----------------------------------------------------
//Avoid all int/id input
$intInputArr = array();
for($i = 0; $i < count($intInputArr); $i++) {
	if (empty($_POST[$intInputArr[$i]]) === true || preg_match("/^\d+$/", $_POST[$intInputArr[$i]]) !== 1) {
		header("HTTP/1.1 400 Bad Request");
		exit;
	}
}

//Replace all special characters
$stringInputArr = array("Password");
for($i = 0; $i < count($stringInputArr); $i++) {
	if (empty($_POST[$stringInputArr[$i]]) === true || preg_match("/^[A-Za-z0-9 ]+$/", $_POST[$stringInputArr[$i]]) !== 1) {
		header("HTTP/1.1 400 Bad Request");
		exit;
	}
}

//check if it is a email format
$emailInputArr = array("Email");
for($i = 0; $i < count($emailInputArr); $i++) {
	if (empty($_POST[$emailInputArr[$i]]) === true || preg_match("/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i", $_POST[$emailInputArr[$i]]) !== 1) {
		header("HTTP/1.1 400 Bad Request");
		exit;
	}
}

//--------------------------------------------Avoid SQL Injection(End)-----------------------------------------------------

//DB connection
$db = new mysqli(DbConfig::Host, DbConfig::User, DbConfig::Password, DbConfig::Database);
if ($db->connect_error !== null) {
	error($db->connect_errno, $db->connect_error);
	exit;
}

/* change character set to utf8 */
if (!$db->set_charset("utf8")) {
    printf("Error loading character set utf8: %s\n", $db->error);
}

$stmt = $db->stmt_init();

// prepare and bind
$query = "INSERT INTO `UserTable` (`UserType`, `UserName`, `Account`, `Password`, `Email`, `School`, `Server`) VALUES (?, ?, ?, ?, ?, ?, ?)";
if(!$stmt->prepare($query))
{
	print "Failed to prepare statement\n";
	exit;
}

$server = DbConfig::ServerLink;
$stmt->bind_param("sssssss", $UserType, $UserName, $Account, $Password, $Email, $School, $server);
// set parameters and execute
$UserType = $_POST["UserType"];
$UserName = $_POST["UserName"];		
$Account = $_POST["Account"];		

$cost = 10;
// Create a random salt
$Salt = strtr(base64_encode(mcrypt_create_iv(16, MCRYPT_DEV_URANDOM)), '+', '.');
$Salt = sprintf("$2a$%02d$", $cost) . $Salt;
$Password =crypt($_POST["Password"], $Salt);		

$Email =$_POST["Email"];
$School=$_POST["School"];

$outputs = array();
$outputs[] = $stmt->execute();

echo json_encode($outputs) ;


//retrieve all rows  
/*
$querySEL = "SELECT `UserType`, `UserName`, `Account`, `Password`, `Email` FROM `UserTable`";
$outputs = array();
if ($result = mysqli_query($db, $querySEL)) {
    while ($row = mysqli_fetch_row($result)) {
        $outputs[] = $row;
    }
	header("Content-Type: application/json");
	echo json_encode($outputs);
	
    // free result set
    mysqli_free_result($result);
}
*/

$querySEL = "SELECT `Password` FROM `UserTable` WHERE Account = ? LIMIT 1";
if(!$stmt->prepare($querySEL))
{
	print "Failed to prepare statement\n";
	exit;
}
$stmt->bind_result($returnPassword);
$stmt->bind_param("s", $Account);
$outputs = array();
$outputs[] = $stmt->execute();

echo json_encode($outputs) ;

while ($stmt->fetch()) {
    //printf ("%s \n", $returnPassword);
}

/*
if ($result = mysqli_query($db, $querySEL)) {

    while ($row = mysqli_fetch_row($result)) {
        $outputs[] = $row;
    }
	header("Content-Type: application/json");
	echo json_encode($outputs);
	
    // free result set
    mysqli_free_result($result);
}
*/

// Hashing the password with its hash as the salt returns the same hash
if ( $returnPassword === crypt($_POST["Password"],$returnPassword) ) {
	printf ("correct \n");
}else{
	printf ("incorrect \n");
}



mysqli_stmt_close($stmt);
mysqli_close($db);

?>