<?php

class Timezone {
    function set_system_timezone() {
        $CI =& get_instance();
        $settings = get_settings('system_settings',true);
        
        /* Set database timezone */
        if(!empty($settings['system_timezone_gmt'])){
            $CI->db->query("SET time_zone='".$settings['system_timezone_gmt']."'");
        }else{
            $CI->db->query("SET time_zone='+05:30'");
        }
        
        /* Set PHP server timezone */
        if(!empty($settings['system_timezone'])){
            date_default_timezone_set($settings['system_timezone']);
        }else{
            date_default_timezone_set('Asia/Kolkata');
        }
    }

}
