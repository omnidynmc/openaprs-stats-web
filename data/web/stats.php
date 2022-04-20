<?php
$config = array();
$table = array();

function reload_config() {
  global $config, $translate_table, $table;

  $config = yaml_parse_file(
    'config.yml',
  );

} // reload_config

function column_push($obj, $column_count=2) {
  global $cur, $data;

  if (count($cur) == $column_count - 1) {
    array_push($cur, $obj);
    array_push($data, $cur);
    $cur = array();
    return;
  } // if

  array_push($cur, $obj);
} // column_push

/**********
 ** MAIN **
 **********/

reload_config();

$sections = array();

foreach($config AS $section) {
  $data = array();
  $cur = array();

  foreach ($section['data'] AS $key => $value) {
    if (array_key_exists("id", $value)) {
      column_push($value);
    } // if
    else {
      foreach ($value AS $obj) {
        column_push($obj);
      } // foreach
    } // else
  } // foreach

  $c = count($cur);
  if ($c == 1) {
    array_push($cur, array());
    array_push($data, $cur);
  } // if
  else if ($c == 2) array_push($data, $cur);

  array_push($sections, array(
      'title' => $section['title'],
      'data' => $data
    )
  );
} // foreach
//print_r($data);

?>
<!doctype html>
<html>
  <head>
    <title>OpenAPRS Stats</title>
    <meta http-equiv="refresh" content="300">
  </head>
  <body>
<?php foreach ($sections AS $section) { ?>

    <h1><?php echo $section['title']; ?></h1>
    <table>
<?php foreach ($section['data'] AS $obj) { ?>
      <tr>
<?php foreach ($obj AS $graph) { ?>
<?php if (array_key_exists("name", $graph)) { ?>
        <td><img src="png/<?php echo $graph["name"]; ?>.png" /></td>
<?php } else { ?>
        <td>&nbsp;</td>
<?php } //if  ?>
<?php } // foreach ?>
      </tr>
<?php } // foreach ?>
    </table>

<?php } // foreach ?>

  </body>
</html>
