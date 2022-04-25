<?php
defined('BASEPATH') or exit('No direct script access allowed');
class Api extends CI_Controller
{

    /*
---------------------------------------------------------------------------
Defined Methods:-
---------------------------------------------------------------------------
1. login
2. get_rider_details
3. get_orders
4. get_fund_transfers
5. update_user
6. update_fcm
7. reset_password
8. verify_user
9. get_settings
10. send_withdrawal_request
11. get_withdrawal_request
12. update_order_status
13. get_pending_orders
14. update_order_request
15. get_rider_cash_collection
16. manage_live_tracking
17. delete_live_tracking
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
        $this->load->model(['category_model', 'order_model', 'rating_model', 'cart_model', 'address_model', 'transaction_model', 'notification_model', 'Rider_model', 'Order_model']);
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
        $this->output->set_output(file_get_contents(base_url('rider-api-doc.txt')));
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
            fcm_id: FCM_ID //{ optional }
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
            $data = fetch_details(['mobile' => $this->input->post('mobile', true)], 'users');
            if ($this->ion_auth->in_group('rider', $data[0]['id'])) {
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
                $response['error'] = true;
                $response['message'] = strip_tags($this->ion_auth->errors());
                echo json_encode($response);
                return false;
            }
        } else {
            // if the login was un-successful
            $response['error'] = true;
            $response['message'] = strip_tags($this->ion_auth->errors());
            echo json_encode($response);
            return false;
        }
    }

    public function get_rider_details()
    {
        /* Parameters to be passed
            id:28
        */
        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('id', 'Id', 'trim|required|numeric|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
            return false;
        }
        $data = fetch_details(['id' => $this->input->post('id', true)], 'users');
        if (isset($data) && !empty($data)) {

            $data[0]['balance'] =  $data[0]['balance'] == null || $data[0]['balance'] == 0 || empty($data[0]['balance']) ? "0" : $data[0]['balance'];
            $data[0]['bonus'] =  $data[0]['bonus'] == null || $data[0]['bonus'] == 0 || empty($data[0]['bonus']) ? "0" : $data[0]['bonus'];
            unset($data[0]['password']);

            if (empty($data[0]['image']) || file_exists(FCPATH . USER_IMG_PATH . $data[0]['image']) == FALSE) {
                $data[0]['image'] = base_url() . NO_IMAGE;
            } else {
                $data[0]['image'] = base_url() . USER_IMG_PATH . $data[0]['image'];
            }
            $data = array_map(function ($value) {
                return $value === NULL ? "" : $value;
            }, $data[0]);

            $response['error'] = false;
            $response['message'] = 'Data retrived successfully';
            $response['data'] = $data;
            print_r(json_encode($response));
            return false;
        } else {
            $response['error'] = true;
            $response['message'] = 'Data does not exist for this id';
            $response['data'] = array();
            print_r(json_encode($response));
            return false;
        }
    }

    /* 11.get_orders

        user_id:101
        active_status: confirmed  {confirmed,preparing,out_for_delivery,delivered,cancelled}      // optional
        limit:25            // { default - 25 } optional
        offset:0            // { default - 0 } optional
        sort: id / date_added // { default - id } optional
        order:DESC/ASC      // { default - DESC } optional
    */

    public function get_orders()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
        $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
        $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'o.id';
        $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('active_status', 'status', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_id = $this->input->post('user_id', true);

            $multiple_status =   (isset($_POST['active_status']) && !empty($_POST['active_status'])) ? explode(',', $_POST['active_status']) : false;
            $download_invoice =   (isset($_POST['download_invoice']) && !empty($_POST['download_invoice'])) ? $_POST['download_invoice'] : 1;
            $order_details = fetch_orders(false, false, $multiple_status, $user_id, $limit, $offset, $sort, $order, $download_invoice);
            if (!empty($order_details['order_data'])) {
                $this->response['error'] = false;
                $this->response['message'] = 'Data retrieved successfully';
                $this->response['total'] = $order_details['total'];
                $this->response['data'] = $order_details['order_data'];
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Order Does Not Exists';
                $this->response['total'] = "0";
                $this->response['data'] = array();
            }
        }
        print_r(json_encode($this->response));
    }

    /* 3.get_fund_transfers

        user_id:101
        limit:25            // { default - 25 } optional
        offset:0            // { default - 0 } optional
        sort: id / date_added // { default - id } optional
        order:DESC/ASC      // { default - DESC } optional

    */

    public function get_fund_transfers()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
        $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
        $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'id';
        $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';

        $this->form_validation->set_rules('user_id', 'User ID', 'trim|numeric|required|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_id = $this->input->post('user_id', true);

            $where = ['rider_id' => $user_id];
            $this->db->select('count(`id`) as total');
            $total_fund_transfers = $this->db->where($where)->get('fund_transfers')->result_array();

            $this->db->select('*');
            $this->db->order_by($sort, $order);
            $this->db->limit($limit, $offset);
            $fund_transfer_details = $this->db->where($where)->get('fund_transfers')->result_array();
            if (!empty($fund_transfer_details)) {

                $this->response['error'] = false;
                $this->response['message'] = 'Data retrieved successfully';
                $this->response['total'] = $total_fund_transfers[0]['total'];
                $this->response['data'] = $fund_transfer_details;
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'No fund transfer has been made yet';
                $this->response['total'] = "0";
                $this->response['data'] = array();
            }
        }
        print_r(json_encode($this->response));
    }

    public function update_user()
    {
        /*
            user_id:34
            username:hiten
            mobile:7852347890                {optional}
            email:amangoswami@gmail.com	     {optional}
            address:address	                 {optional}
            old:12345
            new:345234
            status:1 or 0                    {optional}{Default:1}
        */
        if (!$this->verify_token()) {
            return false;
        }

        $identity_column = $this->config->item('identity', 'ion_auth');

        $this->form_validation->set_rules('email', 'Email', 'xss_clean|trim|valid_email|edit_unique[users.id.' . $this->input->post('user_id', true) . ']');
        $this->form_validation->set_rules('mobile', 'Mobile', 'xss_clean|trim|numeric|edit_unique[users.id.' . $this->input->post('user_id', true) . ']');

        $this->form_validation->set_rules('user_id', 'Id', 'required|xss_clean|numeric|trim');
        $this->form_validation->set_rules('username', 'Username', 'xss_clean|trim');
        $this->form_validation->set_rules('status', 'Status', 'xss_clean|trim|numeric');

        if (!empty($_POST['old']) || !empty($_POST['new'])) {
            $this->form_validation->set_rules('old', $this->lang->line('change_password_validation_old_password_label'), 'required');
            $this->form_validation->set_rules('new', $this->lang->line('change_password_validation_new_password_label'), 'required|min_length[' . $this->config->item('min_password_length', 'ion_auth') . ']');
        }


        $tables = $this->config->item('tables', 'ion_auth');
        if (!$this->form_validation->run()) {
            if (validation_errors()) {
                $response['error'] = true;
                $response['message'] = strip_tags(validation_errors());
                echo json_encode($response);
                return false;
                exit();
            }
        } else {
            if (!empty($_POST['old']) || !empty($_POST['new'])) {
                $identity = ($identity_column == 'mobile') ? 'mobile' : 'email';
                $res = fetch_details(['id' => $_POST['user_id']], 'users', '*');
                if (!empty($res) && $this->ion_auth->in_group('rider', $res[0]['id'])) {
                    if (!$this->ion_auth->change_password($res[0][$identity], $this->input->post('old'), $this->input->post('new'))) {
                        // if the login was un-successful
                        $response['error'] = true;
                        $response['message'] = strip_tags($this->ion_auth->errors());
                        echo json_encode($response);
                        return;
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = 'User does not exists';
                    echo json_encode($response);
                    return;
                }
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
            if (isset($_POST['address']) && !empty($_POST['address'])) {
                $set['address'] = $this->input->post('address', true);
            }
            if (isset($_POST['status']) && !empty($_POST['status'])) {
                $set['active'] = $this->input->post('status', true);
            } else {
                $set['active'] = 1;
            }
            $set = escape_array($set);
            $this->db->set($set)->where('id', $_POST['user_id'])->update($tables['login_users']);
            $response['error'] = false;
            $response['message'] = 'Profile Update Succesfully';
            echo json_encode($response);
            return;
        }
    }
    // 6. update_fcm
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

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return false;
        }

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
    // 7. reset_password
    public function reset_password()
    {
        /* Parameters to be passed
            mobile_no:7894561235            
            new: pass@123
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('mobile_no', 'Mobile No', 'trim|numeric|required|xss_clean|min_length[10]');
        $this->form_validation->set_rules('new', 'New Password', 'trim|required|min_length[' . $this->config->item('min_password_length', 'ion_auth') . ']|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return false;
        }

        $identity_column = $this->config->item('identity', 'ion_auth');
        $res = fetch_details(['mobile' => $_POST['mobile_no']], 'users');
        if (!empty($res) && $this->ion_auth->in_group('rider', $res[0]['id'])) {
            $identity = ($identity_column  == 'email') ? $res[0]['email'] : $res[0]['mobile'];
            if (!$this->ion_auth->reset_password($identity, $_POST['new'])) {
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
            $response['error'] = false;
            $response['message'] = 'User does not exists !';
            $response['data'] = array();
            echo json_encode($response);
            return false;
        }
    }

    //9. verify-user
    public function verify_user()
    {
        /* Parameters to be passed
            mobile: 9874565478
            email: test@gmail.com // { optional }
        */
        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('mobile', 'Mobile', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('email', 'Email', 'trim|xss_clean|valid_email');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return;
        } else {
            if (isset($_POST['mobile']) && is_exist(['mobile' => $_POST['mobile']], 'users')) {
                $user_id = fetch_details(['mobile' => $_POST['mobile']], 'users', 'id');

                //Check if this mobile no. is registered as a Rider or not.
                if (!$this->ion_auth->in_group('rider', $user_id[0]['id'])) {
                    $this->response['error'] = true;
                    $this->response['message'] = 'Mobile number / email could not be found!';
                    print_r(json_encode($this->response));
                    return;
                } else {
                    $this->response['error'] = false;
                    $this->response['message'] = 'Mobile number is registered. ';
                    print_r(json_encode($this->response));
                    return;
                }
            }
            if (isset($_POST['email']) && is_exist(['email' => $_POST['email']], 'users')) {
                $this->response['error'] = false;
                $this->response['message'] = 'Email is registered.';
                print_r(json_encode($this->response));
                return;
            }

            $this->response['error'] = true;
            $this->response['message'] = 'Mobile number / email could not be found!';
            print_r(json_encode($this->response));
            return;
        }
    }
    //10. get_settings
    public function get_settings()
    {
        /* 
            type : rider_privacy_policy / rider_terms_conditions
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('type', 'Setting Type', 'trim|required|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
        } else {
            $allowed_settings = array('rider_terms_conditions', 'rider_privacy_policy', 'currency');
            $type = $_POST['type'];
            $settings_res = get_settings($type);

            if (!in_array($type, $allowed_settings)) {
                $this->response['error'] = false;
                $this->response['message'] = 'Currency';
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
                exit();
            }

            if (!empty($settings_res)) {

                $this->response['error'] = false;
                $this->response['message'] = 'Settings retrieved successfully';
                $this->response['data'] = $settings_res;
                $this->response['currency'] = get_settings('currency');
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Settings Not Found';
                $this->response['data'] = array();
            }
            print_r(json_encode($this->response));
        }
    }

    //11.send_withdrawal_request
    public function send_withdrawal_request()
    {
        /* 
            user_id:15
            payment_address: 12343535
            amount: 560           
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('payment_address', 'Payment Address', 'trim|required|xss_clean');
        $this->form_validation->set_rules('amount', 'Amount', 'trim|required|xss_clean|numeric|greater_than[0]');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
        } else {
            $user_id = $this->input->post('user_id', true);
            $amount = $this->input->post('amount', true);
            $payment_address = $this->input->post('payment_address', true);
            $amount = $this->input->post('amount', true);
            $userData = fetch_details(['id' => $user_id], 'users', 'balance');

            if (!empty($userData)) {

                if ($amount <= $userData[0]['balance']) {

                    $data = [
                        'user_id' => $user_id,
                        'payment_address' => $payment_address,
                        'payment_type' => 'rider',
                        'amount_requested' => $amount,
                    ];

                    if (insert_details($data, 'payment_requests')) {
                        $this->Rider_model->update_balance($amount, $user_id, 'deduct');
                        $userData = fetch_details(['id' => $_POST['user_id']], 'users', 'balance');
                        $this->response['error'] = false;
                        $this->response['message'] = 'Withdrawal Request Sent Successfully';
                        $this->response['data'] = $userData[0]['balance'];
                    } else {
                        $this->response['error'] = true;
                        $this->response['message'] = 'Cannot sent Withdrawal Request.Please Try again later.';
                        $this->response['data'] = array();
                    }
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = 'You don\'t have enough balance to sent the withdraw request.';
                    $this->response['data'] = array();
                }

                print_r(json_encode($this->response));
            }
        }
    }

    //13.get_withdrawal_request
    public function get_withdrawal_request()
    {
        /* 
            user_id:15
            limit:10
            offset:10
        */

        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('limit', 'Limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'Offset', 'trim|numeric|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
        } else {

            $limit = ($this->input->post('limit', true)) ? $this->input->post('limit', true) : null;
            $offset = ($this->input->post('offset', true)) ? $this->input->post('offset', true) : null;
            $userData = fetch_details(['user_id' => $_POST['user_id']], 'payment_requests', '*', $limit, $offset);
            $this->response['error'] = false;
            $this->response['message'] = 'Withdrawal Request Retrieved Successfully';
            $this->response['total'] = strval(count($userData));
            $this->response['data'] = $userData;
            print_r(json_encode($this->response));
        }
    }

    /* to update the status of order */
    public function update_order_status()
    {
        /* 
            rider_id:12
            order_id: 137
            status: confirmed                 {confirmed|preparing|out_for_delivery|delivered|cancelled}  
            otp:value      //{required when status is delivered}
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('order_id', 'Order Id', 'numeric|trim|required|xss_clean');
        $this->form_validation->set_rules('rider_id', 'Rider Id', 'numeric|trim|required|xss_clean');
        if (isset($_POST['status']) && !empty($_POST['status']) && ($_POST['status'] == "delivered" || $_POST['status'] == "cancelled")) {
            $this->form_validation->set_rules('otp', 'OTP', 'numeric|required|trim|xss_clean');
        }
        $this->form_validation->set_rules('status', 'Status', 'trim|required|xss_clean|in_list[preparing,out_for_delivery,delivered,cancelled]');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
        } else {
            $msg = '';
            $order_id = $this->input->post('order_id', true);
            $rider_id = $this->input->post('rider_id', true);
            $otp = (isset($_POST['otp']) && !empty($_POST['otp'])) ? $this->input->post('otp', true) : "0";
            $val = $this->input->post('status', true);
            $field = "status";

            $res = validate_order_status($order_id, $val, 'orders', $rider_id);
            if ($res['error']) {
                $this->response['error'] = true;
                $this->response['message'] = $msg . $res['message'];
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
            if ($val == 'delivered' || $val == 'cancelled') {
                if (isset($otp) && !empty($otp) && $otp != "") {
                    if (!validate_otp($order_id, $otp)) {
                        $this->response['error'] = true;
                        $this->response['message'] = 'Invalid OTP supplied!';
                        $this->response['data'] = array();
                        print_r(json_encode($this->response));
                        return false;
                    }
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = 'Apply OTP!';
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
            }

            $priority_status = [
                'pending' => 0,
                'confirmed' => 1,
                'preparing' => 2,
                'out_for_delivery' => 3,
                'delivered' => 4,
                'cancelled' => 5,
            ];

            $error = TRUE;
            $message = '';

            $where_id = "id = " . $order_id . " and (active_status != 'cancelled' ) ";

            if (isset($order_id) && isset($field) && isset($val)) {
                if ($field == 'status') {
                    $current_orders_status = fetch_details($where_id, 'orders', 'user_id,active_status');
                    $user_id = $current_orders_status[0]['user_id'];
                    $current_orders_status = $current_orders_status[0]['active_status'];

                    if ($priority_status[$val] > $priority_status[$current_orders_status]) {
                        $set = [
                            $field => $val // status => 'proceesed'
                        ];

                        /* Update Active Status of Order Table */
                        if ($this->Order_model->update_order($set, $where_id, true)) {
                            if ($this->Order_model->update_order(['active_status' => $val], $where_id)) {
                                $error = false;
                            }
                        }

                        if ($error == false) {
                            /* Send notification */
                            $title = 'Order status updated';
                            $body =  ' Order status updated to ' . $val . ' for your order ID #' . $order_id . ' please take note of it! Thank you for ordering with us.';
                            send_notifications($user_id, "user", $title, $body, "order", $order_id);

                            /* Process refund when order cancel */
                            process_refund($order_id, $val, 'orders');
                            if (trim($val) == 'cancelled') {
                                $data = fetch_details(['order_id' => $order_id], 'order_items', 'product_variant_id,quantity');
                                $product_variant_ids = $qtns = [];
                                foreach ($data as $d) {
                                    array_push($product_variant_ids, $d['product_variant_id']);
                                    array_push($qtns, $d['quantity']);
                                }
                                update_stock($product_variant_ids, $qtns, 'plus');
                            }

                            /* Process refer and earn bonus */
                            $response = process_referral_bonus($user_id, $order_id, $val);
                            $message = 'Status Updated Successfully';
                        }
                    }
                }
                if ($error == true) {
                    $message = $msg . ' Status Updation Failed';
                }
            }
            $response['error'] = $error;
            $response['message'] = $message;
            print_r(json_encode($response));
        }
    }

    /* 11.get_pending_orders

        user_id:101           // {rider_id}
        limit:25            // { default - 25 } optional
        offset:0            // { default - 0 } optional
        sort: id / date_added // { default - id } optional
        order:DESC/ASC      // { default - DESC } optional

    */

    public function get_pending_orders()
    {
        if (!$this->verify_token()) {
            return false;
        }

        $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 25;
        $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
        $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'o.id';
        $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';

        $this->form_validation->set_rules('user_id', 'User Id', 'trim|numeric|required|xss_clean');
        $this->form_validation->set_rules('active_status', 'status', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
        } else {
            $user_id = $this->input->post('user_id', true);
            $city_id = fetch_details(['id' => $user_id], "users", 'serviceable_city');

            $multiple_status =   (isset($_POST['active_status']) && !empty($_POST['active_status'])) ? explode(',', $_POST['active_status']) : false;
            $download_invoice =   (isset($_POST['download_invoice']) && !empty($_POST['download_invoice'])) ? $_POST['download_invoice'] : 1;
            $order_details = fetch_orders(false, false, $multiple_status, null, $limit, $offset, $sort, $order, $download_invoice, null, null, null, null, null, null, true, $city_id[0]['serviceable_city']);

            if (!empty($order_details)) {
                $this->response['error'] = false;
                $this->response['message'] = 'Data retrieved successfully';
                $this->response['total'] = $order_details['total'];
                $this->response['data'] = $order_details['order_data'];
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Order Does Not Exists';
                $this->response['total'] = "0";
                $this->response['data'] = array();
            }
        }
        print_r(json_encode($this->response));
    }

    public function update_order_request()
    {
        /* 
            rider_id:12
            order_id: 137
            accept_order:1     {1: accept_order | 0: reject order}
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('order_id', 'Order Id', 'numeric|trim|required|xss_clean');
        $this->form_validation->set_rules('rider_id', 'Rider Id', 'numeric|trim|required|xss_clean');
        $this->form_validation->set_rules('accept_order', 'Accept Order', 'numeric|required|trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
        } else {
            $order_id = $this->input->post('order_id', true);
            $rider_id = $this->input->post('rider_id', true);
            $accept_order = $this->input->post('accept_order', true);

            if ($accept_order == "1") {
                // if (!has_rider_one_order($rider_id, $order_id)) {
                //     $this->response['error'] = true;
                //     $this->response['message'] = "You already have one order.";
                //     print_r(json_encode($this->response));
                //     return false;
                // }
                $result = update_rider($rider_id, $order_id);
                if ($result['error']) {
                    $this->response['error'] = true;
                    $this->response['message'] = $result['message'];
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                } else {
                    // delete record from pending list
                    if (is_exist(['order_id' => $order_id], "pending_orders")) {
                        delete_details(['order_id' => $order_id], "pending_orders");
                    }

                    $this->response['error'] = false;
                    $this->response['message'] = $result['message'];
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
            } else {
                if (update_details(['rider_id' => NULL], ['id' => $order_id], "orders")) {
                    if (!is_exist(['order_id' => $order_id], "pending_orders")) {
                        $orders = fetch_details(['id' => $order_id],"orders","city_id");
                        $pending_orders = ['order_id' => $order_id, "city_id" => $orders[0]['city_id']];
                        insert_details($pending_orders, "pending_orders");
                    }
                    $this->response['error'] = false;
                    $this->response['message'] = "Order rejected.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = "Something went Wrong. Try again later.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
            }
        }
    }

    public function get_rider_cash_collection()
    {
        /* 
        rider_id:15  
        status:             // {rider_cash (rider collected) | rider_cash_collection (admin collected)}
        limit:25            // { default - 25 } optional
        offset:0            // { default - 0 } optional
        sort:               // { id } optional
        order:DESC/ASC      // { default - DESC } optional
        search:value        // {optional} 
        */
        if (!$this->verify_token()) {
            return false;
        }

        $this->form_validation->set_rules('rider_id', 'Rider', 'trim|numeric|xss_clean|required');
        $this->form_validation->set_rules('limit', 'limit', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('offset', 'offset', 'trim|numeric|xss_clean');
        $this->form_validation->set_rules('sort', 'sort', 'trim|xss_clean');
        $this->form_validation->set_rules('order', 'order', 'trim|xss_clean');
        $this->form_validation->set_rules('search', 'search', 'trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
        } else {
            $order_data = [];
            $filters['rider_id'] = (isset($_POST['rider_id']) && is_numeric($_POST['rider_id']) && !empty(trim($_POST['rider_id']))) ? $this->input->post('rider_id', true) : '';
            $filters['status'] = (isset($_POST['status']) && !empty(trim($_POST['status']))) ? $this->input->post('status', true) : '';
            $limit = (isset($_POST['limit']) && is_numeric($_POST['limit']) && !empty(trim($_POST['limit']))) ? $this->input->post('limit', true) : 10;
            $offset = (isset($_POST['offset']) && is_numeric($_POST['offset']) && !empty(trim($_POST['offset']))) ? $this->input->post('offset', true) : 0;
            $sort = (isset($_POST['sort']) && !empty(trim($_POST['sort']))) ? $this->input->post('sort', true) : 'transactions.id';
            $order = (isset($_POST['order']) && !empty(trim($_POST['order']))) ? $this->input->post('order', true) : 'DESC';
            $search = (isset($_POST['search']) && !empty(trim($_POST['search']))) ? $this->input->post('search', true) : '';
            $tmpRow = $rows = array();
            $data = $this->Rider_model->get_rider_cash_collection($limit, $offset, $sort, $order, $search, (isset($filters)) ? $filters : null);
            if (isset($data['data']) && !empty($data['data'])) {
                foreach ($data['data'] as $row) {
                    $tmpRow['id'] = $row['id'];
                    $tmpRow['name'] = $row['name'];
                    $tmpRow['mobile'] = $row['mobile'];
                    $tmpRow['order_id'] = $row['order_id'];
                    $tmpRow['cash_received'] = $row['cash_received'];
                    $tmpRow['type'] = $row['type'];
                    $tmpRow['amount'] = $row['amount'];
                    $tmpRow['message'] = $row['message'];
                    $tmpRow['transaction_date'] = $row['transaction_date'];
                    $tmpRow['date'] = $row['date'];
                    if (isset($row['order_id']) && !empty($row['order_id']) && $row['order_id'] != "") {
                        $order_data = fetch_orders($row['order_id']);
                        $tmpRow['order_details'] = $order_data['order_data'];
                    } else {
                        $tmpRow['order_details'] = [];
                    }
                    $rows[] = $tmpRow;
                }
                if ($data['error'] == false) {
                    $data['data'] = $rows;
                } else {
                    $data['data'] = array();
                }
            }
            print_r(json_encode($data));
        }
    }

    public function manage_live_tracking()
    {
        /* 
            order_id: 137
            order_status:out_for_delivery
            latitude:12345678
            longitude:14654654
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('order_id', 'Order Id', 'numeric|trim|required|xss_clean');
        $this->form_validation->set_rules('order_status', 'Order Status', 'trim|required|xss_clean|in_list[preparing,out_for_delivery,delivered,cancelled]');
        $this->form_validation->set_rules('latitude', 'latitude', 'required|trim|xss_clean');
        $this->form_validation->set_rules('longitude', 'longitude', 'required|trim|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return;
        } else {
            $order_id = $this->input->post('order_id', true);
            $order_status = $this->input->post('order_status', true);

            // order delete validation
            if (!is_exist(['id' => $order_id], "orders")) {
                $this->response['error'] = true;
                $this->response['message'] = "Order does not exist.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }

            // order status validation
            if (is_exist(['id' => $order_id, "active_status" => 'cancelled'], "orders")) {
                $this->response['error'] = true;
                $this->response['message'] = "Order has been cancelled.Now You can not trace the order.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            if (is_exist(['id' => $order_id, "active_status" => 'preparing'], "orders")) {
                $this->response['error'] = true;
                $this->response['message'] = "Order is in preparing.Now You can not trace the order.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            if (is_exist(['id' => $order_id, "active_status" => 'pending'], "orders")) {
                $this->response['error'] = true;
                $this->response['message'] = "Order is in pending.Now You can not trace the order.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }

            $data = [
                'order_id' => $order_id,
                'order_status' => $order_status,
                'latitude' => $this->input->post('latitude', true),
                'longitude' => $this->input->post('longitude', true),
            ];
            if (is_exist(['order_id' => $order_id, "order_status" => $order_status], "live_tracking")) {
                // update details
                if (update_details($data, ['order_id' => $order_id], 'live_tracking')) {
                    $this->response['error'] = false;
                    $this->response['message'] = "Live Tracking Details Updated Successfully.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return;
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = "Not Updated.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return;
                }
            } else {
                // insert details
                if (insert_details($data, 'live_tracking')) {
                    $this->response['error'] = false;
                    $this->response['message'] = "Live Tracking Details Inserted Successfully.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return;
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = "Not Inserted.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return;
                }
            }
        }
    }

    public function delete_live_tracking()
    {
        /* 
            order_id: 137
        */

        if (!$this->verify_token()) {
            return false;
        }
        $this->form_validation->set_rules('order_id', 'Order Id', 'numeric|trim|required|xss_clean');

        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            print_r(json_encode($this->response));
            return;
        } else {
            $order_id = $this->input->post('order_id', true);

            // order delete validation
            if (!is_exist(['id' => $order_id], "orders")) {
                $this->response['error'] = true;
                $this->response['message'] = "Order does not exist.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
            if (is_exist(['order_id' => $order_id], "live_tracking")) {
                // update details
                if (delete_details(['order_id' => $order_id], 'live_tracking')) {
                    $this->response['error'] = false;
                    $this->response['message'] = "Live Tracking Details Deleted Successfully.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return;
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = "Not Deleted. Something went wrong. Try again later.";
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return;
                }
            } else {
                $this->response['error'] = true;
                $this->response['message'] = "Not Inserted before.";
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return;
            }
        }
    }
}
