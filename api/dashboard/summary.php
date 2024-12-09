<?php
include_once '../config/database.php';

header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$database = new Database();
$db = $database->getConnection();

try {
    date_default_timezone_set('Asia/Jakarta');
    $today = date('Y-m-d');
    
    $query = "SELECT COALESCE(SUM(total_amount), 0) as today_sales, 
             COUNT(*) as total_transactions 
             FROM transactions 
             WHERE DATE(created_at) = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$today]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    $query = "SELECT 
                DATE(created_at) as date, 
                COALESCE(SUM(total_amount), 0) as amount 
             FROM transactions 
             WHERE created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
             GROUP BY DATE(created_at)
             ORDER BY date ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $sales_data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $formatted_sales_data = array_map(function($item) {
        return [
            'date' => $item['date'],
            'amount' => floatval($item['amount'])
        ];
    }, $sales_data);

    echo json_encode([
        'status' => 'success',
        'today_sales' => floatval($result['today_sales']),
        'total_transactions' => intval($result['total_transactions']),
        'sales_data' => $formatted_sales_data
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
