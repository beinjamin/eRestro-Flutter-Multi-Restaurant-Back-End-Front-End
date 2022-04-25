<?php
defined('BASEPATH') or exit('No direct script access allowed');


class Customer extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper']);
        $this->load->model(['Customer_model', 'address_model']);
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $partner_id = $this->ion_auth->get_user_id();
            if(get_partner_permission($partner_id, 'customer_privacy')){
                $this->data['main_page'] = TABLES . 'manage-customer';
                $settings = get_settings('system_settings', true);
                $this->data['title'] = 'View Customer | ' . $settings['app_name'];
                $this->data['meta_description'] = ' View Customer  | ' . $settings['app_name'];
                $this->data['about_us'] = get_settings('about_us');
                $this->load->view('partner/template', $this->data);
            }else{
                redirect('partner/login', 'refresh');
            }
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function view_customer()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            return $this->Customer_model->get_customer_list();
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    
}
