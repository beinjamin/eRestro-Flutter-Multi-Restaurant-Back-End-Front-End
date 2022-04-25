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
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $this->data['main_page'] = TABLES . 'manage-orders';
            $user_id = $this->session->userdata('user_id');
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Manage Orders | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Manage Order  | ' . $settings['app_name'];
            $this->data['about_us'] = get_settings('about_us');
            $this->data['curreny'] = get_settings('currency');
            $this->data['user_id'] = $user_id;
            $this->load->view('partner/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function view_orders()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            return $this->Order_model->get_orders_list();
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function edit_orders()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {

            $this->data['main_page'] = FORMS . 'edit-orders';
            $settings = get_settings('system_settings', true);

            $this->data['title'] = 'View Order | ' . $settings['app_name'];
            $this->data['meta_description'] = 'View Order | ' . $settings['app_name'];
            $partner_id = $this->session->userdata('user_id');
            $res = $this->Order_model->get_order_details(['o.id' => $_GET['edit_id'],'oi.partner_id' => $partner_id]);
            $this->data['delivery_res'] = $this->db->select("u.id,u.username,(select COUNT(rider_id) from orders where rider_id=u.id and active_status NOT IN('cancelled','delivered')) as rider_orders")->where(['ug.group_id' => '3', 'u.active' => 1, 'u.serviceable_city' => $res[0]['user_city']])->join('users_groups ug', 'ug.user_id = u.id')->get('users u')->result_array();
            $this->data['restro_name'] = fetch_details(['user_id' => $res[0]['partner_id']], "partner_data", "partner_name");
            if (isset($_GET['edit_id']) && !empty($_GET['edit_id']) && !empty($res) && is_numeric($_GET['edit_id'])) {
                $items = [];
                foreach ($res as $row) {
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
                $this->data['order_detls'] = $res;
                $this->data['items'] = $items;
                $this->data['partner_id'] = $partner_id;
                $this->data['settings'] = $settings;
                $this->load->view('partner/template', $this->data);
            } else {
                redirect('partner/orders/', 'refresh');
            }
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    /* Update complete order status */
    public function update_orders()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $this->form_validation->set_rules('orderid', 'Order Id', 'numeric|trim|required|xss_clean');
            $this->form_validation->set_rules('deliver_by', 'Deliver By', 'numeric|trim|xss_clean');
            $this->form_validation->set_rules('val', 'Val', 'trim|required|xss_clean');
            $this->form_validation->set_rules('field', 'Field', 'trim|required|xss_clean');

            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                $msg = '';
                $order_id = $this->input->post('orderid', true);
                $deliver_by = (isset($_POST['deliver_by']) && !empty($_POST['deliver_by'])) ? $this->input->post('deliver_by', true) : "0";
                $val = $this->input->post('val', true);
                $field = $this->input->post('field', true);

                if (!has_rider_one_order($deliver_by, $order_id)) {
                    $this->response['error'] = true;
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['message'] = "Rider already have one order. Assign another Rider.";
                    print_r(json_encode($this->response));
                    return false;
                }

                if (isset($deliver_by) && !empty($deliver_by) && isset($order_id) && !empty($order_id)) {
                    $result = update_rider($deliver_by, $order_id, $val);
                    if ($result['error']) {
                        $this->response['error'] = true;
                        $this->response['message'] = $result['message'];
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['data'] = array();
                        print_r(json_encode($this->response));
                        return false;
                    } else{
                        $msg  = $result['message'];
                    }
                }
                $res = validate_order_status($order_id, $val, 'orders');
                if ($res['error']) {
                    $this->response['error'] = true;
                    $this->response['message'] = $msg . $res['message'];
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }

                $priority_status = [
                    'pending' => 0,
                    'confirmed' => 1,
                    'preparing' => 2,
                    'out_for_delivery' => 3,
                    'delivered' => 4,
                    'cancelled' => 5,
                ];

                $update_status = 1;
                $error = TRUE;
                $message = '';

                $where_id = "id = $order_id and (active_status != 'cancelled'  ) ";

                if (isset($order_id) && isset($field) && isset($val)) {
                    if ( $field == 'status' && $update_status == 1) {

                        $current_orders_status = fetch_details($where_id, 'orders', 'user_id,active_status');
                        $user_id = $current_orders_status[0]['user_id'];
                        $current_orders_status = $current_orders_status[0]['active_status'];

                        if ($priority_status[$val] > $priority_status[$current_orders_status]) {
                            $set = [
                                $field => $val // status => 'proceesed'
                            ];

                            // Update Active Status of Order Table										
                            if ($this->Order_model->update_order($set, $where_id, $_POST['json'])) {
                                if ($this->Order_model->update_order(['active_status' => $val], $where_id)) {
                                    $error = false;
                                }
                            }

                            if ($error == false) {
                                /* Send notification */
                                $title = 'Order status updated';
                                $body =  ' Order status updated to ' . $val . ' for your order ID #' . $order_id . ' please take note of it! Thank you for ordering with us.';
                                send_notifications($user_id, "user", $title, $body, "order",$order_id);

                                /* Process refer and earn bonus */
                                process_refund($order_id, $val, 'orders');
                                if (trim($val == 'cancelled')) {
                                    $data = fetch_details(['order_id' => $order_id], 'order_items', 'product_variant_id,quantity');
                                    $product_variant_ids = [];
                                    $qtns = [];
                                    foreach ($data as $d) {
                                        array_push($product_variant_ids, $d['product_variant_id']);
                                        array_push($qtns, $d['quantity']);
                                    }

                                    update_stock($product_variant_ids, $qtns, 'plus');
                                }
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
                $response['total_amount'] = (!empty($data) ? $data : '');
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                print_r(json_encode($response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
