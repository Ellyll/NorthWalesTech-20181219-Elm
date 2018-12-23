# Elm answer for North Wales Tech 2018-12-19 puzzle

I couldn't pull the data directly from https://pastebin.com/raw/KzwWFYJL due to CORS as Elm runs in the browser, so I wrote a small proxy in php on https://oriel.madarch.org/NorthWalesTech20181219/ which is just 4 lines of code:

```php
<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: text/plain; charset=utf-8");
$content = file_get_contents("https://pastebin.com/raw/KzwWFYJL");
echo $content;
?>
