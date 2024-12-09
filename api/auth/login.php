<?php
include_once '../config/database.php';

if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
        header("Access-Control-Allow-Methods: POST, OPTIONS");
    
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
        header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

    header("Access-Control-Max-Age: 3600");
    header("Content-Length: 0");
    header("Content-Type: text/plain");
    exit(0);
}

header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->username) && !empty($data->password)) {
    try {
        $query = "SELECT id, username, password FROM users WHERE username = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$data->username]);
        
        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            if (password_verify($data->password, $row['password'])) {
                http_response_code(200);
                echo json_encode([
                    "status" => "success",
                    "message" => "Login successful",
                    "data" => [
                        "id" => $row['id'],
                        "username" => $row['username']
                    ]
                ]);
                exit();
            }
        }
        
        http_response_code(401);
        echo json_encode([
            "status" => "error",
            "message" => "Invalid username or password"
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "error",
            "message" => "Login failed: " . $e->getMessage()
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Username and password are required"
    ]);
}
