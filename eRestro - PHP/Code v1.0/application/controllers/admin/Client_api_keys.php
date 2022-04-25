<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Client_api_keys extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload','jwt']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model(['client_apikeys_model']);

        if (!has_permissions('read', 'client_api_keys')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-client-api-keys';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Client Api Keys Management | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Client Api Keys Management | ' . $settings['app_name'];
            $client_api_keys = fetch_details(['status' => 1], 'client_api_keys');
			$token = '';
			if(!empty($client_api_keys) && isset($client_api_keys[0]['secret'])){
				$payload = [
					'iat' => time(), /* issued at time */
					'iss' => 'erestro',
					'exp' => time() + (30 * 60), /* expires after 1 minute */
				];
				$token = $this->jwt->encode($payload, $client_api_keys[0]['secret']);
			}
			$this->data['token'] = $token;
			if (isset($_GET['edit_id'])) {
                $this->data['fetched_data'] = fetch_details(['id' => $_GET['edit_id']], 'client_api_keys');
            }
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function add_client()
    {
        if (isset($_POST['edit_client_api_keys'])) {
            if (print_msg(!has_permissions('update', 'client_api_keys'), PERMISSION_ERROR_MSG, 'client_api_keys')) {
                return false;
            }
        } else {
            if (print_msg(!has_permissions('create', 'client_api_keys'), PERMISSION_ERROR_MSG, 'client_api_keys')) {
                return false;
            }
        }
        $this->form_validation->set_rules('name', 'Client Name', 'trim|required|xss_clean');


        if (!$this->form_validation->run()) {

            $this->response['error'] = true;
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            $this->response['message'] = validation_errors();
            print_r(json_encode($this->response));
        } else {

            $this->client_apikeys_model->set($_POST);

            $this->response['error'] = false;
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            $this->response['message'] = (isset($_POST['edit_client_api_keys'])) ? ' Client Updated Successfully' : 'Client Added Successfully';
            // print_r($_POST);
            print_r(json_encode($this->response));
        }
    }

    public function get_client_api_keys()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            $this->client_apikeys_model->get_list();
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function delete_client()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('delete', 'client_api_keys'), PERMISSION_ERROR_MSG, 'client_api_keys', false)) {
                return false;
            }

            if (delete_details(['id' => $_GET['id']], 'client_api_keys')) {
                $this->response['error'] = false;
                $this->response['message'] = 'Deleted Succesfully';
                print_r(json_encode($this->response));
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Something Went Wrong';
                print_r(json_encode($this->response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
