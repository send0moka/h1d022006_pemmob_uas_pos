<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->id) && (!empty($data->name) || !empty($data->price))) {
    try {
        $query = "UPDATE products SET ";
        $params = [];
        
        if (!empty($data->name)) {
            $query .= "name = ?, ";
            $params[] = $data->name;
        }
        if (isset($data->price)) {
            $query .= "price = ?, ";
            $params[] = $data->price;
        }
        
        $query = rtrim($query, ", ") . " WHERE id = ?";
        $params[] = $data->id;
        
        $stmt = $db->prepare($query);
        $stmt->execute($params);
        
        if ($stmt->rowCount()) {
            http_response_code(200);
            echo json_encode([
                "status" => "success",
                "message" => "Product updated successfully"
            ]);
        } else {
            http_response_code(404);
            echo json_encode([
                "status" => "error",
                "message" => "Product not found"
            ]);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "error",
            "message" => "Failed to update product: " . $e->getMessage()
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID and at least one field to update are required"
    ]);
}
