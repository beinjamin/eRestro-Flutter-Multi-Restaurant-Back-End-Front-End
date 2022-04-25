<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Tax_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function add_tax($data)
    {
        $data = escape_array($data);
        $tax_data = [
            'title' => $data['title'],
            'percentage' => $data['percentage'],
        ];

        if (isset($data['edit_tax_id'])) {
            $this->db->set($tax_data)->where('id', $data['edit_tax_id'])->update('taxes');
        } else {
            $this->db->insert('taxes', $tax_data);
        }
    }

    function get_tax_list()
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'ASC';
        $multipleWhere = '';

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
            $multipleWhere = ['`id`' => $search, '`title`' => $search];
        }

        $count_res = $this->db->select(' COUNT(id) as `total` ');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_where($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $tax_count = $count_res->get('taxes')->result_array();

        foreach ($tax_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' * ');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $tax_search_res = $search_res->order_by($sort, "asc")->limit($limit, $offset)->get('taxes')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($tax_search_res as $row) {
            $row = output_escaping($row);
            if ($row['status'] == '1') {
                if (!$this->ion_auth->is_partner()) {
                    $operate = ' <a href="javascript:void(0)" class="edit_btn btn btn-success btn-xs mr-1 mb-1"  title="Edit" data-id="' . $row['id'] . '" data-url="admin/taxes/"><i class="fa fa-pen"></i></a>';
                    $operate .= ' <a  href="javascript:void(0)" class="btn btn-danger btn-xs mr-1 mb-1"  title="Delete" id="delete-tax" data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';
                }else{
                    $operate = '';
                }
            } else {
                $operate = '';
            }

            $tempRow['id'] = $row['id'];
            $tempRow['title'] = $row['title'];
            $tempRow['percentage'] = $row['percentage'];
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
