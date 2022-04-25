<?php
defined('BASEPATH') or exit('No direct script access allowed');


class Slider extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper']);
        $this->load->model(['Slider_model', 'category_model']);

        if (!has_permissions('read', 'home_slider_images')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }

    public  function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'slider';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = (isset($_GET['edit_id']) && !empty($_GET['edit_id'])) ? 'Edit Slider | ' . $settings['app_name'] : 'Add Slider | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Add Slider | ' . $settings['app_name'];
            $this->data['categories'] = $this->category_model->get_categories();
            if (isset($_GET['edit_id']) && !empty($_GET['edit_id'])) {
                $this->data['fetched_data'] = fetch_details(['id' => $_GET['edit_id']], 'sliders');
            }
            $this->data['about_us'] = get_settings('about_us');
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public  function manage_slider()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-slider';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Slider Management | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Slider Management  | ' . $settings['app_name'];
            $this->data['about_us'] = get_settings('about_us');
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public  function delete_slider()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('delete', 'home_slider_images'), PERMISSION_ERROR_MSG, 'home_slider_images', false)) {
                return false;
            }

            if (delete_details(['id' => $_GET['id']], 'sliders') == TRUE) {
                $this->response['error'] = false;
                $this->response['message'] = 'Deleted Succesfully';
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Something Went Wrong';
            }
            print_r(json_encode($this->response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    function get_values_by_type()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin() && isset($_GET['type_val'])) {
            print_r(json_encode(fetch_details('', $_GET['type_val'], 'id,name')));
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public function add_slider()
    {
        if (isset($_POST['edit_slider'])) {
            if (print_msg(!has_permissions('update', 'home_slider_images'), PERMISSION_ERROR_MSG, 'home_slider_images')) {
                return false;
            }
        } else {
            if (print_msg(!has_permissions('create', 'home_slider_images'), PERMISSION_ERROR_MSG, 'home_slider_images')) {
                return false;
            }
        }

        $this->form_validation->set_rules('slider_type', 'Slider Type', 'trim|required|xss_clean');
        $this->form_validation->set_rules('image', 'Slider Image', 'trim|required|xss_clean', array('required' => 'Slider image is required'));
        if (isset($_POST['slider_type']) && $_POST['slider_type'] == 'categories') {
            $this->form_validation->set_rules('category_id', 'Category', 'trim|required|xss_clean');
        }
        if (isset($_POST['slider_type']) && $_POST['slider_type'] == 'products') {
            $this->form_validation->set_rules('product_id', 'Product', 'trim|required|xss_clean');
        }

        if (!$this->form_validation->run()) {

            $this->response['error'] = true;
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            $this->response['message'] = validation_errors();
            print_r(json_encode($this->response));
        } else {
            $this->Slider_model->add_slider($_POST);
            $this->response['error'] = false;
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            $message = (isset($_POST['edit_slider'])) ? 'Slider Updated Successfully' : 'Slider Added Successfully';
            $this->response['message'] = $message;
            print_r(json_encode($this->response));
        }
    }



    public function view_slider()
    {

        return $this->Slider_model->get_slider_list();
    }
}
