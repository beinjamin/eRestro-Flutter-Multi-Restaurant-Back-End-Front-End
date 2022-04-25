<?php


defined('BASEPATH') or exit('No direct script access allowed');


class Invoice_model extends CI_Model
{
    public function get_sales_list(
        $offset = 0,
        $limit = 10,
        $sort = " o.id ",
        $order = 'ASC'
    ) {

        if (isset($_GET['offset'])) {
            $offset = $_GET['offset'];
        }
        if (isset($_GET['limit'])) {
            $limit = $_GET['limit'];
        }

        if (isset($_GET['search']) and $_GET['search'] != '') {
            $search = $_GET['search'];
            $filters = [
                'u.username' => $search,
                'u.email' => $search,
                'u.mobile' => $search,
                'o.final_total' => $search,
                'o.date_added' => $search,
                'o.id' => $search,
            ];
        }

        $count_res = $this->db->select(' COUNT(o.id) as `total` ')->join(' `users` u', 'u.id= o.user_id');
        if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {

            $count_res->where(" DATE(date_added) >= DATE('" . $_GET['start_date'] . "') ");
            $count_res->where(" DATE(date_added) <= DATE('" . $_GET['end_date'] . "') ");
        }
        
        if (isset($filters) && !empty($filters)) {
            $this->db->group_Start();
            $count_res->or_like($filters);
            $this->db->group_End();
        }

        $sales_count = $count_res->get('`orders` o')->result_array();

        foreach ($sales_count as $row) {
            $total = $row['total'];
        }
        $search_res = $this->db->select(' o.* , u.username ,u.email,u.mobile  ')->join(' `users` u', 'u.id= o.user_id');

        if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {
            $search_res->where(" DATE(date_added) >= DATE('" . $_GET['start_date'] . "') ");
            $search_res->where(" DATE(date_added) <= DATE('" . $_GET['end_date'] . "') ");
        }
        
        if (isset($filters) && !empty($filters)) {
            $search_res->group_Start();
            $search_res->or_like($filters);
            $search_res->group_End();
        }

        $user_details = $search_res->order_by($sort, "DESC")->limit($limit, $offset)->get('`orders` o')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($user_details as $row) {
            $row = output_escaping($row);
           
            $operate = '<a href=' . base_url('admin/orders/edit_orders') . '?edit_id=' . $row['id'] . ' class="btn btn-primary btn-xs mr-1 mb-1" title="View" ><i class="fa fa-eye"></i></a>';
            $operate .= '<a href="javascript:void(0)" class="delete-orders btn btn-danger btn-xs mr-1 mb-1" data-id=' . $row['id'] . ' title="Delete" ><i class="fa fa-trash"></i></a>';
            $operate .= '<a href="' . base_url() . 'admin/invoice?edit_id=' . $row['id'] . '" class="btn btn-info btn-xs mr-1 mb-1" title="Invoice" ><i class="fa fa-file"></i></a>';

            $tempRow['operate'] = $operate;
            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['username'];
            $tempRow['address'] = $row['address'];
            $tempRow['mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0)? str_repeat("X", strlen($row['mobile']) - 3) . substr($row['mobile'], -3) : $row['mobile'];
            $tempRow['date_added'] = $row['date_added'];
            $tempRow['final_total'] = '<span class="badge badge-danger">' . $row['final_total'] . '</span>';
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }

        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
