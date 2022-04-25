<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Taxes extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model('Tax_model');
    }

    public function index()
    {
		if($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)){
            $this->data['main_page'] = TABLES . 'manage-taxes';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Taxes | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Taxes | ' . $settings['app_name'];
            $this->load->view('partner/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function get_tax_list()
    {
		if($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)){
            return $this->Tax_model->get_tax_list();
        } else {
            redirect('partner/login', 'refresh');
        }
    }
}
