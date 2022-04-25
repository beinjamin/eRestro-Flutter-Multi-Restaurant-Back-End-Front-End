<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Fund_transfer extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model('Fund_transfers_model');

        if (!has_permissions('read', 'fund_transfer')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-fund-transfers';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'View Fund Transfer | ' . $settings['app_name'];
            $this->data['meta_description'] = ' View Fund Transfer  | ' . $settings['app_name'];
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function add_fund_transfer()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {


            if (!has_permissions('create', 'fund_transfer')) {
                return false;
            }

            $this->form_validation->set_rules('rider_id', 'Rider', 'trim|required|xss_clean|numeric');
            $this->form_validation->set_rules('transfer_amt', 'Transfer Amount', 'trim|required|xss_clean|numeric');
            $this->form_validation->set_rules('message', 'Message', 'trim|xss_clean');
            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                echo json_encode($this->response);
                return false;
            } else {

                $res = fetch_details(['id' => $_POST['rider_id']], 'users', 'balance');
                if ($res[0]['balance'] > 0 && $res[0]['balance'] != null) {

                    update_wallet_balance('debit', $_POST['rider_id'], $_POST['transfer_amt']);
                    $this->Fund_transfers_model->set_fund_transfer($_POST['rider_id'], $_POST['transfer_amt'], $res[0]['balance'], 'success', $_POST['message']);

                    $this->response['error'] = false;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] = 'Amount Successfully Transfered';
                } else {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] = 'Balance should be greater than 0';
                }

                echo json_encode($this->response);
                return false;
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function view_fund_transfers()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            return $this->Fund_transfers_model->get_fund_transfers_list();
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
