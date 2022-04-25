<?php
defined('BASEPATH') OR exit('No direct script access allowed');

function formatOffset($offset) {
    $hours = $offset / 3600;
    $remainder = $offset % 3600;
    $sign = $hours > 0 ? '+' : '-';
    $hour = (int) abs($hours);
    $minutes = (int) abs($remainder / 60);

    if ($hour == 0 AND $minutes == 0) {
        $sign = ' ';
    }
    return $sign . str_pad($hour, 2, '0', STR_PAD_LEFT).':'. str_pad($minutes,2, '0');
}


function get_timezone(){

	$list = DateTimeZone::listAbbreviations();
	$idents = DateTimeZone::listIdentifiers();

	$data = $offset = $added = array();
	foreach ($list as $abbr => $info) {
	    foreach ($info as $zone) {
	        if ( ! empty($zone['timezone_id'])
	            AND
	            ! in_array($zone['timezone_id'], $added)
	            AND 
	              in_array($zone['timezone_id'], $idents)) {
	            $z = new DateTimeZone($zone['timezone_id']);
	            $c = new DateTime(null, $z);
	            $zone['time'] = $c->format('H:i a');
	            $offset[] = $zone['offset'] = $z->getOffset($c);
	            $data[] = $zone;
	            $added[] = $zone['timezone_id'];
	        }
	    }
	}

	array_multisort($offset, SORT_ASC, $data);
	$options = array();
	foreach ($data as $key => $row) {
	    $options[$row['timezone_id']] = $row['time'] . ' - '
	    . formatOffset($row['offset']) 
	    . ' ' . $row['timezone_id'];
	}

	return $options;
}

function get_timezone_array(){
    $list = DateTimeZone::listAbbreviations();
    $idents = DateTimeZone::listIdentifiers();
    
        $data = $offset = $added = array();
        foreach ($list as $abbr => $info) {
            foreach ($info as $zone) {
                if ( ! empty($zone['timezone_id'])
                    AND
                    ! in_array($zone['timezone_id'], $added)
                    AND 
                      in_array($zone['timezone_id'], $idents)) {
                    $z = new DateTimeZone($zone['timezone_id']);
                    $c = new DateTime(null, $z);
                    $zone['time'] = $c->format('H:i a');
                    $offset[] = $zone['offset'] = $z->getOffset($c);
                    $data[] = $zone;
                    $added[] = $zone['timezone_id'];
                }
            }
        }
    
        array_multisort($offset, SORT_ASC, $data);

        $i = 0;$temp = array();
        foreach ($data as $key => $row) {
            $temp[0] = $row['time'];
            $temp[1] = formatOffset($row['offset']);
            $temp[2] = $row['timezone_id'];
            $options[$i++] = $temp;
        }
        
        return $options;
}
