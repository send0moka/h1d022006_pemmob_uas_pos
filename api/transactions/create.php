<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->user_id) && !empty($data->total_amount) && !empty($data->items)) {
  try {
    $db->beginTransaction();

    $query = "INSERT INTO transactions (user_id, total_amount) VALUES (?, ?)";
    $stmt = $db->prepare($query);
    $stmt->execute([$data->user_id, $data->total_amount]);
    $transaction_id = $db->lastInsertId();

    $query = "INSERT INTO transaction_items (transaction_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
    $stmt = $db->prepare($query);

    foreach ($data->items as $item) {
      $stmt->execute([
        $transaction_id,
        $item->product_id,
        $item->quantity,
        $item->price
      ]);
    }

    $db->commit();

    http_response_code(201);
    echo json_encode([
      "status" => "success",
      "message" => "Transaction created successfully",
      "transaction_id" => $transaction_id
    ]);
  } catch (Exception $e) {
    $db->rollBack();
    http_response_code(500);
    echo json_encode([
      "status" => "error",
      "message" => "Failed to create transaction: " . $e->getMessage()
    ]);
  }
} else {
  http_response_code(400);
  echo json_encode([
    "status" => "error",
    "message" => "Incomplete data provided"
  ]);
}
