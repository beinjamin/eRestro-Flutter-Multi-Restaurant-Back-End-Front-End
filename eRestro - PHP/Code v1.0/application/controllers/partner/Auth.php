<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Auth extends CI_Controller
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
            $this->data['title'] = 'Seller Login Panel | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Seller Login Panel | ' . $settings['app_name'];
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
        } else if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner()) {
            redirect('partner/home', 'refresh');
        } else if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            redirect('admin/home', 'refresh');
        }
    }

    public function sign_up()
    {
        $this->data['main_page'] = FORMS . 'partner-registration';
        $settings = get_settings('system_settings', true);
        $this->data['title'] = 'Sign Up Partner | ' . $settings['app_name'];
        $this->data['meta_description'] = 'Sign Up Partner | ' . $settings['app_name'];
        $this->data['logo'] = get_settings('logo');
        if (isset($_SESSION['to_be_partner_name']) && !empty($_SESSION['to_be_partner_name']) && isset($_SESSION['to_be_partner_mobile']) && !empty($_SESSION['to_be_partner_mobile']) && isset($_SESSION['to_be_partner_id']) && !empty($_SESSION['to_be_partner_id'])) {
            $this->data['title'] = 'Partner Registration | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Partner Registration | ' . $settings['app_name'];
            $this->data['user_data'] = $_SESSION;
        } else {
            $this->data['user_data'] = [];
        }
        $this->data['google_map_api_key'] = $settings['google_map_api_key'];
        $this->load->view('partner/login', $this->data);
    }

    public function create_partner()
    {
        $identity = $this->session->userdata('identity');
        if (!isset($_POST['user_id'])) {
            $this->form_validation->set_rules('name', 'Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('email', 'Mail', 'trim|required|xss_clean|valid_email');
            $this->form_validation->set_rules('mobile', 'Mobile', 'trim|required|xss_clean|min_length[5]');
        } else {
            $this->form_validation->set_rules('user_name', 'Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('user_mobile', 'Mobile', 'trim|required|xss_clean|min_length[5]');
        }

        $this->form_validation->set_rules('profile', 'Partner Profile', 'trim|xss_clean');
        $this->form_validation->set_rules('national_identity_card', 'National Identity Card', 'trim|xss_clean');
        $this->form_validation->set_rules('address_proof', 'Address Proof', 'trim|xss_clean');
        $this->form_validation->set_rules('working_time', 'Working Days', 'trim|xss_clean');
        $this->form_validation->set_rules('cooking_time', 'cooking_time', 'trim|required|xss_clean|numeric');

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

            if (isset($_POST['user_id']) && !empty($_POST['user_id'])) {

                /* check whether user exist or not */
                $user_id_to_seller = $this->input->post('user_id', true);
                $user = fetch_users($this->input->post('user_id', true));
                if (empty($user)) {
                    $this->response['error'] = true;
                    $this->response['message'] = "User not found!";
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = [];
                    print_r(json_encode($this->response));
                    return false;
                }
                $seller_data = array(
                    'user_id' => $this->input->post('user_id', true),
                    'address_proof' => (!empty($proof_doc)) ? $proof_doc : null,
                    'national_identity_card' => (!empty($id_card_doc)) ? $id_card_doc : null,
                    'profile' => (!empty($profile_doc)) ? $profile_doc : null,
                    'address' => $this->input->post('address', true),
                    'pan_number' => $this->input->post('pan_number', true),
                    'tax_number' => $this->input->post('tax_number', true),
                    'tax_name' => $this->input->post('tax_name', true),
                    'partner_name' => $this->input->post('partner_name', true),
                    'bank_name' => $this->input->post('bank_name', true),
                    'bank_code' => $this->input->post('bank_code', true),
                    'account_name' => $this->input->post('account_name', true),
                    'description' => $this->input->post('description', true),
                    'type' => $this->input->post('type', true),
                    'account_number' => $this->input->post('account_number', true),
                    'cooking_time' => $this->input->post('cooking_time', true),
                    'status' => 2,
                    'slug' => create_unique_slug($this->input->post('partner_name', true), 'partner_data')
                );


                if ($this->Partner_model->add_partner($seller_data)) {
                    $group_id = $this->ion_auth->get_users_groups($user_id_to_seller)->row()->id;
                    $this->ion_auth->remove_from_group($group_id, $user_id_to_seller);
                    $this->ion_auth->add_to_group('4', $user_id_to_seller);
                    $this->response['error'] = false;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $message = 'Partner Registered Successfully.';
                    $this->response['message'] = $message;
                    print_r(json_encode($this->response));
                } else {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] = "Partner does not registered.";
                    print_r(json_encode($this->response));
                }
            } else {

                if (!$this->form_validation->is_unique($_POST['mobile'], 'users.mobile') || !$this->form_validation->is_unique($_POST['email'], 'users.email')) {
                    $response["error"]   = true;
                    $response["message"] = "Email or mobile already exists !";
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $response["data"] = array();
                    echo json_encode($response);
                    return false;
                }

                $identity_column = $this->config->item('identity', 'ion_auth');
                $email = strtolower($this->input->post('email'));
                $mobile = $this->input->post('mobile');
                $identity = ($identity_column == 'mobile') ? $mobile : $email;
                $password = $this->input->post('password');

                $additional_data = [
                    'username' => $this->input->post('name', true),
                    'latitude' => $this->input->post('latitude', true),
                    'longitude' => $this->input->post('longitude', true),
                    'city' => $this->input->post('city', true)
                ];
                $tags = array();
                $this->ion_auth->register($identity, $password, $email, $additional_data, ['4']);
                if (update_details(['active' => 1], [$identity_column => $identity], 'users')) {
                    $user_id = fetch_details(['mobile' => $mobile], 'users', 'id');

                    $data = array(
                        'user_id' => $user_id[0]['id'],
                        'address_proof' => (!empty($proof_doc)) ? $proof_doc : null,
                        'national_identity_card' => (!empty($id_card_doc)) ? $id_card_doc : null,
                        'profile' => (!empty($profile_doc)) ? $profile_doc : null,
                        'partner_name' => $this->input->post('partner_name', true),
                        'description' => $this->input->post('description', true),
                        'address' => $this->input->post('address', true),
                        'type' => $this->input->post('type', true),
                        'tax_name' => $this->input->post('tax_name', true),
                        'tax_number' => $this->input->post('tax_number', true),
                        'account_number' => $this->input->post('account_number', true),
                        'account_name' => $this->input->post('account_name', true),
                        'bank_code' => $this->input->post('bank_code', true),
                        'bank_name' => $this->input->post('bank_name', true),
                        'pan_number' => $this->input->post('pan_number', true),
                        'cooking_time' => $this->input->post('cooking_time', true),
                        'status' => 2,
                        'slug' => create_unique_slug($this->input->post('partner_name', true), 'partner_data')
                    );
                    $insert_id = $this->Partner_model->add_partner($data, [], $work_time);
                    if (!empty($insert_id)) {
                        $this->response['error'] = false;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['message'] = 'Partner registared Successfully. Wait for aprooval of admin.';
                        print_r(json_encode($this->response));
                    } else {
                        $this->response['error'] = true;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['message'] = "Partner data was not added.";
                        print_r(json_encode($this->response));
                    }
                } else {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] = "Seller not Registared.";
                    print_r(json_encode($this->response));
                }
            }
        }
    }

    public function verify_account()
    {
        $identity_column = $this->config->item('identity', 'ion_auth');
        $identity = $this->input->post('identity', true);
        $this->form_validation->set_rules('identity', 'Mobile', 'trim|required|xss_clean');
        $this->form_validation->set_rules('password', 'Password', 'trim|required|xss_clean');
        if ($this->form_validation->run()) {
            $res = $this->db->select('id,mobile,username')->where($identity_column, $identity)->get('users')->result_array();
            if (!empty($res)) {
                // exiting user  
                if ($this->ion_auth_model->in_group('partner', $res[0]['id'])) {
                    // already partner
                    $response['error'] = false;
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $response['message'] = "This user is already partner please do login";
                    $response['data'] = array();
                    $response['redirect'] = 1;
                    echo json_encode($response);
                } else {
                    // already user
                    $this->session->set_flashdata('to_be_partner_name', $res[0]['username']);
                    $this->session->set_flashdata('to_be_partner_mobile', $res[0]['mobile']);
                    $this->session->set_flashdata('to_be_partner_id', $res[0]['id']);
                    $response['error'] = false;
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $response['message'] = "Already user";
                    $response['data'] = array();
                    $response['redirect'] = 3;
                    echo json_encode($response);
                }
            } else {
                // no user
                $response['error'] = true;
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                $response['message'] = "Redirect to new registration";
                $response['data'] = array();
                $response['redirect'] = 2;
                echo json_encode($response);
            }
        } else {
            $response['error'] = true;
            $response['csrfName'] = $this->security->get_csrf_token_name();
            $response['csrfHash'] = $this->security->get_csrf_hash();
            $response['message'] = validation_errors();
            $response['data'] = array();
            $response['redirect'] = 0;
            echo json_encode($response);
        }
    }


    public function update_user()
    {

        $identity_column = $this->config->item('identity', 'ion_auth');
        $identity = $this->session->userdata('identity');
        $user = $this->ion_auth->user()->row();
        if ($identity_column == 'email') {
            $this->form_validation->set_rules('email', 'Email', 'required|xss_clean|trim|valid_email|edit_unique[users.email.' . $user->id . ']');
        } else {
            $this->form_validation->set_rules('mobile', 'Mobile', 'required|xss_clean|trim|numeric|edit_unique[users.mobile.' . $user->id . ']');
        }
        $this->form_validation->set_rules('username', 'Username', 'required|xss_clean|trim');

        if (!empty($_POST['old']) || !empty($_POST['new']) || !empty($_POST['new_confirm'])) {
            $this->form_validation->set_rules('old', $this->lang->line('change_password_validation_old_password_label'), 'required');
            $this->form_validation->set_rules('new', $this->lang->line('change_password_validation_new_password_label'), 'required|min_length[' . $this->config->item('min_password_length', 'ion_auth') . ']|matches[new_confirm]');
            $this->form_validation->set_rules('new_confirm', $this->lang->line('change_password_validation_new_password_confirm_label'), 'required');
        }


        $tables = $this->config->item('tables', 'ion_auth');
        if (!$this->form_validation->run()) {
            if (validation_errors()) {
                $response['error'] = true;
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                $response['message'] = validation_errors();
                echo json_encode($response);
                return false;
                exit();
            }
            if ($this->session->flashdata('message')) {
                $response['error'] = false;
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                $response['message'] = $this->session->flashdata('message');
                echo json_encode($response);
                return false;
                exit();
            }
        } else {

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
            $set = ['username' => $this->input->post('username'), 'email' => $this->input->post('email')];
            $set = escape_array($set);
            $this->db->set($set)->where($identity_column, $identity)->update($tables['login_users']);
            $response['error'] = false;
            $response['csrfName'] = $this->security->get_csrf_token_name();
            $response['csrfHash'] = $this->security->get_csrf_hash();
            $response['message'] = 'Profile Update Succesfully';
            echo json_encode($response);
            return;
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
        $this->data['title'] = 'Forget Password | Seller Panel';
        $this->data['meta_description'] = 'Ekart';
        $this->data['logo'] = get_settings('logo');
        $this->load->view('partner/login', $this->data);
    }
}
