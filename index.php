<?php

try {
    $db = new PDO('pgsql:user=myapp dbname=myapp password=dbpass host=localhost');
    $stmt = $db->query( "SELECT * FROM location" );
    var_dump($stmt);
} catch (Exception $e) {
    echo $e->getMessage();
}