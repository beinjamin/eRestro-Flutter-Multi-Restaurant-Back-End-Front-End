<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Home extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->helper(['url', 'language', 'function_helper', 'bootstrap_table_helper', 'file']);
        $this->load->model(['Home_model', 'Order_model']);
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'home';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Admin Panel | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Admin Panel | ' . $settings['app_name'];
            $this->data['curreny'] = get_settings('currency');
            $this->data['order_counter'] = $this->Home_model->count_new_orders();
            $this->data['user_counter'] = $this->Home_model->count_new_users();
            $this->data['rider_counter'] = $this->Home_model->count_riders();
            $this->data['partner_counter'] = $this->Home_model->count_partners();
            $this->data['count_products_low_status'] = $this->Home_model->count_products_stock_low_status();
            $this->data['count_products_availability_status'] = $this->Home_model->count_products_availability_status();
            $this->data['admin_total_earnings'] = $this->Home_model->total_earnings("admin");
            $this->data['total_earnings'] = $this->Home_model->total_earnings("overall");
            $this->data['partner_total_earnings'] = $this->Home_model->total_earnings("partner");
            $orders_count['pending'] = orders_count("pending");
            $orders_count['confirmed'] = orders_count("confirmed");
            $orders_count['preparing'] = orders_count("preparing");
            $orders_count['out_for_delivery'] = orders_count("out_for_delivery");
            $orders_count['delivered'] = orders_count("delivered");
            $orders_count['cancelled'] = orders_count("cancelled");
            $this->data['status_counts'] = $orders_count;
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function category_wise_product_sales()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $res = $this->db->select('c.name as category,count(oi.product_variant_id) as sales')
                ->join(' `product_variants` `pv` ', 'oi.`product_variant_id`=pv.`id`')
                ->join(' `products` p  ', ' pv.`product_id`=p.`id` ')
                ->join(' categories c ', ' p.category_id=c.id ')
                ->group_by('p.category_id')->get('`order_items` oi')->result_array();
            $response['category'] = array_column($res, 'category');
            $response['sales'] = array_column($res, 'sales');
            echo json_encode($response);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function fetch_sales()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $sales[] = array();

            /* fetch earnings monthly */
            $month_res = $this->db->select('SUM(final_total) AS total_sale,DATE_FORMAT(date_added,"%b") AS month_name ')
                ->where('active_status="delivered"')
                ->group_by('year(CURDATE()),MONTH(date_added)')
                ->order_by('year(CURDATE()),MONTH(date_added)')
                ->get('`orders`')->result_array();

            $month_wise_sales['total_sale'] = array_map('intval', array_column($month_res, 'total_sale'));
            $month_wise_sales['month_name'] = array_column($month_res, 'month_name');
            $sales[0] = $month_wise_sales;

            /* fetch earnings weekly */
            $d = strtotime("today");
            $start_week = strtotime("last sunday midnight", $d);
            $end_week = strtotime("next saturday", $d);
            $start = date("Y-m-d", $start_week);
            $end = date("Y-m-d", $end_week);
            $week_res = $this->db->select("DATE_FORMAT(date_added, '%d-%b') as date, SUM(final_total) as total_sale")
                ->where("date(date_added) >='$start' and date(date_added) <= '$end' and  active_status='delivered'")
                ->group_by('day(date_added)')->get('`orders`')->result_array();

            $week_wise_sales['total_sale'] = array_map('intval', array_column($week_res, 'total_sale'));
            $week_wise_sales['week'] = array_column($week_res, 'date');

            $sales[1] = $week_wise_sales;

            /* fetch earnings day wise */
            $day_res = $this->db->select("DAY(date_added) as date, SUM(final_total) as total_sale")
                ->where("date_added >= DATE_SUB(CURDATE(), INTERVAL 29 DAY) and  active_status='delivered'")
                ->group_by('day(date_added)')->get('`orders`')->result_array();
            $day_wise_sales['total_sale'] = array_map('intval', array_column($day_res, 'total_sale'));
            $day_wise_sales['day'] = array_column($day_res, 'date');

            $sales[2] = $day_wise_sales;
            print_r(json_encode($sales));
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function category_wise_product_count()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $res = $this->db->select('c.name as name,count(c.id) as counter')->where(['p.status' => '1', 'c.status' => '1'])->join('products p', 'p.category_id=c.id')->group_by('c.id')->get('categories c')->result_array();
            $result = array();
            $result[0][] = 'Task';
            $result[0][] = 'Hours per Day';
            array_walk($res, function ($v, $k) use (&$result) {
                $result[$k + 1][] = $v['name'];
                $result[$k + 1][] = intval($v['counter']);
            });
            echo json_encode(array_values($result));
        } else {
            redirect('admin/login', 'refresh');
        }
    }


    public function delete_image()
    {
        $this->response['is_deleted'] = delete_image($_POST['id'], $_POST['path'], $_POST['field'], $_POST['img_name'], $_POST['table_name'], $_POST['isjson']);
        $this->response['csrfName'] = $this->security->get_csrf_token_name();
        $this->response['csrfHash'] = $this->security->get_csrf_hash();
        print_r(json_encode($this->response));
    }
    public function logout()
    {
        $this->ion_auth->logout();
        redirect('admin/login', 'refresh');
    }

    public function profile()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $identity_column = $this->config->item('identity', 'ion_auth');
            $this->data['users'] = $this->ion_auth->user()->row();
            $settings = get_settings('system_settings', true);
            $this->data['identity_column'] = $identity_column;
            $this->data['main_page'] = FORMS . 'profile';
            $this->data['title'] = 'Change Password | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Change Password | ' . $settings['app_name'];
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/home', 'refresh');
        }
    }

    public function update_status()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) {
                $this->response['error'] = true;
                $this->response['message'] = DEMO_VERSION_MSG;
                echo json_encode($this->response);
                return false;
                exit();
            }
            if ($_GET['status'] == '1') {
                $_GET['status'] = 0;
            } else if ($_GET['status'] == '2') {
                $_GET['status'] = 1;
            } else {
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
            redirect('admin/login', 'refresh');
        }
    }
}
