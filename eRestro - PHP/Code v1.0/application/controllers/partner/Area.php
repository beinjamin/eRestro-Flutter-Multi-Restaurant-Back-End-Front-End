<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Area extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper']);
        $this->load->model('Area_model');
    }

    public function manage_cities()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {

            $this->data['main_page'] = TABLES . 'manage-city';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'City Management | ' . $settings['app_name'];
            $this->data['meta_description'] = ' City Management  | ' . $settings['app_name'];

            $this->load->view('partner/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function view_city()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            return $this->Area_model->get_list($table = 'cities');
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function get_cities()
    {
        $search =  (isset($_GET['search'])) ? $_GET['search'] : null;
        $cities = $this->Area_model->get_cities("c.name", "ASC", $search);
        $this->response['data'] = $cities['data'];
        print_r(json_encode($this->response));
    }
}
