<?php

class MyConfig
{
    function get_email_settings()
    {
        $t = &get_instance();
        $res = $t->db->where('variable', 'email_settings')->get('settings');
        $numRows = $res->num_rows();
        if ($res->num_rows > 0) {
            $row = $res->row();
            $email_settings = json_decode($row->value);
            if (!empty($email_settings)) {
                if ($email_settings->smtp_encryption == 'off') {
                    $smtp_encryption = $email_settings->smtp_host;
                } else {
                    $smtp_encryption = $email_settings->smtp_encryption . '://' . $email_settings->smtp_host;
                }

                $data = array(
                    'mailtype' => $email_settings->mail_content_type,
                    'protocol' => 'smtp',
                    'smtp_host' => $smtp_encryption,
                    'smtp_port' => $email_settings->smtp_port,
                    'smtp_user' => $email_settings->email,
                    'smtp_pass' => $email_settings->password,
                    'charset' => 'utf-8'
                );
                $t->config->set_item('email_config', $data);
            }
        }
    }
    
    function loadSystemResources()
    {
        if (!method_exists('MyConfig', 'verify_doctor_brown')) {
            $exclude_uris = array(
                base_url("admin/purchase-code"),
                base_url("admin/purchase-code/validator"),
                base_url("admin/home/logout"),
                base_url("admin/"),
                base_url("admin"),
                base_url("admin/home"),
                base_url("admin/login"),
                base_url("auth/login"),
                base_url("app/v1/api"),
                base_url(),
				base_url("products"),
				base_url("cart"),
				base_url("cart/manage"),
				base_url("cart/remove"),
				base_url("cart/clear"),
				base_url("cart/get_user_cart"),
				base_url("cart/checkout"),
				base_url("cart/place-order"),
				base_url("cart/validate-promo-code"),
				base_url("cart/pre-payment-setup"),
				base_url("cart/get-delivery-charge"),
				base_url("cart/send-bank-receipt"),
				base_url("cart/check-product-availability"),
				base_url("home/contact-us"),
				base_url("home/categories"),
				base_url("home/get-products"),
				base_url("home/address-list"),
				base_url("home/checkout"),
				base_url("home/terms-and-conditions"),
				base_url("home/about-us"),
				base_url("home/faq"),
				base_url("home/privacy-policy"),
				base_url("home/login"),
				base_url("home/lang"),
				base_url("home/reset-password"),
				base_url("home/send-contact-us-email"),
				base_url("login"),
				base_url("login/login-check"),
				base_url("login/logout"),
				base_url("login/update-user"),
				base_url("my-account"),
				base_url("my-account/profile"),
				base_url("my-account/orders"),
				base_url("my-account/order_details"),
				base_url("my-account/order_invoice"),
				base_url("my-account/update_order_item_status"),
				base_url("my-account/update_order"),
				base_url("my-account/notifications"),
				base_url("my-account/manage_address"),
				base_url("my-account/wallet"),
				base_url("my-account/transactions"),
				base_url("my-account/add_address"),
				base_url("my-account/edit_address"),
				base_url("my-account/delete_address"),
				base_url("my-account/set_default_address"),
				base_url("my-account/get_address"),
				base_url("my-account/get_address_list"),
				base_url("my-account/get_areas"),
				base_url("my-account/get_zipcode"),
				base_url("my-account/favorites"),
				base_url("my-account/manage_favorites"),
				base_url("my-account/get_transactions"),
				base_url("my-account/get_wallet_transactions"),
				base_url("payment"),
				base_url("payment/paypal"),
				base_url("payment/paytm"),
				base_url("payment/initiate_paytm_transaction"),
				base_url("payment/paytm_response"),
				base_url("payment/success"),
				base_url("payment/cancel"),
				base_url("payment/app_payment_status"),
				base_url("payment/do_capture"),
				base_url("products/category"),
				base_url("products/details"),
				base_url("products/get_details"),
				base_url("products/section"),
				base_url("products/search"),
				base_url("products/tags"),
				base_url("products/save_rating"),
				base_url("products/delete_rating"),
				base_url("products/get_rating"),
				base_url("products/check_zipcode"),
				base_url("sellers"),
				base_url("sellers/"),
            );

            $doctor_brown = get_settings('doctor_brown', true);
            if (empty($doctor_brown) && !in_array(current_url(), $exclude_uris)) {
                /* redirect him to the page where he can enter the purchase code */
                redirect(base_url("admin/purchase-code"));
            }
        }
    }

    function set_session()
    {
        $t = &get_instance();
        $t->load->helper('url');
        $t->load->library('session');
        if (!$t->ion_auth->logged_in()) {
            $currentURL = current_url();
            $params = $_SERVER['QUERY_STRING'];
            $fullURL = (!empty($params)) ? $currentURL . '?' . $params : $currentURL;
            $login_check = strpos($fullURL, 'login');
            $home_check = strpos($fullURL, 'home');

            if ($login_check != true && $home_check != true) {
                $t->session->set_userdata('url', $fullURL);
            }
        }
    }
    function get_current_theme()
    {
        $t = &get_instance();
        $t->config->load('erestro');
        $theme = '';
        $default_theme = $t->config->item('default_theme');
        $current_theme = current_theme();
        if (empty($current_theme)) {
            $theme = $default_theme;
        } else {
            $current_theme = $current_theme[0];
            $theme_folder = APPPATH.'views/front-end/'.$current_theme['slug'];
            $is_dir = is_dir($theme_folder);
            if ($is_dir) {
                $theme = $current_theme['slug'];
            }else{
                $theme = $default_theme;
            }
        }
        define('THEME', $theme);
        define('THEME_ASSETS_URL', base_url('assets/front_end/'.$theme.'/'));
    }

    function language() {
        $ci =& get_instance();
        $ci->load->helper(['language']);
        $siteLang = $ci->input->cookie('language', TRUE);
        if ($siteLang) {
            $ci->lang->load('web_labels_lang',$siteLang);
        }else {
            $ci->lang->load('web_labels_lang','english');
        }
    }

    function verify_doctor_brown()
    {
        $exclude_uris = array(
            base_url("admin/purchase-code"),
            base_url("admin/purchase-code/validator"),
            base_url("admin/home/logout"),
            base_url("admin/"),
            base_url("admin"),
            base_url("admin/home"),
            base_url("admin/login"),
            base_url("auth/login"),
            base_url("app/v1/api"),
            base_url(),
            base_url("products"),
            base_url("cart"),
            base_url("cart/manage"),
            base_url("cart/remove"),
            base_url("cart/clear"),
            base_url("cart/get_user_cart"),
            base_url("cart/checkout"),
            base_url("cart/place-order"),
            base_url("cart/validate-promo-code"),
            base_url("cart/pre-payment-setup"),
            base_url("cart/get-delivery-charge"),
            base_url("cart/send-bank-receipt"),
            base_url("cart/check-product-availability"),
			base_url("home/contact-us"),
			base_url("home/categories"),
			base_url("home/get-products"),
			base_url("home/address-list"),
			base_url("home/checkout"),
			base_url("home/terms-and-conditions"),
			base_url("home/about-us"),
			base_url("home/faq"),
			base_url("home/privacy-policy"),
			base_url("home/login"),
			base_url("home/lang"),
			base_url("home/reset-password"),
			base_url("home/send-contact-us-email"),
            base_url("login"),
            base_url("login/login-check"),
            base_url("login/logout"),
            base_url("login/update-user"),
            base_url("my-account"),
            base_url("my-account/profile"),
            base_url("my-account/orders"),
            base_url("my-account/order_details"),
            base_url("my-account/order_invoice"),
            base_url("my-account/update_order_item_status"),
            base_url("my-account/update_order"),
            base_url("my-account/notifications"),
            base_url("my-account/manage_address"),
            base_url("my-account/wallet"),
            base_url("my-account/transactions"),
            base_url("my-account/add_address"),
            base_url("my-account/edit_address"),
            base_url("my-account/delete_address"),
            base_url("my-account/set_default_address"),
            base_url("my-account/get_address"),
            base_url("my-account/get_address_list"),
            base_url("my-account/get_areas"),
            base_url("my-account/get_zipcode"),
            base_url("my-account/favorites"),
            base_url("my-account/manage_favorites"),
            base_url("my-account/get_transactions"),
            base_url("my-account/get_wallet_transactions"),
            base_url("payment"),
            base_url("payment/paypal"),
            base_url("payment/paytm"),
            base_url("payment/initiate_paytm_transaction"),
            base_url("payment/paytm_response"),
            base_url("payment/success"),
            base_url("payment/cancel"),
            base_url("payment/app_payment_status"),
            base_url("payment/do_capture"),
			base_url("products/category"),
			base_url("products/details"),
			base_url("products/get_details"),
			base_url("products/section"),
			base_url("products/search"),
			base_url("products/tags"),
			base_url("products/save_rating"),
			base_url("products/delete_rating"),
			base_url("products/get_rating"),
			base_url("products/check_zipcode"),
        );
        $doctor_brown = get_settings('doctor_brown', true);

        if (empty($doctor_brown) && !in_array(current_url(), $exclude_uris)) {
            /* redirect him to the page where he can enter the purchase code */
             redirect(base_url("admin/purchase-code"));
        } else {
            $calculated_time_check = $time_check = '';

            $time_check = (isset($doctor_brown["time_check"])) ? trim($doctor_brown["time_check"]) : "";
            $code_bravo = (isset($doctor_brown["code_bravo"])) ? trim($doctor_brown["code_bravo"]) : "";
            $code_adam = (isset($doctor_brown["code_adam"])) ? trim($doctor_brown["code_adam"]) : "";
            $dr_firestone = (isset($doctor_brown["dr_firestone"])) ? trim($doctor_brown["dr_firestone"]) : "";
            $str = $code_bravo . "|" . $code_adam . "|" . $dr_firestone;
            $calculated_time_check = hash('sha256', $str);
            if ($time_check != $calculated_time_check || empty($calculated_time_check) || empty($time_check)) {
                if (!in_array(current_url(), $exclude_uris)) {
                     redirect(base_url("admin/purchase-code"));
                }
            }
        }
    }
}
