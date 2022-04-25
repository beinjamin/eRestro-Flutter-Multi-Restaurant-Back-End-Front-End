<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Faq extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper']);
        $this->load->model('faq_model');

        if (!has_permissions('read', 'faq')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-faq';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'FAQ  | ' . $settings['app_name'];
            $this->data['meta_description'] = 'FAQ  | ' . $settings['app_name'];
            $faq = $this->db->select('*')->or_where_in('status', ['1', '2'])->get('faqs')->result_array();
            $this->data['faq'] = $faq;
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function add_faq()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (isset($_POST['edit_faq'])) {
                if (print_msg(!has_permissions('update', 'faq'), PERMISSION_ERROR_MSG, 'faq')) {
                    return false;
                }
            } else {
                if (print_msg(!has_permissions('create', 'faq'), PERMISSION_ERROR_MSG, 'faq')) {
                    return false;
                }
            }

            $this->form_validation->set_rules('question', 'Question', 'trim|required|xss_clean');
            $this->form_validation->set_rules('answer', 'Answer', 'trim|required|xss_clean');
            if (!$this->form_validation->run()) {

                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                if (isset($_POST['edit_faq'])) {
                    if (is_exist(['question' => $_POST['question'], 'status' => '1'], 'faqs', $_POST['edit_faq'])) {
                        $response["error"]   = true;
                        $response["message"] = "Question Already Exist !";
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response["data"] = array();
                        echo json_encode($response);
                        return false;
                    }
                } else {
                    if (is_exist(['question' => $_POST['question'], 'status' => '1'], 'faqs')) {
                        $response["error"]   = true;
                        $response["message"] = "Question Already Exist !";
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response["data"] = array();
                        echo json_encode($response);
                        return false;
                    }
                }
                $this->faq_model->add_faq($_POST);
                $this->response['error'] = false;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $message = (isset($_POST['edit_faq'])) ? 'Faq Updated Successfully' : 'Faq Added Successfully';
                $this->response['message'] = $message;
                print_r(json_encode($this->response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function delete_faq()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('delete', 'faq'), PERMISSION_ERROR_MSG, 'faq', false)) {
                return false;
            }

            if (update_details(['status' => '0'], ['id' => $_GET['id']], 'faqs') == TRUE) {
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
