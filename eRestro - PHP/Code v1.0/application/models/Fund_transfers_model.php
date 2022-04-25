<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Fund_transfers_model extends CI_Model
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function set_fund_transfer($rider_id, $amount, $opening_bal, $status = 'success', $message = "")
    {
        $t = &get_instance();
        $res = $t->db->select('balance')->where('id', $rider_id)->get('users')->result_array();

        $data = [
            'rider_id' => $rider_id,
            'opening_balance' => $opening_bal,
            'closing_balance' => $opening_bal - $amount,
            'amount' => $amount,
            'status' => $status,
            'message' => $message
        ];
        $data = escape_array($data);
        $t->db->insert('fund_transfers', $data);
    }

    function get_fund_transfers_list($user_id = '')
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'ASC';
        $multipleWhere = $where = '';

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
            $multipleWhere = ['fund_transfers.`id`' => $search, 'users.`username`' => $search, 'mobile' => $search, 'message' => $search, 'fund_transfers.opening_balance' => $search, 'fund_transfers.closing_balance' => $search, 'fund_transfers.status' => $search, 'fund_transfers.amount' => $search ];
        }
        if ($user_id != '' && is_numeric($user_id)) {
            $where = array('fund_transfers.rider_id' => trim($user_id));
        }
        $count_res = $this->db->select(' COUNT(fund_transfers.id) as `total` ');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }
        $count_res->join('users', ' fund_transfers.rider_id = users.id ');
        $transfers_count = $count_res->get('fund_transfers')->result_array();
        foreach ($transfers_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' fund_transfers.*,users.username as name ,users.mobile as mobile ');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }
        $search_res->join('users', 'fund_transfers.rider_id = users.id', 'left');
        $transfers_res = $search_res->order_by($sort, "asc")->limit($limit, $offset)->get('fund_transfers')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($transfers_res as $row) {
            $row = output_escaping($row);
            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['name'];
            $tempRow['mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['mobile']) - 3) . substr($row['mobile'], -3) : $row['mobile'];
            $tempRow['opening_balance'] = $row['opening_balance'];
            $tempRow['closing_balance'] = $row['closing_balance'];
            $tempRow['amount'] = $row['amount'];
            $tempRow['status'] = $row['status'];
            $tempRow['message'] = $row['message'];
            $tempRow['date'] = $row['date_created'];
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
