<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Home extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language']);
        $this->load->model(['Home_model', 'Order_model']);
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $user_id = $this->session->userdata('user_id');
            $user_res = $this->db->select('balance,username')->where('id', $user_id)->get('users')->result_array();
            $this->data['main_page'] = FORMS . 'home';
            $settings = get_settings('system_settings', true);
            $this->data['curreny'] = get_settings('currency');
            $this->data['title'] = 'Partner Panel | ' . $settings['app_name'];
            $this->data['order_counter'] = orders_count("", $user_id);
            $this->data['balance'] = ($user_res[0]['balance'] == NULL) ? 0 : $user_res[0]['balance'];
            $this->data['products'] = $this->Home_model->count_products($user_id);
            $this->data['username'] =  $user_res[0]['username'];
            $this->data['ratings'] =  fetch_details(['user_id' => $user_id], "partner_data", "rating,no_of_ratings");
            $this->data['meta_description'] = 'Partner Panel | ' . $settings['app_name'];
            $this->data['count_products_low_status'] = $this->Home_model->count_products_stock_low_status($user_id);
            $this->data['count_products_availability_status'] = $this->Home_model->count_products_availability_status($user_id);
            $orders_count['pending'] = orders_count("pending", $user_id);
            $orders_count['confirmed'] = orders_count("confirmed", $user_id);
            $orders_count['preparing'] = orders_count("preparing", $user_id);
            $orders_count['out_for_delivery'] = orders_count("out_for_delivery", $user_id);
            $orders_count['delivered'] = orders_count("delivered", $user_id);
            $orders_count['cancelled'] = orders_count("cancelled", $user_id);
            $this->data['status_counts'] = $orders_count;
            $this->data['user_id'] = $user_id;
            $this->load->view('partner/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function profile()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $identity_column = $this->config->item('identity', 'ion_auth');
            $settings = get_settings('system_settings', true);
            $user_id = $this->session->userdata('user_id');
            $this->data['identity_column'] = $identity_column;
            $this->data['main_page'] = FORMS . 'profile';
            $this->data['title'] = 'Partner Profile | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Partner Profile | ' . $settings['app_name'];
            $this->data['cities'] = fetch_details("", 'cities');
            $this->data['google_map_api_key'] = $settings['google_map_api_key'];
            $this->data['fetched_data'] = $this->db->select(' u.*,sd.* ')
                ->join('users_groups ug', ' ug.user_id = u.id ')
                ->join('partner_data sd', ' sd.user_id = u.id ')
                ->where(['ug.group_id' => '4', 'ug.user_id' => $user_id])
                ->get('users u')
                ->result_array();
            $this->data['tags'] = fetch_details(["rt.partner_id" => $user_id], "partner_tags rt", "rt.*,t.title", null, null, null, "DESC", "", '', "tags t", "t.id=rt.tag_id");
            $this->load->view('partner/template', $this->data);
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function update_status()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            if (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) {
                $this->response['error'] = true;
                $this->response['message'] = DEMO_VERSION_MSG;
                echo json_encode($this->response);
                return false;
                exit();
            }
            if ($_GET['status'] == '1') {
                $_GET['status'] = 0;
            } else if ($_GET['status'] == '0') {
                $_GET['status'] = 1;
            }
            $this->db->trans_start();
            if ($_GET['table'] == 'users') {
                $this->db->set('active', $this->db->escape($_GET['status']));
            } else {
                $this->db->set('status', $this->db->escape($_GET['status']));
            }

            $this->db->where('id', $_GET['id'])->update($_GET['table']);
            $this->db->trans_complete();
            $error = false;
            $message = str_replace('_', ' ', $_GET['table']);
            if ($this->db->trans_status() === true) {
                $error = true;
            }
            $response['error'] = $error;
            $response['csrfName'] = $this->security->get_csrf_token_name();
            $response['csrfHash'] = $this->security->get_csrf_hash();
            $response['message'] = $message;
            print_r(json_encode($response));
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function fetch_sales()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $user_id = $this->session->userdata('user_id');
            $sales[] = array();

            /* monthly earnings */
            $month_res = $this->db->select('SUM(sub_total) AS total_sale,DATE_FORMAT(date_added,"%b") AS month_name ')->where(['partner_id' => $user_id])
                ->group_by('year(CURDATE()),MONTH(date_added)')
                ->order_by('year(CURDATE()),MONTH(date_added)')
                ->get('`order_items`')->result_array();

            $month_wise_sales['total_sale'] = array_map('intval', array_column($month_res, 'total_sale'));
            $month_wise_sales['month_name'] = array_column($month_res, 'month_name');
            $sales[0] = $month_wise_sales;

            /* weekly earnings */
            $d = strtotime("today");
            $start_week = strtotime("last sunday midnight", $d);
            $end_week = strtotime("next saturday", $d);
            $start = date("Y-m-d", $start_week);
            $end = date("Y-m-d", $end_week);
            $week_res = $this->db->select("DATE_FORMAT(date_added, '%d-%b') as date, SUM(sub_total) as total_sale")
                ->where("date(date_added) >='$start' and date(date_added) <= '$end' ")->where(['partner_id' => $user_id])
                ->group_by('day(date_added)')->get('`order_items`')->result_array();

            $week_wise_sales['total_sale'] = array_map('intval', array_column($week_res, 'total_sale'));
            $week_wise_sales['week'] = array_column($week_res, 'date');

            $sales[1] = $week_wise_sales;

            /* daily earnings */
            $day_res = $this->db->select("DAY(date_added) as date, SUM(sub_total) as total_sale")
                ->where('date_added >= DATE_SUB(CURDATE(), INTERVAL 29 DAY)')->where(['partner_id' => $user_id])
                ->group_by('day(date_added)')->get('`order_items`')->result_array();
            $day_wise_sales['total_sale'] = array_map('intval', array_column($day_res, 'total_sale'));
            $day_wise_sales['day'] = array_column($day_res, 'date');

            $sales[2] = $day_wise_sales;
            print_r(json_encode($sales));
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function category_wise_product_count()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $user_id = $this->session->userdata('user_id');
            $res = $this->db->select('c.name as name,count(c.id) as counter')->where(['p.status' => '1', 'c.status' => '1', 'p.partner_id' => $user_id])->join('products p', 'p.category_id=c.id')->group_by('c.id')->get('categories c')->result_array();

            $result = array();
            $result[0][] = 'Task';
            $result[0][] = 'Hours per Day';
            array_walk($res, function ($v, $k) use (&$result) {
                $result[$k + 1][] = $v['name'];
                $result[$k + 1][] = intval($v['counter']);
            });
            echo json_encode(array_values($result));
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function logout()
    {
        $this->ion_auth->logout();
        redirect('partner/login', 'refresh');
    }
}
