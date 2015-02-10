<?php

try {
    $dbh = new PDO('pgsql:user=myapp dbname=myapp password=dbpass host=localhost');
    selectTest($dbh);
    $dbh = null;
} catch (Exception $e) {
    echo $e->getMessage();
    exit();
}

function selectTest($dbh) {
    /*** The SQL SELECT statement ***/
    $sql = "SELECT * FROM person";

    /*** fetch into an PDOStatement object ***/
    $stmt = $dbh->query($sql);

    /*** echo number of columns ***/
    $result = $stmt->fetch(PDO::FETCH_NUM);
    var_dump($result);
}