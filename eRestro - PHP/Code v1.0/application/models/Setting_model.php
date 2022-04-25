<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Setting_model extends CI_Model
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper', 'timezone_helper']);
    }

    public function update_system_setting($post)
    {
        $post = escape_array($post);

        $system_data = [
            'system_configurations' => $post['system_configurations'],
            'system_timezone_gmt' => $post['system_timezone_gmt'],
            'system_configurations_id' => $post['system_configurations_id'],
            'app_name' => $post['app_name'],
            'support_number' => $post['support_number'],
            'support_email' => $post['support_email'],
            'current_version' => $post['current_version'],
            'current_version_ios' => $post['current_version_ios'],
            'is_version_system_on' => (isset($post['is_version_system_on'])) ? '1' : '0',
            'currency' => $post['currency'],
            'system_timezone' => $post['system_timezone'],
            'is_refer_earn_on' => (isset($post['is_refer_earn_on'])) ? '1' : '0',
            'tax' => (isset($post['tax'])) ? $post['tax'] : '0',
            'is_email_setting_on' => (isset($post['is_email_setting_on'])) ? '1' : '0',
            'google_map_api_key' => $post['google_map_api_key'],
            'min_refer_earn_order_amount' => $post['min_refer_earn_order_amount'],
            'refer_earn_bonus' => $post['refer_earn_bonus'],
            'refer_earn_method' => $post['refer_earn_method'],
            'max_refer_earn_amount' => $post['max_refer_earn_amount'],
            'refer_earn_bonus_times' => $post['refer_earn_bonus_times'],
            'minimum_cart_amt' => $post['minimum_cart_amt'],
            'low_stock_limit' => (isset($post['low_stock_limit'])) ? $post['low_stock_limit'] : '5',
            'max_items_cart' => $post['max_items_cart'],
            'is_rider_otp_setting_on' => (isset($post['is_rider_otp_setting_on'])) ? '1' : '0',
            'is_app_maintenance_mode_on' => (isset($post['is_app_maintenance_mode_on'])) ? '1' : '0',
            'cart_btn_on_list' => (isset($post['cart_btn_on_list'])) ? '1' : '0',
            'expand_product_images' => (isset($post['expand_product_images'])) ? '1' : '0',
        ];

        $main_image_name = $post['logo'];
        $favicon_image_name = $post['favicon'];

        $system_data = json_encode($system_data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'system_settings'
        ));
        $count = $query->num_rows();
        if ($main_image_name != NULL && !empty($main_image_name)) {
            $logo_res = $this->db->get_where('settings', array(
                'variable' => 'logo'
            ));
            $logo_count = $logo_res->num_rows();
            if ($logo_count == 0) {
                $this->db->insert('settings', ['value' => $main_image_name, 'variable' => 'logo']);
            } else {
                $this->db->set('value', $main_image_name)->where('variable', 'logo')->update('settings');
            }
        }
        if ($favicon_image_name != NULL && !empty($favicon_image_name)) {
            $favicon_res = $this->db->get_where('settings', array(
                'variable' => 'favicon'
            ));
            $favicon_count = $favicon_res->num_rows();
            if ($favicon_count == 0) {
                $this->db->insert('settings', ['value' => $favicon_image_name, 'variable' => 'favicon']);
            } else {
                $this->db->set('value', $favicon_image_name)->where('variable', 'favicon')->update('settings');
            }
        }
        if ($count === 0) {
            $data = array(
                'variable' => 'system_settings',
                'value' => $system_data
            );
            $this->db->insert('settings', $data);
            $this->db->insert('settings', ['value' => $post['currency']]);
        } else {
            $this->db->set('value', $system_data)->where('variable', 'system_settings')->update('settings');
            $this->db->set('value', $post['currency'])->where('variable', 'currency')->update('settings');
        }
    }

   
    public function update_payment_method($post)
    {

        $post = escape_array($post);

        $payment_data = array();
        $payment_data['paypal_payment_method'] = isset($post['paypal_payment_method']) ? '1' : '0';
        $payment_data['paypal_mode'] = isset($post['paypal_mode']) && !empty($post['paypal_mode']) ? $post['paypal_mode'] : '';
        $payment_data['paypal_business_email'] = isset($post['paypal_business_email']) && !empty($post['paypal_business_email']) ? $post['paypal_business_email'] : '';
        $payment_data['currency_code'] = isset($post['currency_code']) && !empty($post['currency_code']) ? $post['currency_code'] : '';

        $payment_data['razorpay_payment_method'] = isset($post['razorpay_payment_method']) ? '1' : '0';
        $payment_data['razorpay_key_id'] = isset($post['razorpay_key_id']) && !empty($post['razorpay_key_id']) ? $post['razorpay_key_id'] : '';
        $payment_data['razorpay_secret_key'] = isset($post['razorpay_secret_key']) && !empty($post['razorpay_secret_key']) ? $post['razorpay_secret_key'] : '';


        $payment_data['paystack_payment_method'] = isset($post['paystack_payment_method']) ? '1' : '0';
        $payment_data['paystack_key_id'] = isset($post['paystack_key_id']) && !empty($post['paystack_key_id']) ? $post['paystack_key_id'] : '';
        $payment_data['paystack_secret_key'] = isset($post['paystack_secret_key']) && !empty($post['paystack_secret_key']) ? $post['paystack_secret_key'] : '';


        $payment_data['stripe_payment_method'] = isset($post['stripe_payment_method']) ? '1' : '0';
        $payment_data['stripe_payment_mode'] = isset($post['stripe_payment_mode']) ? $post['stripe_payment_mode'] : 'test';
        $payment_data['stripe_publishable_key'] = isset($post['stripe_publishable_key']) && !empty($post['stripe_publishable_key']) ? $post['stripe_publishable_key'] : '';
        $payment_data['stripe_secret_key'] = isset($post['stripe_secret_key']) && !empty($post['stripe_secret_key']) ? $post['stripe_secret_key'] : '';
        $payment_data['stripe_webhook_secret_key'] = isset($post['stripe_webhook_secret_key']) && !empty($post['stripe_webhook_secret_key']) ? $post['stripe_webhook_secret_key'] : '';
        $payment_data['stripe_currency_code'] = isset($post['stripe_currency_code']) && !empty($post['stripe_currency_code']) ? $post['stripe_currency_code'] : '';

        $payment_data['flutterwave_payment_method'] = isset($post['flutterwave_payment_method']) ? '1' : '0';
        $payment_data['flutterwave_public_key'] = isset($post['flutterwave_public_key']) && !empty($post['flutterwave_public_key']) ? $post['flutterwave_public_key'] : '';
        $payment_data['flutterwave_secret_key'] = isset($post['flutterwave_secret_key']) && !empty($post['flutterwave_secret_key']) ? $post['flutterwave_secret_key'] : '';
        $payment_data['flutterwave_encryption_key'] = isset($post['flutterwave_encryption_key']) && !empty($post['flutterwave_encryption_key']) ? $post['flutterwave_encryption_key'] : '';
        $payment_data['flutterwave_currency_code'] = isset($post['flutterwave_currency_code']) && !empty($post['flutterwave_currency_code']) ? $post['flutterwave_currency_code'] : '';

        $payment_data['paytm_payment_method'] = isset($post['paytm_payment_method']) ? '1' : '0';
        $payment_data['paytm_payment_mode'] = isset($post['paytm_payment_mode']) && !empty($post['paytm_payment_mode']) ? $post['paytm_payment_mode'] : '';
        $payment_data['paytm_merchant_key'] = isset($post['paytm_merchant_key']) && !empty($post['paytm_merchant_key']) ? $post['paytm_merchant_key'] : '';
        $payment_data['paytm_merchant_id'] = isset($post['paytm_merchant_id']) && !empty($post['paytm_merchant_id']) ? $post['paytm_merchant_id'] : '';
        $payment_data['paytm_website'] = isset($post['paytm_payment_mode']) && $post['paytm_payment_mode'] == 'production' ? $post['paytm_website'] : 'WEBSTAGING';
        $payment_data['paytm_industry_type_id'] = isset($post['paytm_payment_mode']) && $post['paytm_payment_mode'] == 'production' ? $post['paytm_industry_type_id'] : 'Retail';

        $payment_data['cod_method'] = isset($post['cod_method']) ? '1' : '0';

        $payment_data = json_encode($payment_data);

        $query = $this->db->get_where('settings', array(
            'variable' => 'payment_method'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'payment_method',
                'value' => $payment_data
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $payment_data)->where('variable', 'payment_method')->update('settings');
        }
    }

    public function update_fcm_details($post)
    {
        $post = escape_array($post);

        $query = $this->db->get_where('settings', array(
            'variable' => 'fcm_server_key'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'fcm_server_key',
                'value' => $post['fcm_server_key']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $post['fcm_server_key'])->where('variable', 'fcm_server_key')->update('settings');
        }
    }

    public function update_contact_details($post)
    {
        $post = escape_array($post);

        $query = $this->db->get_where('settings', array(
            'variable' => 'contact_us'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'contact_us',
                'value' => $post['contact_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $post['contact_input_description'])->where('variable', 'contact_us')->update('settings');
        }
    }

    public function update_privacy_policy($post)
    {
        $post = escape_array($post);

        $query = $this->db->get_where('settings', array(
            'variable' => 'privacy_policy'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'privacy_policy',
                'value' => $post['privacy_policy_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $post['privacy_policy_input_description'])->where('variable', 'privacy_policy')->update('settings');
        }
    }

    public function update_terms_n_condtions($post)
    {
        $post = escape_array($post);

        $query = $this->db->get_where('settings', array(
            'variable' => 'terms_conditions'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'terms_conditions',
                'value' => $post['terms_n_conditions_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $post['terms_n_conditions_input_description'])->where('variable', 'terms_conditions')->update('settings');
        }
    }

    public function update_about_us($post)
    {
        $query = $this->db->get_where('settings', array(
            'variable' => 'about_us'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'about_us',
                'value' => $post['about_us_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $post['about_us_input_description'])->where('variable', 'about_us')->update('settings');
        }
    }

    public function update_email_settings($data)
    {
        $data = escape_array($data);
        $email_data = json_encode($data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'email_settings'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'email_settings',
                'value' => $email_data
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $email_data)->where('variable', 'email_settings')->update('settings');
        }
    }



    public function update_rider_privacy_policy($data)
    {
        $data = escape_array($data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'rider_privacy_policy'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'rider_privacy_policy',
                'value' => $data['privacy_policy_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $data['privacy_policy_input_description'])->where('variable', 'rider_privacy_policy')->update('settings');
        }
    }
    public function update_partner_privacy_policy($data)
    {
        $data = escape_array($data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'partner_privacy_policy'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'partner_privacy_policy',
                'value' => $data['privacy_policy_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $data['privacy_policy_input_description'])->where('variable', 'partner_privacy_policy')->update('settings');
        }
    }

    public function update_rider_terms_n_condtions($data)
    {
        $data = escape_array($data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'rider_terms_conditions'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'rider_terms_conditions',
                'value' => $data['terms_n_conditions_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $data['terms_n_conditions_input_description'])->where('variable', 'rider_terms_conditions')->update('settings');
        }
    }
    public function update_partner_terms_n_condtions($data)
    {
        $data = escape_array($data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'partner_terms_conditions'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'partner_terms_conditions',
                'value' => $data['terms_n_conditions_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $data['terms_n_conditions_input_description'])->where('variable', 'partner_terms_conditions')->update('settings');
        }
    }
    public function update_admin_privacy_policy($data)
    {
        $data = escape_array($data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'admin_privacy_policy'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'admin_privacy_policy',
                'value' => $data['privacy_policy_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $data['privacy_policy_input_description'])->where('variable', 'admin_privacy_policy')->update('settings');
        }
    }

    public function update_admin_terms_n_condtions($data)
    {
        $data = escape_array($data);
        $query = $this->db->get_where('settings', array(
            'variable' => 'admin_terms_conditions'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'admin_terms_conditions',
                'value' => $data['terms_n_conditions_input_description']
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $data['terms_n_conditions_input_description'])->where('variable', 'admin_terms_conditions')->update('settings');
        }
    }

    public function firebase_setting($post)
    {
        $post = escape_array($post);

        $system_data = json_encode($post);
        $query = $this->db->get_where('settings', array(
            'variable' => 'firebase_settings'
        ));
        $count = $query->num_rows();
        if ($count === 0) {
            $data = array(
                'variable' => 'firebase_settings',
                'value' => $system_data
            );
            $this->db->insert('settings', $data);
        } else {
            $this->db->set('value', $system_data)->where('variable', 'firebase_settings')->update('settings');
        }
    }
}
