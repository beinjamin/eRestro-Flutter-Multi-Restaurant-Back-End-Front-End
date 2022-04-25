<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Transaction_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function add_transaction($data)
    {
        $this->load->model('Order_model');
        $data = escape_array($data);
        /* transaction_type : transaction - for payment transactions | wallet - for wallet transactions  */
        $transaction_type = (!isset($data['transaction_type']) || empty($data['transaction_type'])) ? 'transaction' : $data['transaction_type'];
        $trans_data = [
            'transaction_type' => $transaction_type,
            'user_id' => $data['user_id'],
            'order_id' => $data['order_id'],
            'type' => strtolower($data['type']),
            'txn_id' => $data['txn_id'],
            'amount' => $data['amount'],
            'status' => $data['status'],
            'message' => $data['message'],
        ];
        $this->db->insert('transactions', $trans_data);
    }

    function get_transactions_list($user_id = '' ,$group_id = 2)
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'ASC';
        $multipleWhere = '';
        $where = [];
        if (isset($_GET['transaction_type']))
            $where = ['transactions.transaction_type' => $_GET['transaction_type']];

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
        if (isset($user_id) && !empty($user_id)) {
            $user_where = ['users.id' => $user_id];
        }
        if (isset($_GET['user_id']) && !empty($_GET['user_id'])) {
            $where = ['users.id' => $_GET['user_id']];
        }      

        if (isset($_GET['user_type']) && !empty($_GET['user_type'])) {
            $group_id = fetch_details(['name' => $_GET['user_type']],"groups","id");
        }
        $where = ['ug.group_id' => $group_id[0]['id']];

        $count_res = $this->db->select(' COUNT(transactions.id) as `total` ')->join('users', ' transactions.user_id = users.id', 'left')->join('users_groups ug', 'ug.user_id = users.id');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_Start();
            $count_res->or_like($multipleWhere);
            $this->db->group_End();
        }

        if (isset($_GET['user_type']) && !empty($_GET['user_type'])) {
            if($_GET['user_type'] == "partner"){
                $count_res->join('partner_data rd',"rd.user_id = users.id");
            }
        }
        if (isset($_GET['user_id']) && !empty($_GET['user_id'])) {
            $where = ['users.id' => $_GET['user_id']];
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
        $restro_name = "";
        if (isset($_GET['user_type']) && !empty($_GET['user_type'])) {
            if($_GET['user_type'] == "partner"){
                $restro_name = " ,rd.partner_name";
            }else{
                $restro_name = "";
            }
        }

        $search_res = $this->db->select(" transactions.*,users.username as name $restro_name ");
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
        $search_res->join('users', ' transactions.user_id = users.id', 'left')->join('users_groups ug', 'ug.user_id = users.id');
        if (isset($_GET['user_type']) && !empty($_GET['user_type'])) {
            if($_GET['user_type'] == "partner"){
                $search_res->join('partner_data rd',"rd.user_id = users.id");
            }
        }
        $txn_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('transactions')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($txn_search_res as $row) {
            $row = output_escaping($row);
            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['name'];
            $tempRow['partner_name'] = (isset($row['partner_name']) && !empty($row['partner_name'])) ? $row['partner_name'] : "";
            $tempRow['order_id'] = $row['order_id'];
            $tempRow['user_id'] = $row['user_id'];
            $tempRow['type'] = $row['type'];
            $tempRow['txn_id'] = $row['txn_id'];
            $tempRow['payu_txn_id'] = $row['payu_txn_id'];
            $tempRow['amount'] = $row['amount'];
            $tempRow['status'] = $row['status'];
            $tempRow['message'] = $row['message'];
            $tempRow['txn_date'] = $row['transaction_date'];
            $tempRow['date'] = $row['date_created'];

            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }

    function get_transactions($id = '', $user_id = '', $transaction_type = '', $type = '', $search = '', $offset = '0', $limit = '25', $sort = 'id', $order = 'DESC')
    {
        $where = $multiple_where = [];
        $count_sql = $this->db->select(' COUNT(id) as `total`');
        if (!empty($user_id)) {
            $where['user_id'] = $user_id;
        }

        if ($transaction_type != '') {
            $where['transaction_type'] = $transaction_type;
        }

        if ($type != '') {
            $where['type'] = $type;
        }

        if ($id !== '') {
            $where['id'] = $id;
        }

        if ($search !== '') {
            $multiple_where = [
                'id' => $search,
                'transaction_type' => $search,
                'type' => $search,
                'order_id' => $search,
                'txn_id' => $search,
                'amount' => $search,
                'status' => $search,
                'message' => $search,
                'transaction_date' => $search,
                'date_created' => $search,
            ];
        }

        if (isset($where) && !empty($where)) {
            $count_sql->where($where);
        }

        if (isset($multiple_where) && !empty($multiple_where)) {
            $count_sql->group_start();  //group start
            $count_sql->or_like($multiple_where);
            $count_sql->group_end();  //group end
        }

        $count = $count_sql->get('transactions')->result_array();
        $total = $count[0]['total'];

        /* query for transactions list */
        $transactions_sql = $this->db->select('*');
        if (isset($where) && !empty($where)) {
            $transactions_sql->where($where);
        }

        if (isset($multiple_where) && !empty($multiple_where)) {
            $transactions_sql->group_start();  //group start
            $transactions_sql->or_like($multiple_where);
            $transactions_sql->group_end();  //group end
        }

        if ($limit != '' && $offset !== '') {
            $transactions_sql->limit($limit, $offset);
        }

        $transactions_sql->order_by($sort, $order);
        $q = $this->db->get('transactions')->result_array();
        $data = [];
        foreach($q as $row){
            $data[] = array_map(function ($value) {
                return $value === NULL ? "" : $value;
            }, $row);
        }
        $transactions['data'] = $data;
        $transactions['total'] = $total;
        return $transactions;
    }
}
