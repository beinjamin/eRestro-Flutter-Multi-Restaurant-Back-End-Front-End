<?php
defined('BASEPATH') or exit('No direct script access allowed');
defined('JWT_SECRET_KEY') or define('JWT_SECRET_KEY', '68f05dec6014f68e760c5c5fa3e31bcf391a2e10');
/*
|--------------------------------------------------------------------------
| Display Debug backtrace
|--------------------------------------------------------------------------
|
| If set to TRUE, a backtrace will be displayed along with php errors. If
| error_reporting is disabled, the backtrace will not display, regardless
| of this setting
|
*/
defined('SHOW_DEBUG_BACKTRACE') or define('SHOW_DEBUG_BACKTRACE', TRUE);

/*
|--------------------------------------------------------------------------
| File and Directory Modes
|--------------------------------------------------------------------------
|
| These prefs are used when checking and setting modes when working
| with the file system.  The defaults are fine on servers with proper
| security, but you may wish (or even need) to change the values in
| certain environments (Apache running a separate process for each
| user, PHP under CGI with Apache suEXEC, etc.).  Octal values should
| always be used to set the mode correctly.
|
*/
defined('FILE_READ_MODE')  or define('FILE_READ_MODE', 0644);
defined('FILE_WRITE_MODE') or define('FILE_WRITE_MODE', 0666);
defined('DIR_READ_MODE')   or define('DIR_READ_MODE', 0755);
defined('DIR_WRITE_MODE')  or define('DIR_WRITE_MODE', 0755);

/*
|--------------------------------------------------------------------------
| File Stream Modes
|--------------------------------------------------------------------------
|
| These modes are used when working with fopen()/popen()
|
*/
defined('FOPEN_READ')                           or define('FOPEN_READ', 'rb');
defined('FOPEN_READ_WRITE')                     or define('FOPEN_READ_WRITE', 'r+b');
defined('FOPEN_WRITE_CREATE_DESTRUCTIVE')       or define('FOPEN_WRITE_CREATE_DESTRUCTIVE', 'wb'); // truncates existing file data, use with care
defined('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE')  or define('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE', 'w+b'); // truncates existing file data, use with care
defined('FOPEN_WRITE_CREATE')                   or define('FOPEN_WRITE_CREATE', 'ab');
defined('FOPEN_READ_WRITE_CREATE')              or define('FOPEN_READ_WRITE_CREATE', 'a+b');
defined('FOPEN_WRITE_CREATE_STRICT')            or define('FOPEN_WRITE_CREATE_STRICT', 'xb');
defined('FOPEN_READ_WRITE_CREATE_STRICT')       or define('FOPEN_READ_WRITE_CREATE_STRICT', 'x+b');

/*
|--------------------------------------------------------------------------
| Exit Status Codes
|--------------------------------------------------------------------------
|
| Used to indicate the conditions under which the script is exit()ing.
| While there is no universal standard for error codes, there are some
| broad conventions.  Three such conventions are mentioned below, for
| those who wish to make use of them.  The CodeIgniter defaults were
| chosen for the least overlap with these conventions, while still
| leaving room for others to be defined in future versions and user
| applications.
|
| The three main conventions used for determining exit status codes
| are as follows:
|
|    Standard C/C++ Library (stdlibc):
|       http://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
|       (This link also contains other GNU-specific conventions)
|    BSD sysexits.h:
|       http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits
|    Bash scripting:
|       http://tldp.org/LDP/abs/html/exitcodes.html
|
*/
defined('EXIT_SUCCESS')        or define('EXIT_SUCCESS', 0); // no errors
defined('EXIT_ERROR')          or define('EXIT_ERROR', 1); // generic error
defined('EXIT_CONFIG')         or define('EXIT_CONFIG', 3); // configuration error
defined('EXIT_UNKNOWN_FILE')   or define('EXIT_UNKNOWN_FILE', 4); // file not found
defined('EXIT_UNKNOWN_CLASS')  or define('EXIT_UNKNOWN_CLASS', 5); // unknown class
defined('EXIT_UNKNOWN_METHOD') or define('EXIT_UNKNOWN_METHOD', 6); // unknown class member
defined('EXIT_USER_INPUT')     or define('EXIT_USER_INPUT', 7); // invalid user input
defined('EXIT_DATABASE')       or define('EXIT_DATABASE', 8); // database error
defined('EXIT__AUTO_MIN')      or define('EXIT__AUTO_MIN', 9); // lowest automatically-assigned error code
defined('EXIT__AUTO_MAX')      or define('EXIT__AUTO_MAX', 125); // highest automatically-assigned error code


// Custom Constant Variables
define('FORMS', 'forms/');
define('ALLOW_MODIFICATION', 1);
define('DEMO_VERSION_MSG', 'Modification in demo version is not allowed');
define('TABLES', 'tables/');
define('VIEW', 'view/');
define('CATEGORY_IMG_PATH', 'uploads/category_image/');
define('SUBCATEGORY_IMG_PATH', 'uploads/subcategory_image/');
define('PRODUCT_IMG_PATH', 'uploads/product_image/');
define('SLIDER_IMG_PATH', 'uploads/slider_image/');
define('OFFER_IMG_PATH', 'uploads/offer_image/');
define('NOTIFICATION_IMG_PATH', 'uploads/notifications/');
define('USER_IMG_PATH', 'uploads/user_image/');
define('UPDATE_PATH', 'update/');
define('MEDIA_PATH', 'uploads/media/');
define('NO_IMAGE', 'assets/no-image.png');
define('EMAIL_ORDER_SUCCESS_IMG_PATH', 'assets/admin/images/order-success.png');
define('REVIEW_IMG_PATH', 'uploads/review_image/');
define('TICKET_IMG_PATH', 'uploads/tickets/');
define('DIRECT_BANK_TRANSFER_IMG_PATH', 'uploads/bank_transfer/');
define('RESTRO_DOCUMENTS_PATH', 'uploads/partner/');
define('AVTAR_IMAGE', 'assets/avtar.png');
define('MIN_PHP_VERSION', "7.3");
define('MAX_PHP_VERSION', "7.4");

//Thumbnail paths
define('THUMB_MD', 'thumb-md/');
define('THUMB_SM', 'thumb-sm/');
define('CROPPED_MD', 'cropped-md/');
define('CROPPED_SM', 'cropped-sm/');

define('PERMISSION_ERROR_MSG', ' You are not authorize to operate on the module ');

// ticket status 
define('PENDING', '1');
define('OPENED', '2');
define('RESOLVED', '3');
define('CLOSED', '4');
define('REOPEN', '5');