<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Attribute extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper']);
        $this->load->model('attribute_model');
        if (!has_permissions('read', 'attribute')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'attribute';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Manage Attributes | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Manage Attributes | ' . $settings['app_name'];
            if (isset($_GET['edit_id'])) {
                $this->data['fetched_data'] = $this->db->select(' attr.* ,GROUP_CONCAT(av.value) as attribute_values')->join('attribute_values av', 'av.attribute_id = attr.id')
                    ->where(['attr.id' => $_GET['edit_id']])->group_by('attr.id')->get('attributes attr')->result_array();
            }
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function manage_attribute()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-attribute';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Attribute | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Attribute  | ' . $settings['app_name'];
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function add_attributes()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (isset($_POST['edit_attribute_id'])) {
                if (print_msg(!has_permissions('update', 'attribute'), PERMISSION_ERROR_MSG, 'attribute')) {
                    return false;
                }
            } else {
                if (print_msg(!has_permissions('create', 'attribute'), PERMISSION_ERROR_MSG, 'attribute')) {
                    return false;
                }
            }

            $this->form_validation->set_rules('name', 'Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('attribute_values', 'Attribute Values', 'trim|xss_clean');

            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                if (isset($_POST['edit_attribute_id'])) {
                    if (is_exist(['name' => $_POST['name']], 'attributes', $_POST['edit_attribute_id'])) {
                        $response["error"]   = true;
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response["message"] = "This Attribute Already Exist.";
                        $response["data"] = array();
                        echo json_encode($response);
                        return false;
                    }
                    if($this->attribute_model->add_attributes($_POST)){
                        $response["error"]   = true;
                        $response["message"] = "This combination already exist ! Please provide a new combination";
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response["data"] = array();
                        echo json_encode($response);
                        return false;
                    }else{   
                        $this->response['error'] = false;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['message'] = "Attribute Updated Successfully";
                        print_r(json_encode($this->response));
                        return false;
                    }
                } else {
                    if (is_exist(['name' => $_POST['name']], 'attributes')) {
                        $response["error"]   = true;
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response["message"] = "This Attribute Already Exist.";
                        $response["data"] = array();
                        echo json_encode($response);
                        return false;
                    }
                    $this->attribute_model->add_attributes($_POST);
                    $this->response['error'] = false;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] = 'Attribute Added Successfully';
                    print_r(json_encode($this->response));

                }
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function attribute_list()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            return $this->attribute_model->get_attribute_list();
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function update_attribute_values_status()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) {
                $this->response['error'] = true;
                $this->response['message'] = DEMO_VERSION_MSG;
                echo json_encode($this->response);
                return false;
                exit();
            }
            if (isset($_GET['id']) && !empty($_GET['id'])) {
                $id = $this->input->get("id", true);
                if (update_details(['status' => 0], ['id' => $id], "attribute_values")) {
                    $response['error'] = false;
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $response['message'] = "Value Deleted Successfully.";
                    print_r(json_encode($response));
                    return false;
                } else {
                    $response['error'] = true;
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $response['message'] = "Something went wrong.Please try again later.";
                    print_r(json_encode($response));
                    return false;
                }
            } else {
                $response['error'] = true;
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                $response['message'] = "ID field is required.";
                print_r(json_encode($response));
                return false;
            }

           
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
