<?php
defined('BASEPATH') OR exit('No direct script access allowed');

function table_open($url,$class,$attr,$element){

	$table="<table class='table-striped' data-url='".base_url($url)."' ";
	foreach ($attr as $key => $val) {
		$table.= $key.'='.'"'.$val.'" ';
	}
	$table.=">";	

	$thead="<thead><tr>";    
    foreach ($element as $key => $val ) {
    	$thead.='<th ';
    	foreach ($val as $i => $j) {
    		# code...
    		$thead.= $i.'='.'"'.$j.'"';    		
    	}
       $thead.='>'.$key.'</th>';
    }                                              
	$thead.="</tr></thead>";

	$table.=$thead."</table>";

	return $table;
}

?>
