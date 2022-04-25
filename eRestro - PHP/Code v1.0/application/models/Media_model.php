<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Media_model extends CI_Model
{
    public function __construct()
    {
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function set_media($data)
    {
        $data = escape_array($data);
        $extenstion = trim($data['file_ext'], '.');
        $extenstionData = find_media_type($extenstion);
        $media_type = $extenstionData[0];
        $partner_id = $data['partner_id'];
        $data = [
            'name' => $data['file_name'],
            'partner_id' => $partner_id ,
            'extension' => ltrim($data['file_ext'], '.'),
            'title' => $data['raw_name'],
            'type' => ($media_type != false) ? $media_type : 'other',
            'size' => $data['file_size'],
            'sub_directory' => $data['sub_directory'],
        ];

        $this->db->insert('media', $data);
        $insert_id = $this->db->insert_id();
        return  $insert_id;
    }

    function get_media_by_id($id)
    {
        $this->db->where('id', $id);
        $q = $this->db->get('media');
        return $q->result_array();
    }


    public function fetch_media()
    {
        if (($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) || ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0))) {

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
                $multipleWhere = ['id' => $search, 'name' => $search];
            }

            if (isset($_GET['type']) and $_GET['type'] != '') {
                $where['type'] = trim(strtolower($_GET['type']));
            }

            if($this->ion_auth->logged_in() && $this->ion_auth->is_partner()){
                $where['partner_id'] = $this->ion_auth->get_user_id();
            }

            $count_res = $this->db->select(' COUNT(id) as `total` ');

            if (isset($multipleWhere) && !empty($multipleWhere)) {
                $count_res->or_like($multipleWhere);
            }
            if (isset($where) && !empty($where)) {
                $count_res->where($where);
            }
            if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {

                $count_res->where(" DATE(date_created) >= DATE('" . $_GET['start_date'] . "') ");
                $count_res->where(" DATE(date_created) <= DATE('" . $_GET['end_date'] . "') ");
            }
            $attr_count = $count_res->get('media')->result_array();

            foreach ($attr_count as $row) {
                $total = $row['total'];
            }

            $search_res = $this->db->select('*');
            if (isset($multipleWhere) && !empty($multipleWhere)) {
                $search_res->or_like($multipleWhere);
            }
            if (isset($where) && !empty($where)) {
                $search_res->where($where);
            }

            if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {

                $search_res->where(" DATE(date_created) >= DATE('" . $_GET['start_date'] . "') ");
                $search_res->where(" DATE(date_created) <= DATE('" . $_GET['end_date'] . "') ");
            }

            $city_search_res = $search_res->order_by($sort, 'desc')->limit($limit, $offset)->get('media')->result_array();
            $bulkData = array();
            $bulkData['total'] = $total;
            $rows = array();
            $tempRow = array();

            $i = 0;
            foreach ($city_search_res as $row) {
                $operate = "";
                if ($this->ion_auth->is_partner() && $row['partner_id'] == $this->session->userdata('user_id')) {
                    $operate = '<a href="javascript:void(0);" class="delete-media btn btn-danger btn-xs mr-1 mb-1" title="Delete" data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';
                }
                if ($this->ion_auth->is_admin()) {
                    $operate = '<a href="javascript:void(0);" class="delete-media btn btn-danger btn-xs mr-1 mb-1" title="Delete" data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';
                }
                $operate .= '<a href="javascript:void(0);" class="copy-to-clipboard btn btn-primary btn-xs mr-1 mb-1" title="Copy to clipboard" ><i class="fa fa-copy"></i></a>';
                $operate .= "<a href='javascript:void(0);' class='btn btn-info btn-xs mr-1 mb-1 copy-relative-path' data-path=" . $row['sub_directory'] . $row['name'] . " title='Copy image path for csv file'><i class='fa fa-copy'></i></a>";

                $tempRow['id'] = $row['id'];
                $tempRow['partner_id'] = $row['partner_id'];
                $tempRow['name'] = $row['name'];
                if (file_exists(FCPATH . $row['sub_directory'] . $row['name'])) {
                    $row['image'] = get_image_url($row['sub_directory'] . $row['name'], 'thumb', 'sm', trim(strtolower($row['type'])));
                } else {
                    $row['image'] = base_url() . NO_IMAGE;
                }

                $tempRow['image'] = '<div class="image-upload-div text-center"><span class="path d-none">' . base_url() . $row['sub_directory'] . $row['name'] . '</span><span class="relative-path d-none">' . $row['sub_directory'] . $row['name'] . '</span><a href="' . $row['image'] . '" data-toggle="lightbox" data-gallery="gallery" ><img src="' .  $row['image'] . '" class="img-fluid "></a></div>';
                $tempRow['extension'] = $row['extension'];
                $tempRow['partner_id'] = $row['partner_id'];
                $tempRow['sub_directory'] = $row['sub_directory'];
                $tempRow['size'] = ($row['size'] > 1) ? formatBytes($row['size']) : $row['size'];
                $tempRow['operate'] = $operate;
                $rows[] = $tempRow;
                $i++;
            }
            $bulkData['rows'] = $rows;
            print_r(json_encode($bulkData));
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function get_media($limit = "", $offset = '', $sort = 'id', $order = 'DESC',$search = NULL,$type = "",$partner_id = NULL)
    {

        $multipleWhere = '';

        if (isset($search) and $search != '') {
            $multipleWhere = ['id' => $search, 'name' => $search];
        }

        if (isset($type) and $type != '') {
            $where['type'] = trim(strtolower($type));
        }
        if (isset($partner_id) and $partner_id != '') {
            $where['partner_id'] = $partner_id;
        }

        $count_res = $this->db->select(' COUNT(id) as `total` ');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }
        $attr_count = $count_res->get('media')->result_array();

        foreach ($attr_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('*');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $city_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('media')->result_array();
        $bulkData =  $rows = $tempRow = array();
        $bulkData['error'] = (empty($city_search_res)) ? true : false;
        $bulkData['message'] = (empty($city_search_res)) ? 'Media(s) does not exist' : 'Media retrieved successfully';
        $bulkData['total'] = (empty($city_search_res)) ? 0 : $total;
        $i = 0;
        foreach ($city_search_res as $row) {
            $tempRow['id'] = $row['id'];
            $tempRow['partner_id'] = $row['partner_id'];
            $tempRow['name'] = $row['name'];
            if (file_exists(FCPATH . $row['sub_directory'] . $row['name'])) {
                $row['image'] = get_image_url($row['sub_directory'] . $row['name'], 'thumb', 'sm', trim(strtolower($row['type'])));
            } else {
                $row['image'] = base_url() . NO_IMAGE;
            }
            $tempRow['image'] =  base_url() . $row['sub_directory'] . $row['name'] ;
            $tempRow['relative_path'] =  $row['sub_directory'] . $row['name'];
            $tempRow['extension'] = $row['extension'];
            $tempRow['sub_directory'] = $row['sub_directory'];
            $tempRow['size'] = ($row['size'] > 1) ? formatBytes($row['size']) : $row['size'];
            $rows[] = $tempRow;
            $i++;
        }
        $bulkData['data'] = $rows;
        print_r(json_encode($bulkData));
    }
}
