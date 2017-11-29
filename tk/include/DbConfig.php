<?php
class DbConfig {
	const Host = "(server_host)";
	const Database = "(database_name)";
	const User = "(database_user)";
	const Password = "(password)";
    const ServerLink = "(server_link)";
}
    
class DbTable {
    const Answer = "AnswerTable";
    const GiftAccess = "GiftAccessRightTable";
    const GiftOwning = "GiftOwningTable";
    const GroupRelationship = "GroupRelationshipTable";
    const Group = "GroupTable";
    const Note = "NoteTable";
    const Question = "QuestionTable";
    const Submit = "SubmitTable";
    const User = "UserTable";
}

class ServerInfo{
    const Link = "(server_link)";
}

function error($errorCode, $errorMessage) {
    header("HTTP/1.1 500 Internal Server Error");
    echo "Error $errorCode: $errorMessage";
}

class OutputableException extends Exception {
    private $humanMessage;
    
    public function __construct($code, $message, $humanMessage = null) {
        parent::__construct($message, $code, null);
        $this->humanMessage = $humanMessage;
    }
    
    public function getHumanMessage() {
        return $this->humanMessage;
    }
}

//reference to nieprzeklinaj at gmail dot com (http://www.php.net/manual/en/mysqli-stmt.bind-result.php)
function fetch($result){
    $array = array();
    
    if($result instanceof mysqli_stmt)
    {
        $result->store_result();
        
        $variables = array();
        $data = array();
        $meta = $result->result_metadata();
        
        while($field = $meta->fetch_field())
            $variables[] = &$data[$field->name]; // pass by reference
        
        call_user_func_array(array($result, 'bind_result'), $variables);
        
        $i=0;
        while($result->fetch())
        {
            $array[$i] = array();
            foreach($data as $k=>$v)
            $array[$i][$k] = $v;
            $i++;
            
            // don't know why, but when I tried $array[] = $data, I got the same one result in all rows
        }
    }
    elseif($result instanceof mysqli_result)
    {
        while($row = $result->fetch_assoc())
            $array[] = $row;
    }
    
    return $array;
}

?>