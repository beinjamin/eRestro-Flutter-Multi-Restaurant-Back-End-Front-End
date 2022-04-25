<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Category extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model(['category_model']);
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $this->data['main_page'] = TABLES . 'manage-category';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Category Management | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Category Management | ' . $settings['app_name'];
            $id = $this->input->get('id', true);
            if (isset($id) && !empty($id)) {
                $this->data['base_category_url'] = base_url() . 'partner/category/category_list?id=' . $id;
            } else {
                $this->data['base_category_url']  = base_url() . 'partner/category/category_list';
            }
            $this->data['category_result'] = $this->category_model->get_categories();
            $this->load->view('partner/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function get_categories()
    {
        $ignore_status = isset($_GET['ignore_status']) && $_GET['ignore_status'] == 1 ? 1 : '';
        $response['data'] = $this->data['category_result'] = $this->category_model->get_categories(NULL, '', '', 'row_order', 'ASC', 'true', '', $ignore_status);
        echo json_encode($response);
        return;
    }

    public function get_seller_categories()
    {
        $seller_id = (isset($_GET['seller_id']) && !empty($_GET['seller_id'])) ? $this->input->get('seller_id', true) :  $this->session->userdata('user_id');
        $ignore_status = isset($_GET['ignore_status']) && $_GET['ignore_status'] == 1 ? 1 : '';
        $response['data'] = $this->category_model->get_seller_categories($seller_id);
        echo json_encode($response);
        return;
    }

    public function category_list()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            return $this->category_model->get_category_list();
        } else {
            redirect('partner/login', 'refresh');
        }
    }
}
