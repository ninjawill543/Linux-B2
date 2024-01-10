<?php
$host='mysql';
$user='root';
$password='password';
$db ='docker_database';

$conn = new mysqli($host, $user, $password, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST["username"];

    $sql = "INSERT INTO users (username) VALUES ('$username')";
    if ($conn->query($sql) === TRUE) {
        echo "Username added successfully!";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

$sql = "SELECT username FROM users";
$result = $conn->query($sql);

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Docker PHP</title>
</head>
<body>

    <h2>Add User</h2>
    <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
        <label for="username">Username:</label>
        <input type="text" name="username" required>
        <button type="submit">Add User</button>
    </form>

    <h2>Users in the Database</h2>
    <?php
    if ($result->num_rows > 0) {
        echo "<ul>";
        while($row = $result->fetch_assoc()) {
            echo "<li>" . $row["username"] . "</li>";
        }
        echo "</ul>";
    } else {
        echo "No users in the database.";
    }

    $conn->close();
    ?>

</body>
</html>
