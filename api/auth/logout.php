<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->user_id)) {
  http_response_code(200);
  echo json_encode([
    "status" => "success",
    "message" => "Logged out successfully"
  ]);
} else {
  http_response_code(400);
  echo json_encode([
    "status" => "error",
    "message" => "User ID is required"
  ]);
}
