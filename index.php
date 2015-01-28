<?php

echo 'root';

$db = new PDO('pgsql:user=admin dbname=application password=password');
$table = $db->query(  "SELECT * FROM application_table"  )->fetchAll(PDO::FETCH_ASSOC);


var_dump(phpinfo());