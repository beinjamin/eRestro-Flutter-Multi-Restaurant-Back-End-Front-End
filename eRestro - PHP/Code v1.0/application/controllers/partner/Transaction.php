<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Transaction extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model('Transaction_model');
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $this->data['main_page'] = TABLES . 'partner-wallet';
            $this->data['partner_id'] = $this->session->userdata('user_id');;
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Partner wallet | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Partner wallet  | ' . $settings['app_name'];
            $this->load->view('partner/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function view_transaction()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $this->data['main_page'] = TABLES . 'transaction';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'View Transaction | ' . $settings['app_name'];
            $this->data['meta_description'] = ' View Transaction  | ' . $settings['app_name'];
            $this->load->view('seller/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function view_transactions()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $seller_id = $this->session->userdata('user_id');
            return $this->Transaction_model->get_transactions_list($seller_id);
        } else {
            redirect('partner/login', 'refresh');
        }
    }
}
