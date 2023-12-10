<?php

// Tested with PHP 8.1.2
// https://www.w3schools.com/php/php_examples.asp

// Some of the primitives require a limit. 0 defaults to 1, and
// negative numbers are evaluated as a subtrahend of total.
// So a large number will be used to represent no limit.
$NO_LIMIT = 1000;

$INPUT = "0 3 6 9 12 15
          1 3 6 10 15 21
          10 13 16 21 30 45";

// Personal rule: if there's a primitive named 'explode', you *MUST* use it.
$lines = explode("\n", $INPUT, $NO_LIMIT);

$histories = [];
for ($i = 0; $i < count($lines); $i++) {
    $strHistory = explode(" ", ltrim($lines[$i], " "), $NO_LIMIT);
    $intHistory = [];
    for ($j = 0; $j < count($strHistory); $j++) {
        $intHistory[] = (int)$strHistory[$j];
    }
    $histories[] = $intHistory;
}

$results = [];
for ($i = 0; $i < count($histories); $i++) {
    print("\n*** history #$i\n");
    $currentHistory = $histories[$i];
    printArrayValues($currentHistory, 0);
    $lastOfEach = [];
    $lastOfEach[] = end($currentHistory);
    $nTabs = 1;
    while(!allElements0($currentHistory)) {
        $newHistory = [];
        $currentValue = $currentHistory[0];
        for ($j = 1; $j < count($currentHistory); $j++) {
            $newHistory[] = $currentHistory[$j] - $currentValue;
            $currentValue = $currentHistory[$j];
        }
        $currentHistory = $newHistory;
        $lastOfEach[] = end($currentHistory);
        printArrayValues($currentHistory, $nTabs);
        $nTabs += 1;
    }
    print("\n--- last of each row: \n");
    printArrayValues($lastOfEach, 0);
    $sum = 0;
    for ($k = 0; $k < count($lastOfEach); $k++) {
      $sum += $lastOfEach[$k];
    }
    $results[] = $sum;
}

print("\n=== results: \n");
printArrayValues($results, 0);

$finalSum = 0;
for ($l = 0; $l < count($results); $l++) {
  $finalSum += $results[$l];
}

print("\n\n********** Part 1: the grand total: $finalSum");




$results = [];
for ($i = 0; $i < count($histories); $i++) {
    print("\n*** history #$i\n");
    $currentHistory = $histories[$i];
    printArrayValues($currentHistory, 0);
    $firstOfEach = [];
    $firstOfEach[] = $currentHistory[0];
    $nTabs = 1;
    while(!allElements0($currentHistory)) {
        $newHistory = [];
        $currentValue = $currentHistory[0];
        for ($j = 1; $j < count($currentHistory); $j++) {
            $newHistory[] = $currentHistory[$j] - $currentValue;
            $currentValue = $currentHistory[$j];
        }
        $currentHistory = $newHistory;
        $firstOfEach[] = $currentHistory[0];
        printArrayValues($currentHistory, $nTabs);
        $nTabs += 1;
    }
    print("\n--- first of each row: \n");
    printArrayValues($firstOfEach, 0);
    $sum = 0;
    for ($k = count($firstOfEach) - 1; $k >= 0; $k--) {
      $sum = $firstOfEach[$k] - $sum;
    }
    print("\n");
    $results[] = $sum;
}

print("\n=== results: \n");
printArrayValues($results, 0);

$finalSum = 0;
for ($l = 0; $l < count($results); $l++) {
  $finalSum += $results[$l];
}

print("\n\n********** Part 2: the grand total: $finalSum");


function allElements0($arr) {
    for ($k = 0; $k < count($arr); $k++) {
        if ($arr[$k] != 0) return false;
    }
    return true;
}

function printArrayValues($arr, $nTabs) {
    for ($k = 0; $k < $nTabs; $k++) {
        print("\t");
    }
    for ($k = 0; $k < count($arr); $k++) {
      print("\t$arr[$k]");
    }
    print("\n");
}

?>
