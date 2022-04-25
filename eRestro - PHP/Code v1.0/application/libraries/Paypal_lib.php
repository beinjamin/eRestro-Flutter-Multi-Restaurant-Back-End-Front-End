<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
/**
 * PayPal Library for CodeIgniter 3.x
 *
 * Library for PayPal payment gateway. It helps to integrate PayPal payment gateway
 * in the CodeIgniter application.
 *
 * It requires PayPal configuration file and it should be placed in the config directory.
 *
 * @package     CodeIgniter
 * @category    Libraries
 * @author      CodexWorld
 * @license     http://www.codexworld.com/license/
 * @link        http://www.codexworld.com
 * @version     2.0
 */

class Paypal_lib{

    var $last_error;
    var $ipn_log;
    var $ipn_log_file;
    var $ipn_response;    
    var $ipn_data = array();
    var $fields = array();
    var $submit_btn = '';
    var $button_path = '';
    var $CI;
    
    function __construct(){
        $this->CI =& get_instance();
        $this->CI->load->helper('url');
        $this->CI->load->helper('form');
        // $this->CI->load->config('paypal');
        $payment_settings = get_settings('payment_method',true);
        $this->system_settings = get_settings('system_settings',true);
        $mode = $payment_settings['paypal_mode'];
        $this->paypal_url = ($mode == 'sandbox')?'https://www.sandbox.paypal.com/cgi-bin/webscr':'https://www.paypal.com/cgi-bin/webscr';
                
        $this->last_error = '';
        $this->ipn_response = '';

        $this->ipn_log_file = BASEPATH.'logs/paypal_ipn.log';;
        $this->ipn_log = TRUE; 
        
        // $this->button_path = $this->CI->config->item('paypal_lib_button_path');
        
        // populate $fields array with a few default values.
        $businessEmail = $payment_settings['paypal_business_email'];
        $this->add_field('business',$businessEmail);
        $this->add_field('rm','2');
        $this->add_field('cmd','_xclick');

        $this->add_field('currency_code', $payment_settings['currency_code']);
        $this->add_field('quantity', '1');
        $this->button('Pay Now!');
    }

    function button($value){
        // changes the default caption of the submit button
        $this->submit_btn = form_submit('pp_submit', $value, 'class="btn btn-success"');
    }

    function image($file){
        $this->submit_btn = '<input type="image" name="add" src="'.base_url(rtrim($this->button_path, '/').'/'. $file).'" border="0" />';
    }

    function add_field($field, $value){
        // adds a key=>value pair to the fields array
        $this->fields[$field] = $value;
    }

    function paypal_auto_form(){
        // form with hidden elements which is submitted to paypal
        $this->button('Click here if you\'re not automatically redirected...');

        echo '<html>' . "\n";
        echo '<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><title>Processing Payment.. Please wait.. |'. $this->system_settings['app_name'] .'</title>
        <link href="'.base_url('assets/img/favicon.png').'" rel="shortcut icon" type="image/ico" />
        <link href="'.base_url('assets/admin/css/adminlte.min.css').'" rel="stylesheet" type="text/css" />
        </head>' . "\n";
        echo '<body style="text-align:center; font-size:2em;" onLoad="document.forms[\'paypal_auto_form\'].submit();">' . "\n";
        echo '<p style="text-align:center;">Please wait, your order is being processed and you will be redirected to the paypal website.</p>' . "\n";
        echo $this->paypal_form('paypal_auto_form');
        echo '</body></html>';
    }

    function paypal_form($form_name='paypal_form'){
        $str = '';
        $str .= '<form method="post" action="'.$this->paypal_url.'" name="'.$form_name.'"/>' . "\n";
        // $str .= '<input type="hidden" name="paymentaction" value="authorization" />';
        $str .= '<input type="hidden" name="payer_email" value="testing@infinitietech.com" />';
        foreach ($this->fields as $name => $value)
            $str .= form_hidden($name, $value) . "\n";
        $str .= '<p><img src="'.base_url('assets/old-pre-loader.gif').'" alt="Please wait.. Loading" title="Please wait.. Loading.." width="140px" /></p>';
        $str .= '<p>'. $this->submit_btn . '</p>';
        $str .= form_close() . "\n";

        return $str;
    }
    
    function validate_ipn($paypalReturn){
        $ipn_response = $this->curlPost($this->paypal_url, $paypalReturn);
        
        if(preg_match("/VERIFIED/i", $ipn_response)){
            // Valid IPN transaction.
            return true;
        }else{
            // Invalid IPN transaction.  Check the log for details.
            $this->last_error = 'IPN Validation Failed.';
            $this->log_ipn_results(false);    
            return false;
        }
    }

    function log_ipn_results($success){
        if (!$this->ipn_log) return;  // is logging turned off?

        // Timestamp
        $text = '['.date('m/d/Y g:i A').'] - '; 

        // Success or failure being logged?
        if ($success) $text .= "SUCCESS!\n";
        else $text .= 'FAIL: '.$this->last_error."\n";

        // Log the POST variables
        $text .= "IPN POST Vars from Paypal:\n";
        foreach ($this->ipn_data as $key=>$value)
            $text .= "$key=$value, ";

        // Log the response from the paypal server
        $text .= "\nIPN Response from Paypal Server:\n ".$this->ipn_response;

        // Write to log
        $fp=fopen($this->ipn_log_file,'a');
        fwrite($fp, $text . "\n\n"); 

        fclose($fp);  // close file
    }

    function dump(){
        // Used for debugging, this function will output all the field/value pairs
        ksort($this->fields);
        echo '<h2>ppal->dump() Output:</h2>' . "\n";
        echo '<code style="font: 12px Monaco, \'Courier New\', Verdana, Sans-serif;  background: #f9f9f9; border: 1px solid #D0D0D0; color: #002166; display: block; margin: 14px 0; padding: 12px 10px;">' . "\n";
        foreach ($this->fields as $key => $value) echo '<strong>'. $key .'</strong>:    '. urldecode($value) .'<br/>';
        echo "</code>\n";
    }
    
    function curlPost($paypal_url, $paypal_return_arr){
        $req = 'cmd=_notify-validate';
        foreach($paypal_return_arr as $key => $value){
            $value = urlencode(stripslashes($value));
            $req .= "&$key=$value";
        }
            
        $ipn_site_url = $paypal_url;
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $ipn_site_url);
        curl_setopt($ch, CURLOPT_HEADER, false);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $req);
        $result = curl_exec($ch);
        curl_close($ch);
    
        return $result;
    }

}