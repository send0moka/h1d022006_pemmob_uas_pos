<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$query = "SELECT t.*, u.username, 
          COUNT(ti.id) as item_count 
          FROM transactions t 
          LEFT JOIN users u ON t.user_id = u.id 
          LEFT JOIN transaction_items ti ON t.id = ti.transaction_id 
          GROUP BY t.id 
          ORDER BY t.created_at DESC";

try {
  $stmt = $db->prepare($query);
  $stmt->execute();

  $transactions = [];
  while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    array_push($transactions, [
      "id" => $row['id'],
      "user_id" => $row['user_id'],
      "username" => $row['username'],
      "total_amount" => $row['total_amount'],
      "item_count" => $row['item_count'],
      "created_at" => $row['created_at']
    ]);
  }

  http_response_code(200);
  echo json_encode([
    "status" => "success",
    "data" => $transactions
  ]);
} catch (Exception $e) {
  http_response_code(500);
  echo json_encode([
    "status" => "error",
    "message" => "Failed to fetch transactions: " . $e->getMessage()
  ]);
}
