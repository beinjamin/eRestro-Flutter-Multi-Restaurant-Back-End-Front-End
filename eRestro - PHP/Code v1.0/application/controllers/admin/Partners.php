<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Partners extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model('Partner_model');
        if (!has_permissions('read', 'partner')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-partner';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Partner Management | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Partner Management  | ' . $settings['app_name'];
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function manage_partner()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'partner';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Add Partner | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Add Partner | ' . $settings['app_name'];
            $this->data['categories'] = $this->category_model->get_categories();
            $this->data['cities'] = fetch_details("", 'cities');
            $this->data['google_map_api_key'] = $settings['google_map_api_key'];
            if (isset($_GET['edit_id']) && !empty($_GET['edit_id'])) {
                $this->data['title'] = 'Update Partner | ' . $settings['app_name'];
                $this->data['meta_description'] = 'Update Partner | ' . $settings['app_name'];
                $this->data['fetched_data'] = $this->db->select(' u.*,sd.* ')
                    ->join('users_groups ug', ' ug.user_id = u.id ')
                    ->join('partner_data sd', ' sd.user_id = u.id ')
                    ->where(['ug.group_id' => '4', 'ug.user_id' => $_GET['edit_id']])
                    ->get('users u')
                    ->result_array();
                $this->data['tags'] = fetch_details(["rt.partner_id" => $_GET['edit_id']], "partner_tags rt", "rt.*,t.title", null, null, null, "DESC", "", '', "tags t", "t.id=rt.tag_id");
            }
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function view_partners()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            return $this->Partner_model->get_partners_list();
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function remove_partners()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (print_msg(!has_permissions('delete', 'partner'), PERMISSION_ERROR_MSG, 'partner', false)) {
                return true;
            }

            if (!isset($_GET['id']) && empty($_GET['id'])) {
                $this->response['error'] = true;
                $this->response['message'] = 'Partner id is required';
                print_r(json_encode($this->response));
                return;
                exit();
            }
            $all_status = [0, 1, 2, 7];
            $status = $this->input->get('status', true);
            $id = $this->input->get('id', true);
            if (!in_array($status, $all_status)) {
                $this->response['error'] = true;
                $this->response['message'] = 'Invalid status';
                print_r(json_encode($this->response));
                return;
                exit();
            }
            if ($status == 2) {
                $this->response['error'] = true;
                $this->response['message'] = 'First approve this Partner from edit partner manu.';
                print_r(json_encode($this->response));
                return;
                exit();
            }
            $status = ($status == 7) ? 1 : (($status == 1) ? 7 : 1);

            if (update_details(['status' => $status], ['user_id' => $id], 'partner_data') == TRUE) {
                $this->response['error'] = false;
                $this->response['message'] = 'Partner removed succesfully';
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

    public function delete_partner()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            // also remove restro tags
            if (print_msg(!has_permissions('delete', 'partner'), PERMISSION_ERROR_MSG, 'partner', false)) {
                return true;
            }

            if (!isset($_GET['id']) && empty($_GET['id'])) {
                $this->response['error'] = true;
                $this->response['message'] = 'Partner id is required';
                print_r(json_encode($this->response));
                return;
                exit();
            }
            $id = $this->input->get('id', true);
            $deleted = false;
            $delete = array(
                "media" => 0,
                "payment_requests" => 0,
                "products" => 0,
                "product_variants" => 0,
                "product_attributes" => 0,
                "order_items" => 0,
                "orders" => 0,
                "partner_data" => 0,
                "product_tags" => 0,
                "product_rating" => 0,
                "product_add_ons" => 0,
                "partner_timings" => 0,
            );

            $partner_data = fetch_details(['user_id' => $id], 'partner_data', 'id,profile,national_identity_card,address_proof');
            if (!empty($partner_data)) {
                unlink(FCPATH . $partner_data[0]['profile']);
                unlink(FCPATH . $partner_data[0]['national_identity_card']);
                unlink(FCPATH . $partner_data[0]['address_proof']);
            }

            /* set restro restro id zero so admin can have access of media */
            if (update_details(['partner_id' => 0], ['partner_id' => $id], 'media')) {
                $delete['media'] = 1;
                $deleted = TRUE;
            }

            /* delete product and its related all details */
            $pr_ids = fetch_details(['partner_id' => $id], "products", "id");
            if (delete_details(['partner_id' => $id], 'products')) {
                $delete['products'] = 1;

            }
            foreach ($pr_ids as $row) {
                if (delete_details(['product_id' => $row['id']], 'product_attributes')) {
                    $delete['product_attributes'] = 1;
                }
                if (delete_details(['product_id' => $row['id']], 'product_variants')) {
                    $delete['product_variants'] = 1;
                }
                if (is_exist(['product_id' => $row['id']], "product_tags")) {
                    delete_details(['product_id' => $row['id']], 'product_tags');
                    $delete['product_tags'] = 1;
                }
                if (is_exist(['product_id' => $row['id']], "product_rating")) {
                    delete_details(['product_id' => $row['id']], 'product_rating');
                    $delete['product_rating'] = 1;
                }
                if (is_exist(['product_id' => $row['id']], "product_add_ons")) {
                    delete_details(['product_id' => $row['id']], 'product_add_ons');
                    $delete['product_add_ons'] = 1;
                }
                $deleted = TRUE;
            }

            /* check order items */
            $order_items = fetch_details(['partner_id' => $id], 'order_items', 'id,order_id');
            if (is_exist(['partner_id' => $id], "order_items")) {
                delete_details(['partner_id' => $id], 'order_items');
                $delete['order_items'] = 1;
                $deleted = TRUE;
            }

            /** delete orders */
            if (!empty($order_items)) {
                $res_order_id = array_values(array_unique(array_column($order_items, "order_id")));
                delete_details(null, "orders", "id", $res_order_id);
                $deleted = TRUE;
            } else {
                $delete['order_items'] = 1;
                $delete['orders'] = 1;
                $deleted = TRUE;
            }

            /** delete restro details */
            if (delete_details(['user_id' => $id], 'partner_data')) {
                $delete['partner_data'] = 1;
                $deleted = TRUE;
            }
            if (delete_details(['partner_id' => $id], 'partner_timings')) {
                $delete['partner_timings'] = 1;
                $deleted = TRUE;
            }


            if (update_details(['group_id' => '2'], ['user_id' => $id, 'group_id' => 4], 'users_groups') == TRUE && $deleted == TRUE) {
                $this->response['error'] = false;
                $this->response['message'] = 'Partner deleted. Now partner is member or customer of this system.';
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


    public function add_partner()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (isset($_POST['edit_restro'])) {
                if (print_msg(!has_permissions('update', 'partner'), PERMISSION_ERROR_MSG, 'partner')) {
                    return true;
                }
            } else {
                if (print_msg(!has_permissions('create', 'partner'), PERMISSION_ERROR_MSG, 'partner')) {
                    return true;
                }
            }
            // validate owner details

            $this->form_validation->set_rules('name', 'Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('email', 'Mail', 'trim|required|xss_clean');
            $this->form_validation->set_rules('mobile', 'Mobile', 'trim|required|xss_clean|min_length[5]');
            if (!isset($_POST['edit_restro'])) {
                $this->form_validation->set_rules('password', 'Password', 'trim|required|xss_clean');
                $this->form_validation->set_rules('confirm_password', 'Confirm password', 'trim|required|matches[password]|xss_clean|min_length[8]');
            }
            if (!isset($_POST['edit_restro'])) {
                $this->form_validation->set_rules('profile', 'Partner Profile', 'trim|xss_clean');
                $this->form_validation->set_rules('national_identity_card', 'National Identity Card', 'trim|xss_clean');
                $this->form_validation->set_rules('address_proof', 'Address Proof', 'trim|xss_clean');
                $this->form_validation->set_rules('working_time', 'Working Days', 'trim|xss_clean|required');
            }
            $this->form_validation->set_rules('global_commission', 'global_commission', 'trim|required|xss_clean|numeric');
            $this->form_validation->set_rules('cooking_time', 'cooking_time', 'trim|required|xss_clean|numeric');
            $this->form_validation->set_rules('restro_tags[]', 'Restro Tags', 'trim|xss_clean');

            // validate restro details
            $this->form_validation->set_rules('partner_name', 'Partner Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('description', 'Description', 'trim|required|xss_clean');
            $this->form_validation->set_rules('address', 'Address', 'trim|required|xss_clean');
            $this->form_validation->set_rules('latitude', 'Latitude', 'trim|xss_clean|numeric');
            $this->form_validation->set_rules('longitude', 'Longitude', 'trim|xss_clean|numeric');
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

                // process permissions of sellers
                $permmissions = array();
                $permmissions['customer_privacy'] = (isset($_POST['customer_privacy'])) ? 1 : 0;
                $permmissions['view_order_otp'] = (isset($_POST['view_order_otp'])) ? 1 : 0;
                $permmissions['assign_rider'] = (isset($_POST['assign_rider'])) ? 1 : 0;
                $permmissions['is_email_setting_on'] = (isset($_POST['is_email_setting_on'])) ? 1 : 0;

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
                        'permissions' => $permmissions,
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

                        // process tags if any
                        if (isset($_POST['restro_tags']) && !empty($_POST['restro_tags'])) {
                            foreach ($_POST['restro_tags'] as $row) {
                                $tempRow['partner_id'] = $user_id[0]['id'];
                                $tempRow['tag_id'] = $row;
                                $tags[] = $tempRow;
                            }
                        }
                        $data = array(
                            'user_id' => $user_id[0]['id'],
                            'address_proof' => (!empty($proof_doc)) ? $proof_doc : null,
                            'national_identity_card' => (!empty($id_card_doc)) ? $id_card_doc : null,
                            'profile' => (!empty($profile_doc)) ? $profile_doc : null,
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
                            'bank_name' => $this->input->post('bank_name', true),
                            'pan_number' => $this->input->post('pan_number', true),
                            'cooking_time' => $this->input->post('cooking_time', true),
                            'gallery' => (isset($_POST['gallery']) && !empty($_POST['gallery'])) ? $this->input->post('gallery', true) : NULL,
                            'status' => 1,
                            'permissions' => $permmissions,
                            'slug' => create_unique_slug($this->input->post('partner_name', true), 'partner_data')
                        );
                        $insert_id = $this->Partner_model->add_partner($data, [], $work_time, $tags);
                        if (!empty($insert_id)) {
                            $this->response['error'] = false;
                            $this->response['csrfName'] = $this->security->get_csrf_token_name();
                            $this->response['csrfHash'] = $this->security->get_csrf_hash();
                            $this->response['message'] = 'Partner Added Successfully';
                            print_r(json_encode($this->response));
                        } else {
                            $this->response['error'] = true;
                            $this->response['csrfName'] = $this->security->get_csrf_token_name();
                            $this->response['csrfHash'] = $this->security->get_csrf_hash();
                            $this->response['message'] = "Partner data was not added";
                            print_r(json_encode($this->response));
                        }
                    } else {
                        $this->response['error'] = true;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $message = (isset($_POST['edit_restro'])) ? 'Partner not Updated' : 'Partner not Added.';
                        $this->response['message'] = $message;
                        print_r(json_encode($this->response));
                    }
                }
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
