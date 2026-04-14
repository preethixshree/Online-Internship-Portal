<?php
$host = "127.0.0.1";
$user = "root";
$pass = "2005";
$dbname = "oipwt";
$port = 3306;
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
try {
    $conn = mysqli_connect($host, $user, $pass, $dbname, $port);
     mysqli_set_charset($conn, "utf8mb4");
    if (!$conn) {
        throw new Exception("Connection failed: " . mysqli_connect_error());
    }
    file_put_contents('debug_log.txt', date('Y-m-d H:i:s') . " - Database connected successfully\n", FILE_APPEND);
    
} catch (Exception $e) {
    file_put_contents('debug_log.txt', date('Y-m-d H:i:s') . " - Database Error: " . $e->getMessage() . "\n", FILE_APPEND);
    die("Database Connection Error: " . $e->getMessage());
}
function getDBConnection() {
    global $conn;
    return $conn;
}
?>