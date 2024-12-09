<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->name) && !empty($data->price)) {
  $query = "INSERT INTO products (name, price) VALUES (?, ?)";
  $stmt = $db->prepare($query);

  try {
    $stmt->execute([$data->name, $data->price]);
    http_response_code(201);
    echo json_encode([
      "status" => "success",
      "message" => "Product created successfully",
      "id" => $db->lastInsertId()
    ]);
  } catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
      "status" => "error",
      "message" => "Failed to create product: " . $e->getMessage()
    ]);
  }
} else {
  http_response_code(400);
  echo json_encode([
    "status" => "error",
    "message" => "Name and price are required"
  ]);
}
