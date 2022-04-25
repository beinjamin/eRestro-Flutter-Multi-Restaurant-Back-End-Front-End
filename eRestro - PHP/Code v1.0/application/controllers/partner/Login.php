<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Login extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language']);
        $this->load->model('Partner_model');
        $this->lang->load('auth');
    }

    public function index()
    {
        if (!$this->ion_auth->logged_in() && !$this->ion_auth->is_partner()) {
            $this->data['main_page'] = FORMS . 'login';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Partner Login Panel | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Partner Login Panel | ' . $settings['app_name'];
            $this->data['logo'] = get_settings('logo');
            $this->data['app_name'] = $settings['app_name'];
            $identity = $this->config->item('identity', 'ion_auth');
            if (empty($identity)) {
                $identity_column = 'text';
            } else {
                $identity_column = $identity;
            }
            $this->data['identity_column'] = $identity_column;
            $this->load->view('partner/login', $this->data);
        } else if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 2 || $this->ion_auth->partner_status() == 7)) {
            $this->ion_auth->logout();
            $this->data['main_page'] = FORMS . 'login';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Partner Login Panel | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Partner Login Panel | ' . $settings['app_name'];
            $this->data['logo'] = get_settings('logo');
            $this->data['app_name'] = $settings['app_name'];
            $identity = $this->config->item('identity', 'ion_auth');
            if (empty($identity)) {
                $identity_column = 'text';
            } else {
                $identity_column = $identity;
            }
            $this->data['identity_column'] = $identity_column;
            $this->load->view('partner/login', $this->data);
        } else if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            redirect('partner/home', 'refresh');
        } else if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {
            redirect('rider/home', 'refresh');
        } else if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            redirect('admin/home', 'refresh');
        }
    }

    public function update_user()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            // validate owner details

            $identity = $this->session->userdata('identity');
            $this->form_validation->set_rules('name', 'Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('email', 'Mail', 'trim|required|xss_clean|valid_email');
            $this->form_validation->set_rules('mobile', 'Mobile', 'trim|required|xss_clean|min_length[5]');
            if (!empty($_POST['old']) || !empty($_POST['new']) || !empty($_POST['new_confirm'])) {
                $this->form_validation->set_rules('old', $this->lang->line('change_password_validation_old_password_label'), 'required');
                $this->form_validation->set_rules('new', $this->lang->line('change_password_validation_new_password_label'), 'required|min_length[' . $this->config->item('min_password_length', 'ion_auth') . ']|matches[new_confirm]');
                $this->form_validation->set_rules('new_confirm', $this->lang->line('change_password_validation_new_password_confirm_label'), 'required');
            }
            if (!isset($_POST['edit_restro'])) {
                $this->form_validation->set_rules('profile', 'Partner Profile', 'trim|xss_clean');
                $this->form_validation->set_rules('national_identity_card', 'National Identity Card', 'trim|xss_clean');
                $this->form_validation->set_rules('address_proof', 'Address Proof', 'trim|xss_clean');
            }
            $this->form_validation->set_rules('working_time', 'Working Days', 'trim|xss_clean');
            $this->form_validation->set_rules('global_commission', 'global_commission', 'trim|required|xss_clean|numeric');
            $this->form_validation->set_rules('cooking_time', 'cooking_time', 'trim|required|xss_clean|numeric');
            $this->form_validation->set_rules('restro_tags[]', 'Restro Tags', 'trim|xss_clean');

            // validate restro details
            $this->form_validation->set_rules('partner_name', 'Partner Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('description', 'Description', 'trim|required|xss_clean');
            $this->form_validation->set_rules('address', 'Address', 'trim|required|xss_clean');
            $this->form_validation->set_rules('latitude', 'Latitude', 'trim|xss_clean');
            $this->form_validation->set_rules('longitude', 'Longitude', 'trim|xss_clean');
            $this->form_validation->set_rules('type', 'Type', 'trim|required|xss_clean');
            $this->form_validation->set_rules('tax_name', 'Tax Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('tax_number', 'Tax Number', 'trim|required|xss_clean');

            // bank details
            $this->form_validation->set_rules('account_number', 'Account Number', 'trim|xss_clean');
            $this->form_validation->set_rules('account_name', 'Account Name', 'trim|xss_clean');
            $this->form_validation->set_rules('bank_code', 'Bank Code', 'trim|xss_clean');
            $this->form_validation->set_rules('bank_name', 'Bank Name', 'trim|xss_clean');
            $this->form_validation->set_rules('pan_number', 'Pan Number', 'trim|xss_clean');

            if (!$this->form_validation->run()) {

                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                // process images

                if (!file_exists(FCPATH . RESTRO_DOCUMENTS_PATH)) {
                    mkdir(FCPATH . RESTRO_DOCUMENTS_PATH, 0777);
                }

                //process store logo
                $temp_array_logo = $profile_doc = array();
                $logo_files = $_FILES;
                $profile_error = "";
                $config = [
                    'upload_path' =>  FCPATH . RESTRO_DOCUMENTS_PATH,
                    'allowed_types' => 'jpg|png|jpeg|gif',
                    'max_size' => 8000,
                ];
                if (isset($logo_files['profile']) && !empty($logo_files['profile']['name']) && isset($logo_files['profile']['name'])) {
                    $other_img = $this->upload;
                    $other_img->initialize($config);

                    if (isset($_POST['edit_restro']) && !empty($_POST['edit_restro']) && isset($_POST['old_profile']) && !empty($_POST['old_profile'])) {
                        $old_logo = explode('/', $this->input->post('old_profile', true));
                        delete_images(RESTRO_DOCUMENTS_PATH, $old_logo[2]);
                    }

                    if (!empty($logo_files['profile']['name'])) {

                        $_FILES['temp_image']['name'] = $logo_files['profile']['name'];
                        $_FILES['temp_image']['type'] = $logo_files['profile']['type'];
                        $_FILES['temp_image']['tmp_name'] = $logo_files['profile']['tmp_name'];
                        $_FILES['temp_image']['error'] = $logo_files['profile']['error'];
                        $_FILES['temp_image']['size'] = $logo_files['profile']['size'];
                        if (!$other_img->do_upload('temp_image')) {
                            $profile_error = 'Images :' . $profile_error . ' ' . $other_img->display_errors();
                        } else {
                            $temp_array_logo = $other_img->data();
                            resize_review_images($temp_array_logo, FCPATH . RESTRO_DOCUMENTS_PATH);
                            $profile_doc  = RESTRO_DOCUMENTS_PATH . $temp_array_logo['file_name'];
                        }
                    } else {
                        $_FILES['temp_image']['name'] = $logo_files['profile']['name'];
                        $_FILES['temp_image']['type'] = $logo_files['profile']['type'];
                        $_FILES['temp_image']['tmp_name'] = $logo_files['profile']['tmp_name'];
                        $_FILES['temp_image']['error'] = $logo_files['profile']['error'];
                        $_FILES['temp_image']['size'] = $logo_files['profile']['size'];
                        if (!$other_img->do_upload('temp_image')) {
                            $profile_error = $other_img->display_errors();
                        }
                    }
                    //Deleting Uploaded Images if any overall error occured
                    if ($profile_error != NULL || !$this->form_validation->run()) {
                        if (isset($profile_doc) && !empty($profile_doc || !$this->form_validation->run())) {
                            foreach ($profile_doc as $key => $val) {
                                unlink(FCPATH . RESTRO_DOCUMENTS_PATH . $profile_doc[$key]);
                            }
                        }
                    }
                }

                if ($profile_error != NULL) {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] =  $profile_error;
                    print_r(json_encode($this->response));
                    return;
                }

                //process national_identity_card
                $temp_array_id_card = $id_card_doc = array();
                $id_card_files = $_FILES;
                $id_card_error = "";
                $config = [
                    'upload_path' =>  FCPATH . RESTRO_DOCUMENTS_PATH,
                    'allowed_types' => 'jpg|png|jpeg|gif',
                    'max_size' => 8000,
                ];
                if (isset($id_card_files['national_identity_card']) &&  !empty($id_card_files['national_identity_card']['name']) && isset($id_card_files['national_identity_card']['name'])) {
                    $other_img = $this->upload;
                    $other_img->initialize($config);

                    if (isset($_POST['edit_restro']) && !empty($_POST['edit_restro']) && isset($_POST['old_national_identity_card']) && !empty($_POST['old_national_identity_card'])) {
                        $old_national_identity_card = explode('/', $this->input->post('old_national_identity_card', true));
                        delete_images(RESTRO_DOCUMENTS_PATH, $old_national_identity_card[2]);
                    }

                    if (!empty($id_card_files['national_identity_card']['name'])) {

                        $_FILES['temp_image']['name'] = $id_card_files['national_identity_card']['name'];
                        $_FILES['temp_image']['type'] = $id_card_files['national_identity_card']['type'];
                        $_FILES['temp_image']['tmp_name'] = $id_card_files['national_identity_card']['tmp_name'];
                        $_FILES['temp_image']['error'] = $id_card_files['national_identity_card']['error'];
                        $_FILES['temp_image']['size'] = $id_card_files['national_identity_card']['size'];
                        if (!$other_img->do_upload('temp_image')) {
                            $id_card_error = 'Images :' . $id_card_error . ' ' . $other_img->display_errors();
                        } else {
                            $temp_array_id_card = $other_img->data();
                            resize_review_images($temp_array_id_card, FCPATH . RESTRO_DOCUMENTS_PATH);
                            $id_card_doc  = RESTRO_DOCUMENTS_PATH . $temp_array_id_card['file_name'];
                        }
                    } else {
                        $_FILES['temp_image']['name'] = $id_card_files['national_identity_card']['name'];
                        $_FILES['temp_image']['type'] = $id_card_files['national_identity_card']['type'];
                        $_FILES['temp_image']['tmp_name'] = $id_card_files['national_identity_card']['tmp_name'];
                        $_FILES['temp_image']['error'] = $id_card_files['national_identity_card']['error'];
                        $_FILES['temp_image']['size'] = $id_card_files['national_identity_card']['size'];
                        if (!$other_img->do_upload('temp_image')) {
                            $id_card_error = $other_img->display_errors();
                        }
                    }
                    //Deleting Uploaded Images if any overall error occured
                    if ($id_card_error != NULL || !$this->form_validation->run()) {
                        if (isset($id_card_doc) && !empty($id_card_doc || !$this->form_validation->run())) {
                            foreach ($id_card_doc as $key => $val) {
                                unlink(FCPATH . RESTRO_DOCUMENTS_PATH . $id_card_doc[$key]);
                            }
                        }
                    }
                }

                if ($id_card_error != NULL) {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] =  $id_card_error;
                    print_r(json_encode($this->response));
                    return;
                }

                //process address_proof
                $temp_array_proof = $proof_doc = array();
                $proof_files = $_FILES;
                $proof_error = "";
                $config = [
                    'upload_path' =>  FCPATH . RESTRO_DOCUMENTS_PATH,
                    'allowed_types' => 'jpg|png|jpeg|gif',
                    'max_size' => 8000,
                ];
                if (isset($proof_files['address_proof']) && !empty($proof_files['address_proof']['name']) && isset($proof_files['address_proof']['name'])) {
                    $other_img = $this->upload;
                    $other_img->initialize($config);

                    if (isset($_POST['edit_restro']) && !empty($_POST['edit_restro']) && isset($_POST['old_address_proof']) && !empty($_POST['old_address_proof'])) {
                        $old_address_proof = explode('/', $this->input->post('old_address_proof', true));
                        delete_images(RESTRO_DOCUMENTS_PATH, $old_address_proof[2]);
                    }

                    if (!empty($proof_files['address_proof']['name'])) {

                        $_FILES['temp_image']['name'] = $proof_files['address_proof']['name'];
                        $_FILES['temp_image']['type'] = $proof_files['address_proof']['type'];
                        $_FILES['temp_image']['tmp_name'] = $proof_files['address_proof']['tmp_name'];
                        $_FILES['temp_image']['error'] = $proof_files['address_proof']['error'];
                        $_FILES['temp_image']['size'] = $proof_files['address_proof']['size'];
                        if (!$other_img->do_upload('temp_image')) {
                            $proof_error = 'Images :' . $proof_error . ' ' . $other_img->display_errors();
                        } else {
                            $temp_array_proof = $other_img->data();
                            resize_review_images($temp_array_proof, FCPATH . RESTRO_DOCUMENTS_PATH);
                            $proof_doc  = RESTRO_DOCUMENTS_PATH . $temp_array_proof['file_name'];
                        }
                    } else {
                        $_FILES['temp_image']['name'] = $proof_files['address_proof']['name'];
                        $_FILES['temp_image']['type'] = $proof_files['address_proof']['type'];
                        $_FILES['temp_image']['tmp_name'] = $proof_files['address_proof']['tmp_name'];
                        $_FILES['temp_image']['error'] = $proof_files['address_proof']['error'];
                        $_FILES['temp_image']['size'] = $proof_files['address_proof']['size'];
                        if (!$other_img->do_upload('temp_image')) {
                            $proof_error = $other_img->display_errors();
                        }
                    }
                    //Deleting Uploaded Images if any overall error occured
                    if ($proof_error != NULL || !$this->form_validation->run()) {
                        if (isset($proof_doc) && !empty($proof_doc || !$this->form_validation->run())) {
                            foreach ($proof_doc as $key => $val) {
                                unlink(FCPATH . RESTRO_DOCUMENTS_PATH . $proof_doc[$key]);
                            }
                        }
                    }
                }

                if ($proof_error != NULL) {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] =  $proof_error;
                    print_r(json_encode($this->response));
                    return;
                }

                // process working hours for restro

                $work_time = [];
                if (isset($_POST['working_time']) && !empty($_POST['working_time'])) {
                    $working_time = $this->input->post('working_time', true);
                    $work_time = json_decode($working_time, true);
                }


                if (isset($_POST['edit_restro'])) {

                    $restro_data = array(
                        'user_id' => $this->input->post('edit_restro', true),
                        'edit_restro_data_id' => $this->input->post('edit_restro_data_id', true),
                        'address_proof' => (!empty($proof_doc)) ? $proof_doc : $this->input->post('old_address_proof', true),
                        'national_identity_card' => (!empty($id_card_doc)) ? $id_card_doc : $this->input->post('old_national_identity_card', true),
                        'profile' => (!empty($profile_doc)) ? $profile_doc : $this->input->post('old_profile', true),
                        'global_commission' => (isset($_POST['global_commission']) && !empty($_POST['global_commission'])) ? $this->input->post('global_commission', true) : 0,
                        'partner_name' => $this->input->post('partner_name', true),
                        'description' => $this->input->post('description', true),
                        'address' => $this->input->post('address', true),
                        'type' => $this->input->post('type', true),
                        'tax_name' => $this->input->post('tax_name', true),
                        'tax_number' => $this->input->post('tax_number', true),
                        'account_number' => $this->input->post('account_number', true),
                        'account_name' => $this->input->post('account_name', true),
                        'bank_code' => $this->input->post('bank_code', true),
                        'cooking_time' => $this->input->post('cooking_time', true),
                        'bank_name' => $this->input->post('bank_name', true),
                        'pan_number' => $this->input->post('pan_number', true),
                        'gallery' => (isset($_POST['gallery']) && !empty($_POST['gallery'])) ? $this->input->post('gallery', true) : NULL,
                        'status' => $this->input->post('status', true),
                        'slug' => create_unique_slug($this->input->post('partner_name', true), 'partner_data')
                    );
                    $profile = array(
                        'name' => $this->input->post('name', true),
                        'email' => $this->input->post('email', true),
                        'mobile' => $this->input->post('mobile', true),
                        'password' => $this->input->post('password', true),
                        'latitude' => $this->input->post('latitude', true),
                        'longitude' => $this->input->post('longitude', true),
                        'city' => $this->input->post('city', true)
                    );
                    if (!empty($_POST['old']) || !empty($_POST['new']) || !empty($_POST['new_confirm'])) {
                        if (!$this->ion_auth->change_password($identity, $this->input->post('old'), $this->input->post('new'))) {
                            $response['error'] = true;
                            $response['csrfName'] = $this->security->get_csrf_token_name();
                            $response['csrfHash'] = $this->security->get_csrf_hash();
                            $response['message'] = $this->ion_auth->errors();
                            echo json_encode($response);
                            return;
                            exit();
                        }
                    }

                    // process updated tags
                    $tags = array();
                    if (isset($_POST['restro_tags']) && !empty($_POST['restro_tags'])) {
                        foreach ($_POST['restro_tags'] as $row) {
                            $tempRow['partner_id'] = $this->input->post('edit_restro', true);
                            $tempRow['tag_id'] = $row;
                            $tags[] = $tempRow;
                        }
                    }

                    if ($this->Partner_model->add_partner($restro_data, $profile, $work_time, $tags)) {
                        $this->response['error'] = false;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $message = 'Partner Update Successfully';
                        $this->response['message'] = $message;
                        print_r(json_encode($this->response));
                    } else {
                        $this->response['error'] = true;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['message'] = "Partner data was not updated";
                        print_r(json_encode($this->response));
                    }
                } else {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] = "Something went wrong.";
                    print_r(json_encode($this->response));
                }
            }
        } else {
            redirect('partner/home', 'refresh');
        }
    }

    public function auth()
    {
        $identity_column = $this->config->item('identity', 'ion_auth');
        $identity = $this->input->post('identity', true);
        $this->form_validation->set_rules('identity', 'Email', 'trim|required|xss_clean');
        $this->form_validation->set_rules('password', 'Password', 'trim|required|xss_clean');
        $res = $this->db->select('id')->where($identity_column, $identity)->get('users')->result_array();
        if ($this->form_validation->run()) {
            if (!empty($res)) {
                if ($this->ion_auth_model->in_group('partner', $res[0]['id'])) {
                    $remember = (bool)$this->input->post('remember');
                    if ($this->ion_auth->login($this->input->post('identity', true), $this->input->post('password', true), $remember)) {
                        //if the login is successful
                        $response['error'] = false;
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response['message'] = $this->ion_auth->messages();
                        echo json_encode($response);
                    } else {
                        // if the login was un-successful
                        $response['error'] = true;
                        $response['csrfName'] = $this->security->get_csrf_token_name();
                        $response['csrfHash'] = $this->security->get_csrf_hash();
                        $response['message'] = $this->ion_auth->errors();
                        echo json_encode($response);
                    }
                } else {
                    $response['error'] = true;
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $response['message'] = ucfirst($identity_column) . ' field is not correct';
                    echo json_encode($response);
                }
            } else {
                $response['error'] = true;
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                $response['message'] = '' . ucfirst($identity_column) . ' field is not correct';
                echo json_encode($response);
            }
        } else {
            $response['error'] = true;
            $response['csrfName'] = $this->security->get_csrf_token_name();
            $response['csrfHash'] = $this->security->get_csrf_hash();
            $response['message'] = validation_errors();
            echo json_encode($response);
        }
    }

    public function forgot_password()
    {
        $this->data['main_page'] = FORMS . 'forgot-password';
        $this->data['title'] = 'Forget Password | Partner Panel';
        $this->data['meta_description'] = 'Ekart';
        $this->data['logo'] = get_settings('logo');
        $this->load->view('partner/login', $this->data);
    }
}
