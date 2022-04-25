<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Rider_model extends CI_Model
{

    public function __construct()
    {
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function update_rider($data)
    {
        $data = escape_array($data);
        $rider_data = [
            'username' => $data['name'],
            'email' => $data['email'],
            'mobile' => $data['mobile'],
            'address' => $data['address'],
            'commission_method' => $data['commission_method'],
            'commission' => $data['commission'],
            'serviceable_city' => $data['serviceable_city'],
            'active' => (isset($data['active']) && $data['active'] != "") ? $data['active'] : 1,
        ];
        $this->db->set($rider_data)->where('id', $data['edit_rider'])->update('users');
        return $this->db->last_query();
    }

    function get_riders_list()
    {
        $offset = 0;
        $limit = 10;
        $sort = 'u.id';
        $order = 'ASC';
        $multipleWhere = '';
        $where = ['ug.group_id' => '3'];

        if (isset($_GET['offset']))
            $offset = $_GET['offset'];
        if (isset($_GET['limit']))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($_GET['sort'] == 'id') {
                $sort = "u.id";
            } else {
                $sort = $_GET['sort'];
            }
        if (isset($_GET['order']))
            $order = $_GET['order'];

        if (isset($_GET['search']) and $_GET['search'] != '') {
            $search = $_GET['search'];
            $multipleWhere = ['u.`id`' => $search, 'u.`username`' => $search, 'u.`email`' => $search, 'u.`mobile`' => $search, 'u.`address`' => $search, 'u.`balance`' => $search];
        }

        $count_res = $this->db->select(' COUNT(u.id) as `total` ')->join('users_groups ug', ' ug.user_id = u.id ')->join("cities c","c.id=u.serviceable_city","left");

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $offer_count = $count_res->get('users u')->result_array();

        foreach ($offer_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' u.*,c.name as city_name ')->join('users_groups ug', ' ug.user_id = u.id ')->join("cities c","c.id=u.serviceable_city","left");
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $where['ug.group_id'] = '3';
            $search_res->where($where);
        }

        $offer_search_res = $search_res->order_by($sort, "asc")->limit($limit, $offset)->get('users u')->result_array();
        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($offer_search_res as $row) {
            $tempRow['commission'] = 0;
            $row = output_escaping($row);
            $operate = '<a href="javascript:void(0)" class="edit_btn btn btn-primary btn-xs mr-1 mb-1" title="Edit" data-id="' . $row['id'] . '" data-url="admin/riders/"><i class="fa fa-pen"></i></a>';
            $operate .= '<a  href="javascript:void(0)" class="btn btn-danger btn-xs mr-1 mb-1" title="Delete" id="delete-riders"  data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';
            $operate .= '<a href="javascript:void(0)" class=" fund_transfer btn btn-info btn-xs mr-1 mb-1" title="Fund Transfer" data-target="#fund_transfer_rider"   data-toggle="modal" data-id="' . $row['id'] . '" ><i class="fa fa-arrow-alt-circle-right"></i></a>';
            $operate .= " <a href='javascript:void(0)' data-id=" . $row['id'] . " data-toggle='modal' data-target='#rider-rating-modal' class='btn btn-success btn-xs mr-1 mb-1' title='View Ratings' ><i class='fa fa-star'></i></a>";

            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['username'];
            $tempRow['email'] = $row['email'];
            $tempRow['mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['mobile']) - 3) . substr($row['mobile'], -3) : $row['mobile'];
            if (isset($row['email']) && !empty($row['email']) && $row['email'] != "") {
                $tempRow['email'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['email']) - 3) . substr($row['email'], -3) : $row['email'];
            } else {
                $tempRow['email'] = "";
            }
            $tempRow['address'] = $row['address'];
            $tempRow['serviceable_city'] = $row['city_name'];
            $tempRow['city_id'] = $row['serviceable_city'];
            $tempRow['rating'] = '<input type="text" class="kv-fa rating-loading" value="' . $row['rating'] . '" data-size="xs" title="" readonly> <span> (' . $row['rating'] . '/' . $row['no_of_ratings'] . ') </span>';
            $tempRow['cash_received'] = $row['cash_received'];
            $tempRow['commission_method'] = ucwords(str_replace("_"," ",$row['commission_method']));
            if(isset($row['commission_method'] ) && !empty($row['commission_method']) &&  $row['commission_method'] == "fixed_commission_per_order"){
                $tempRow['commission'] = $row['commission']." ".get_settings('currency');
            }
            if(isset($row['commission_method'] ) && !empty($row['commission_method']) &&  $row['commission_method'] == "percentage_on_delivery_charges"){
                $tempRow['commission'] = $row['commission']." (%)";
            }
            $tempRow['balance'] =  $row['balance'] == null || $row['balance'] == 0 || empty($row['balance']) ? "0" : number_format($row['balance'], 2);
            $tempRow['date'] = $row['created_at'];
            $tempRow['active'] = $row['active'];
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }

    function update_balance($amount, $rider_id, $action)
    {
        /**
         * @param
         * action = deduct / add
         */

        if ($action == "add") {
            $this->db->set('balance', 'balance+' . $amount, FALSE);
        } elseif ($action == "deduct") {
            $this->db->set('balance', 'balance-' . $amount, FALSE);
        }
        return $this->db->where('id', $rider_id)->update('users');
    }
    public function get_riders($id, $search, $offset, $limit, $sort, $order)
    {
        $multipleWhere = '';
        $where['ug.group_id'] =  3;
        if (!empty($search)) {
            $multipleWhere = ['u.`id`' => $search, 'u.`username`' => $search, 'u.`email`' => $search, 'u.`mobile`' => $search, 'u.`address`' => $search, 'u.`balance`' => $search];
        }
        if (!empty($id)) {
            $where['u.id'] = $id;
        }

        $count_res = $this->db->select(' COUNT(u.id) as `total` ')->join('users_groups ug', ' ug.user_id = u.id ')->join("cities c","c.id=u.serviceable_city","left");

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $cat_count = $count_res->get('users u')->result_array();

        foreach ($cat_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' u.*,c.name as city_name ')->join('users_groups ug', ' ug.user_id = u.id ')->join("cities c","c.id=u.serviceable_city","left");
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $cat_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('users u')->result_array();
        $rows = array();
        $tempRow = array();
        $bulkData = array();
        $bulkData['error'] = (empty($cat_search_res)) ? true : false;
        $bulkData['message'] = (empty($cat_search_res)) ? 'Delivery(s) does not exist' : 'Riders retrieved successfully';
        $bulkData['total'] = (empty($cat_search_res)) ? 0 : $total;
        if (!empty($cat_search_res)) {
            foreach ($cat_search_res as $row) {
                $row = output_escaping($row);
                $tempRow['id'] = $row['id'];
                $tempRow['name'] = $row['username'];
                $tempRow['mobile'] = $row['mobile'];
                $tempRow['email'] = $row['email'];
                $tempRow['balance'] = $row['balance'];
                $tempRow['address'] = $row['address'];
                $tempRow['serviceable_city'] = $row['city_name'];
                $tempRow['city_id'] = $row['serviceable_city'];
                $tempRow['cash_received'] = $row['cash_received'];
                $tempRow['rating'] = $row['rating'];
                $tempRow['no_of_ratings'] = $row['no_of_ratings'];
                if (empty($row['image']) || file_exists(FCPATH . USER_IMG_PATH . $row['image']) == FALSE) {
                    $tempRow['image'] = base_url() . NO_IMAGE;
                } else {
                    $tempRow['image'] = base_url() . USER_IMG_PATH . $row['image'];
                }
               
                $tempRow['status'] = $row['active'];
                $tempRow['date'] = $row['created_at'];

                $rows[] = $tempRow;
            }
            $bulkData['data'] = $rows;
        } else {
            $bulkData['data'] = [];
        }
        print_r(json_encode($bulkData));
    }

    public function get_rider_cash_collection($limit = "", $offset = '', $sort = 'transactions.id', $order = 'DESC', $search = NULL, $filter = "")
    {

        $multipleWhere = '';

        if (isset($search) and $search != '') {
            $multipleWhere = ['`transactions.id`' => $search, '`transactions.amount`' => $search, '`transactions.date_created`' => $search, 'users.username' => $search, 'users.mobile' => $search, 'users.email' => $search, 'type' => $search, 'transactions.status' => $search];
        }

        if (isset($filter['status']) && !empty($filter['status'])) {
            $where = ['transactions.type' => $filter['status']];
        }
        if (isset($filter['rider_id']) && !empty($filter['rider_id'])) {
            $user_where = ['users.id' => $filter['rider_id']];
        }

        $count_res = $this->db->select(' COUNT(transactions.id) as `total` ')->join('users', ' transactions.user_id = users.id', 'left')->where('transactions.status = 1');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_Start();
            $count_res->or_like($multipleWhere);
            $this->db->group_End();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        if (isset($user_where) && !empty($user_where)) {
            $count_res->where($user_where);
        }

        $txn_count = $count_res->get('transactions')->result_array();

        foreach ($txn_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' transactions.*,users.username as name,users.mobile,users.cash_received');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_Start();
            $search_res->or_like($multipleWhere);
            $this->db->group_End();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }
        if (isset($user_where) && !empty($user_where)) {
            $search_res->where($user_where);
        }
        $search_res->join('users', ' transactions.user_id = users.id', 'left')->where('transactions.status = 1');
        $txn_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('transactions')->result_array();

        $bulkData = array();
        $bulkData = array();
        $bulkData['error'] = (empty($txn_search_res)) ? true : false;
        $bulkData['message'] = (empty($txn_search_res)) ? 'Cash collection does not exist' : 'Cash collection are retrieve successfully';
        $bulkData['total'] = (empty($txn_search_res)) ? 0 : $total;
        $rows = array();
        $tempRow = array();

        foreach ($txn_search_res as $row) {
            $row = output_escaping($row);
            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['name'];
            $tempRow['mobile'] = $row['mobile'];
            $tempRow['order_id'] = $row['order_id'];
            $tempRow['cash_received'] = $row['cash_received'];
            $tempRow['type'] = (isset($row['type']) && $row['type'] == "rider_cash") ? 'Received' : 'Collected';
            $tempRow['amount'] = $row['amount'];
            $tempRow['message'] = $row['message'];
            $tempRow['transaction_date'] = $row['transaction_date'];
            $tempRow['date'] = $row['date_created'];

            $rows[] = $tempRow;
        }
        $bulkData['data'] = $rows;
        return $bulkData;
    }

    function get_cash_collection_list($user_id = '')
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'ASC';
        $multipleWhere = '';
        $where = [];

        if (isset($_GET['filter_date']) && $_GET['filter_date'] != NULL)
            $where = ['DATE(transactions.transaction_date)' => $_GET['filter_date']];

        if (isset($_GET['offset']))
            $offset = $_GET['offset'];
        if (isset($_GET['limit']))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($_GET['sort'] == 'id') {
                $sort = "id";
            } else {
                $sort = $_GET['sort'];
            }
        if (isset($_GET['order']))
            $order = $_GET['order'];

        if (isset($_GET['search']) and $_GET['search'] != '') {
            $search = $_GET['search'];
            $multipleWhere = ['`transactions.id`' => $search, '`transactions.amount`' => $search, '`transactions.date_created`' => $search, 'users.username' => $search, 'users.mobile' => $search, 'users.email' => $search, 'type' => $search, 'transactions.status' => $search];
        }
        if (isset($_GET['filter_rider']) && !empty($_GET['filter_rider']) && $_GET['filter_rider'] != NULL) {
            $where = ['users.id' => $_GET['filter_rider']];
        }
        if (isset($_GET['filter_status']) && !empty($_GET['filter_status'])) {
            $where = ['transactions.type' => $_GET['filter_status']];
        }
        if (!empty($user_id)) {
            $user_where = ['users.id' => $user_id];
        }



        $count_res = $this->db->select(' COUNT(transactions.id) as `total` ')->join('users', ' transactions.user_id = users.id', 'left')->where('transactions.status = 1');

        if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {
            $count_res->where(" DATE(transactions.transaction_date) >= DATE('" . $_GET['start_date'] . "') ");
            $count_res->where(" DATE(transactions.transaction_date) <= DATE('" . $_GET['end_date'] . "') ");
        }
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_Start();
            $count_res->or_like($multipleWhere);
            $this->db->group_End();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        if (isset($user_where) && !empty($user_where)) {
            $count_res->where($user_where);
        }

        $txn_count = $count_res->get('transactions')->result_array();

        foreach ($txn_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' transactions.*,users.username as name,users.mobile,users.cash_received');

        if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {
            $search_res->where(" DATE(transactions.transaction_date) >= DATE('" . $_GET['start_date'] . "') ");
            $search_res->where(" DATE(transactions.transaction_date) <= DATE('" . $_GET['end_date'] . "') ");
        }

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_Start();
            $search_res->or_like($multipleWhere);
            $this->db->group_End();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }
        if (isset($user_where) && !empty($user_where)) {
            $search_res->where($user_where);
        }
        $search_res->join('users', ' transactions.user_id = users.id', 'left')->where('transactions.status = 1');
        $txn_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('transactions')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($txn_search_res as $row) {
            $row = output_escaping($row);
            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['name'];
            $tempRow['mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['mobile']) - 3) . substr($row['mobile'], -3) : $row['mobile'];
            $tempRow['order_id'] = $row['order_id'];
            $tempRow['cash_received'] = $row['cash_received'];
            $tempRow['type'] = (isset($row['type']) && $row['type'] == "rider_cash") ? '<label class="badge badge-danger">Received</label>' : '<label class="badge badge-success">Collected</label>';
            $tempRow['amount'] = $row['amount'];
            $tempRow['message'] = $row['message'];
            $tempRow['txn_date'] = $row['transaction_date'];
            $tempRow['date'] = $row['date_created'];

            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
