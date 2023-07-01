<?php

/**
 * PHP CodeSniffer Tooling
 *
 * PHP version 8
 *
 * @author Troy Hurteau <jthurtea@ncsu.edu>
 */

declare(strict_types=1);

//# https://github.com/squizlabs/PHP_CodeSniffer
$path = dirname(dirname(__FILE__));
$ventToken = '.vent.php';
$fileChars = '_A-Za-z0-9-'; // #NOTE do not include "."
$dirPrefix = 'local-dev\.';
$filePrefix = 'local-dev\.|example\.|php[\d]+\.|'; // #NOTE e.g. do not include env.
$fileSuffix = '\.tether|\.root|\.vent|\.pylon|\.bulb|\.quay|\.sema';
$valid = "/^(({$dirPrefix})?[{$fileChars}]+\/)*($filePrefix)*[{$fileChars}]+({$fileSuffix})?\.php$/";
$file = key_exists('scan', $_GET) ? $_GET['scan'] : false;
$lintStatusCodes = [2];
if ($file && strpos($file, 'vendor:') === 0) {
    $path = '/opt/application/vendor';
    $file = substr($file, strlen('vendor:'));
}
if ($file) {
    preg_match($valid, $file) === 1 || throw new Exception('Invalid File Selection');
    $format = '--report=json';
    $fullpath = "{$path}/{$file}";
    $validFile = is_file($fullpath) && is_readable($fullpath);
} else {
    print("specify ?scan=&lt;file&gt;");
    return;
}

$buffer = [];
$status = 0;
if (!$validFile) {
    print("invalid file specified: {$file}");
    return;
}
exec("php -l {$fullpath}", $buffer, $status);
if ($status && !in_array($status, $lintStatusCodes)) {
    array_unshift($buffer, "php -l returned status {$status}");
}
print(implode("<br>\n", $buffer));
