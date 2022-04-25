<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Slider_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function add_slider($data)
    {
        $data = escape_array($data);

        $slider_data = [
            'type' => $data['slider_type'],
            'image' => $data['image'],
        ];

        if (isset($data['slider_type']) && $data['slider_type'] == 'categories' && isset($data['category_id']) && !empty($data['category_id'])) {
            $slider_data['type_id'] = $data['category_id'];
        }

        if (isset($data['slider_type']) && $data['slider_type'] == 'products' && isset($data['product_id']) && !empty($data['product_id'])) {
            $slider_data['type_id'] = $data['product_id'];
        }

        if (isset($data['edit_slider'])) {
            if (empty($data['image'])) {
                unset($slider_data['image']);
            }

            $this->db->set($slider_data)->where('id', $data['edit_slider'])->update('sliders');
        } else {
            $this->db->insert('sliders', $slider_data);
        }
    }

    function get_slider_list()
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
            $multipleWhere = ['`id`' => $search, '`type`' => $search];
        }

        $count_res = $this->db->select(' COUNT(id) as `total` ');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_where($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $slider_count = $count_res->get('sliders')->result_array();

        foreach ($slider_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' * ');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $slider_search_res = $search_res->order_by($sort, "asc")->limit($limit, $offset)->get('sliders')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($slider_search_res as $row) {
            $row = output_escaping($row);

            $operate = ' <a href="' . base_url('admin/slider?edit_id=' . $row['id']) . '" class="btn btn-success btn-xs mr-1 mb-1"  title="Edit" data-id="' . $row['id'] . '" data-url="admin/slider/"><i class="fa fa-pen"></i></a>';
            $operate .= ' <a  href="javascript:void(0)" class="btn btn-danger btn-xs mr-1 mb-1"  title="Delete" id="delete-slider" data-id="' . $row['id'] . '"  ><i class="fa fa-trash"></i></a>';

            $tempRow['id'] = $row['id'];
            $tempRow['type'] = $row['type'];
            $tempRow['type_id'] = $row['type_id'];

            if (empty($row['image']) || file_exists(FCPATH . $row['image']) == FALSE) {
                $row['image'] = base_url() . NO_IMAGE;
                $row['image_main'] = base_url() . NO_IMAGE;
            } else {
                $row['image_main'] = base_url($row['image']);
                $row['image'] = get_image_url($row['image'], 'thumb', 'sm');
            }
            $tempRow['image'] = "<a href='" . $row['image_main'] . "' data-toggle='lightbox' data-gallery='gallery'> <img src='" . $row['image'] . "' class='h-25' ></a>";
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
