<?php
class Database {

	function create_database($data)
	{
		$mysqli = new mysqli($data['hostname'],$data['username'],$data['password'],'');
		if(mysqli_connect_errno())
			return false;
		$mysqli->query("CREATE DATABASE IF NOT EXISTS ".$data['database']);
		$mysqli->close();
		return true;
	}

	function create_tables($data)
	{
		$mysqli = new mysqli($data['hostname'],$data['username'],$data['password'],$data['database']);
		if(mysqli_connect_errno())
			return false;
		$query = file_get_contents('assets/sqlcommand.sql');
		$mysqli->multi_query($query);
		$mysqli->close();
		return true;
	}

	function create_admin($data)
	{
		$mysqli = new mysqli($data['hostname'],$data['username'],$data['password'],$data['database']);
		if(mysqli_connect_errno())
			return false;
	
		$password = $data['admin_password']; 
		$admin_email = $data['admin_email']; 

		$params = [
			'cost' => 12
		];

		if (empty($password) || strpos($password, "\0") !== FALSE || strlen($password) > 32)
		{
			return FALSE;
		}else{
			$password = password_hash($password, PASSWORD_BCRYPT, $params);
        }
        
        $set = " `password`='".$password."', `mobile`='".$data['admin_mobile']."' ";
        if(isset($data['admin_email'])){
            $set .= ", `email`='".$data['admin_email']."' ";
        }        

        $mysqli->query("UPDATE users SET ".$set."  WHERE `id`=1 ");   
		$mysqli->close();
		return true;
	}

	function create_base_url($data)
	{
		$mysqli = new mysqli($data['hostname'],$data['username'],$data['password'],$data['database']);
		if(mysqli_connect_errno())
			return false;
		
		$data_json = array(
			'app_url' => $data['app_url'],
			'company_title' => 'TaskHub'
		);

		$data = json_encode($data_json);

		$mysqli->query("UPDATE settings SET `data`='$data' WHERE `type`='general'");

		$mysqli->close();
		return true;
	}
}
