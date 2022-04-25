<?php
defined('BASEPATH') or exit('No direct script access allowed');


class Api extends CI_Controller
{

    /*

---------------------------------------------------------------------------
Defined Methods:-
---------------------------------------------------------------------------

1. login
2. update_fcm
3. reset_password
4. get_login_identity
5. verify_user
6. register_user
7. update_user
8. is_city_deliverable
9. get_slider_images
10. get_offer_images
11. get_categories
12. get_cities
13. get_products
14. validate_promo_code
15. get_partners
16. add_address
17. update_address
18. get_address
19. delete_address
20. get_settings
21. place_order
22. get_orders
23. set_product_rating
24. delete_product_rating
25. get_product_rating
26. manage_cart(Add/Update)
27. get_user_cart
28. add_to_favorites
29. remove_from_favorites
30. get_favorites
31. get_notifications
32. update_order_status
33. add_transaction
34. get_sections
35. transactions
36. delete_order
37. get_ticket_types
38. add_ticket
39. edit_ticket
40. send_message
41. get_tickets
42. get_messages
43. set_rider_rating
44. get_rider_rating
45. delete_rider_rating
46. get_promo_codes
47. remove_from_cart

Payment Method APIs
    48. make_payments
        -get_paypal_link
        -paypal_transaction_webview
        -app_payment_status
        -ipn
    49. stripe_webhook
    50. generate_paytm_checksum
    51. generate_paytm_txn_token
    52. validate_paytm_checksum
    53. validate_refer_code
    54. flutterwave_webview
    55. flutterwave_payment_response

56. get_live_tracking_details

---------------------------------------------------------------------------
---------------------------------------------------------------------------

*/


    public function __construct()
    {
        parent::__construct();
        header("Content-Type: application/json");
        header("Expires: 0");
        header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
        header("Cache-Control: no-store, no-cache, must-revalidate");
        header("Cache-Control: post-check=0, pre-check=0", false);
        header("Pragma: no-cache");

        $this->load->library(['upload', 'jwt', 'ion_auth', 'form_validation', 'paypal_lib']);
        $this->load->model(['category_model', 'order_model', 'rating_model', 'Area_model', 'cart_model', 'address_model', 'transaction_model', 'ticket_model', 'Order_model', 'notification_model', 'faq_model', 'Partner_model', 'Promo_code_model']);
        $this->load->helper(['language', 'string']);
        $this->form_validation->set_error_delimiters($this->config->item('error_start_delimiter', 'ion_auth'), $this->config->item('error_end_delimiter', 'ion_auth'));
        $this->lang->load('auth');
        // date_default_timezone_set('America/New_York');
        $response = $temp = $bulkdata = array();
        $this->identity_column = $this->config->item('identity', 'ion_auth');
        // initialize db tables data
        $this->tables = $this->config->item('tables', 'ion_auth');
    }


    public function index()
    {
        $this->load->helper('file');
        $this->output->set_content_type(get_mime_by_extension(base_url('api-doc.txt')));
        $this->output->set_output(file_get_contents(base_url('api-doc.txt')));
    }

    public function generate_token()
    {
        $payload = [
            'iat' => time(), /* issued at time */
            'iss' => 'erestro',
            'exp' => time() + (30 * 60), /* expires after 1 minute */
            // 'sub' => 'eshop Authentication'
        ];
        $token = $this->jwt->encode($payload, JWT_SECRET_KEY);
        print_r(json_encode($token));
    }

    public function verify_token()
    {
        try {
            $token = $this->jwt->getBearerToken();
        } catch (Exception $e) {
            $response['error'] = true;
            $response['message'] = $e->getMessage();
            print_r(json_encode($response));
            return false;
        }

        if (!empty($token)) {

            $api_keys = fetch_details(['status' => 1], 'client_api_keys');
            if (empty($api_keys)) {
                $response['error'] = true;
                $response['message'] = 'No Client(s) Data Found !';
                print_r(json_encode($response));
                return false;
            }
            JWT::$leeway = 60;
            $flag = true; //For payload indication that it return some data or throws an expection.
            $error = true; //It will indicate that the payload had verified the signature and hash is valid or not.
            foreach ($api_keys as $row) {
                $message = '';
                try {
                    $payload = $this->jwt->decode($token, $row['secret'], ['HS256']);
                    if (isset($payload->iss) && $payload->iss == 'erestro') {
                        $error = false;
                        $flag = false;
                    } else {
                        $error = true;
                        $flag = false;
                        $message = 'Invalid Hash';
                        break;
                    }
                } catch (Exception $e) {
                    $message = $e->getMessage();
                }
            }

            if ($flag) {
                $response['error'] = true;
                $response['message'] = $message;
                print_r(json_encode($response));
                return false;
            } else {
                if ($error == true) {
                    $response['error'] = true;
                    $response['message'] = $message;
                    print_r(json_encode($response));
                    return false;
                } else {
                    return true;
                }
            }
        } else {
            $response['error'] = true;
            $response['message'] = "Unauthorized access not allowed";
            print_r(json_encode($response));
            return false;
        }
    }

    public function login()
    {
        /* Parameters to be passed
            mobile: 9874565478
            
            password: 12345678
            fcm_id: FCM_ID
        */
        if (!$this->verify_token()) {
            return false;
        }
        $identity_column = $this->config->item('identity', 'ion_auth');
        if ($identity_column == 'mobile') {
            $this->form_validation->set_rules('mobile', 'Mobile', 'trim|numeric|required|xss_clean');
        } elseif ($identity_column == 'email') {
            $this->form_validation->set_rules('email', 'Email', 'trim|required|xss_clean|valid_email');
        } else {
            $this->form_validation->set_rules('identity', 'Identity', 'trim|required|xss_clean');
        }
        $this->form_validation->set_rules('password', 'Password', 'trim|required|xss_clean');
        $this->form_validation->set_rules('fcm_id', 'FCM ID', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return false;
        }

        $login = $this->ion_auth->login($this->input->post('mobile'), $this->input->post('password'), false);
        if ($login) {
            if (isset($_POST['fcm_id']) && !empty($_POST['fcm_id'])) {
                update_details(['fcm_id' => $_POST['fcm_id']], ['mobile' => $_POST['mobile']], 'users');
            }
            $data = fetch_details(['mobile' => $this->input->post('mobile', true)], 'users');
            unset($data[0]['password']);


            if (empty($data[0]['image']) || file_exists(FCPATH . USER_IMG_PATH . $data[0]['image']) == FALSE) {
                $data[0]['image'] = base_url() . NO_IMAGE;
            } else {
                $data[0]['image'] = base_url() . USER_IMG_PATH . $data[0]['image'];
            }
            $data = array_map(function ($value) {
                return $value === NULL ? "" : $value;
            }, $data[0]);
            //if the login is successful
            $response['error'] = false;
            $response['message'] = strip_tags($this->ion_auth->messages());
            $response['data'] = $data;
            echo json_encode($response);
            return false;
        } else {
            if (!is_exist(['mobile' => $_POST['mobile']], 'users')) {
                $response['error'] = true;
                $response['message'] = 'User does not exists !';
                echo json_encode($response);
                return false;
            }

            // if the login was un-successful
            // just print json message
            $response['error'] = true;
            $response['message'] = strip_tags($this->ion_auth->errors());
            echo json_encode($response);
            return false;
        }
    }

    public function update_fcm()
    {
        /* Parameters to be passed
            user_id:12
            fcm_id: FCM_ID
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('fcm_id', 'Fcm Id', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return false;
        }

        if (isset($_POST['fcm_id']) && $_POST['fcm_id'] != NULL && !empty($_POST['fcm_id'])) {
            $user_res = update_details(['fcm_id' => $_POST['fcm_id']], ['id' => $_POST['user_id']], 'users');
            if ($user_res) {
                $response['error'] = false;
                $response['message'] = 'Updated Successfully';
                $response['data'] = array();
                echo json_encode($response);
                return false;
            } else {
                $response['error'] = true;
                $response['message'] = 'Updation Failed !';
                $response['data'] = array();
                echo json_encode($response);
                return false;
            }
        }
    }

    public function reset_password()
    {
        /* Parameters to be passed
            mobile_no:7894561235            
            new: pass@123
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('mobile_no', 'Mobile No', 'trim|numeric|required|xss_clean|max_length[16]');
        $this->form_validation->set_rules('new', 'New Password', 'trim|required|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return false;
        }

        $identity_column = $this->config->item('identity', 'ion_auth');
        $res = fetch_details(['mobile' => $this->input->post("mobile_no", true)], 'users', "mobile,id");
        if (!empty($res)) {
            if ($this->ion_auth->in_group('members', $res[0]['id'])) {
                $identity = ($identity_column  == 'email') ? $res[0]['email'] : $res[0]['mobile'];
                if (!$this->ion_auth->reset_password($identity, $this->input->post("new", true))) {
                    $response['error'] = true;
                    $response['message'] = strip_tags($this->ion_auth->messages());
                    $response['data'] = array();
                    echo json_encode($response);
                    return false;
                } else {
                    $response['error'] = false;
                    $response['message'] = 'Reset Password Successfully';
                    $response['data'] = array();
                    echo json_encode($response);
                    return false;
                }
            } else {
                $response['error'] = true;
                $response['message'] = 'You can not reset password of higher authority!';
                $response['data'] = array();
                echo json_encode($response);
                return false;
            }
        } else {
            $response['error'] = true;
            $response['message'] = 'User does not exists !';
            $response['data'] = array();
            echo json_encode($response);
            return false;
        }
    }

    public function get_login_identity()
    {
        if (!$this->verify_token()) {
            return false;
        }
        $response['error'] = false;
        $response['message'] = 'Data Retrieved Successfully';
        $response['data'] = array('identity' => $this->config->item('identity', 'ion_auth'));
        echo json_encode($response);
        return false;
    }

    public function verify_user()
    {
        /* Parameters to be passed
            mobile: 9874565478
            email: test@gmail.com 
        */
        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('mobile', 'Mobile', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('email', 'Email', 'trim|xss_clean|valid_email');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            if (isset($_POST['mobile']) && is_exist(['mobile' => $_POST['mobile']], 'users')) {
                $this->response['error'] = true;
                $this->response['message'] = 'Mobile is already registered.Please login again !';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            if (isset($_POST['email']) && is_exist(['email' => $_POST['email']], 'users')) {
                $this->response['error'] = true;
                $this->response['message'] = 'Email is already registered.Please login again !';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }

            $this->response['error'] = false;
            $this->response['message'] = 'Ready to sent OTP request!';
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        }
    }

    public function register_user()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('name', 'Name', 'trim|required|xss_clean');
        $this->form_validation->set_rules('email', 'Mail', 'trim|required|xss_clean|valid_email|is_unique[users.email]', array('is_unique' => ' The email is already registered . Please login'));
        $this->form_validation->set_rules('mobile', 'Mobile', 'trim|required|xss_clean|max_length[16]|numeric|is_unique[users.mobile]', array('is_unique' => ' The mobile number is already registered . Please login'));
        $this->form_validation->set_rules('country_code', 'Country Code', 'trim|required|xss_clean');
        $this->form_validation->set_rules('fcm_id', 'Fcm Id', 'trim|xss_clean');
        $this->form_validation->set_rules('referral_code', 'Referral code', 'trim|is_unique[users.referral_code]|xss_clean');
        $this->form_validation->set_rules('friends_code', 'Friends code', 'trim|xss_clean');
        $this->form_validation->set_rules('latitude', 'Latitude', 'trim|xss_clean');
        $this->form_validation->set_rules('longitude', 'Longitude', 'trim|xss_clean');
        $this->form_validation->set_rules('password', 'Password', 'trim|required|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            if (isset($_POST['friends_code']) && !empty($_POST['friends_code'])) {
                $friends_code = $_POST['friends_code'];
                $friend = fetch_details(['referral_code' => $friends_code], 'users', '*');
                if (empty($friend)) {
                    $response["error"]   = true;
                    $response["message"] = "Invalid friends code! Please pass the valid referral code of the inviter";
                    $response["data"] = [];
                    echo json_encode($response);
                    return false;
                }
            }

            $identity_column = $this->config->item('identity', 'ion_auth');

            $email = strtolower($this->input->post('email'));
            $mobile = $this->input->post('mobile');
            $identity = ($identity_column == 'mobile') ? $mobile : $email;
            $password = $this->input->post('password');

            $additional_data = [
                'username' => $this->input->post('name'),
                'mobile' => $this->input->post('mobile'),
                'country_code' => $this->input->post('country_code'),
                'fcm_id' => $this->input->post('fcm_id'),
                'referral_code' => $this->input->post('referral_code', true),
                'friends_code' => $this->input->post('friends_code', true),
                'latitude' => $this->input->post('latitude'),
                'longitude' => $this->input->post('longitude'),
                'active' => 1
            ];

            $res = $this->ion_auth->register($identity, $password, $email, $additional_data, ['2']);

            update_details(['active' => 1], [$identity_column => $identity], 'users');

            $data = fetch_details([$identity_column => $identity], 'users');
            unset($data[0]['password']);

            $data = array_map(function ($value) {
                return $value === NULL ? "" : $value;
            }, $data[0]);

            $this->response['error'] = false;
            $this->response['message'] = 'Registered Successfully';
            $this->response['data'] = $data;
        }
        print_r(json_encode($this->response));
    }

    public function update_user()
    {
        /*
            user_id:34
            username:hiten                 {optional}
            mobile:7852347890              {optional}
            email:amangoswami@gmail.com	   {optional}
            image:[]                       {optional}
            referral_code:Userscode        {optional}
            old:12345                      {optional but if one param set then "new" will be mandatory}
            new:345234
        */
        if (!$this->verify_token()) {
            return false;
        }
        if (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0 && $_POST['user_id'] == "1") {
            $this->response['error'] = true;
            $this->response['message'] = DEMO_VERSION_MSG;
            echo json_encode($this->response);
            return false;
            exit();
        }

        $identity_column = $this->config->item('identity', 'ion_auth');

        $this->form_validation->set_rules('user_id', 'Id', 'required|xss_clean|numeric|trim');
        $this->form_validation->set_rules('email', 'Email', 'xss_clean|trim|valid_email|edit_unique[users.id.' . $this->input->post('user_id', true) . ']');
        $this->form_validation->set_rules('username', 'Username', 'xss_clean|trim');
        $this->form_validation->set_rules('referral_code', 'Referral code', 'trim|xss_clean');
        $this->form_validation->set_rules('image', 'Profile Image', 'trim|xss_clean');

        if (!empty($_POST['old']) || !empty($_POST['new'])) {
            $this->form_validation->set_rules('old', $this->lang->line('change_password_validation_old_password_label'), 'required');
            $this->form_validation->set_rules('new', $this->lang->line('change_password_validation_new_password_label'), 'required|min_length[6]');
        }

        $tables = $this->config->item('tables', 'ion_auth');
        if (!$this->form_validation->run()) {
            if (validation_errors()) {
                $response['error'] = true;
                $response['message'] = validation_errors();
                echo json_encode($response);
                return false;
                exit();
            }
        } else {
            if (!empty($_POST['old']) || !empty($_POST['new'])) {
                $identity = ($identity_column == 'mobile') ? 'mobile' : 'email';
                $res = fetch_details(['id' => $_POST['user_id']], 'users', $identity);
                if (!empty($res)) {
                    if (!$this->ion_auth->change_password($res[0][$identity], $this->input->post('old'), $this->input->post('new'))) {

                        // if the login was un-successful
                        $response['error'] = true;
                        $response['message'] = strip_tags($this->ion_auth->errors());
                        echo json_encode($response);
                        return;
                    } else {
                        $user_details = fetch_details(['id' => $_POST['user_id']], 'users', "*");

                        if (empty($user_details[0]['image']) || file_exists(FCPATH . USER_IMG_PATH . $user_details[0]['image']) == FALSE) {
                            $user_details[0]['image'] = base_url() . NO_IMAGE;
                        } else {
                            $user_details[0]['image'] = base_url() . USER_IMG_PATH . $user_details[0]['image'];
                        }
                        $user_details[0]['image_sm'] = get_image_url(base_url() . USER_IMG_PATH . $user_details[0]['image'], 'thumb', 'sm');
                        $user_details = array_map(function ($value) {
                            return $value === NULL ? "" : $value;
                        }, $user_details[0]);

                        $response['error'] = false;
                        $response['message'] = 'Password Update Succesfully';
                        $response['data'] = $user_details;
                        echo json_encode($response);
                        return;
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = 'User not exists';
                    echo json_encode($response);
                    return;
                }
            }

            $is_updated = false;
            /* update referral_code if it is empty in user's database */
            if (isset($_POST['referral_code']) && !empty($_POST['referral_code'])) {
                $user = fetch_details(['id' => $_POST['user_id']], 'users', "referral_code");
                if (empty($user[0]['referral_code'])) {
                    update_details(['referral_code' => $_POST['referral_code']], ['id' => $_POST['user_id']], "users");
                    $is_updated = true;
                }
            }

            if (!file_exists(FCPATH . USER_IMG_PATH)) {
                mkdir(FCPATH . USER_IMG_PATH);
            }

            $config = [
                'upload_path' =>  FCPATH . USER_IMG_PATH,
                'allowed_types' => 'jpeg|gif|jpg|png',
            ];

            $image_new_name = '';
            $image_info_error = '';

            if (!empty($_FILES['image']['name']) && isset($_FILES['image']['name'])) {
                $this->upload->initialize($config);
                if ($this->upload->do_upload('image')) {
                    $image_data = $this->upload->data();
                    $image_new_name = $image_data['file_name'];
                    resize_image($image_data, FCPATH . USER_IMG_PATH);
                } else {
                    $image_info_error = 'Profile Image :' . $this->upload->display_errors();
                }

                if ($image_info_error != NULL || !$this->form_validation->run()) {
                    if (isset($image_new_name) && $image_new_name != NULL) {
                        unlink(FCPATH . USER_IMG_PATH . $image_new_name);
                    }
                }
            }

            if (isset($image_info_error) && !empty($image_info_error)) {
                $response['error'] = true;
                $response['message'] = $image_info_error;
                echo json_encode($response);
                return;
            }

            $set = [];
            if (isset($_POST['username']) && !empty($_POST['username'])) {
                $set['username'] = $this->input->post('username', true);
            }
            if (isset($_POST['email']) && !empty($_POST['email'])) {
                $set['email'] = $this->input->post('email', true);
            }
            if (isset($_POST['mobile']) && !empty($_POST['mobile'])) {
                $set['mobile'] = $this->input->post('mobile', true);
            }

            if (!empty($_FILES['image']['name']) && isset($_FILES['image']['name'])) {
                $set['image'] = $image_new_name;
            }

            if (!empty($set)) {
                $set = escape_array($set);
                $this->db->set($set)->where('id', $_POST['user_id'])->update($tables['login_users']);
                $user_details = fetch_details(['id' => $_POST['user_id']], 'users', "*");
                if (empty($user_details[0]['image']) || file_exists(FCPATH . USER_IMG_PATH . $user_details[0]['image']) == FALSE) {
                    $user_details[0]['image'] = base_url() . NO_IMAGE;
                } else {
                    $user_details[0]['image'] = base_url() . USER_IMG_PATH . $user_details[0]['image'];
                }

                $user_details[0]['image_sm'] = get_image_url(base_url() . USER_IMG_PATH . $user_details[0]['image'], 'thumb', 'sm');
                $user_details = array_map(function ($value) {
                    return $value === NULL ? "" : $value;
                }, $user_details[0]);
                $response['error'] = false;
                $response['message'] = 'Profile Update Succesfully';
                $response['data'] = $user_details;
                echo json_encode($response);
                return;
            } else if ($is_updated == true) {
                $user_details = fetch_details(['id' => $_POST['user_id']], 'users', "*");
                if (empty($user_details[0]['image']) || file_exists(FCPATH . USER_IMG_PATH . $user_details[0]['image']) == FALSE) {
                    $user_details[0]['image'] = base_url() . NO_IMAGE;
                } else {
                    $user_details[0]['image'] = base_url() . USER_IMG_PATH . $user_details[0]['image'];
                }

                $user_details[0]['image_sm'] = get_image_url(base_url() . USER_IMG_PATH . $user_details[0]['image'], 'thumb', 'sm');
                $user_details = array_map(function ($value) {
                    return $value === NULL ? "" : $value;
                }, $user_details[0]);
                $response['error'] = false;
                $response['message'] = 'Referel Code Update Succesfully';
                $response['data'] = $user_details;
                echo json_encode($response);
                return;
            }
        }
    }

    // is_city_deliverable
    public function is_city_deliverable()
    {
        /*
        32. is_city_deliverable
            id:1    // {optional} 
            name:bhuj  // {optional}
        */
        $this->form_validation->set_rules('id', 'Id', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('name', 'Name', 'trim|xss_clean');

        if (!$this->verify_token()) {
            return false;
        }

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = validation_errors();
            $this->response['data'] = array();
            echo json_encode($this->response);
            return false;
        } else {
            if (isset($_POST['id']) && !empty($_POST['id'])) {
                $type = "id";
                $value = $this->input->post('id', true);
            }
            if (isset($_POST['name']) && !empty($_POST['name'])) {
                $type = "name";
                $value = $this->input->post('name', true);
            }

            if (!is_exist([$type => $value], 'cities')) {
                $this->response['error'] = true;
                $this->response['message'] = "We doesn't delviery the foods at selected city!";
                $this->response['data'] = array();
                echo json_encode($this->response);
                return false;
            } else {
                $city = fetch_details([$type => $value], "cities", "id");
                $this->response['error'] = false;
                $this->response['message'] = 'City is delivarable.';
                $this->response['city_id'] = $city[0]['id'];
                $this->response['data'] = array();
                echo json_encode($this->response);
                return false;
            }
        }
    }

    public function get_slider_images()
    {
        if (!$this->verify_token()) {
            return false;
        }
        $res = fetch_details('', 'sliders');
        $i = 0;
        foreach ($res as $row) {
            $res[$i]['image'] = base_url($res[$i]['image']);

            if (strtolower($res[$i]['type']) == 'categories') {
                $id = (!empty($res[$i]['type_id']) && isset($res[$i]['type_id'])) ? $res[$i]['type_id'] : '';
                $cat_res = $this->category_model->get_categories($id);
                $res[$i]['data']  =  $cat_res;
            } else if (strtolower($res[$i]['type']) == 'products') {
                $id = (!empty($res[$i]['type_id']) && isset($res[$i]['type_id'])) ? $res[$i]['type_id'] : '';
                $pro_res = fetch_product(NULL, NULL, $id);
                $res[$i]['data']  =  $pro_res['product'];
            } else {
                $res[$i]['data']  =  [];
            }

            $i++;
        }
        $this->response['error'] = false;
        $this->response['data'] = $res;
        print_r(json_encode($this->response));
    }

    public function get_offer_images()
    {
        if (!$this->verify_token()) {
            return false;
        }
        $res = fetch_details('', 'offers');
        $i = 0;
        foreach ($res as $row) {
            $res[$i]['image'] = base_url($res[$i]['image']);

            if (strtolower($res[$i]['type']) == 'categories') {
                $id = (!empty($res[$i]['type_id']) && isset($res[$i]['type_id'])) ? $res[$i]['type_id'] : '';
                $cat_res = $this->category_model->get_categories($id);
                $res[$i]['data']  =  $cat_res;
            } else if (strtolower($res[$i]['type']) == 'products') {
                $id = (!empty($res[$i]['type_id']) && isset($res[$i]['type_id'])) ? $res[$i]['type_id'] : '';
                $pro_res = fetch_product(NULL, NULL, $id);
                $res[$i]['data']  =  $pro_res['product'];
            } else {
                $res[$i]['data']  =  [];
            }

            $i++;
        }
        $this->response['error'] = false;
        $this->response['data'] = $res;
        print_r(json_encode($this->response));
    }

    public function get_categories()
    {
        /*
            id:15               // optional
            limit:25            // { default - 25 } optional
            offset:0            // { default - 0 } optional
            sort:               id / name
                                // { default -row_id } optional
            order:DESC/ASC      // { default - ASC } optional
            search:value        // { optional }
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('id', 'Category Id', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        $this->form_validation->set_rules('search', 'search', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        }
        $limit = (isset($_POST['limit'])  && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
        $offset = (isset($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
        $sort = (isset($_POST['sort(array)']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'row_order';
        $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'ASC';
        $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : null;

        $this->response['message'] = "Cateogry(s) retrieved successfully!";
        $id = (!empty($_POST['id']) && isset($_POST['id'])) ? $_POST['id'] : '';
        $cat_res = $this->category_model->get_categories($id, $limit, $offset, $sort, $order, "false", "", "", $search);
        $popular_categories = $this->category_model->get_categories(NULL, "", "", 'clicks', 'DESC', 'false', "", "", "");

        $this->response['error'] = (empty($cat_res)) ? true : false;
        $this->response['total'] = !empty($cat_res) ? $cat_res[0]['total'] : 0;
        $this->response['message'] = (empty($cat_res)) ? 'Category does not exist' : 'Category retrieved successfully';
        $this->response['data'] = $cat_res;
        $this->response['popular_categories'] = $popular_categories;

        print_r(json_encode($this->response));
    }

    //3.get_cities
    public function get_cities()
    {
        /*
           sort:               // { c.name / c.id } optional
           order:DESC/ASC      // { default - ASC } optional
           search:value        // {optional} 
           limit:10            // {pass default limit for city list}{default : 25}
           offset:0            // {optional default :0}
       */
        $this->form_validation->set_rules('sort', 'sort', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        $this->form_validation->set_rules('search', 'search', 'trim|xss_clean');

        if (!$this->verify_token()) {
            return false;
        }
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'c.name';
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'ASC';
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : "";
            $limit = (isset($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;

            $result = $this->Area_model->get_cities($sort, $order, $search,$limit,$offset);
            print_r(json_encode($result));
        }
    }

    /* 4.get_products

        id:101              // optional
        category_id:29      // optional
        user_id:15          // optional
        search:keyword      // optional   // search by product name and highlights
        tags:multiword tag1, tag2, another tag      // optional {search by restro and product tags}
        highlights:multiword tag1, tag2, another tag      // optional
        attribute_value_ids : 34,23,12 // { Use only for filteration } optional
        limit:25            // { default - 25 } optional
        offset:0            // { default - 0 } optional
        sort:p.id / p.date_added / pv.price
                            { default - p.id } optional
        order:DESC/ASC      // { default - DESC } optional
        top_rated_foods: 1 // { default - 0 } optional
        discount: 5             // optional
        min_price:10000          // optional
        max_price:50000          // optional
        partner_id:1255           //{optional}
        product_ids: 19,20             // optional
        product_variant_ids: 44,45,40             // optional
        vegetarian:1|2|3             //{optional -> 1 - veg | 2 - non-veg | 3 - Both}
        filter_by:p.id|sd.user_id       // {p.id = product list | sd.user_id = partner list}            
                             { default - sd.user_id } optional      
        latitude:123                 // {optional}
        longitude:123                // {optional}
    */

    public function get_products()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('id', 'Product ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('vegetarian', 'vegetarian', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('search', 'Search', 'trim|xss_clean');
        $this->form_validation->set_rules('category_id', 'Category id', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('partner_id', 'partner id', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('attribute_value_ids', 'Attr Ids', 'trim|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean|alpha');
        $this->form_validation->set_rules('top_rated_foods', ' Top Rated Foods ', 'trim|xss_clean|numeric');
        $this->form_validation->set_rules('min_price', ' Min Price ', 'trim|xss_clean|numeric|less_than_equal_to[' . $this->input->post('max_price') . ']');
        $this->form_validation->set_rules('max_price', ' Max Price ', 'trim|xss_clean|numeric|greater_than_equal_to[' . $this->input->post('min_price') . ']');
        $this->form_validation->set_rules('discount', ' Discount ', 'trim|xss_clean|numeric');
        $this->form_validation->set_rules('filter_by', ' filter_by ', 'trim|xss_clean');
        $this->form_validation->set_rules('latitude', 'latitude', 'trim|xss_clean');
        $this->form_validation->set_rules('longitude', 'longitude', 'trim|xss_clean');
        $this->form_validation->set_rules('city_id', 'city_id', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            if (isset($_POST['latitude']) && !empty($_POST['latitude']) && empty($_POST['longitude'])) {
                $this->response['error'] = true;
                $this->response['message'] = "The Longitude Field is Required";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            if (isset($_POST['longitude']) && !empty($_POST['longitude']) && empty($_POST['latitude'])) {
                $this->response['error'] = true;
                $this->response['message'] = "The Latitude Field is Required";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            $filters['longitude'] = (isset($_POST['longitude']) && !empty($_POST['longitude'])) ? $this->input->post("longitude", true) : 0;
            $filters['latitude'] = (isset($_POST['latitude']) && !empty($_POST['latitude'])) ? $this->input->post("latitude", true) : 0;
            $filters['city_id'] = (isset($_POST['city_id']) && !empty($_POST['city_id'])) ? $this->input->post("city_id", true) : 0;
            $limit = (isset($_POST['limit'])) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset'])) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $_POST['order'] : 'ASC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $_POST['sort'] : 'p.row_order';
            $partner_id = (isset($_POST['partner_id']) && !empty(trim($_POST['partner_id']))) ?  $this->input->post('partner_id', true) : NULL;
            $filters['search'] =  (isset($_POST['search'])) ? $_POST['search'] : null;
            $filters['tags'] =  (isset($_POST['tags'])) ? $_POST['tags'] : "";
            $filters['highlights'] =  (isset($_POST['highlights'])) ? $_POST['highlights'] : "";
            $filters['attribute_value_ids'] = (isset($_POST['attribute_value_ids'])) ? $_POST['attribute_value_ids'] : null;
            $filters['is_similar_products'] = (isset($_POST['is_similar_products'])) ? $_POST['is_similar_products'] : null;
            $filters['vegetarian'] = (isset($_POST['vegetarian'])) ? $this->input->post("vegetarian", true) : null;
            $filters['discount'] = (isset($_POST['discount'])) ? $_POST['discount'] : 0;
            $filters['product_type'] = (isset($_POST['top_rated_foods']) && $_POST['top_rated_foods'] == 1) ? 'top_rated_foods_including_all_foods' : null;
            $filters['min_price'] = (isset($_POST['min_price']) && !empty($_POST['min_price'])) ? $this->input->post("min_price", true) : 0;
            $filters['max_price'] = (isset($_POST['max_price']) && !empty($_POST['max_price'])) ? $this->input->post("max_price", true) : 0;
            $filter_by = (isset($_POST['filter_by']) && !empty($_POST['filter_by'])) ? $this->input->post("filter_by", true) : 'sd.user_id';

            $category_id = (isset($_POST['category_id'])) ? $_POST['category_id'] : null;
            $product_id = (isset($_POST['id'])) ? $_POST['id'] : null;
            $product_ids = (isset($_POST['product_ids'])) ? $_POST['product_ids'] : null;
            $product_variant_ids = (isset($_POST['product_variant_ids']) && !empty($_POST['product_variant_ids'])) ? $this->input->post("product_variant_ids", true) : null;
            if ($product_ids != null) {
                $product_id = explode(",", $product_ids);
            }
            if ($product_variant_ids != null) {
                $filters['product_variant_ids'] = explode(",", $product_variant_ids);
            }
            $user_id = (isset($_POST['user_id'])) ? $_POST['user_id'] : null;

            $products = fetch_product($user_id, (isset($filters)) ? $filters : null, $product_id, $category_id, $limit, $offset, $sort, $order, null, null, $partner_id, $filter_by);

            $final_total = "0";
            if (isset($filters['discount']) && !empty($filters['discount'])) {
                $final_total = (isset($products['product'][0]['total']) && !empty($products['product'][0]['total'])) ? $products['product'][0]['total'] : "";
            } else {
                $final_total = (isset($products['total'])) ? strval($products['total']) : '';
            }

            if (!empty($products['product'])) {
                $this->response['error'] = false;
                $this->response['message'] = "Products retrieved successfully !";
                $this->response['min_price'] = (isset($products['min_price']) && !empty($products['min_price'])) ? strval($products['min_price']) : 0;
                $this->response['max_price'] = (isset($products['max_price']) && !empty($products['max_price'])) ? strval($products['max_price']) : 0;
                $this->response['search'] = (isset($_POST['search'])) ? $this->input->post("search", true) : "";
                $this->response['filters'] = (isset($products['filters']) && !empty($products['filters'])) ? $products['filters'] : [];
                $this->response['categories'] = (isset($products['categories']) && !empty($products['categories'])) ? $products['categories'] : [];
                $this->response['product_tags'] = (isset($products['product_tags']) && !empty($products['product_tags'])) ? $products['product_tags'] : [];
                $this->response['partner_tags'] = (isset($products['partner_tags']) && !empty($products['partner_tags'])) ? $products['partner_tags'] : [];
                $this->response['total'] = $final_total;
                $this->response['offset'] = (isset($_POST['offset']) && !empty($_POST['offset'])) ? $this->input->post("offset", true) : '0';
                $this->response['data'] = $products['product'];
            } else {
                $this->response['error'] = true;
                $this->response['message'] = "Products Not Found !";
                $this->response['data'] = array();
            }
        }
        print_r(json_encode($this->response));
    }

    //7.validate_promo_code
    public function validate_promo_code()
    {
        /*
            promo_code:'NEWOFF10'
            user_id:28
            final_total:'300'

        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('promo_code', 'Promo Code', 'trim|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User Id', 'trim|required|xss_clean');
        $this->form_validation->set_rules('final_total', 'Final Total', 'trim|required|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            print_r(json_encode(validate_promo_code($_POST['promo_code'], $_POST['user_id'], $_POST['final_total'])));
        }
    }

    public function get_partners()
    {
        /*
            id:1      //{optional}
            city_id:1  //{optional}
            user_id:1  //{optional}
            limit:25            // { default - 25 } optional
            offset:0            // { default - 0 } optional
            sort:p.id / p.date_added / pv.price
                                { default - p.id } optional
            order:DESC/ASC      // { default - DESC } optional
            top_rated_partner: 1 // { default - 0 } optional
            only_opened_partners: 1 // { default - 0 } optional
            vegetarian:1|2|3             //{optional -> 1 - veg | 2 - non-veg | 3 - both}
            latitude:123                 // {optional}
            longitude:123                // {optional}
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('city_id', 'City ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('id', 'ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('vegetarian', 'Vegetarian', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('latitude', 'latitude', 'trim|xss_clean');
        $this->form_validation->set_rules('longitude', 'longitude', 'trim|xss_clean');
        $this->form_validation->set_rules('top_rated_partner', 'top_rated_partner', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('only_opened_partners', 'only_opened_partners', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('search', 'search', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            if (isset($_POST['latitude']) && !empty($_POST['latitude']) && empty($_POST['longitude'])) {
                $this->response['error'] = true;
                $this->response['message'] = "The Longitude Field is Required";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            if (isset($_POST['longitude']) && !empty($_POST['longitude']) && empty($_POST['latitude'])) {
                $this->response['error'] = true;
                $this->response['message'] = "The Latitude Field is Required";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }

            $filters['city_id'] = (isset($_POST['city_id']) && !empty($_POST['city_id'])) ? $this->input->post("city_id", true) : "";
            $filters['longitude'] = (isset($_POST['longitude']) && !empty($_POST['longitude'])) ? $this->input->post("longitude", true) : 0;
            $filters['latitude'] = (isset($_POST['latitude']) && !empty($_POST['latitude'])) ? $this->input->post("latitude", true) : 0;
            $filters['id'] = (isset($_POST['id']) && !empty($_POST['id'])) ? $this->input->post("id", true) : "";
            $filters['vegetarian'] = (isset($_POST['vegetarian']) && !empty($_POST['vegetarian'])) ? $this->input->post("vegetarian", true) : "";
            $filters['top_rated_partner'] = (isset($_POST['top_rated_partner']) && !empty($_POST['top_rated_partner'])) ? $this->input->post("top_rated_partner", true) : 0;
            $filters['only_opened_partners'] = (isset($_POST['only_opened_partners']) && !empty($_POST['only_opened_partners'])) ? $this->input->post("only_opened_partners", true) : 0;
            $limit = (isset($_POST['limit'])) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset'])) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'u.id';
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : '';
            $user_id = (isset($_POST['user_id']) && !empty(trim($_POST['user_id']))) ? $this->input->post('user_id', true) : null;

            if (isset($filters['city_id']) && !empty($filters['city_id'])) {
                if (!is_exist(['id' => $filters['city_id']], 'cities')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'City Not Deliverable!';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }
            if (isset($filters['id']) && !empty($filters['id'])) {
                if (!is_exist(['user_id' => $filters['id'], 'status' => 1], 'partner_data')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'Partner Not Found or Deactivated!';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }

            $data = fetch_partners((isset($filters)) ? $filters : null, $user_id, $limit, $offset, $sort, $order, $search);
            if (!empty($data['data'])) {
                for ($i = 0; $i < count($data['data']); $i++) {
                    $working_time = fetch_details(["partner_id" => $data['data'][$i]['partner_id']], "partner_timings");
                    $data['data'][$i]['partner_working_time'] = $working_time;
                }
            }
            print_r(json_encode($data));
        }
    }

    //13. add_address
    public function add_address()
    {

        /* 
            user_id:1
            mobile:9727800638
            address:#123,Time Square Empire,bhuj 
            city_id:1
            latitude:1234
            longitude:1234
            area:umiya nagar
            type:Home | Office | Others      {optional}
            name:John Smith              {optional}
            country_code:+91             {optional}
            alternate_mobile:9876543210  {optional}
            landmark:prince hotel        {optional}
            pincode:370001               {optional}
            state:Gujarat                {optional}
            country:India                {optional}
            is_default:1                 {optional}{default - 0}
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('name', 'Name', 'trim|xss_clean');
        $this->form_validation->set_rules('type', 'Type', 'trim|xss_clean');
        $this->form_validation->set_rules('mobile', 'Mobile', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('alternate_mobile', 'Alternative Mobile', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('address', 'Address', 'trim|required|xss_clean');
        $this->form_validation->set_rules('landmark', 'Landmark', 'trim|xss_clean');
        $this->form_validation->set_rules('area', 'Area', 'trim|required|xss_clean');
        $this->form_validation->set_rules('city', 'City', 'trim|required|xss_clean');
        $this->form_validation->set_rules('pincode', 'Pincode', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('country_code', 'Country Code', 'trim|xss_clean');
        $this->form_validation->set_rules('state', 'State', 'trim|xss_clean');
        $this->form_validation->set_rules('country', 'Country', 'trim|xss_clean');
        $this->form_validation->set_rules('latitude', 'Latitude', 'trim|required|xss_clean');
        $this->form_validation->set_rules('longitude', 'Longitude', 'trim|required|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $city = (isset($_POST['city']) && !empty($_POST['city'])) ? $this->input->post("city", true) : "";
            $user_id = (isset($_POST['user_id']) && !empty($_POST['user_id'])) ? $this->input->post("user_id", true) : "";
            if (isset($user_id) && !empty($user_id)) {
                if (!is_exist(['id' => $user_id], 'users')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'User Not Found!';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }
            if (isset($city) && !empty($city)) {
                if (!is_exist(['name' => $city], 'cities')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'City Not Found or We are not delivering in this city !';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }
            $city_id = fetch_details(['name' => $city], "cities", "id");
            $_POST['city_id'] = $city_id[0]['id'];
            $this->address_model->set_address($_POST);
            $res = $this->address_model->get_address($user_id, false, true);
            $this->response['error'] = false;
            $this->response['message'] = 'Address Added Successfully';
            $this->response['data'] = $res;
        }
        print_r(json_encode($this->response));
    }

    //update_address
    public function update_address()
    {
        /*
            id:1
            user_id:1                    {optional}
            mobile:9727800638            {optional}
            address:#123,Time Square,bhuj    {optional} 
            city:1                    {optional}
            type:Home | Office | Others      {optional}
            name:John Smith              {optional}
            country_code:+91             {optional}
            alternate_mobile:9876543210  {optional}
            landmark:prince hotel        {optional}
            area:umiya nagar             {optional}
            pincode:370001               {optional}
            state:Gujarat                {optional}
            country:India                {optional}
            latitude:1234                {optional}
            longitude:1234               {optional}
            is_default:1                 {optional}{default - 0}
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('id', 'Id', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('type', 'Type', 'trim|xss_clean');
        $this->form_validation->set_rules('country_code', 'Country Code', 'trim|xss_clean');
        $this->form_validation->set_rules('name', 'Name', 'trim|xss_clean');
        $this->form_validation->set_rules('mobile', 'Mobile', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('alternate_mobile', 'Alternative Mobile', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('address', 'Address', 'trim|xss_clean');
        $this->form_validation->set_rules('landmark', 'Landmark', 'trim|xss_clean');
        $this->form_validation->set_rules('area_id', 'Area', 'trim|xss_clean');
        $this->form_validation->set_rules('latitude', 'Latitude', 'trim|xss_clean');
        $this->form_validation->set_rules('longitude', 'Longitude', 'trim|xss_clean');
        $this->form_validation->set_rules('city', 'City', 'trim|xss_clean');
        $this->form_validation->set_rules('pincode', 'Pincode', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('state', 'State', 'trim|xss_clean');
        $this->form_validation->set_rules('country', 'Country', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $id = (isset($_POST['id']) && !empty($_POST['id'])) ? $this->input->post("id", true) : "";
            $city = (isset($_POST['city']) && !empty($_POST['city'])) ? $this->input->post("city", true) : "";

            if (isset($id) && !empty($id)) {
                if (!is_exist(['id' => $id], 'addresses')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'Address Not Found!';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }

            if (isset($city) && !empty($city)) {
                if (!is_exist(['name' => $city], 'cities')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'City Not Found or We are not delivering in this city !';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }
            $city_id = fetch_details(['name' => $city], "cities", "id");
            $_POST['city_id'] = $city_id[0]['id'];
            $this->address_model->set_address($_POST);
            $res = $this->address_model->get_address(null, $_POST['id'], true);
            $this->response['error'] = false;
            $this->response['message'] = 'Address updated Successfully';
            $this->response['data'] = $res;
        }
        print_r(json_encode($this->response));
    }

    //get_address
    public function get_address()
    {
        /*
            user_id:3    
            address_id:bhuj         {optional}  {if want to get only one address by id}
            partner_id:1234     {optional}  {for delivery check}
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User id', 'trim|numeric|xss_clean|required');
        $this->form_validation->set_rules('address_id', 'Address Id', 'trim|xss_clean|numeric');
        $this->form_validation->set_rules('partner_id', 'partner Id', 'trim|xss_clean|numeric');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_id = (isset($_POST['user_id']) && !empty($_POST['user_id'])) ? $this->input->post("user_id", true) : "";
            $address_id = (isset($_POST['address_id']) && !empty($_POST['address_id'])) ? $this->input->post("address_id", true) : "";
            $partner_id = (isset($_POST['partner_id']) && !empty($_POST['partner_id'])) ? $this->input->post("partner_id", true) : "";

            if (isset($user_id) && !empty($user_id)) {
                if (!is_exist(['id' => $user_id], 'users')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'User Not Found!';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }

            $res = $this->address_model->get_address($user_id, $address_id, false, false, $partner_id);
            $is_default_counter = array_count_values(array_column($res, 'is_default'));

            if (!isset($is_default_counter['1']) && !empty($res)) {
                update_details(['is_default' => '1'], ['id' => $res[0]['id']], 'addresses');
                $res = $this->address_model->get_address($user_id, $address_id, false, false, $partner_id);
            }
            if (!empty($res)) {
                $this->response['error'] = false;
                $this->response['message'] = 'Address Retrieved Successfully';
                $this->response['data'] = $res;
            } else {
                $this->response['error'] = true;
                $this->response['message'] = "No Details Found!";
                $this->response['data'] = array();
            }
        }
        print_r(json_encode($this->response));
    }

    //delete_address
    public function delete_address()
    {
        /*
            id:3
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('id', 'Id', 'trim|required|numeric|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $id = (isset($_POST['id']) && !empty($_POST['id'])) ? $this->input->post("id", true) : "";
            if (isset($id) && !empty($id)) {
                if (!is_exist(['id' => $id], 'addresses')) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'Address Not Found!';
                    $this->response['data'] =  array();
                    echo json_encode($this->response);
                    return false;
                }
            }
            $this->address_model->delete_address($_POST);
            $this->response['error'] = false;
            $this->response['message'] = 'Address Deleted Successfully';
            $this->response['data'] = array();
        }
        print_r(json_encode($this->response));
    }

    //5.get_settings
    public function get_settings()
    {
        /*
            type : payment_method | all // { default : all  } optional            
            user_id:  15 { optional }
        */
        if (!$this->verify_token()) {
            return false;
        }
        $type = (isset($_POST['type']) && $_POST['type'] == 'payment_method') ? 'payment_method' : 'all';
        $this->form_validation->set_rules('type', 'Setting Type', 'trim|xss_clean');
        $this->form_validation->set_rules('user_id', 'User id', 'trim|numeric|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
        } else {
            $tags = $city = $general_settings = array();

            if ($type == 'all' || $type == 'payment_method') {

                $limit = (isset($_POST['limit'])) ? $this->input->post('limit', true) : 30;
                $offset = (isset($_POST['offset'])) ? $this->input->post('offset', true) : 0;
                $filter = array('tags' => "a");
                $products = fetch_product(null, $filter, null, null, $limit, $offset, 'p.id', 'DESC', null);
                for ($i = 0; $i < count($products); $i++) {
                    if (isset($products['partner_tags']) && !empty($products['partner_tags'])) {
                        $tags = $products['partner_tags'];
                    }
                }
                $settings = [
                    'logo' => 0,
                    'privacy_policy' => 0,
                    'terms_conditions' => 0,
                    'fcm_server_key' => 0,
                    'contact_us' => 0,
                    'payment_method' => 1,
                    'about_us' => 0,
                    'currency' => 0,
                    'user_data' => 0,
                    'system_settings' => 1,
                ];

                if ($type == 'payment_method') {

                    $settings_res['payment_method'] = get_settings($type, $settings[$_POST['type']]);

                    if (isset($_POST['user_id']) && !empty($_POST['user_id'])) {
                        $cart_total_response = get_cart_total($_POST['user_id'], false, 0);
                        $cod_allowed = isset($cart_total_response[0]['is_cod_allowed']) ? $cart_total_response[0]['is_cod_allowed'] : 1;
                        $settings_res['is_cod_allowed'] = $cod_allowed;
                    } else {
                        $settings_res['is_cod_allowed'] = 1;
                    }

                    $general_settings = $settings_res;
                } else {
                    foreach ($settings as $type => $isjson) {
                        if ($type == 'payment_method') {
                            continue;
                        }
                        $general_settings[$type] = [];
                        $settings_res = get_settings($type, $isjson);

                        if ($type == 'logo') {
                            $settings_res = base_url() . $settings_res;
                        }
                        if ($type == 'user_data') {
                            if (isset($_POST['user_id']) && !empty($_POST['user_id'])) {
                                $cart_total_response = get_cart_total($_POST['user_id'], false, 0);
                                $settings_res = fetch_users($_POST['user_id']);
                                $settings_res['cart_total_items'] = (isset($cart_total_response[0]['cart_count']) && $cart_total_response[0]['cart_count'] > 0) ? $cart_total_response[0]['cart_count'] : '0';
                                $settings_res = $settings_res;
                            } else {
                                $settings_res = "";
                            }
                        }
                        if ($type == 'system_settings') {
                            unset($settings_res['google_map_api_key']);
                        }
                        array_push($general_settings[$type], $settings_res);
                    }
                }

                $this->response['error'] = false;
                $this->response['message'] = 'Settings retrieved successfully';
                $this->response['data'] = $general_settings;
                $this->response['data']['tags'] = $tags;
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Settings Not Found';
                $this->response['data'] = array();
            }
            print_r(json_encode($this->response));
        }
    }



    //8.place_order
    public function place_order()
    {
        /*
            user_id:5
            mobile:9974692496
            product_variant_id: 1,2,3
            quantity: 3,3,1
            total:60.0
            delivery_charge:20.0
            tax_amount:10
            tax_percentage:10
            final_total:55
            latitude:40.1451
            longitude:-45.4545
            promo_code:NEW20                        {optional}
            payment_method: Paypal / Payumoney / COD / PAYTM
            address_id:17
            is_wallet_used:1 {By default 0}
            wallet_balance_used:1
            active_status:awaiting {optional}
            order_note:text      //{optional}
            delivery_tip:text      //{optional}
      
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|required|xss_clean');
        $this->form_validation->set_rules('mobile', 'Mobile Id', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('product_variant_id', 'Product Variant Id', 'trim|required|xss_clean');
        $this->form_validation->set_rules('quantity', 'Quantities', 'trim|required|xss_clean');
        $this->form_validation->set_rules('final_total', 'Final Total', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('promo_code', 'Promo Code', 'trim|xss_clean');
        $this->form_validation->set_rules('order_note', 'Order Note', 'trim|xss_clean');
        $this->form_validation->set_rules('delivery_tip', 'Delivery Tip', 'trim|numeric|xss_clean');

        /*
        ------------------------------
        If Wallet Balance Is Used
        ------------------------------
        */
        $this->form_validation->set_rules('is_wallet_used', ' Wallet Balance Used', 'trim|required|numeric|xss_clean');
        if (isset($_POST['is_wallet_used']) && $_POST['is_wallet_used'] == '1') {
            $this->form_validation->set_rules('wallet_balance_used', ' Wallet Balance ', 'trim|required|numeric|xss_clean');
        }
        $this->form_validation->set_rules('latitude', 'Latitude', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('longitude', 'Longitude', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('payment_method', 'Payment Method', 'trim|required|xss_clean');
        $this->form_validation->set_rules('address_id', 'Address id', 'trim|numeric|xss_clean');

        $settings = get_settings('system_settings', true);
        $currency = isset($settings['currency']) && !empty($settings['currency']) ? $settings['currency'] : '';
        if (isset($settings['minimum_cart_amt']) && !empty($settings['minimum_cart_amt'])) {
            $this->form_validation->set_rules('total', 'Total', 'trim|xss_clean|greater_than_equal_to[' . $settings['minimum_cart_amt'] . ']', array('greater_than_equal_to' => 'Total amount should be greater or equal to ' . $currency . $settings['minimum_cart_amt'] . ' total is ' . $currency . $_POST['total'] . ''));
        }
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $_POST['order_note'] = (isset($_POST['order_note']) && !empty($_POST['order_note'])) ? $this->input->post("order_note", true) : NULL;
            $_POST['delivery_tip'] = (isset($_POST['delivery_tip']) && !empty($_POST['delivery_tip'])) ? $this->input->post("delivery_tip", true) : NULL;

            $_POST['is_delivery_charge_returnable'] = (isset($_POST['delivery_charge']) && !empty($_POST['delivery_charge']) && $_POST['delivery_charge'] != '' && $_POST['delivery_charge'] > 0) ? 1 : 0;
            $res = $this->Order_model->place_order($_POST);

            print_r(json_encode($res));

            /* notify all system users, partner and user by email and push notification */
            $fcm_admin_msg = 'New order placed for ' . $settings['app_name'] . ' please confirm it.';
            $fcm_admin_subject = 'New order placed ID #' . $res['order_id'];
            send_notifications("", "admins", $fcm_admin_subject, $fcm_admin_msg, "place_order");

            $fcm_restro_subject = 'New order placed ID #' . $res['order_id'];
            send_notifications($res['order_item_data'][0]['partner_id'], "partner", $fcm_restro_subject, "", "place_order");

            $fcm_user_subject = 'Wait for Order Confirmation';
            $fcm_user_msg = 'Thanks for your order ID #' . $res['order_id'] . '. We will let you know once your order confirm by partner on this email ID.';
            send_notifications($res['order_item_data'][0]['user_id'], "user", $fcm_user_subject, $fcm_user_msg, "place_order",$res['order_id']);
        }
    }

    //get_orders
    public function get_orders()
    {
        // user_id:101
        // id:101              // {optional}
        // active_status: confirmed  {pending,confirmed,preparing,out_for_delivery,delivered,cancelled}     // optional
        // limit:25            // { default - 25 } optional
        // offset:0            // { default - 0 } optional
        // sort: o.id / date_added // { default - o.id } optional
        // order:DESC/ASC      // { default - DESC } optional        
        // download_invoice:0 // { default - 0 } optional       

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('id', 'Id', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('active_status', 'status', 'trim|xss_clean');
        $this->form_validation->set_rules('download_invoice', 'Invoice', 'trim|numeric|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'o.id';
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : '';
            $multiple_status =   (isset($_POST['active_status']) && !empty($_POST['active_status'])) ? explode(',', $_POST['active_status']) : false;
            $download_invoice =   (isset($_POST['download_invoice']) && $_POST['download_invoice'] != null) ? $this->input->post('download_invoice', true) : 1;
            $id =   (isset($_POST['id']) && !empty($_POST['id'])) ? $this->input->post('id', true) : null;
            $order_details = fetch_orders($id, $_POST['user_id'], $multiple_status, false, $limit, $offset, $sort, $order, $download_invoice, false, false, $search);
            if (!empty($order_details['order_data'])) {

                $this->response['error'] = false;
                $this->response['message'] = 'Data retrieved successfully';
                $this->response['total'] = $order_details['total'];
                $this->response['data'] = $order_details['order_data'];
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'No Order(s) Found !';
                $this->response['data'] = array();
            }
        }
        print_r(json_encode($this->response));
    }

    //set_product_rating
    public function set_product_rating()
    {
        /*
            user_id: 21
            product_id: 33
            rating: 4.2
            comment: 'Done' {optional}
            images[]:[]
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('product_id', 'Product Id', 'trim|numeric|xss_clean|required');
        $this->form_validation->set_rules('rating', 'Rating', 'trim|numeric|xss_clean|greater_than[0]|less_than[6]');
        $this->form_validation->set_rules('comment', 'Comment', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = strip_tags(validation_errors());
            $response['data'] = array();
            echo json_encode($response);
        } else {
            if (!file_exists(FCPATH . REVIEW_IMG_PATH)) {
                mkdir(FCPATH . REVIEW_IMG_PATH, 0777);
            }

            $temp_array = array();
            $files = $_FILES;
            $images_new_name_arr = array();
            $images_info_error = "";
            $config = [
                'upload_path' =>  FCPATH . REVIEW_IMG_PATH,
                'allowed_types' => 'jpg|png|jpeg|gif',
                'max_size' => 8000,
            ];

            if (!empty($_FILES['images']['name'][0]) && isset($_FILES['images']['name'])) {
                $other_image_cnt = count($_FILES['images']['name']);
                $other_img = $this->upload;
                $other_img->initialize($config);

                for ($i = 0; $i < $other_image_cnt; $i++) {

                    if (!empty($_FILES['images']['name'][$i])) {

                        $_FILES['temp_image']['name'] = $files['images']['name'][$i];
                        $_FILES['temp_image']['type'] = $files['images']['type'][$i];
                        $_FILES['temp_image']['tmp_name'] = $files['images']['tmp_name'][$i];
                        $_FILES['temp_image']['error'] = $files['images']['error'][$i];
                        $_FILES['temp_image']['size'] = $files['images']['size'][$i];
                        if (!$other_img->do_upload('temp_image')) {
                            $images_info_error = 'Images :' . $images_info_error . ' ' . $other_img->display_errors();
                        } else {
                            $temp_array = $other_img->data();
                            resize_review_images($temp_array, FCPATH . REVIEW_IMG_PATH);
                            $images_new_name_arr[$i] = REVIEW_IMG_PATH . $temp_array['file_name'];
                        }
                    } else {
                        $_FILES['temp_image']['name'] = $files['images']['name'][$i];
                        $_FILES['temp_image']['type'] = $files['images']['type'][$i];
                        $_FILES['temp_image']['tmp_name'] = $files['images']['tmp_name'][$i];
                        $_FILES['temp_image']['error'] = $files['images']['error'][$i];
                        $_FILES['temp_image']['size'] = $files['images']['size'][$i];
                        if (!$other_img->do_upload('temp_image')) {
                            $images_info_error = $other_img->display_errors();
                        }
                    }
                }

                //Deleting Uploaded Images if any overall error occured
                if ($images_info_error != NULL || !$this->form_validation->run()) {
                    if (isset($images_new_name_arr) && !empty($images_new_name_arr || !$this->form_validation->run())) {
                        foreach ($images_new_name_arr as $key => $val) {
                            unlink(FCPATH . REVIEW_IMG_PATH . $images_new_name_arr[$key]);
                        }
                    }
                }
            }

            if ($images_info_error != NULL) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] =  $images_info_error;
                print_r(json_encode($this->response));
                return;
            }
            $user_id = $this->input->post("user_id", true);
            $product_id = $this->input->post("product_id", true);
            $res = $this->db->select('*')->join('product_variants pv', 'pv.id=oi.product_variant_id')
                ->join('products p', 'p.id=pv.product_id')
                ->join('orders o', 'o.id=oi.order_id')
                ->where(['pv.product_id' => $product_id, 'oi.user_id' => $user_id, "o.active_status" => "delivered"])->limit(1)->get('order_items oi')->result_array();
            if (empty($res)) {
                $response['error'] = true;
                $response['message'] = 'You cannot review as the product is not purchased yet!';
                $response['data'] = array();
                echo json_encode($response);
                return;
            }

            $rating_data = fetch_details(['user_id' => $_POST['user_id'], 'product_id' => $_POST['product_id']], 'product_rating', 'images');
            $rating_images = $images_new_name_arr;
            if (isset($rating_data[0]['images']) && isset($rating_data) && !empty($rating_data[0]['images'])) {
                $existing_images = json_decode($rating_data[0]['images']);
                $rating_images = array_merge($existing_images, $images_new_name_arr);
            }

            $_POST['images'] = $rating_images;
            $this->rating_model->set_rating($_POST);
            $rating_data = $this->rating_model->fetch_rating((isset($_POST['product_id'])) ? $_POST['product_id'] : '', '', '25', '0', 'id', 'DESC');
            $rating['product_rating'] = $rating_data['product_rating'];
            $rating['no_of_rating'] = (isset($rating_data['no_of_rating']) && !empty($rating_data['no_of_rating'])) ? $rating_data['no_of_rating'] : "0";
            $response['error'] = false;
            $response['message'] = 'Product Rated Successfully';
            $response['data'] = $rating;
            echo json_encode($response);
            return;
        }
    }

    //  delete_product_rating
    public function delete_product_rating()
    {
        /*
        rating_id:32
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('rating_id', 'Rating Id', 'trim|numeric|required|xss_clean');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = strip_tags(validation_errors());
            $response['data'] = array();
            echo json_encode($response);
        } else {
            $this->rating_model->delete_rating($_POST['rating_id']);
            $response['error'] = false;
            $response['message'] = 'Deleted Rating Successfully';
            $response['data'] = array();
            echo json_encode($response);
        }
    }

    // get_product_rating
    /*
        product_id : 12
        user_id : 1 		{optional}
        limit:25                // { default - 25 } optional
        offset:0                // { default - 0 } optional
        sort: type   			// { default - type } optional
        order:DESC/ASC          // { default - DESC } optional
    */
    public function get_product_rating()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('product_id', 'Product Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        }
        $limit = (isset($_POST['limit'])  && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
        $offset = (isset($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
        $sort = (isset($_POST['sort(array)']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'id';
        $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';
        $has_images = (isset($_POST['has_images']) && !empty(trim($_POST['has_images']))) ? 1 : 0;

        // update category clicks
        $category_id = fetch_details(['id' => $this->input->post('product_id', true)], 'products', 'category_id');
        $this->db->set('clicks', 'clicks+1', FALSE);
        $this->db->where('id', $category_id[0]['category_id']);
        $this->db->update('categories');

        $pr_rating = fetch_details(['id' => $this->input->post('product_id', true)], 'products', 'rating');


        $rating = $this->rating_model->fetch_rating((isset($_POST['product_id'])) ? $_POST['product_id'] : '', (isset($_POST['user_id'])) ? $_POST['user_id'] : '', $limit, $offset, $sort, $order, '', $has_images);
        if (!empty($rating)) {
            $response['error'] = false;
            $response['message'] = 'Rating retrieved successfully';
            $response['no_of_rating'] = (!empty($rating['no_of_rating'])) ? $rating['no_of_rating'] : 0;
            $response['total'] = $rating['total_reviews'];
            $response['star_1'] = $rating['star_1'];
            $response['star_2'] = $rating['star_2'];
            $response['star_3'] = $rating['star_3'];
            $response['star_4'] = $rating['star_4'];
            $response['star_5'] = $rating['star_5'];
            $response['total_images'] = (isset($rating['total_images']) && !empty($rating['total_images'])) ? $rating['total_images'] : "";
            $response['product_rating'] = (!empty($pr_rating)) ? $pr_rating[0]['rating'] : "0";
            $response['data'] = $rating['product_rating'];
        } else {
            $response['error'] = true;
            $response['message'] = 'No ratings found !';
            $response['no_of_rating'] = array();
            $response['data'] = array();
        }
        echo json_encode($response);
    }

    // manage_cart
    public function manage_cart()
    {
        /*
        Add/Update
        user_id:2
        product_variant_id:23
        is_saved_for_later: 1 { default:0 }
        qty:2 // pass 0 to remove qty
        add_on_id:1           {optional}
        add_on_qty:1          {required when passing add on id}
    */
        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('user_id', 'User', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('product_variant_id', 'Product Variant', 'trim|required|xss_clean');
        $this->form_validation->set_rules('qty', 'Quantity', 'trim|required|xss_clean');
        $this->form_validation->set_rules('is_saved_for_later', 'Saved For Later', 'trim|xss_clean');
        $this->form_validation->set_rules('add_on_id', 'Add On Id', 'trim|xss_clean');

        if (isset($_POST['add_on_id']) && !empty($_POST['add_on_id'])) {
            $this->form_validation->set_rules('add_on_qty', 'Add On QTY', 'trim|xss_clean|required');
        }

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $product_variant_id = $this->input->post('product_variant_id', true);
            $user_id = $this->input->post('user_id', true);
            if (!is_single_seller($product_variant_id, $user_id)) {
                $this->response['error'] = true;
                $this->response['message'] = 'Only single partner items are allow in cart.You can remove privious item(s) and add this item.';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
            $qty = $this->input->post('qty', true);
            $saved_for_later = (isset($_POST['is_saved_for_later']) && $_POST['is_saved_for_later'] != "") ? $this->input->post('is_saved_for_later', true) : 0;
            $check_status = ($qty == 0 || $saved_for_later == 1) ? false : true;
            $settings = get_settings('system_settings', true);
            $cart_count = get_cart_count($_POST['user_id']);
            $is_variant_available_in_cart = is_variant_available_in_cart($this->input->post('product_variant_id', true),  $this->input->post('user_id', true));
            if (!$is_variant_available_in_cart) {
                if ($cart_count[0]['total'] >= $settings['max_items_cart']) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'Maximum ' . $settings['max_items_cart'] . ' Item(s) Can Be Added Only!';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return;
                }
            }

            if (!$this->cart_model->add_to_cart($_POST, $check_status)) {
                $response = get_cart_total($_POST['user_id'], false); // we will calculate add ons in this function
                $cart_user_data = $this->cart_model->get_user_cart($_POST['user_id'], 0);
                $tmp_cart_user_data = $cart_user_data;
                if (!empty($tmp_cart_user_data)) {
                    for ($i = 0; $i < count($tmp_cart_user_data); $i++) {
                        $product_data = fetch_details(['id' => $tmp_cart_user_data[$i]['product_variant_id']], 'product_variants', 'product_id,availability');
                        if (!empty($product_data[0]['product_id'])) {
                            $pro_details = fetch_product($_POST['user_id'], null, $product_data[0]['product_id']);
                            if (!empty($pro_details['product'])) {
                                if (trim($pro_details['product'][0]['availability']) == 0 && $pro_details['product'][0]['availability'] != null) {
                                    update_details(['is_saved_for_later' => '1'], $cart_user_data[$i]['id'], 'cart');
                                    unset($cart_user_data[$i]);
                                }

                                if (!empty($pro_details['product'])) {
                                    $cart_user_data[$i]['product_details'] = $pro_details['product'];
                                } else {
                                    delete_details(['id' => $cart_user_data[$i]['id']], 'cart');
                                    unset($cart_user_data[$i]);
                                    continue;
                                }
                            } else {
                                delete_details(['id' => $cart_user_data[$i]['id']], 'cart');
                                unset($cart_user_data[$i]);
                                continue;
                            }
                        } else {
                            delete_details(['id' => $cart_user_data[$i]['id']], 'cart');
                            unset($cart_user_data[$i]);
                            continue;
                        }
                    }
                }

                $this->response['error'] = false;
                $this->response['message'] = 'Cart Updated !';
                $this->response['cart'] = (isset($cart_user_data) && !empty($cart_user_data)) ? $cart_user_data : [];
                $this->response['data'] = [
                    'total_quantity' => ($_POST['qty'] == 0) ? '0' : strval($_POST['qty']),
                    'sub_total' => strval($response['sub_total']),
                    'total_items' => (isset($response[0]['total_items'])) ? strval($response[0]['total_items']) : "0",
                    'tax_percentage' => (isset($response['tax_percentage'])) ? strval($response['tax_percentage']) : "0",
                    'tax_amount' => (isset($response['tax_amount'])) ? strval($response['tax_amount']) : "0",
                    'cart_count' => (isset($response[0]['cart_count'])) ? strval($response[0]['cart_count']) : "0",
                    'max_items_cart' => $settings['max_items_cart'],
                    'overall_amount' => $response['overall_amount'],
                ];
                print_r(json_encode($this->response));
                return;
            }
        }
    }

    //10. get_user_cart
    public function get_user_cart()
    {
        /*
            user_id:1
            is_saved_for_later: 1 { default:0 }
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('is_saved_for_later', 'Saved for later', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('search', 'Search keyword', 'trim|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $is_saved_for_later = (isset($_POST['is_saved_for_later']) && $_POST['is_saved_for_later'] == 1) ? $_POST['is_saved_for_later'] : 0;
            $user_id = (isset($_POST['user_id']) && !empty($_POST['user_id'])) ? $this->input->post("user_id", true) : "";

            $cart_user_data = $this->cart_model->get_user_cart($user_id, $is_saved_for_later);
            $cart_total_response = get_cart_total($user_id, '', $is_saved_for_later);
            $tmp_cart_user_data = $cart_user_data;
            if (!empty($tmp_cart_user_data)) {
                for ($i = 0; $i < count($tmp_cart_user_data); $i++) {
                    $product_data = fetch_details(['id' => $tmp_cart_user_data[$i]['product_variant_id']], 'product_variants', 'product_id,availability');
                    if (!empty($product_data[0]['product_id'])) {
                        $pro_details = fetch_product($user_id, null, $product_data[0]['product_id']);
                        if (!empty($pro_details['product'])) {
                            if (trim($pro_details['product'][0]['availability']) == 0 && $pro_details['product'][0]['availability'] != null) {
                                update_details(['is_saved_for_later' => '1'], $cart_user_data[$i]['id'], 'cart');
                                unset($cart_user_data[$i]);
                            }

                            if (!empty($pro_details['product'])) {
                                $cart_user_data[$i]['product_details'] = $pro_details['product'];
                            } else {
                                delete_details(['id' => $cart_user_data[$i]['id']], 'cart');
                                unset($cart_user_data[$i]);
                                continue;
                            }
                        } else {
                            delete_details(['id' => $cart_user_data[$i]['id']], 'cart');
                            unset($cart_user_data[$i]);
                            continue;
                        }
                    } else {
                        delete_details(['id' => $cart_user_data[$i]['id']], 'cart');
                        unset($cart_user_data[$i]);
                        continue;
                    }
                }
            }

            if (empty($cart_user_data)) {
                $this->response['error'] = true;
                $this->response['message'] = 'Cart Is Empty !';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            $this->response['error'] = false;
            $this->response['message'] = 'Data Retrieved From Cart !';
            $this->response['total_quantity'] = $cart_total_response['quantity'];
            $this->response['sub_total'] = $cart_total_response['sub_total'];
            $this->response['tax_percentage'] = (isset($cart_total_response['tax_percentage'])) ? $cart_total_response['tax_percentage'] : "0";
            $this->response['tax_amount'] = (isset($cart_total_response['tax_amount'])) ? $cart_total_response['tax_amount'] : "0";
            $this->response['overall_amount'] = round($cart_total_response['overall_amount']);
            $this->response['total_arr'] =  round($cart_total_response['total_arr']);
            $this->response['variant_id'] =  $cart_total_response['variant_id'];
            $this->response['data'] = array_values($cart_user_data);
            print_r(json_encode($this->response));
            return;
        }
    }

    //12. add_to_favorites
    public function add_to_favorites()
    {
        /*
            user_id:15
            type:partners | products
            type_id:60
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('type', 'Type', 'trim|required|xss_clean|in_list[partners,products]');
        $this->form_validation->set_rules('type_id', 'Type ID', 'trim|numeric|required|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_id = $this->input->post('user_id', true);
            $type = $this->input->post('type', true);
            $type_id = $this->input->post('type_id', true);
            if (is_exist(['user_id' => $user_id, 'type' => $type, 'type_id' => $type_id], 'favorites')) {
                $response["error"]   = true;
                $response["message"] = "Already added to favorite !";
                $response["data"] = array();
                echo json_encode($response);
                return false;
            }
            $data = [
                'user_id' => $user_id,
                'type' => $type,
                'type_id' => $type_id,
            ];
            insert_details($data, "favorites");
            $this->response['error'] = false;
            $this->response['message'] = 'Added to favorite';
            $this->response['data'] = array();
        }
        print_r(json_encode($this->response));
    }

    //remove_from_favorites
    public function remove_from_favorites()
    {
        /*
            user_id:15
            type:partners | products  {optional}
            type_id:60                   {optional}
        */
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('type', 'Type', 'trim|xss_clean|in_list[partners,products]');
        if (isset($_POST['type']) && !empty($_POST['type']) && (!isset($_POST['type_id']) || empty($_POST['type_id']))) {
            $this->form_validation->set_rules('type_id', 'Type ID', 'trim|required|numeric|xss_clean');
        } else {
            $this->form_validation->set_rules('type_id', 'Type ID', 'trim|numeric|xss_clean');
        }

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $data = ['user_id' => $this->input->post('user_id', true)];
            if (isset($_POST['type']) && !empty($_POST['type']) && isset($_POST['type_id']) && !empty($_POST['type_id'])) {
                $data['type'] = $this->input->post('type', true);
                $data['type_id'] = $this->input->post('type_id', true);
                if (!is_exist(['user_id' => $data['user_id'], 'type' => $data['type'], 'type_id' => $data['type_id']], 'favorites')) {
                    $response["error"]   = true;
                    $response["message"] = "partner or Product not added as favorite !";
                    $response["data"] = array();
                    echo json_encode($response);
                    return false;
                }
            }
            delete_details($data, 'favorites');
            $this->response['error'] = false;
            $this->response['message'] = 'Removed from favorite';
            $this->response['data'] = array();
        }
        print_r(json_encode($this->response));
    }

    //get_favorites
    public function get_favorites()
    {
        /*
            user_id:12
            type:partners | products 
            limit : 10 {optional}
            offset: 0 {optional}
        */
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('type', 'Type', 'trim|xss_clean|required|in_list[partners,products]');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $limit = (isset($_POST['limit'])  && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $type = (isset($_POST['type']) && !empty(trim($_POST['type']))) ? $this->input->post('type', true) : 'products';

            $result = get_favorites($this->input->post('user_id', true), $type, $limit, $offset);
            if (isset($result) && !empty($result) && isset($result['data']) && !empty($result['data'])) {
                $this->response['error'] = false;
                $this->response['message'] = 'Data Retrieved Successfully';
                $this->response['total'] = (isset($result['total']) && !empty($result['total'])) ? $result['total'] : [];
                $this->response['data'] = (isset($result['data']) && !empty($result['data'])) ? $result['data'] : [];
                print_r(json_encode($this->response));
                return;
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'No Favourite(s) Product or partner Were Added.';
                $this->response['total'] = [];
                $this->response['data'] = [];
                print_r(json_encode($this->response));
                return;
            }
        }
        print_r(json_encode($this->response));
    }

    //get_notifications()
    public function get_notifications()
    {
        /* 
            sort: id / date_added // { default - id } optional
            order:DESC/ASC      // { default - DESC } optional    
            limit:10            // { default - 25 } {optional}
            offset:0            // { default - 0 } {optional}
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $_POST['order'] : 'DESC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $_POST['sort'] : 'id';
            $res = $this->notification_model->get_notifications($offset, $limit, $sort, $order);
            $this->response['error'] = false;
            $this->response['message'] = 'Notification Retrieved Successfully';
            $this->response['total'] = $res['total'];
            $this->response['data'] = $res['data'];
        }
        print_r(json_encode($this->response));
    }

    /*
        status: cancelled
        order_id:1201
    */
    public function update_order_status()
    {
        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('status', 'Status', 'trim|required|xss_clean');
        $this->form_validation->set_rules('order_id', 'Order id', 'trim|required|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return false;
        } else {
            $status = $this->input->post("status", true);
            $order_id = $this->input->post("order_id", true);

            $res = validate_order_status($order_id, $status, 'orders');
            if ($res['error']) {
                $this->response['error'] = (isset($res['return_request_flag'])) ? false : true;
                $this->response['message'] = $res['message'];
                $this->response['data'] = $res['data'];
                print_r(json_encode($this->response));
                return false;
            }


            if ($this->order_model->update_order(['status' => $status], ['id' => $order_id], true)) {
                $this->order_model->update_order(['active_status' => $status], ['id' => $order_id], false);
                process_refund($order_id, $status, 'orders');
                $data = fetch_details(['order_id' => $order_id], 'order_items', 'product_variant_id,quantity');
                $product_variant_ids = $qtns = [];
                foreach ($data as $d) {
                    array_push($product_variant_ids, $d['product_variant_id']);
                    array_push($qtns, $d['quantity']);
                }

                update_stock($product_variant_ids, $qtns, 'plus');
                $this->response['error'] = false;
                $this->response['message'] = 'Status Updated Successfully';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Something went wrong! Please try again after some time.';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
        }
    }

    public function add_transaction()
    {
        /*
            transaction_type : transaction / wallet  // { optional - default is transaction }
            user_id : 15 
            order_id:  23
            type : COD / stripe / razorpay / paypal / paystack / flutterwave - for transaction | credit / debit - for wallet
            payment_method:razorpay / paystack / flutterwave        // used for waller credit option, required when transaction_type - wallet and type - credit
            txn_id : 201567892154 
            amount : 450
            status : success / failure
            message : Done 
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('transaction_type', 'Transaction Type', 'trim|xss_clean');
        $this->form_validation->set_rules('user_id', 'User id', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('order_id', 'order id', 'trim|required|xss_clean');
        $this->form_validation->set_rules('type', 'Type', 'trim|required|xss_clean');
        $this->form_validation->set_rules('txn_id', 'Txn', 'trim|required|xss_clean');
        $this->form_validation->set_rules('amount', 'Amount', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('status', 'Status', 'trim|required|xss_clean');
        $this->form_validation->set_rules('message', 'message', 'trim|required|xss_clean');
        if (isset($_POST['transaction_type']) && $_POST['transaction_type'] == "wallet" && $_POST['type'] == "credit") {
            $this->form_validation->set_rules('payment_method', 'Payment method', 'trim|required|xss_clean');
        }

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            /* if it's a wallet credit transaction then verify the payment with the help of txn_id */
            if (isset($_POST['transaction_type']) && $_POST['transaction_type'] == "wallet" && $_POST['type'] == "credit") {
                $payment_method = $this->input->post('payment_method', true);
                $payment_method = strtolower($payment_method);
                $txn_id = $this->input->post('txn_id', true);
                $user_id = $this->input->post('user_id', true);
                $user = fetch_users($user_id);
                if (empty($user)) {
                    $this->response['error'] = true;
                    $this->response['message'] = "User not found!";
                    $this->response['data'] = [];
                    print_r(json_encode($this->response));
                    return false;
                }
                $old_balance = $user['balance'];

                /* check if this transaction has already been added or not in transactions table */
                $transaction = fetch_details(['txn_id' => $txn_id], 'transactions');
                if (empty($transaction) || (isset($transaction[0]['status']) && strtolower($transaction[0]['status']) != 'success')) {
                    $payment = verify_payment_transaction($txn_id, $payment_method); /* calling all in one verify payment transaction function */
                    if ($payment['error'] == false) {
                        $this->load->model('customer_model');
                        if (!$this->customer_model->update_balance($payment['amount'], $user_id, 'add')) {
                            $this->response['error'] = true;
                            $this->response['message'] = "Wallet could not be recharged due to database operation failure";
                            $this->response['amount'] = $payment['amount'];
                            $this->response['old_balance'] = "$old_balance";
                            $this->response['new_balance'] = "$old_balance";
                            $this->response['data'] = $payment['data'];
                            print_r(json_encode($this->response));
                            return false;
                        }
                        $new_balance = $old_balance + $payment['amount'];

                        $this->response['amount'] = $payment['amount'];
                        $this->response['old_balance'] = "$old_balance";
                        $this->response['new_balance'] = "$new_balance";
                        $_POST['message'] = "$payment_method - Wallet credited on successful payment confirmation.";
                        $_POST['amount'] = $payment['amount'];
                    } else {
                        $new_balance = $old_balance + $payment['amount'];
                        $this->response['error'] = true;
                        $this->response['message'] = "Wallet could not be recharged! " . $payment['message'];
                        $this->response['amount'] = $payment['amount'];
                        $this->response['old_balance'] = "$old_balance";
                        $this->response['new_balance'] = "$new_balance";
                        $this->response['data'] = [];
                        print_r(json_encode($this->response));
                        return false;
                    }
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = "Wallet could not be recharged! Transaction has already been added before";
                    $this->response['amount'] = 0;
                    $this->response['old_balance'] = "$old_balance";
                    $this->response['new_balance'] = "$old_balance";
                    $this->response['data'] = [];
                    print_r(json_encode($this->response));
                    return false;
                }
            }

            $transaction_type = (isset($_POST['transaction_type']) && !empty($_POST['transaction_type'])) ? $_POST['transaction_type'] : "transaction";
            $this->transaction_model->add_transaction($_POST);
            $this->response['error'] = false;
            $this->response['message'] = ($transaction_type == "wallet") ? 'Wallet Transaction Added Successfully' : 'Transaction Added Successfully';
            $this->response['data'] = (!empty($this->response['data'])) ? $this->response['data'] : [];
        }
        print_r(json_encode($this->response));
    }

    //13 get_sections
    public function get_sections()
    {
        /*
                limit:10            // { default - 25 } {optional}
                offset:0            // { default - 0 } {optional}
                user_id:12              {optional}
                section_id:4            {optional}
                top_rated_foods: 1 // { default - 0 } optional
                p_limit:10          // { default - 10 } {optional}
                p_offset:10         // { default - 0 } {optional}    
                p_sort:pv.price      // { default - pid } {optional}
                p_order:asc         // { default - desc } {optional}
                filter_by:p.id|sd.user_id       // {p.id = product list | sd.user_id = partner list}            
                             { default - p.id } optional
                latitude:123                 // {optional}
                longitude:123                // {optional}

            */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('limit', 'Limit', 'trim|xss_clean');
        $this->form_validation->set_rules('offset', 'Offset', 'trim|xss_clean');
        $this->form_validation->set_rules('user_id', 'User Id', 'trim|xss_clean');
        $this->form_validation->set_rules('section_id', 'Section Id', 'trim|xss_clean');
        $this->form_validation->set_rules('p_limit', 'Product Limit', 'trim|xss_clean');
        $this->form_validation->set_rules('p_offset', 'Product Offset', 'trim|xss_clean');
        $this->form_validation->set_rules('p_sort', 'Product Sort', 'trim|xss_clean');
        $this->form_validation->set_rules('p_order', 'Product Order', 'trim|xss_clean');
        $this->form_validation->set_rules('filter_by', ' filter_by ', 'trim|xss_clean');
        $this->form_validation->set_rules('city_id', ' City Id ', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        }
        if (isset($_POST['latitude']) && !empty($_POST['latitude']) && empty($_POST['longitude'])) {
            $this->response['error'] = true;
            $this->response['message'] = "The Longitude Field is Required";
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        }
        if (isset($_POST['longitude']) && !empty($_POST['longitude']) && empty($_POST['latitude'])) {
            $this->response['error'] = true;
            $this->response['message'] = "The Latitude Field is Required";
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        }

        $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
        $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
        $user_id = (isset($_POST['user_id']) && !empty(trim($_POST['user_id']))) ? $this->input->post('user_id', true) : 0;
        $section_id = (isset($_POST['section_id']) && !empty(trim($_POST['section_id']))) ? $this->input->post('section_id', true) : 0;
        $filters['product_type'] = (isset($_POST['top_rated_foods']) && $_POST['top_rated_foods'] == 1) ? 'top_rated_foods_including_all_foods' : null;
        $p_limit = (isset($_POST['p_limit']) && !empty(trim($_POST['p_limit']))) ? $this->input->post('p_limit', true) : 10;
        $p_offset = (isset($_POST['p_offset']) && !empty(trim($_POST['p_offset']))) ? $this->input->post('p_offset', true) : 0;
        $p_order = (isset($_POST['p_order']) && !empty(trim($_POST['p_order']))) ? $_POST['p_order'] : 'DESC';
        $p_sort = (isset($_POST['p_sort']) && !empty(trim($_POST['p_sort']))) ? $_POST['p_sort'] : 'p.id';
        $filter_by = (isset($_POST['filter_by']) && !empty($_POST['filter_by'])) ? $this->input->post("filter_by", true) : 'p.id';

        $this->db->select('*');
        if (isset($_POST['section_id']) && !empty($_POST['section_id'])) {
            $this->db->where('id', $section_id);
        }
        $this->db->limit($limit, $offset);
        $sections = $this->db->order_by('row_order')->get('sections')->result_array();

        if (!empty($sections)) {
            for ($i = 0; $i < count($sections); $i++) {
                $product_ids = explode(',', $sections[$i]['product_ids']);
                $product_ids = array_filter($product_ids);
                $filters['show_only_active_products'] = 1;
                if (isset($_POST['top_rated_foods']) && !empty($_POST['top_rated_foods'])) {
                    $filters['product_type'] = (isset($_POST['top_rated_foods']) && $_POST['top_rated_foods'] == 1) ? 'top_rated_foods_including_all_foods' : null;
                } else {
                    if (isset($sections[$i]['product_type']) && !empty($sections[$i]['product_type'])) {
                        $filters['product_type'] = (isset($sections[$i]['product_type'])) ? $sections[$i]['product_type'] : null;
                    }
                }
                $filters['longitude'] = (isset($_POST['longitude']) && !empty($_POST['longitude'])) ? $this->input->post("longitude", true) : 0;
                $filters['latitude'] = (isset($_POST['latitude']) && !empty($_POST['latitude'])) ? $this->input->post("latitude", true) : 0;
                $filters['city_id'] = (isset($_POST['city_id']) && !empty($_POST['city_id'])) ? $this->input->post("city_id", true) : 0;
                $categories = (isset($sections[$i]['categories']) && !empty($sections[$i]['categories']) && $sections[$i]['categories'] != NULL) ? explode(',', $sections[$i]['categories']) : null;

                $products = fetch_product($user_id, (isset($filters)) ? $filters : null, (isset($product_ids) && !empty($product_ids)) ? $product_ids : null, $categories, $p_limit, $p_offset, $p_sort, $p_order, null, null, null, $filter_by);
                if (!empty($products['product'])) {
                    $this->response['error'] = false;
                    $this->response['message'] = "Sections retrived successfully";
                    $sections[$i]['title'] =  output_escaping($sections[$i]['title']);
                    $sections[$i]['short_description'] =  output_escaping($sections[$i]['short_description']);
                    $sections[$i]['categories'] =  (isset($sections[$i]['categories']) && !empty($sections[$i]['categories'])) ? $sections[$i]['categories'] : "";
                    $sections[$i]['product_ids'] =  (isset($sections[$i]['product_ids']) && !empty($sections[$i]['product_ids'])) ? $sections[$i]['product_ids'] : "";
                    $sections[$i]['total'] =  strval($products['total']);
                    $sections[$i]['filters'] = (isset($products['filters'])) ? $products['filters'] : [];
                    $sections[$i]['product_tags'] = (isset($products['product_tags']) && !empty($products['product_tags'])) ? $products['product_tags'] : [];
                    $sections[$i]['partner_tags'] = (isset($products['partner_tags']) && !empty($products['partner_tags'])) ? $products['partner_tags'] : [];
                    $sections[$i]['product_details'] =  $products['product'];
                    unset($sections[$i]['product_details'][0]['total']);
                } else {
                    $this->response['error'] = false;
                    $this->response['message'] = "Sections retrived successfully";
                    $sections[$i]['total'] = "0";
                    $sections[$i]['filters'] = [];
                    $sections[$i]['product_details'] =  [];
                }
            }
            $this->response['data'] = $sections;
        } else {
            $this->response['error'] = true;
            $this->response['message'] = "No sections are available";
            $this->response['data'] = array();
        }
        print_r(json_encode($this->response));
    }

    //17. get_faqs
    public function get_faqs()
    {
        if (!$this->verify_token()) {
            return false;
        }

        /*
            limit:25                // { default - 25 } optional
            offset:0                // { default - 0 } optional
            sort: id   			    // { default - id } optional
            order:DESC/ASC          // { default - DESC } optional
        */

        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $_POST['order'] : 'DESC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $_POST['sort'] : 'id';
            $res = $this->faq_model->get_faqs($offset, $limit, $sort, $order);
            $this->response['error'] = false;
            $this->response['message'] = 'FAQ(s) Retrieved Successfully';
            $this->response['total'] = $res['total'];
            $this->response['data'] = $res['data'];
        }

        print_r(json_encode($this->response));
    }

    public function transactions()
    {
        /*
            user_id:73 
            id: 1001                // { optional}
            transaction_type:transaction / wallet // { default - transaction } optional
            type : COD / stripe / razorpay / paypal / paystack / flutterwave - for transaction | credit / debit - for wallet // { optional }
            search : Search keyword // { optional }
            limit:25                // { default - 25 } optional
            offset:0                // { default - 0 } optional
            sort: id / date_created // { default - id } optional
            order:DESC/ASC          // { default - DESC } optional
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User ID', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('transaction_type', 'Transaction Type', 'trim|xss_clean');
        $this->form_validation->set_rules('type', 'Type', 'trim|xss_clean');
        $this->form_validation->set_rules('search', 'Search keyword', 'trim|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_id = (isset($_POST['user_id']) && is_numeric($_POST['user_id']) && !empty(trim($_POST['user_id']))) ? $this->input->post('user_id', true) : "";
            $id = (isset($_POST['id']) && is_numeric($_POST['id']) && !empty(trim($_POST['id']))) ? $this->input->post('id', true) : "";
            $transaction_type = (isset($_POST['transaction_type']) && !empty(trim($_POST['transaction_type']))) ? $this->input->post('transaction_type', true) : "transaction";
            $type = (isset($_POST['type']) && !empty(trim($_POST['type']))) ? $this->input->post('type', true) : "";
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : "";
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $_POST['order'] : 'DESC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $_POST['sort'] : 'id';
            $res = $this->transaction_model->get_transactions($id, $user_id, $transaction_type, $type, $search, $offset, $limit, $sort, $order);
            $this->response['error'] = false;
            $this->response['message'] = 'Transactions Retrieved Successfully';
            $this->response['total'] = $res['total'];
            $this->response['balance'] = get_user_balance($user_id);
            $this->response['data'] = $res['data'];
        }

        print_r(json_encode($this->response));
    }

    public function delete_order()
    {
        /*
            order_id:1
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('order_id', 'Order ID', 'trim|required|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $order_id = $_POST['order_id'];
            delete_details(['id' => $order_id], 'orders');
            delete_details(['order_id' => $order_id], 'order_items');

            $this->response['error'] = false;
            $this->response['message'] = 'Order deleted successfully';
            $this->response['data'] = array();
        }
        print_r(json_encode($this->response));
    }

    public function get_ticket_types()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $this->db->select('*');
        $types = $this->db->get('ticket_types')->result_array();
        if (!empty($types)) {
            for ($i = 0; $i < count($types); $i++) {
                $types[$i] = output_escaping($types[$i]);
            }
        }
        $this->response['error'] = false;
        $this->response['message'] = 'Ticket types fetched successfully';
        $this->response['data'] = $types;
        print_r(json_encode($this->response));
    }

    public function add_ticket()
    {
        /*
            ticket_type_id:1
            subject:product_image not displying
            email:test@gmail.com
            description:its not showing images of products in web
            user_id:1
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('ticket_type_id', 'Ticket Type', 'trim|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User id', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('subject', 'Subject', 'trim|required|xss_clean');
        $this->form_validation->set_rules('email', 'email', 'trim|required|xss_clean');
        $this->form_validation->set_rules('description', 'description', 'trim|required|xss_clean');


        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $ticket_type_id = $this->input->post('ticket_type_id', true);
            $user_id = $this->input->post('user_id', true);
            $subject = $this->input->post('subject', true);
            $email = $this->input->post('email', true);
            $description = $this->input->post('description', true);
            $user = fetch_users($user_id);
            if (empty($user)) {
                $this->response['error'] = true;
                $this->response['message'] = "User not found!";
                $this->response['data'] = [];
                print_r(json_encode($this->response));
                return false;
            }
            $data = array(
                'ticket_type_id' => $ticket_type_id,
                'user_id' => $user_id,
                'subject' => $subject,
                'email' => $email,
                'description' => $description,
                'status' => PENDING,
            );
            $insert_id = $this->ticket_model->add_ticket($data);
            if (!empty($insert_id)) {
                $result = $this->ticket_model->get_tickets($insert_id, $ticket_type_id, $user_id);
                $this->response['error'] = false;
                $this->response['message'] =  'Ticket Added Successfully';
                $this->response['data'] = $result['data'];
            } else {
                $this->response['error'] = true;
                $this->response['message'] =  'Ticket Not Added';
                $this->response['data'] = (!empty($this->response['data'])) ? $this->response['data'] : [];
            }
        }
        print_r(json_encode($this->response));
    }
    //29. edit_ticket
    public function edit_ticket()
    {
        /*
            ticket_id:1
            ticket_type_id:1
            subject:product_image not displying
            email:test@gmail.com
            description:its not showing attachments of products in web
            user_id:1
            status:3 or 5 [3 -> resolved, 5 -> reopened]
            [1 -> pending, 2 -> opened, 3 -> resolved, 4 -> closed, 5 -> reopened]
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('ticket_type_id', 'Ticket Type Id', 'trim|required|xss_clean');
        $this->form_validation->set_rules('ticket_id', 'Ticket Id', 'trim|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User id', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('subject', 'Subject', 'trim|required|xss_clean');
        $this->form_validation->set_rules('email', 'Email', 'trim|required|xss_clean');
        $this->form_validation->set_rules('description', 'Description', 'trim|required|xss_clean');
        $this->form_validation->set_rules('status', 'Status', 'trim|required|xss_clean');


        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $status = $this->input->post('status', true);
            $ticket_id = $this->input->post('ticket_id', true);
            $user_id = $this->input->post('user_id', true);
            $res = fetch_details('id=' . $ticket_id . ' and user_id=' . $user_id, 'tickets', '*');
            if (empty($res)) {
                $this->response['error'] = true;
                $this->response['message'] = "User id is changed you can not udpate the ticket.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
            if ($status == RESOLVED && $res[0]['status'] == CLOSED) {
                $this->response['error'] = true;
                $this->response['message'] = "Current status is closed.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
            if ($status == REOPEN && ($res[0]['status'] == PENDING || $res[0]['status'] == OPENED)) {
                $this->response['error'] = true;
                $this->response['message'] = "Current status is pending or opened.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
            $ticket_type_id = $this->input->post('ticket_type_id', true);
            $user_id = $this->input->post('user_id', true);
            $subject = $this->input->post('subject', true);
            $email = $this->input->post('email', true);
            $description = $this->input->post('description', true);
            $user = fetch_users($user_id);
            if (empty($user)) {
                $this->response['error'] = true;
                $this->response['message'] = "User not found!";
                $this->response['data'] = [];
                print_r(json_encode($this->response));
                return false;
            }
            $data = array(
                'ticket_type_id' => $ticket_type_id,
                'user_id' => $user_id,
                'subject' => $subject,
                'email' => $email,
                'description' => $description,
                'status' => $status,
                'ticket_id' => $ticket_id,
                'edit_ticket' => $ticket_id
            );
            if (!$this->ticket_model->add_ticket($data)) {
                $result = $this->ticket_model->get_tickets($ticket_id, $ticket_type_id, $user_id);
                $this->response['error'] = false;
                $this->response['message'] =  'Ticket updated Successfully';
                $this->response['data'] = $result['data'];
            } else {
                $this->response['error'] = true;
                $this->response['message'] =  'Ticket Not Added';
                $this->response['data'] = (!empty($this->response['data'])) ? $this->response['data'] : [];
            }
        }
        print_r(json_encode($this->response));
    }

    //40. send_message
    public function send_message()
    {
        /*
            user_type:user
            user_id:1
            ticket_id:1	
            message:test	
            attachments[]:files  {optional} {type allowed -> image,video,document,spreadsheet,archive}
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_type', 'User Type', 'trim|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User id', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('ticket_id', 'Ticket id', 'trim|required|numeric|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_type = $this->input->post('user_type', true);
            $user_id = $this->input->post('user_id', true);
            $ticket_id = $this->input->post('ticket_id', true);
            $message = (isset($_POST['message']) && !empty(trim($_POST['message']))) ? $this->input->post('message', true) : "";


            $user = fetch_users($user_id);
            if (empty($user)) {
                $this->response['error'] = true;
                $this->response['message'] = "User not found!";
                $this->response['data'] = [];
                print_r(json_encode($this->response));
                return false;
            }
            if (!file_exists(FCPATH . TICKET_IMG_PATH)) {
                mkdir(FCPATH . TICKET_IMG_PATH, 0777);
            }

            $temp_array = array();
            $files = $_FILES;
            $images_new_name_arr = array();
            $images_info_error = "";
            $allowed_media_types = implode('|', allowed_media_types());
            $config = [
                'upload_path' =>  FCPATH . TICKET_IMG_PATH,
                'allowed_types' => $allowed_media_types,
                'max_size' => 8000,
            ];


            if (!empty($_FILES['attachments']['name'][0]) && isset($_FILES['attachments']['name'])) {
                $other_image_cnt = count($_FILES['attachments']['name']);
                $other_img = $this->upload;
                $other_img->initialize($config);

                for ($i = 0; $i < $other_image_cnt; $i++) {

                    if (!empty($_FILES['attachments']['name'][$i])) {

                        $_FILES['temp_image']['name'] = $files['attachments']['name'][$i];
                        $_FILES['temp_image']['type'] = $files['attachments']['type'][$i];
                        $_FILES['temp_image']['tmp_name'] = $files['attachments']['tmp_name'][$i];
                        $_FILES['temp_image']['error'] = $files['attachments']['error'][$i];
                        $_FILES['temp_image']['size'] = $files['attachments']['size'][$i];
                        if (!$other_img->do_upload('temp_image')) {
                            $images_info_error = 'attachments :' . $images_info_error . ' ' . $other_img->display_errors();
                        } else {
                            $temp_array = $other_img->data();
                            resize_review_images($temp_array, FCPATH . TICKET_IMG_PATH);
                            $images_new_name_arr[$i] = TICKET_IMG_PATH . $temp_array['file_name'];
                        }
                    } else {
                        $_FILES['temp_image']['name'] = $files['attachments']['name'][$i];
                        $_FILES['temp_image']['type'] = $files['attachments']['type'][$i];
                        $_FILES['temp_image']['tmp_name'] = $files['attachments']['tmp_name'][$i];
                        $_FILES['temp_image']['error'] = $files['attachments']['error'][$i];
                        $_FILES['temp_image']['size'] = $files['attachments']['size'][$i];
                        if (!$other_img->do_upload('temp_image')) {
                            $images_info_error = $other_img->display_errors();
                        }
                    }
                }

                //Deleting Uploaded attachments if any overall error occured
                if ($images_info_error != NULL || !$this->form_validation->run()) {
                    if (isset($images_new_name_arr) && !empty($images_new_name_arr || !$this->form_validation->run())) {
                        foreach ($images_new_name_arr as $key => $val) {
                            unlink(FCPATH . TICKET_IMG_PATH . $images_new_name_arr[$key]);
                        }
                    }
                }
            }
            if ($images_info_error != NULL) {
                $this->response['error'] = true;
                $this->response['message'] =  $images_info_error;
                print_r(json_encode($this->response));
                return false;
            }
            $data = array(
                'user_type' => $user_type,
                'user_id' => $user_id,
                'ticket_id' => $ticket_id,
                'message' => $message
            );
            if (!empty($_FILES['attachments']['name'][0]) && isset($_FILES['attachments']['name'])) {
                $data['attachments'] = $images_new_name_arr;
            }
            $insert_id = $this->ticket_model->add_ticket_message($data);
            if (!empty($insert_id)) {
                $data1 = $this->config->item('type');
                $result = $this->ticket_model->get_messages($ticket_id, $user_id, "", "", "1", "", "", $data1, $insert_id);
                if (!empty($result)) {
                    /* Send notification */
                    $user_roles = fetch_details("", "user_permissions", '*', '',  '', '', '');
                    foreach ($user_roles as $user) {
                        $user_res = fetch_details(['id' => $user['user_id']], 'users', 'fcm_id');
                        $fcm_ids[0][] = $user_res[0]['fcm_id'];
                    }
                    $fcm_admin_msg = (!empty($result['data'][0]['message'])) ? $result['data'][0]['message'] : "Attachments";
                    $fcm_admin_subject = (!empty($result['data'][0]['subject'])) ? $result['data'][0]['subject'] : "Ticket Message";
                    if (!empty($fcm_ids)) {
                        $fcmMsg = array(
                            'title' => $fcm_admin_subject,
                            'body' => $fcm_admin_msg,
                            'type' => "ticket_message",
                            'type_id' => $ticket_id,
                            'chat' => json_encode($result['data']),
                            'content_available' => true
                        );
                        send_notification($fcmMsg, $fcm_ids);
                    }
                }
                $this->response['error'] = false;
                $this->response['message'] =  'Ticket Message Added Successfully!';
                $this->response['data'] = $result['data'][0];
            } else {
                $this->response['error'] = true;
                $this->response['message'] =  'Ticket Message Not Added';
                $this->response['data'] = (!empty($this->response['data'])) ? $this->response['data'] : [];
            }
        }
        print_r(json_encode($this->response));
    }

    //41. get_tickets
    public function get_tickets()
    {
        /*
        31. get_tickets
            ticket_id: 1001                // { optional}
            ticket_type_id: 1001                // { optional}
            user_id: 1001                // { optional}
            status:   [1 -> pending, 2 -> opened, 3 -> resolved, 4 -> closed, 5 -> reopened]// { optional}
            search : Search keyword // { optional }
            limit:25                // { default - 25 } optional
            offset:0                // { default - 0 } optional
            sort: id | date_created | last_updated                // { default - id } optional
            order:DESC/ASC          // { default - DESC } optional
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('ticket_id', 'Ticket ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('ticket_type_id', 'Ticket Type ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('status', 'User ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('search', 'Search keyword', 'trim|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $ticket_id = (isset($_POST['ticket_id']) && is_numeric($_POST['ticket_id']) && !empty(trim($_POST['ticket_id']))) ? $this->input->post('ticket_id', true) : "";
            $ticket_type_id = (isset($_POST['ticket_type_id']) && is_numeric($_POST['ticket_type_id']) && !empty(trim($_POST['ticket_type_id']))) ? $this->input->post('ticket_type_id', true) : "";
            $user_id = (isset($_POST['user_id']) && is_numeric($_POST['user_id']) && !empty(trim($_POST['user_id']))) ? $this->input->post('user_id', true) : "";
            $status = (isset($_POST['status']) && is_numeric($_POST['status']) && !empty(trim($_POST['status']))) ? $this->input->post('status', true) : "";
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : "";
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 10;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $_POST['order'] : 'DESC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $_POST['sort'] : 'id';
            $result = $this->ticket_model->get_tickets($ticket_id, $ticket_type_id, $user_id, $status, $search, $offset, $limit, $sort, $order);
            print_r(json_encode($result));
        }
    }

    //42. get_messages
    public function get_messages()
    {
        /*
    42. get_messages
        ticket_id: 1001            
        user_type: 1001                // { optional}
        user_id: 1001                // { optional}
        search : Search keyword // { optional }
        limit:25                // { default - 25 } optional
        offset:0                // { default - 0 } optional
        sort: id | date_created | last_updated                // { default - id } optional
        order:DESC/ASC          // { default - DESC } optional
    */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('ticket_id', 'Ticket ID', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('status', 'User ID', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('search', 'Search keyword', 'trim|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $ticket_id = (isset($_POST['ticket_id']) && is_numeric($_POST['ticket_id']) && !empty(trim($_POST['ticket_id']))) ? $this->input->post('ticket_id', true) : "";
            $user_id = (isset($_POST['user_id']) && is_numeric($_POST['user_id']) && !empty(trim($_POST['user_id']))) ? $this->input->post('user_id', true) : "";
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : "";
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 10;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $_POST['order'] : 'DESC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $_POST['sort'] : 'id';
            $data = $this->config->item('type');
            $result = $this->ticket_model->get_messages($ticket_id, $user_id, $search, $offset, $limit, $sort, $order, $data, "");
            print_r(json_encode($result));
        }
    }

    public function set_rider_rating()
    {
        /*
            user_id: 21
            rider_id: 33
            rating: 4.2
            comment: Done {optional}
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('rider_id', 'Rider Id', 'trim|numeric|xss_clean|required');
        $this->form_validation->set_rules('rating', 'Rating', 'trim|numeric|xss_clean|greater_than[0]|less_than[6]');
        $this->form_validation->set_rules('comment', 'Comment', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = strip_tags(validation_errors());
            $response['data'] = array();
            echo json_encode($response);
        } else {

            $user_id = $this->input->post("user_id", true);
            $rider_id = $this->input->post("rider_id", true);
            $res = $this->db->select('id')
                ->where(['rider_id' => $rider_id, 'user_id' => $user_id, "active_status" => "delivered"])->order_by('id', "DESC")->limit(1)->get('orders')->result_array();
            if (empty($res)) {
                $response['error'] = true;
                $response['message'] = 'You cannot review as the Rider is not Delivere yet or this delviery boy were not delivered your order!';
                $response['data'] = array();
                echo json_encode($response);
                return;
            }

            $this->rating_model->set_rider_rating($_POST);
            $rating_data = $this->rating_model->fetch_rider_rating((isset($_POST['rider_id'])) ? $_POST['rider_id'] : '', '', '25', '0', 'id', 'DESC');
            $rating['no_of_rating'] = (isset($rating_data['no_of_rating']) && !empty($rating_data['no_of_rating'])) ? $rating_data['no_of_rating'] : "0";
            $rating['rider_rating'] = (isset($rating_data['rating']) && !empty($rating_data['rating'])) ? $rating_data['rating'] : "0";
            $rating['product_rating'] = $rating_data['rider_rating'];
            $response['error'] = false;
            $response['message'] = 'Product Rated Successfully';
            $response['data'] = $rating;
            echo json_encode($response);
            return;
        }
    }

    // get_rider_rating
    /*
        rider_id : 12
        user_id : 1 		{optional}
        limit:25                // { default - 25 } optional
        offset:0                // { default - 0 } optional
        sort: u.id   			// { default - u.id } optional
        order:DESC/ASC          // { default - DESC } optional
    */
    public function get_rider_rating()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('rider_id', 'Rider Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        }
        $limit = (isset($_POST['limit'])  && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
        $offset = (isset($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
        $sort = (isset($_POST['sort(array)']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'u.id';
        $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';

        $rating = $this->rating_model->fetch_rider_rating((isset($_POST['rider_id'])) ? $this->input->post('rider_id', true) : '', (isset($_POST['user_id'])) ? $this->input->post('user_id', true) : '', $limit, $offset, $sort, $order, '');
        if (!empty($rating)) {
            $response['error'] = false;
            $response['message'] = 'Rating retrieved successfully';
            $response['no_of_rating'] = (!empty($rating['no_of_rating'])) ? $rating['no_of_rating'] : "0";
            $response['total'] = $rating['total_reviews'];
            $response['star_1'] = $rating['star_1'];
            $response['star_2'] = $rating['star_2'];
            $response['star_3'] = $rating['star_3'];
            $response['star_4'] = $rating['star_4'];
            $response['star_5'] = $rating['star_5'];
            $response['rider_rating'] = (!empty($rating['rating'])) ? $rating['rating'] : "0";
            $response['data'] = $rating['rider_rating'];
        } else {
            $response['error'] = true;
            $response['message'] = 'No ratings found !';
            $response['no_of_rating'] = array();
            $response['data'] = array();
        }
        echo json_encode($response);
    }

    //  delete_rider_rating
    public function delete_rider_rating()
    {
        /*
        rating_id:32
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('rating_id', 'Rating Id', 'trim|numeric|required|xss_clean');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = strip_tags(validation_errors());
            $response['data'] = array();
            echo json_encode($response);
        } else {
            $this->rating_model->delete_rider_rating($_POST['rating_id']);
            $response['error'] = false;
            $response['message'] = 'Deleted Rating Successfully';
            $response['data'] = array();
            echo json_encode($response);
        }
    }

    public function stripe_webhook()
    {
        $this->load->library(['stripe']);
        $credentials = $this->stripe->get_credentials();

        $request_body = file_get_contents('php://input');
        $event = json_decode($request_body, FALSE);
        log_message('error', 'Stripe Webhook --> ' . var_export($event, true));
        log_message('error', 'Stripe Webhook SERVER Variable --> ' . var_export($_SERVER, true));

        if (!empty($event->data->object->payment_intent)) {
            $txn_id = (isset($event->data->object->payment_intent)) ? $event->data->object->payment_intent : "";
            // $txn_id = "pi_1IEZnFBpktnZYCfOuAquYdTv";
            if (!empty($txn_id)) {
                $transaction = fetch_details(['txn_id' => $txn_id], 'transactions', '*');
                if (!empty($transaction)) {
                    $order_id = $transaction[0]['order_id'];
                    $user_id = $transaction[0]['user_id'];
                } else {
                    $order_id = 0;
                }
            }
            $amount = $event->data->object->amount;
            $currency = $event->data->object->currency;
            $balance_transaction = $event->data->object->balance_transaction;
        } else {
            $order_id = 0;
            $amount = 0;
            $currency = (isset($event->data->object->currency)) ? $event->data->object->currency : "";
            $balance_transaction = 0;
        }

        /* Wallet refill has unique format for order ID - wallet-refill-user-{user_id}-{system_time}-{3 random_number}  */
        if (empty($order_id)) {
            $order_id = (!empty($event->data->object->metadata) && isset($event->data->object->metadata->order_id)) ? $event->data->object->metadata->order_id : 0;
        }

        if (!is_numeric($order_id) && strpos($order_id, "wallet-refill-user") !== false) {
            $temp = explode("-", $order_id);
            if (isset($temp[3]) && is_numeric($temp[3]) && !empty($temp[3] && $temp[3] != '')) {
                $user_id = $temp[3];
            } else {
                $user_id = 0;
            }
        }

        $http_stripe_signature = isset($_SERVER['HTTP_STRIPE_SIGNATURE']) ? $_SERVER['HTTP_STRIPE_SIGNATURE'] : "";
        $result = $this->stripe->construct_event($request_body, $http_stripe_signature, $credentials['webhook_key']);

        if ($result == "Matched") {
            if ($event->type == 'charge.succeeded') {
                if (!empty($order_id)) {
                    /* To do the wallet recharge if the order id is set in the patter */
                    if (strpos($order_id, "wallet-refill-user") !== false) {
                        $data['transaction_type'] = "wallet";
                        $data['user_id'] = $user_id;
                        $data['order_id'] = $order_id;
                        $data['type'] = "credit";
                        $data['txn_id'] = $txn_id;
                        $data['amount'] = $amount / 100;
                        $data['status'] = "success";
                        $data['message'] = "Wallet refill successful";
                        $this->transaction_model->add_transaction($data);

                        $this->load->model('customer_model');
                        if ($this->customer_model->update_balance($amount / 100, $user_id, 'add')) {
                            $response['error'] = false;
                            $response['transaction_status'] = $event->type;
                            $response['message'] = "Wallet recharged successfully!";
                        } else {
                            $response['error'] = true;
                            $response['transaction_status'] = $event->type;
                            $response['message'] = "Wallet could not be recharged!";
                            log_message('error', 'Stripe Webhook | wallet recharge failure --> ' . var_export($event, true));
                        }
                        echo json_encode($response);
                        return false;
                    } else {

                        /* process the order and mark it as received */
                        $order = fetch_orders($order_id, false, false, false, false, false, false, false);
                        // log_message('error', 'Stripe Webhook | order --> ' . var_export($order, true));
                        if (isset($order['order_data'][0]['user_id'])) {
                            $user = fetch_details(['id' => $order['order_data'][0]['user_id']], 'users');

                            if (isset($user[0]['email']) && !empty($user[0]['email'])) {
                                send_mail($user[0]['email'], 'Wait for Order Confirmation', 'Thanks for your order. We will let you know once your order confirm by partner on this email ID.');
                            }
                            /* No need to add because the transaction is already added just update the transaction status */
                            if (!empty($transaction)) {
                                $transaction_id = $transaction[0]['id'];
                                update_details(['status' => 'success'], ['id' => $transaction_id], 'transactions');
                            }

                            /* add transaction of the payment */

                            update_details(['active_status' => 'pending'], ['id' => $order_id], 'orders');

                            $status = json_encode(array(array('pending', date("d-m-Y h:i:sa"))));
                            update_details(['status' => $status], ['id' => $order_id], 'orders', false);
                        }
                    }
                } else {
                    /* No order ID found */
                    // log_message('error', 'Stripe Webhook | No Order ID found --> ' . var_export($event, true));
                }

                $response['error'] = false;
                $response['transaction_status'] = $event->type;
                $response['message'] = "Transaction successfully done";
                echo json_encode($response);
                return false;
            } elseif ($event->type == 'charge.failed') {
                if (!empty($order_id)) {
                    update_details(['active_status' => 'cancelled'], ['id' => $order_id], 'orders');
                }
                /* No need to add because the transaction is already added just update the transaction status */
                if (!empty($transaction)) {
                    $transaction_id = $transaction[0]['id'];
                    update_details(['status' => 'failed'], ['id' => $transaction_id], 'transactions');
                }
                $response['error'] = true;
                $response['transaction_status'] = $event->type;
                $response['message'] = "Transaction is failed. ";
                // log_message('error', 'Stripe Webhook | Transaction is failed --> ' . var_export($event, true));
                echo json_encode($response);
                return false;
            } elseif ($event->type == 'charge.pending') {
                $response['error'] = false;
                $response['transaction_status'] = $event->type;
                $response['message'] = "Waiting customer to finish transaction ";
                // log_message('error', 'Stripe Webhook | Waiting customer to finish transaction --> ' . var_export($event, true));
                echo json_encode($response);
                return false;
            } elseif ($event->type == 'charge.expired') {
                if (!empty($order_id)) {
                    update_details(['active_status' => 'cancelled'], ['id' => $order_id], 'orders');
                }
                /* No need to add because the transaction is already added just update the transaction status */
                if (!empty($transaction)) {
                    $transaction_id = $transaction[0]['id'];
                    update_details(['status' => 'expired'], ['id' => $transaction_id], 'transactions');
                }
                $response['error'] = true;
                $response['transaction_status'] = $event->type;
                $response['message'] = "Transaction is expired.";
                // log_message('error', 'Stripe Webhook | Transaction is expired --> ' . var_export($event, true));
                echo json_encode($response);
                return false;
            } elseif ($event->type == 'charge.refunded') {
                if (!empty($order_id)) {
                    update_details(['active_status' => 'cancelled'], ['id' => $order_id], 'orders');
                }
                /* No need to add because the transaction is already added just update the transaction status */
                if (!empty($transaction)) {
                    $transaction_id = $transaction[0]['id'];
                    update_details(['status' => 'refunded'], ['id' => $transaction_id], 'transactions');
                }
                $response['error'] = true;
                $response['transaction_status'] = $event->type;
                $response['message'] = "Transaction is refunded.";
                // log_message('error', 'Stripe Webhook | Transaction is refunded --> ' . var_export($event, true));
                echo json_encode($response);
                return false;
            } else {
                $response['error'] = true;
                $response['transaction_status'] = $event->type;
                $response['message'] = "Transaction could not be detected.";
                // log_message('error', 'Stripe Webhook | Transaction could not be detected --> ' . var_export($event, true));
                echo json_encode($response);
                return false;
            }
        } else {
            log_message('error', 'Stripe Webhook | Invalid Server Signature  --> ' . var_export($result, true));
            return false;
        }
    }



    public function generate_paytm_checksum()
    {
        /*
            order_id:1001
            amount:1099
            user_id:73              //{ optional } 
            industry_type:Industry  //{ optional } 
            channel_id:WAP          //{ optional }
            website:website link    //{ optional }
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->load->library(['paytm']);
        $this->form_validation->set_rules('order_id', 'Order ID', 'trim|required|xss_clean');
        $this->form_validation->set_rules('amount', 'Amount', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|xss_clean');
        $this->form_validation->set_rules('industry_type', 'Industry Type', 'trim|xss_clean');
        $this->form_validation->set_rules('channel_id', 'Channel ID', 'trim|xss_clean');
        $this->form_validation->set_rules('website', 'Website', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return false;
        } else {
            $settings = get_settings('payment_method', true);
            $credentials = $this->paytm->get_credentials();

            $paytm_params["MID"] = $settings['paytm_merchant_id'];

            $paytm_params["ORDER_ID"] = $this->input->post('order_id', true);
            $paytm_params["TXN_AMOUNT"] = $this->input->post('amount', true);
            $paytm_params["CUST_ID"] = $this->input->post('user_id', true);
            // $paytm_params["INDUSTRY_TYPE_ID"] = $this->input->post('industry_type', true);
            // $paytm_params["CHANNEL_ID"] = $this->input->post('channel_id', true);
            $paytm_params["WEBSITE"] = $this->input->post('website', true);
            $paytm_params["CALLBACK_URL"] = $credentials['url'] . "theia/paytmCallback?ORDER_ID=" . $paytm_params["ORDER_ID"];

            /**
             * Generate checksum by parameters we have
             * Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
             */
            $paytm_checksum = $this->paytm->generateSignature($paytm_params, $settings['paytm_merchant_key']);

            // echo sprintf("generateSignature Returns: %s\n", $paytm_checksum);
            if (!empty($paytm_checksum)) {
                $response['error'] = false;
                $response['message'] = "Checksum created successfully";
                $response['order id'] = $paytm_params["ORDER_ID"];
                $response['data'] = $paytm_params;
                $response['signature'] = $paytm_checksum;
                print_r(json_encode($response));
                return false;
            } else {
                $response['error'] = true;
                $response['message'] = "Data not found!";
                print_r(json_encode($response));
                return false;
            }
        }
    }

    public function generate_paytm_txn_token()
    {
        /*
            amount:100.00
            order_id:102
            user_id:73
            industry_type:      //{optional}
            channel_id:      //{optional}
            website:      //{optional}
        */
        $this->form_validation->set_rules('order_id', 'Order ID', 'trim|required|xss_clean');
        $this->form_validation->set_rules('amount', 'Amount', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|required|xss_clean');
        $this->form_validation->set_rules('industry_type', 'Industry Type', 'trim|xss_clean');
        $this->form_validation->set_rules('channel_id', 'Channel ID', 'trim|xss_clean');
        $this->form_validation->set_rules('website', 'Website', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return false;
        } else {
            $this->load->library('paytm');
            $credentials = $this->paytm->get_credentials();
            $order_id = $_POST['order_id'];
            $amount = $_POST['amount'];
            $user_id = $_POST['user_id'];
            $paytmParams = array();

            $paytmParams["body"] = array(
                "requestType"   => "Payment",
                "mid"           => $credentials['paytm_merchant_id'],
                "websiteName"   => "WEBSTAGING",
                "orderId"       => $order_id,
                "callbackUrl"   => $credentials['url'] . "theia/paytmCallback?ORDER_ID=" . $order_id,
                "txnAmount"     => array(
                    "value"     => $amount,
                    "currency"  => "INR",
                ),
                "userInfo"      => array(
                    "custId"    => $user_id,
                ),
            );

            /*
            * Generate checksum by parameters we have in body
            * Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
            */
            $checksum = $this->paytm->generateSignature(json_encode($paytmParams["body"], JSON_UNESCAPED_SLASHES), $credentials['paytm_merchant_key']);

            $paytmParams["head"] = array(
                "signature"    => $checksum
            );

            $post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);

            /* for Staging */
            $url = $credentials['url'] . "/theia/api/v1/initiateTransaction?mid=" . $credentials['paytm_merchant_id'] . "&orderId=" . $order_id;

            /* for Production */
            // $url = "https://securegw.paytm.in/theia/api/v1/initiateTransaction?mid=YOUR_MID_HERE&orderId=ORDERID_98765";

            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json"));
            $paytm_response = curl_exec($ch);

            if (!empty($paytm_response)) {
                $paytm_response = json_decode($paytm_response, true);
                if (isset($paytm_response['body']['resultInfo']['resultMsg']) && ($paytm_response['body']['resultInfo']['resultMsg'] == "Success" || $paytm_response['body']['resultInfo']['resultMsg'] == "Success Idempotent")) {
                    $response['error'] = false;
                    $response['message'] = "Transaction token generated successfully";
                    $response['txn_token'] = $paytm_response['body']['txnToken'];
                    $response['paytm_response'] = $paytm_response;
                } else {
                    $response['error'] = true;
                    $response['message'] = $paytm_response['body']['resultInfo']['resultMsg'];
                    $response['txn_token'] = "";
                    $response['paytm_response'] = $paytm_response;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Could not generate transaction token. Try again!";
                $response['txn_token'] = "";
                $response['paytm_response'] = $paytm_response;
            }
            print_r(json_encode($response));
        }
    }
    public function validate_paytm_checksum()
    {
        /*
            paytm_checksum:PAYTM_CHECKSUM
            order_id:1001
            amount:1099
            user_id:73              //{ optional } 
            industry_type:Industry  //{ optional } 
            channel_id:WAP          //{ optional }
            website:website link    //{ optional }
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->load->library(['paytm']);
        $this->form_validation->set_rules('order_id', 'Order ID', 'trim|required|xss_clean');
        $this->form_validation->set_rules('amount', 'Amount', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|xss_clean');
        $this->form_validation->set_rules('industry_type', 'Industry Type', 'trim|xss_clean');
        $this->form_validation->set_rules('channel_id', 'Channel ID', 'trim|xss_clean');
        $this->form_validation->set_rules('website', 'Website', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return false;
        } else {
            $settings = get_settings('payment_method', true);
            $credentials = $this->paytm->get_credentials();

            $paytm_checksum = $this->input->post('paytm_checksum', true);

            $paytm_params["MID"] = $settings['paytm_merchant_id'];
            $paytm_params["ORDER_ID"] = $this->input->post('order_id', true);
            $paytm_params["TXN_AMOUNT"] = $this->input->post('amount', true);
            // $paytm_params["CUST_ID"] = $this->input->post('user_id', true);
            // $paytm_params["INDUSTRY_TYPE_ID"] = $this->input->post('industry_type', true);
            // $paytm_params["CHANNEL_ID"] = $this->input->post('channel_id', true);;
            // $paytm_params["WEBSITE"] = $this->input->post('website', true);
            // $paytm_params["CALLBACK_URL"] = $credentials['url'] . "/theia/paytmCallback?ORDER_ID=" . $paytm_params["ORDER_ID"];

            $isVerifySignature = $this->paytm->verifySignature($paytm_params, $settings['paytm_merchant_key'], $paytm_checksum);
            if ($isVerifySignature) {
                $this->response['error'] = false;
                $this->response['message'] = "Checksum Matched";
                print_r(json_encode($this->response));
                return false;
            } else {
                $this->response['error'] = true;
                $this->response['message'] = "Checksum Mismatched";
                print_r(json_encode($this->response));
                return false;
            }
        }
    }

    // validate_refer_code
    public function validate_refer_code()
    {
        /* 
            referral_code:USERS_CODE_TO_BE_VALIDATED
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('referral_code', 'Referral code', 'trim|required|is_unique[users.referral_code]|xss_clean');
        $this->form_validation->set_message('is_unique', 'This %s is already used by some other user.');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
        } else {
            $this->response['error'] = false;

            $this->response['message'] = "Referral Code is available to be used";
        }
        print_r(json_encode($this->response));
        return false;
    }

    public function flutterwave_webview()
    {
        /* 
            amount:100
            user_id:73
            reference:eShop-165232013-400  // { optional }
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('amount', 'Amount', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('user_id', 'User ID', 'trim|required|numeric|xss_clean');
        $this->form_validation->set_rules('reference', 'Reference', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return false;
        } else {
            $this->load->library('flutterwave');

            $app_settings = get_settings('system_settings', true);
            $payment_settings = get_settings('payment_method', true);
            $logo = base_url() . get_settings('favicon');
            $user_id = $this->input->post('user_id', true);
            $user = fetch_users($user_id);
            if (empty($user) || !isset($user['mobile'])) {
                $response['error'] = true;
                $response['message'] = "User not found!";
                print_r(json_encode($response));
                return false;
            }

            $data['tx_ref'] = (isset($_POST['reference']) && !empty($_POST['reference'])) ? $_POST['reference'] : $app_settings['app_name'] . "-" . time() . "-" . rand(1000, 9999);
            $data['amount'] = $this->input->post('amount', true);
            $data['currency'] = (isset($payment_settings['flutterwave_currency_code']) && !empty($payment_settings['flutterwave_currency_code'])) ? $payment_settings['flutterwave_currency_code'] : "NGN";
            $data['redirect_url'] = base_url('app/v1/api/flutterwave-payment-response');
            $data['payment_options'] = "card";
            $data['meta']['user_id'] = $user_id;
            $data['customer']['email'] = (!empty($user['email'])) ? $user['email'] : $app_settings['support_email'];
            $data['customer']['phonenumber'] = $user['mobile'];
            $data['customer']['name'] = $user['username'];
            $data['customizations']['title'] = $app_settings['app_name'] . " Payments ";
            $data['customizations']['description'] = "Online payments on " . $app_settings['app_name'];
            $data['customizations']['logo'] = (!empty($logo)) ? $logo : "";
            $payment = $this->flutterwave->create_payment($data);
            if (!empty($payment)) {
                $payment = json_decode($payment, true);
                if (isset($payment['status']) && $payment['status'] == 'success' && isset($payment['data']['link'])) {
                    $response['error'] = false;
                    $response['message'] = "Payment link generated. Follow the link to make the payment!";
                    $response['link'] = $payment['data']['link'];
                    print_r(json_encode($response));
                } else {
                    $response['error'] = true;
                    $response['message'] = "Could not initiate payment. " . $payment['message'];
                    $response['link'] = "";
                    print_r(json_encode($response));
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Could not initiate payment. Try again later! ";
                $response['link'] = "";
                print_r($response);
            }
        }
    }
    public function flutterwave_payment_response()
    {
        if (isset($_GET['transaction_id']) && !empty($_GET['transaction_id'])) {
            $this->load->library('flutterwave');
            $transaction_id = $_GET['transaction_id'];
            $transaction = $this->flutterwave->verify_transaction($transaction_id);
            if (!empty($transaction)) {
                $transaction = json_decode($transaction, true);
                if ($transaction['status'] == 'error') {
                    $response['error'] = true;
                    $response['message'] = $transaction['message'];
                    $response['amount'] = 0;
                    $response['status'] = "failed";
                    $response['currency'] = "NGN";
                    $response['transaction_id'] = $transaction_id;
                    $response['reference'] = "";
                    print_r(json_encode($response));
                    return false;
                }

                if ($transaction['status'] == 'success' && $transaction['data']['status'] == 'successful') {
                    $response['error'] = false;
                    $response['message'] = "Payment has been completed successfully";
                    $response['amount'] = $transaction['data']['amount'];
                    $response['currency'] = $transaction['data']['currency'];
                    $response['status'] = $transaction['data']['status'];
                    $response['transaction_id'] = $transaction['data']['id'];
                    $response['reference'] = $transaction['data']['tx_ref'];
                    print_r(json_encode($response));
                    return false;
                } else if ($transaction['status'] == 'success' && $transaction['data']['status'] != 'successful') {
                    $response['error'] = true;
                    $response['message'] = "Payment is " . $transaction['data']['status'];
                    $response['amount'] = $transaction['data']['amount'];
                    $response['currency'] = $transaction['data']['currency'];
                    $response['status'] = $transaction['data']['status'];
                    $response['transaction_id'] = $transaction['data']['id'];
                    $response['reference'] = $transaction['data']['tx_ref'];
                    print_r(json_encode($response));
                    return false;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Transaction not found";
                print_r(json_encode($response));
            }
        } else {
            $response['error'] = true;
            $response['message'] = "Invalid request!";
            print_r(json_encode($response));
            return false;
        }
    }

    public function get_paypal_link()
    {
        /*
            user_id : 2
            order_id : 1
            amount : 150
        */

        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('order_id', 'Order ID', 'trim|required|xss_clean');
        $this->form_validation->set_rules('amount', 'Amount', 'trim|required|numeric|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_id = $_POST['user_id'];
            $order_id = $_POST['order_id'];
            $amount = $_POST['amount'];
            if (!is_numeric($order_id)) {
                $this->response['error'] = false;
                $this->response['message'] = 'Order created for wallet!';
                $this->response['data'] = base_url('app/v1/api/paypal_transaction_webview?' . 'user_id=' . $user_id . '&order_id=' . $order_id . '&amount=' . $amount);
                print_r(json_encode($this->response));
                return false;
            }
            $this->response['error'] = false;
            $this->response['message'] = 'Order Detail Founded !';
            $this->response['data'] = base_url('app/v1/api/paypal_transaction_webview?' . 'user_id=' . $user_id . '&order_id=' . $order_id . '&amount=' . $amount);
        }
        print_r(json_encode($this->response));
    }

    //paypal_transaction_webview()
    public function paypal_transaction_webview()
    {
        /*
            user_id : 2
            order_id : 1
        */

        header("Content-Type: html");

        $this->form_validation->set_data($_GET);

        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('order_id', 'Order ID', 'trim|required|xss_clean');
        $this->form_validation->set_rules('amount', 'Amount', 'trim|required|numeric|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return false;
        }

        $user_id = $this->input->get('user_id', true);
        $order_id = $this->input->get('order_id', true);
        $amount = $this->input->get('amount', true);

        $q = $this->db->where('id', $user_id)->get('users')->result_array();
        if (empty($q) && !isset($q)) {
            echo "user error update";
            return false;
        }

        $order_res = $this->db->where('id', $order_id)->get('orders')->result_array();
        if (!empty($order_res)) {

            $data['user'] = $q[0];
            $data['order'] = $order_res[0];
            $data['payment_type'] = "paypal";
            // Set variables for paypal form
            $returnURL = base_url() . 'app/v1/api/app_payment_status';
            $cancelURL = base_url() . 'app/v1/api/app_payment_status';
            $notifyURL = base_url() . 'app/v1/api/ipn';
            $txn_id = time() . "-" . rand();
            // Get current user ID from the session
            $userID = $data['user']['id'];
            $order_id = $data['order']['id'];
            $payeremail = $data['user']['email'];
            // $userID = $data['user']->id;
            // Add fields to paypal form
            $this->paypal_lib->add_field('return', $returnURL);
            $this->paypal_lib->add_field('cancel_return', $cancelURL);
            $this->paypal_lib->add_field('notify_url', $notifyURL);
            $this->paypal_lib->add_field('item_name', 'Test');
            $this->paypal_lib->add_field('custom', $userID . '|' . $payeremail);
            $this->paypal_lib->add_field('item_number', $order_id);
            $this->paypal_lib->add_field('amount', $amount);
            // Render paypal form
            $this->paypal_lib->paypal_auto_form();
        } else {
            $data['user'] = $q[0];
            $data['payment_type'] = "paypal";
            // Set variables for paypal form
            $returnURL = base_url() . 'app/v1/api/app_payment_status';
            $cancelURL = base_url() . 'app/v1/api/app_payment_status';
            $notifyURL = base_url() . 'app/v1/api/ipn';
            $txn_id = time() . "-" . rand();
            // Get current user ID from the session
            $userID = $data['user']['id'];
            $order_id = $order_id;
            $payeremail = $data['user']['email'];

            $this->paypal_lib->add_field('return', $returnURL);
            $this->paypal_lib->add_field('cancel_return', $cancelURL);
            $this->paypal_lib->add_field('notify_url', $notifyURL);
            $this->paypal_lib->add_field('item_name', 'Online shopping');
            $this->paypal_lib->add_field('custom', $userID . '|' . $payeremail);
            $this->paypal_lib->add_field('item_number', $order_id);
            $this->paypal_lib->add_field('amount', $amount);
            // Render paypal form
            $this->paypal_lib->paypal_auto_form();
        }
    }

    public function app_payment_status()
    {
        $paypalInfo = $this->input->get();

        if (!empty($paypalInfo) && isset($_GET['st']) && strtolower($_GET['st']) == "completed") {
            $response['error'] = false;
            $response['message'] = "Payment Completed Successfully";
            $response['data'] = $paypalInfo;
        } elseif (!empty($paypalInfo) && isset($_GET['st']) && strtolower($_GET['st']) == "authorized") {
            $response['error'] = false;
            $response['message'] = "Your payment is has been Authorized successfully. We will capture your transaction within 30 minutes, once we process your order. After successful capture coins wil be credited automatically.";
            $response['data'] = $paypalInfo;
        } elseif (!empty($paypalInfo) && isset($_GET['st']) && strtolower($_GET['st']) == "Pending") {
            $response['error'] = false;
            $response['message'] = "Your payment is pending and is under process. We will notify you once the status is updated.";
            $response['data'] = $paypalInfo;
        } else {
            $response['error'] = true;
            $response['message'] = "Payment Cancelled / Declined ";
            $response['data'] = (isset($_GET)) ? $this->input->get() : "";
        }
        print_r(json_encode($response));
    }

    public function ipn()
    {
        // Paypal posts the transaction data
        $paypalInfo = $this->input->post();
        // log_message('error', 'Paypal IPN POST --> ' . var_export($paypalInfo, true));

        if (!empty($paypalInfo)) {
            // Validate and get the ipn response
            $ipnCheck = $this->paypal_lib->validate_ipn($paypalInfo);

            // Check whether the transaction is valid
            if ($ipnCheck) {

                $order_id = $paypalInfo["item_number"];
                /* if its not numeric then it is for the wallet recharge */
                if (
                    $paypalInfo["payment_status"] == 'Completed' &&
                    !is_numeric($order_id) && strpos($order_id, "wallet-refill-user") !== false
                ) {
                    $temp = explode("-", $order_id);   /* Order ID format for wallet refill >> wallet-refill-user-{user_id}-{system_time}-{3 random_number}  */
                    if (isset($temp[3]) && is_numeric($temp[3]) && !empty($temp[3] && $temp[3] != '')) {
                        $user_id = $temp[3];
                    } else {
                        $user_id = 0;
                    }
                    $amount = $paypalInfo["mc_gross"];
                    /* IPN for user wallet recharge */
                    $data['transaction_type'] = "wallet";
                    $data['user_id'] = $user_id;
                    $data['order_id'] = $order_id;
                    $data['type'] = "credit";
                    $data['txn_id'] = $paypalInfo["txn_id"];
                    $data['amount'] = $amount;
                    $data['status'] = "success";
                    $data['message'] = "Wallet refill successful";
                    $this->transaction_model->add_transaction($data);

                    $this->load->model('customer_model');
                    if ($this->customer_model->update_balance($amount, $user_id, 'add')) {
                        $response['error'] = false;
                        $response['transaction_status'] = "success";
                        $response['message'] = "Wallet recharged successfully!";
                    } else {
                        $response['error'] = true;
                        $response['transaction_status'] = "success";
                        $response['message'] = "Wallet could not be recharged!";
                        log_message('error', 'Paypal IPN | wallet recharge failure --> ' . var_export($paypalInfo, true));
                    }
                    echo json_encode($response);
                    return false;
                } else {
                    /* IPN for normal Order  */
                    // Insert the transaction data in the database
                    $userData = explode('|', $paypalInfo['custom']);

                    $data['transaction_type'] = 'Transaction';
                    $data['user_id'] = $userData[0];
                    $data['payer_email']  = $userData[1];
                    $data['order_id'] = $paypalInfo["item_number"];
                    $data['type'] = 'paypal';
                    $data['txn_id'] = $paypalInfo["txn_id"];
                    $data['amount'] = $paypalInfo["mc_gross"];
                    $data['currency_code'] = $paypalInfo["mc_currency"];
                    $data['status'] = 'success';
                    $data['message'] = 'Payment Verified';
                    if ($paypalInfo["payment_status"] == 'Completed') {
                        send_mail($userData[1], 'Wait for Order Confirmation', 'Thanks for your order. We will let you know once your order confirm by partner on this email ID.');

                        // log_message('error', 'Paypal IPN POST --> ' . var_export($overall_order_data, true));
                        $this->transaction_model->add_transaction($data);

                        update_details(['active_status' => 'pending'], ['id' => $data['order_id']], 'orders');

                        $status = json_encode(array(array('pending', date("d-m-Y h:i:sa"))));
                        update_details(['status' => $status], ['id' => $data['order_id']], 'orders', false);
                    } else if (
                        $paypalInfo["payment_status"] == 'Expired' || $paypalInfo["payment_status"] == 'Failed'
                        || $paypalInfo["payment_status"] == 'Refunded' || $paypalInfo["payment_status"] == 'Reversed'
                    ) {
                        /* if transaction wasn't completed successfully then cancel the order and transaction */
                        $data['transaction_type'] = 'Transaction';
                        $data['user_id'] = $userData[0];
                        $data['payer_email']  = $userData[1];
                        $data['order_id'] = $paypalInfo["item_number"];
                        $data['type'] = 'paypal';
                        $data['txn_id'] = $paypalInfo["txn_id"];
                        $data['amount'] = $paypalInfo["mc_gross"];
                        $data['currency_code'] = $paypalInfo["mc_currency"];
                        $data['status'] = $paypalInfo["payment_status"];
                        $data['message'] = 'Payment could not be completed due to one or more reasons!';
                        $this->transaction_model->add_transaction($data);

                        update_details(['active_status' => 'cancelled'], ['id' => $data['order_id']], 'orders');
                        $status = json_encode(array(array('cancelled', date("d-m-Y h:i:sa"))));
                        update_details(['status' => $status], ['id' => $data['order_id']], 'orders', false);
                    }
                }
            }
        }
    }

    //41. get_promo_codes
    public function get_promo_codes()
    {
        /*
         31. get_promo_codes
             search : Search keyword // { optional }
             limit:25                // { default - 25 } optional
             offset:0                // { default - 0 } optional
             sort: id | date_created | last_updated                // { default - id } optional
             order:DESC/ASC          // { default - DESC } optional
         */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('search', 'Search keyword', 'trim|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : "";
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 10;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $_POST['order'] : 'DESC';
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $_POST['sort'] : 'id';
            $promo_code = $this->Promo_code_model->get_promo_codes($limit, $offset, $sort, $order, $search);
            print_r(json_encode($promo_code));
            return false;
        }
    }

    public function remove_from_cart()
    {
        /*
            user_id:2           
            product_variant_id:23 {optional} //if not passed all items in the cart will be removed.    
      */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('product_variant_id', 'Product Variant', 'trim|numeric|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            //Fetching cart items to check wheather cart is empty or not
            $cart_total_response = get_cart_total($_POST['user_id']);
            $settings = get_settings('system_settings', true);
            if (!isset($cart_total_response[0]['total_items'])) {
                $this->response['error'] = true;
                $this->response['message'] = 'Cart Is Already Empty !';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }

            $this->cart_model->remove_from_cart($_POST);

            //Fetching cart items to send the details to api after the item is removed
            $cart_total_response = get_cart_total($_POST['user_id']);
            $this->response['error'] = false;
            $this->response['message'] = 'Removed From Cart !';
            if (!empty($cart_total_response) && isset($cart_total_response)) {
                $this->response['data'] = [
                    'total_quantity' => strval($cart_total_response['quantity']),
                    'sub_total' => strval($cart_total_response['sub_total']),
                    'total_items' => (isset($cart_total_response[0]['total_items'])) ? strval($cart_total_response[0]['total_items']) : "0",
                    'max_items_cart' => $settings['max_items_cart']
                ];
            } else {
                $this->response['data'] = [];
            }

            print_r(json_encode($this->response));
            return;
        }
    }

    public function get_delivery_charges()
    {
        /*
            user_id:1
            address_id:1
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|xss_clean|required|numeric');
        $this->form_validation->set_rules('address_id', 'Address Id', 'trim|xss_clean|required|numeric');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $user_id = $this->input->post('user_id', true);
            $address_id = $this->input->post('address_id', true);

            $result = get_delivery_charge($address_id, $user_id);
            if (isset($result) && !empty($result)) {
                $this->response['error'] = $result['error'];
                $this->response['message'] = $result['message'];
                $this->response['delivery_charge'] = strval($result['charge']);
                $this->response['distance'] = $result['distance'];
                $this->response['duration'] = $result['duration'];
                print_r(json_encode($this->response));
                return false;
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Somthing went wrong. Please try again later.';
                $this->response['delivery_charge'] = "0";
                $this->response['distance'] = "0";
                $this->response['duration'] = "0";
                print_r(json_encode($this->response));
                return false;
            }
        }
    }

    public function search_places()
    {
        /*
            input:string     {user typed input}
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->load->library(['google_maps']);
        $this->form_validation->set_rules('input', 'Input', 'trim|xss_clean|required');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $input = $this->input->post('input', true);
            $result = $this->google_maps->search_places($input);

            if (isset($result['http_code']) && $result['http_code'] != "200") {
                $this->response['error'] = true;
                $this->response['message'] = 'The provided API key is invalid.';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
            if (isset($result['body']) && !empty($result['body'])) {
                if (isset($result['body']['status']) && $result['body']['status'] == "REQUEST_DENIED") {
                    /* The request is missing an API key */
                    $this->response['error'] = true;
                    $this->response['message'] = 'The provided API key is invalid.';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                } else if (isset($result['body']['status']) && $result['body']['status'] == "OK") {
                    // indicating the API request was successful
                    $this->response['error'] = false;
                    $this->response['message'] = 'Data fetched successfully.';
                    $this->response['data'] = (isset($result['body']['candidates']) && !empty($result['body']['candidates'])) ? $result['body']['candidates'] : [];
                    print_r(json_encode($this->response));
                    return false;
                } else if (isset($result['body']['status']) && $result['body']['status'] == "OVER_QUERY_LIMIT") {
                    // You have exceeded the QPS limits. Billing has not been enabled on your account
                    $this->response['error'] = true;
                    $this->response['message'] = 'You have exceeded the QPS limits or billing not enabled may be.';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                } else if (isset($result['body']['status']) && $result['body']['status'] == "INVALID_REQUEST") {
                    // indicating the API request was malformed, generally due to the missing input parameter
                    $this->response['error'] = true;
                    $this->response['message'] = 'Indicating the API request was malformed.';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                } else if (isset($result['body']['status']) && $result['body']['status'] == "UNKNOWN_ERROR") {
                    // indicating an unknown error
                    $this->response['error'] = true;
                    $this->response['message'] = 'An unknown error occure.';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                } else if (isset($result['body']['status']) && $result['body']['status'] == "ZERO_RESULTS") {
                    // indicating that the search was successful but returned no results. This may occur if the search was passed a bounds in a remote location.
                    $this->response['error'] = true;
                    $this->response['message'] = 'Data not found or invalid.Please check!';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = 'Something went wrong.';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
            }
        }
    }

    public function get_live_tracking_details()
    {
        /*
            order_id:1
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('order_id', 'order_id', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return;
        } else {
            $order_id = $this->input->post('order_id', true);
            $data = fetch_details(['order_id' => $order_id],'live_tracking',"*","","",'id',"desc");
            if(!empty($data)){
                $this->response['error'] = false;
                $this->response['message'] = "Live Tracking Detail fetched succesfully.";
                $this->response['data'] = $data;
                print_r(json_encode($this->response));
                return false;
            }else{
                $this->response['error'] = true;
                $this->response['message'] = "Live Tracking Not available.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
        }
    }
    public function test()
    {
        $result = find_google_map_distance(23.24114205388701, 69.66720847135304, 23.235700208395272, 69.7287490771754);
        print_r(json_encode($result));
    }
}
