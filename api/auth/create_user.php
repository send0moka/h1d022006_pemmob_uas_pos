<?php
include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

$username = "admin";
$password = "admin123";
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

try {
  $query = "INSERT INTO users (username, password) VALUES (?, ?)";
  $stmt = $db->prepare($query);
  $stmt->execute([$username, $hashed_password]);

  echo "User created successfully\n";
  echo "Username: " . $username . "\n";
  echo "Password: " . $password . "\n";
} catch (PDOException $e) {
  echo "Error: " . $e->getMessage();
}
