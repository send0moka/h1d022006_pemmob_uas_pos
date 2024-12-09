<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$query = "SELECT * FROM products ORDER BY created_at DESC";
$stmt = $db->prepare($query);
$stmt->execute();

$products = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
  array_push($products, [
    "id" => $row['id'],
    "name" => $row['name'],
    "price" => $row['price'],
    "created_at" => $row['created_at']
  ]);
}

http_response_code(200);
echo json_encode([
  "status" => "success",
  "data" => $products
]);
