<?php
defined('BASEPATH') or exit('No direct script access allowed');

/*
| -------------------------------------------------------------------------
| Hooks
| -------------------------------------------------------------------------
| This file lets you define "hooks" to extend CI without hacking the core
| files.  Please see the user guide for info:
|
|	https://codeigniter.com/user_guide/general/hooks.html
|
*/

$hook['pre_system'][] = array(
    'class'    => 'Check_installer',
    'function' => 'check_for_installer',
    'filename' => 'check_installer.php',
    'filepath' => 'hooks'
);

$hook['post_controller_constructor'][] = array(
    'class'    => 'Timezone',
    'function' => 'set_system_timezone',
    'filename' => 'timezone.php',
    'filepath' => 'hooks'
);

$hook['post_controller_constructor'][] = array(
    'class'    => 'MyConfig',
    'function' => 'get_email_settings',
    'filename' => 'MyConfig.php',
    'filepath' => 'hooks'
);

$hook['post_controller_constructor'][] = array(
    'class'    => 'MyConfig',
    'function' => 'set_session',
    'filename' => 'MyConfig.php',
    'filepath' => 'hooks'
);
$hook['post_controller_constructor'][] = array(
    'class'    => 'MyConfig',
    'function' => 'get_current_theme',
    'filename' => 'MyConfig.php',
    'filepath' => 'hooks'
);
$hook['post_controller_constructor'][] = array(
    'class'    => 'MyConfig',
    'function' => 'language',
    'filename' => 'MyConfig.php',
    'filepath' => 'hooks'
);
$hook['post_controller_constructor'][] = array(
    'class'    => 'MyConfig',
    'function' => 'verify_doctor_brown',
    'filename' => 'MyConfig.php',
    'filepath' => 'hooks'
);

$hook['post_controller_constructor'][] = array(
    'class'    => 'MyConfig',
    'function' => 'loadSystemResources',
    'filename' => 'MyConfig.php',
    'filepath' => 'hooks'
);
