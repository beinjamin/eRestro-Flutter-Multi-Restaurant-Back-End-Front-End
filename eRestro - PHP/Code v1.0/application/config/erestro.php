<?php

defined('BASEPATH') or exit('No direct script access allowed');

$config['system_modules'] = [
    'orders' =>  array('read', 'update', 'delete'),
    'categories' =>  array('create', 'read', 'update', 'delete'),
    'category_order' =>  array('read', 'update'),
    'product' => array('create', 'read', 'update', 'delete'),
    'media' => array('create', 'read', 'update', 'delete'),
    'product_order' => array('read', 'update'),
    'tax' => array('create', 'read', 'update', 'delete'),
    'attribute' => array('create', 'read', 'update', 'delete'),
    'home_slider_images' => array('create', 'read', 'update', 'delete'),
    'new_offer_images' => array('create', 'read', 'delete'),
    'promo_code' => array('create', 'read', 'update', 'delete'),
    'featured_section' => array('create', 'read', 'update', 'delete'),
    'customers' => array('read', 'update'),
    'rider' => array('create', 'read', 'update', 'delete'),
    'fund_transfer' => array('create', 'read', 'update', 'delete'),
    'send_notification' => array('create', 'read', 'delete'),
    'notification_setting' => array('read', 'update'),
    'client_api_keys' => array('create', 'read', 'update', 'delete'),
    'city' => array('create', 'read', 'update', 'delete'),
    'faq' => array('create', 'read', 'update', 'delete'),
    'support_tickets' => array('create', 'read', 'update', 'delete'),
    'settings' => array('read', 'update'),
    'system_update' => array('update'),
    'partner' => array('create', 'read', 'update', 'delete'),
    'tags' => array('create', 'read', 'update', 'delete'),
    'payment_request' => array('read', 'update'),
];

$config['type'] = array(
    'image' => array(
        'types' => array('jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'),
        'icon' => ''
    ),
    'video' => array(
        'types' => array('mp4', '3gp', 'avchd', 'avi', 'flv', 'mkv', 'mov', 'webm', 'wmv', 'mpg', 'mpeg', 'ogg'),
        'icon' => 'assets/admin/images/video-file.png'
    ),
    'document' => array(
        'types' => array('doc', 'docx', 'txt', 'pdf', 'ppt', 'pptx'),
        'icon' => 'assets/admin/images/doc-file.png'
    ),
    'spreadsheet' => array(
        'types' => array('xls', 'xsls'),
        'icon' => 'assets/admin/images/xls-file.png'
    ),
    'archive' => array(
        'types' => array('zip', '7z', 'bz2', 'gz', 'gzip', 'rar', 'tar'),
        'icon' => 'assets/admin/images/zip-file.png'
    )
);

$config['default_theme'] = 'classic';

$config['supported_payment_methods'] = array("paypal", "razorpay", "paystack", "stripe", "flutterwave", "paytm");
