<?php
defined('BASEPATH') or exit('No direct script access allowed');


class Orders extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'timezone_helper']);
        $this->load->model('Order_model');
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {
            $this->data['main_page'] = TABLES . 'manage-orders';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Manage Orders | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Manage Order  | ' . $settings['app_name'];
            $this->data['about_us'] = get_settings('about_us');
            $this->data['curreny'] = get_settings('currency');
            $this->load->view('rider/template', $this->data);
        } else {
            redirect('rider/login', 'refresh');
        }
    }

    public function view_pending_orders()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {
            $deliveryBoyId = $this->ion_auth->get_user_id();
            $city_id = fetch_details(['id' => $deliveryBoyId], "users", 'serviceable_city');
            return $this->Order_model->get_orders_list(null, true, $city_id[0]['serviceable_city']);
        } else {
            redirect('rider/login', 'refresh');
        }
    }
    public function view_orders()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {
            $deliveryBoyId = $this->ion_auth->get_user_id();
            return $this->Order_model->get_orders_list($deliveryBoyId);
        } else {
            redirect('rider/login', 'refresh');
        }
    }

    public function edit_orders()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {
            $rider = $this->ion_auth->user()->row();
            $this->data['main_page'] = FORMS . 'edit-orders';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'View Order | ' . $settings['app_name'];
            $this->data['meta_description'] = 'View Order | ' . $settings['app_name'];
            $res = $this->Order_model->get_order_details(['o.id' => $_GET['edit_id']]);

            $this->data['restro_data'] = fetch_details(['rd.user_id' => $res[0]['partner_id']], "partner_data rd", "rd.partner_name,rd.address,u.latitude as restro_lat,u.longitude as restro_lng",null,null,null,null,null,null,"users u","u.id=rd.user_id");
            $this->data['google_map_api_key'] = $settings['google_map_api_key'];

            if ($rider->id == $res[0]['rider_id'] && isset($_GET['edit_id']) && !empty($_GET['edit_id']) && !empty($res) && is_numeric($_GET['edit_id'])) {
                $items = [];
                foreach ($res as $row) {
                    if ($rider->id == $row['rider_id']) {
                        $temp['id'] = $row['order_item_id'];
                        $temp['add_ons'] = $row['add_ons'];
                        $temp['item_otp'] = $row['item_otp'];
                        $temp['product_id'] = $row['product_id'];
                        $temp['product_variant_id'] = $row['product_variant_id'];
                        $temp['product_type'] = $row['type'];
                        $temp['pname'] = $row['pname'];
                        $temp['vname'] = $row['variant_name'];
                        $temp['quantity'] = $row['quantity'];
                        $temp['is_cancelable'] = $row['is_cancelable'];
                        $temp['tax_amount'] = $row['tax_amount'];
                        $temp['discounted_price'] = $row['discounted_price'];
                        $temp['price'] = $row['price'];
                        $temp['row_price'] = $row['row_price'];
                        $temp['active_status'] = $row['active_status'];
                        $temp['product_image'] = $row['product_image'];
                        $temp['product_variants'] = get_variants_values_by_id($row['product_variant_id']);
                        array_push($items, $temp);
                    }
                }
                $this->data['order_detls'] = $res;
                $this->data['items'] = $items;
                $this->data['settings'] = get_settings('system_settings', true);
                $this->load->view('rider/template', $this->data);
            } else {
                redirect('rider/orders/', 'refresh');
            }
        } else {
            redirect('rider/login', 'refresh');
        }
    }

    /* To update the status of particular order item */
    public function update_order_status()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {
            $this->form_validation->set_rules('order_id', 'Order Id', 'numeric|trim|required|xss_clean');
            if (isset($_POST['status']) && !empty($_POST['status']) && $_POST['status'] == "delivered") {
                $this->form_validation->set_rules('otp', 'OTP', 'numeric|required|trim|xss_clean');
            }
            $this->form_validation->set_rules('status', 'Status', 'trim|required|xss_clean|in_list[preparing,out_for_delivery,delivered,cancelled]');

            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {

                $msg = '';
                $order_id = $this->input->post('order_id', true);
                $rider_id = $this->ion_auth->user()->row();
                $otp = (isset($_POST['otp']) && !empty($_POST['otp'])) ? $this->input->post('otp', true) : "0";
                $val = $this->input->post('status', true);
                $field = "status";

                $res = validate_order_status($order_id, $val, 'orders', $rider_id);
                if ($res['error']) {
                    $this->response['error'] = true;
                    $this->response['message'] = $msg . $res['message'];
                    $this->response['data'] = array();
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    print_r(json_encode($this->response));
                    return false;
                }
                if ($val == 'delivered') {
                    if (isset($otp) && !empty($otp) && $otp != "") {
                        if (!validate_otp($order_id, $otp)) {
                            $this->response['error'] = true;
                            $this->response['message'] = 'Invalid OTP supplied!';
                            $this->response['data'] = array();
                            $this->response['csrfName'] = $this->security->get_csrf_token_name();
                            $this->response['csrfHash'] = $this->security->get_csrf_hash();
                            print_r(json_encode($this->response));
                            return false;
                        }
                    } else {
                        $this->response['error'] = true;
                        $this->response['message'] = 'Apply OTP!';
                        $this->response['data'] = array();
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
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
                                send_notifications($user_id, "user", $title, $body, "order",$order_id);

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
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                print_r(json_encode($response));
            }
        } else {
            redirect('rider/login', 'refresh');
        }
    }
    public function update_order_request()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {

            if (!isset($_GET['order_id']) || empty($_GET['order_id']) || !isset($_GET['req_status']) || $_GET['req_status'] == "") {
                $this->response['error'] = true;
                $this->response['message'] = "Order ID or Request Status params are required.";
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['data'] = array();
                print_r(json_encode($this->response));
                return false;
            }
            $rider_id = $this->ion_auth->get_user_id();
            $order_id = $this->input->get('order_id', true);
            $accept_order = $this->input->get('req_status', true);

            if ($accept_order == "1") {
                $result = update_rider($rider_id, $order_id);
                if ($result['error']) {
                    $this->response['error'] = true;
                    $this->response['message'] = $result['message'];
                    $this->response['data'] = array();
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
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
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    print_r(json_encode($this->response));
                    return false;
                }
            } else {
                if (update_details(['rider_id' => NULL], ['id' => $order_id, 'rider_id' => $rider_id], "orders")) {
                    $this->response['error'] = false;
                    $this->response['message'] = "Order rejected.";
                    $this->response['data'] = array();
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    print_r(json_encode($this->response));
                    return false;
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = "Something went Wrong. Try again later.";
                    $this->response['data'] = array();
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    print_r(json_encode($this->response));
                    return false;
                }
            }
        } else {
            redirect('rider/login', 'refresh');
        }
    }
}
