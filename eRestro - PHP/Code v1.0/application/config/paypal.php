<?php  if (!defined('BASEPATH')) exit('No direct script access allowed');

// ------------------------------------------------------------------------
// Paypal library configuration
// ------------------------------------------------------------------------

// PayPal environment, Sandbox or Live
// $config['sandbox'] = TRUE; // FALSE for live environment
// $config['sandbox'] = FALSE; // TRUE for development environment
$config['sandbox'] = $config['Sandbox'] = FALSE; // FALSE for live environment

// PayPal business email
// $config['business'] = 'seller@somedomain.com';
$config['business'] = 'paypal@nonvoip.com';

// What is the default currency?
$config['paypal_lib_currency_code'] = 'USD';

// Where is the button located at?
$config['paypal_lib_button_path'] = 'assets/images/';

// If (and where) to log ipn response in a file
$config['paypal_lib_ipn_log'] = TRUE;
$config['paypal_lib_ipn_log_file'] = BASEPATH . 'logs/paypal_ipn.log';


?>