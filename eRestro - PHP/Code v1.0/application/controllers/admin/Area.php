<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Area extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper', 'file']);
        $this->load->model('Area_model');

        if (!has_permissions('read', 'city')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        } else {
            $this->session->set_flashdata('authorize_flag', "");
        }
    }



    public function manage_cities()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (!has_permissions('read', 'city')) {
                $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
                redirect('admin/home', 'refresh');
            }

            $this->data['main_page'] = TABLES . 'manage-city';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'City Management | ' . $settings['app_name'];
            $this->data['meta_description'] = ' City Management  | ' . $settings['app_name'];
            $this->data['google_map_api_key'] = $settings['google_map_api_key'];
            if (isset($_GET['edit_id'])) {
                $this->data['fetched_data'] = fetch_details(['id' => $_GET['edit_id']], 'cities');
            }
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public function manage_city_outlines()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (!has_permissions('update', 'city')) {
                $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
                redirect('admin/home', 'refresh');
            }

            $this->data['main_page'] = TABLES . 'manage-city-outlines';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Deliverable Area Management | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Deliverable Area Management  | ' . $settings['app_name'];
            $this->data['fetched_data'] = fetch_details("", 'cities');
            $this->data['google_map_api_key'] = $settings['google_map_api_key'];
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function view_city()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            return $this->Area_model->get_list($table = 'cities');
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public function delete_city()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (trim($_GET['table']) == 'cities') {
                if (print_msg(!has_permissions('delete', 'city'), PERMISSION_ERROR_MSG, 'city')) {
                    return false;
                }
            } 
            if (delete_details(['id' => $_GET['id']], $_GET['table'])) {
                $response['error'] = false;
                $response['message'] = 'Deleted Successfully';
            } else {
                $response['error'] = true;
                $response['message'] = 'Something went wrong';
            }
            echo json_encode($response);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function add_city()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (isset($_POST['edit_city'])) {
                if (print_msg(!has_permissions('update', 'city'), PERMISSION_ERROR_MSG, 'city')) {
                    return false;
                }
            } else {
                if (print_msg(!has_permissions('create', 'city'), PERMISSION_ERROR_MSG, 'city')) {
                    return false;
                }
            }
            if (!isset($_POST['boundary_points']) && empty($_POST['boundary_points'])) {

                $this->form_validation->set_rules('city_name', ' City Name ', 'trim|xss_clean|required');
                $this->form_validation->set_rules('latitude', ' latitude ', 'trim|xss_clean|required');
                $this->form_validation->set_rules('longitude', ' longitude ', 'trim|xss_clean|required');
                $this->form_validation->set_rules('time_to_travel', 'Time to Travel ', 'trim|xss_clean|required');
                $this->form_validation->set_rules('max_deliverable_distance', 'Max Deliverable Distance ', 'trim|xss_clean|required');
                $this->form_validation->set_rules('delivery_charge_method', 'delivery_charge_method ', 'trim|xss_clean|required');
                $this->form_validation->set_rules('fixed_charge', 'fixed_charge ', 'trim|xss_clean');
                $this->form_validation->set_rules('per_km_charge', 'per_km_charge ', 'trim|xss_clean');
                $this->form_validation->set_rules('range_wise_charges', 'range_wise_charges ', 'trim|xss_clean');
            } else {
                $this->form_validation->set_rules('geolocation_type', ' Geolocation Type ', 'trim|xss_clean|required');
                $this->form_validation->set_rules('radius', ' radius ', 'trim|xss_clean');
                $this->form_validation->set_rules('boundary_points', ' boundary_points ', 'trim|xss_clean|required');
            }

            if (!$this->form_validation->run()) {

                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                if (isset($_POST['edit_city']) && !empty($_POST['edit_city']) && $_POST['edit_city'] != "") {
                    if (isset($_POST['city_name']) && !empty($_POST['city_name'])) {
                        if (is_exist(["name" => $_POST['city_name']], 'cities', $_POST['edit_city'])) {
                            $response["error"]   = true;
                            $response["message"] = "City Name Already Exist ! Provide a unique name";
                            $response['csrfName'] = $this->security->get_csrf_token_name();
                            $response['csrfHash'] = $this->security->get_csrf_hash();
                            $response["data"] = array();
                            echo json_encode($response);
                            return false;
                        }
                    }
                } else {
                    if (is_exist(['name' => $_POST['city_name']], 'cities')) {
                        $response["error"]   = true;
                        $response["message"] = "City Name Already Exist ! Provide a unique name";
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response["data"] = array();
                        echo json_encode($response);
                        return false;
                    }
                }
                $delivery_charge_method = $this->input->post('delivery_charge_method',true);
                if($delivery_charge_method == 'fixed_charge'){
                    $_POST['charges'] = $this->input->post('fixed_charge',true);
                }
                if($delivery_charge_method == 'per_km_charge'){
                    $_POST['charges'] = $this->input->post('per_km_charge',true);
                }
                if($delivery_charge_method == 'range_wise_charges'){
                    $_POST['charges'] = $this->input->post('range_wise_charges',true);
                }
                $this->Area_model->add_city($_POST);
                $this->response['error'] = false;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $message = (isset($_POST['edit_city']) && !empty($_POST['edit_city']) && $_POST['edit_city'] != "") ? 'City Updated Successfully' : 'City Added Successfully';
                $this->response['message'] = $message;
                print_r(json_encode($this->response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }


    public function get_cities()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $search =  (isset($_GET['search'])) ? $_GET['search'] : null;
            $cities = $this->Area_model->get_cities($sort = "c.name", $order = "ASC", $search);
            $this->response['data'] = $cities['data'];
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            print_r(json_encode($this->response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function update_delivery_charge_method()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('update', 'city'), PERMISSION_ERROR_MSG, 'city')) {
                return false;
            }
            if (!isset($_GET['delivery_charge_method']) || empty($_GET['delivery_charge_method']) || $_GET['delivery_charge_method'] == "") {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = "Select delivery charge method.";
                print_r(json_encode($this->response));
                return false;
            }

            if (!in_array($this->input->get('delivery_charge_method', true), ['range_wise_charges', 'fixed_charge', 'per_km_charge'])) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = "Select proper method for delivery charge.";
                print_r(json_encode($this->response));
                return false;
            }
            if (!isset($_GET['charges']) || empty($_GET['charges']) || $_GET['charges'] == "") {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = "Select ranges for delivery charge.";
                print_r(json_encode($this->response));
                return false;
            } else {
                $delivery_charge_method = $this->input->get('delivery_charge_method', true);
                $charges = $this->input->get('charges', true);
                insert_details([$delivery_charge_method => $charges, 'delivery_charge_method' => $delivery_charge_method], "cities");
                $this->response['error'] = false;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = "Charges Updated Successfully.";
                print_r(json_encode($this->response));
                return false;
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
