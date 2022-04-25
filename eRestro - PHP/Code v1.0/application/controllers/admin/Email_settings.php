<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Email_settings extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper']);
        $this->load->model('Setting_model');

        if (!has_permissions('read', 'email_settings')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'email-settings';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Email Settings | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Email Settings | ' . $settings['app_name'];
            $this->data['email_settings'] = get_settings('email_settings', true);
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }


    public function set_email_settings()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('update', 'email_settings'), PERMISSION_ERROR_MSG, 'email_settings')) {
                return false;
            }

            $this->form_validation->set_rules('email', 'Email', 'trim|required|xss_clean|valid_email');
            $this->form_validation->set_rules('password', 'Password', 'trim|required|xss_clean');
            $this->form_validation->set_rules('smtp_host', 'Smpt Host', 'trim|required|xss_clean');
            $this->form_validation->set_rules('smtp_port', 'Smpt Port', 'trim|required|xss_clean');
            $this->form_validation->set_rules('mail_content_type', 'Mail Content Type', 'trim|required|xss_clean');
            $this->form_validation->set_rules('smtp_encryption', 'Smpt Encryption', 'trim|required|xss_clean');

            if (!$this->form_validation->run()) {

                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                $this->Setting_model->update_email_settings($_POST);
                $this->response['error'] = false;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = 'System Setting Updated Successfully';
                print_r(json_encode($this->response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
