<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Tag_model extends CI_Model
{

    public function __construct()
    {
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    public function add_tags($data)
    {
        $data = escape_array($data);

        $attr_data = [
            'title' => $data['title'],
        ];

        if (isset($data['edit_tag']) && !empty($data['edit_tag'])) {
            $this->db->set($attr_data)->where('id', $data['edit_tag'])->update('tags');
            return $data['edit_tag'];
        } else {
            $this->db->insert('tags', $attr_data);
            return $this->db->insert_id();
        }
    }


    public function get_tag_list(
        $partner_id = NULL,
        $offset = 0,
        $limit = 10,
        $sort = 't.id',
        $order = 'DESC'
    ) {
        $multipleWhere = '';

        if (isset($_GET['offset']))
            $offset = $_GET['offset'];
        if (isset($_GET['limit']))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($_GET['sort'] == 't.id') {
                $sort = "t.id";
            } else {
                $sort = $_GET['sort'];
            }
        if (isset($_GET['order']))
            $order = $_GET['order'];

        if (isset($_GET['search']) and $_GET['search'] != '') {
            $search = $_GET['search'];
            $multipleWhere = ['t.title' => $search];
        }
        if (isset($partner_id) and $partner_id != '') {
            $where = ['partner_id' => $partner_id];
        }

        $count_res = $this->db->select(' COUNT(t.id) as `total`');

        if (isset($partner_id) and $partner_id != '') {
            $count_res->join("partner_tags rt", "t.id=rt.tag_id", "left");
        }

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $attr_count = $count_res->get('tags t')->result_array();

        foreach ($attr_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('t.id as tag_id,t.title');
        if (isset($partner_id) and $partner_id != '') {
            $search_res->join("partner_tags rt", "t.id=rt.tag_id", "left");
        }
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $city_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('tags t')->result_array();
        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();
        foreach ($city_search_res as $row) {
            $row = output_escaping($row);
            $partner_id = $this->ion_auth->get_user_id();
            if ($this->ion_auth->is_admin()) {
                $operate = ' <a href="javascript:void(0)" class="edit_btn btn btn-success btn-xs mr-1 mb-1" title="View" data-id="' . $row['tag_id'] . '" data-url="admin/tag/"><i class="fa fa-pen"></i></a>';
            } else if ($this->ion_auth->is_partner()) {
                $operate = ' <a href="javascript:void(0)" class="edit_btn btn btn-success btn-xs mr-1 mb-1" title="View" data-id="' . $row['tag_id'] . '" data-url="partner/tag/"><i class="fa fa-pen"></i></a>';
            }
            $operate .= ' <a href="javaScript:void(0)" id="delete-restro-tag" class="btn btn-danger btn-xs mr-1 mb-1" title="Delete" data-id="' . $row['tag_id'] . '"><i class="fa fa-trash"></i></a>';

            $tempRow['id'] = $row['tag_id'];
            $tempRow['title'] = $row['title'];
            $tempRow['operate'] = $operate;

            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }

    function get_tags($search = NULL, $limit = NULL, $offset = NULL, $sort = 't.id', $order = 'DESC', $partner_id = NULL)
    {
        $multipleWhere = '';
        $where = array();
        if (!empty($search)) {
            $multipleWhere = [
                '`t.title`' => $search
            ];
        }

        if (isset($partner_id) && !empty($partner_id) && $partner_id != NULL) {
            $where = ['rt.partner_id' => $partner_id];
        }

        $count_res = $this->db->select(' COUNT(t.id) as `total`')->join("partner_tags rt", "t.id=rt.tag_id", "left");

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }

        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $cat_count = $count_res->get('tags t')->result_array();
        foreach ($cat_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('*,t.id as tag_id')->join("partner_tags rt", "t.id=rt.tag_id", "left");
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $cat_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->group_by('t.id')->get('tags t')->result_array();
        $rows = $tempRow = $bulkData = array();
        $bulkData['error'] = (empty($cat_search_res)) ? true : false;
        $bulkData['message'] = (empty($cat_search_res)) ? 'Tag(s) does not exist' : 'Tag(s) retrieved successfully';
        $bulkData['total'] = (empty($cat_search_res)) ? 0 : $total;
        if (!empty($cat_search_res)) {
            foreach ($cat_search_res as $row) {
                $row = output_escaping($row);
                $tempRow['id'] = $row['tag_id'];
                $tempRow['partner_id'] = $row['partner_id'];
                $tempRow['title'] = $row['title'];
                $tempRow['date_created'] = $row['date_created'];
                $rows[] = $tempRow;
            }
            $bulkData['data'] = $rows;
        } else {
            $bulkData['data'] = [];
        }
        return $bulkData;
    }
}
