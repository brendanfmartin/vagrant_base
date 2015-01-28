<?php

echo 'root';

$db = new PDO('postgresql://myapp:dbpass@localhost:15432/myapp');
// $table = $db->query(  "SELECT * FROM application_table"  )->fetchAll(PDO::FETCH_ASSOC);


var_dump(phpinfo());