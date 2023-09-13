<?php

$arr = [0,1,2,3,4,5,6,7,8,9];

for ($i = 0; $i < 10; $i++)
{
    shuffle($arr);

    echo '!byte ';

    foreach ($arr as $val)
    {
        echo $val . ', ';
    }

    echo PHP_EOL;
}
