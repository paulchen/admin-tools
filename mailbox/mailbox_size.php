<?php
require_once(dirname(__FILE__) . '/config.php');

$db = new PDO("mysql:dbname=$db_name;host=$db_host", $db_user, $db_pass);

function db_query($query, $parameters = array()) {
	global $db;

	if(!($stmt = $db->prepare($query))) {
		$error = $db->errorInfo();
		db_error($error[2], debug_backtrace(), $query, $parameters);
	}
	// see https://bugs.php.net/bug.php?id=40740 and https://bugs.php.net/bug.php?id=44639
	foreach($parameters as $key => $value) {
		$stmt->bindValue($key+1, $value, is_numeric($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
	}
	if(!$stmt->execute()) {
		$error = $stmt->errorInfo();
		db_error($error[2], debug_backtrace(), $query, $parameters);
	}
	$data = $stmt->fetchAll(PDO::FETCH_ASSOC);
	if(!$stmt->closeCursor()) {
		$error = $stmt->errorInfo();
		db_error($error[2], debug_backtrace(), $query, $parameters);
	}

	return $data;
}

function db_error($error, $stacktrace, $query, $parameters) {
	/* TODO
	global $report_email, $email_from;

	header('HTTP/1.1 500 Internal Server Error');
	echo "A database error has just occurred. Please don't freak out, the administrator has already been notified.\n";

	$params = array(
			'ERROR' => $error,
			'STACKTRACE' => dump_r($stacktrace),
			'QUERY' => $query,
			'PARAMETERS' => dump_r($parameters),
			'REQUEST_URI' => (isset($_SERVER) && isset($_SERVER['REQUEST_URI'])) ? $_SERVER['REQUEST_URI'] : 'none',
		);
	send_mail('db_error.php', 'Database error', $params, true);
	*/
}

if(count($argv) != 3) {
	die(1);
}

$all_mails = $argv[1];
$unread_mails = $argv[2];

if(!preg_match('/^[0-9]+$/', $all_mails) || !preg_match('/^[0-9]+$/', $unread_mails)) {
	die(2);
}

db_query('INSERT INTO mailbox_size (`all`, unread) VALUES (?, ?)', array($all_mails, $unread_mails));

db_query('DELETE FROM mailbox_size WHERE DATE_SUB(NOW(), INTERVAL 1 DAY) > timestamp');

