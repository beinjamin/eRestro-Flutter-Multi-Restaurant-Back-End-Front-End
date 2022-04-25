<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Area_model extends CI_Model
{

    function add_city($data)
    {
        $city_data = [];
        if (isset($data['boundary_points']) && !empty($data['boundary_points']) && $data['boundary_points'] != "") {
            $city_data = [
                'boundary_points' => (isset($data['boundary_points']) && !empty($data['boundary_points']) && $data['boundary_points'] != "") ? $data['boundary_points'] : NULL,
                'radius' => (isset($data['radius']) && !empty($data['radius']) && $data['radius'] != "") ? $data['radius'] : 0,
                'geolocation_type' => (isset($data['geolocation_type']) && !empty($data['geolocation_type']) && $data['geolocation_type'] != "") ? $data['geolocation_type'] : NULL,
            ];
        } else {
            $charges = $data['charges'];
            $data = escape_array($data);
            $city_data = [
                'name' => $data['city_name'],
                'latitude' => $data['latitude'],
                'longitude' => $data['longitude'],
                'time_to_travel' => $data['time_to_travel'],
                'max_deliverable_distance' => $data['max_deliverable_distance'],
                'delivery_charge_method' => $data['delivery_charge_method'],
                $data['delivery_charge_method'] => $charges
            ];
        }
        if (isset($data['edit_city']) && !empty($data['edit_city']) && $data['edit_city'] != "") {
            $this->db->set($city_data)->where('id', $data['edit_city'])->update('cities');
        } else {
            $this->db->insert('cities', $city_data);
        }
    }

    function get_list()
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

        $tax_count = $count_res->get('cities')->result_array();

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

        $tax_search_res = $search_res->order_by($sort, "desc")->limit($limit, $offset)->get('cities')->result_array();
        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($tax_search_res as $row) {
            $row = output_escaping($row);
            $amount = 0 ;
            if (!$this->ion_auth->is_partner()) {
                $operate = ' <a href="javascript:void(0)" class="edit-city btn btn-success btn-xs mr-1 mb-1"  title="Edit" data-id="' . $row['id'] . '" data-url="admin/area/manage_cities"><i class="fa fa-pen"></i></a>';
                $operate .= ' <a  href="javascript:void(0)" class="btn btn-danger btn-xs mr-1 mb-1"  title="Delete" id="delete-location" data-table="cities" data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';
            }
            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['name'];
            $tempRow['latitude'] = $row['latitude'];
            $tempRow['longitude'] = $row['longitude'];
            $tempRow['geolocation_type'] = $row['geolocation_type'];
            $tempRow['radius'] = $row['radius'];
            $tempRow['boundary_points'] = $row['boundary_points'];
            $tempRow['time_to_travel'] = $row['time_to_travel'];
            $tempRow['max_deliverable_distance'] = $row['max_deliverable_distance'];
            $tempRow['max_deliverable_distance'] = $row['max_deliverable_distance'];
            $tempRow['delivery_charge_method'] = $row['delivery_charge_method'];
            if($row['delivery_charge_method'] == "fixed_charge"){
                $amount = $row['fixed_charge'];
            }
            if($row['delivery_charge_method'] == "per_km_charge"){
                $amount = $row['per_km_charge'];
            }
            if($row['delivery_charge_method'] == "range_wise_charges"){
                $amount = $row['range_wise_charges'];
            }
            $tempRow['delivery_charge_amount'] = $amount;
            $tempRow['fixed_charge'] = $row['fixed_charge'];
            $tempRow['per_km_charge'] = $row['per_km_charge'];
            $tempRow['range_wise_charges'] = $row['range_wise_charges'];
            if (!$this->ion_auth->is_partner()) {
                $tempRow['operate'] = $operate;
            }
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }

    function get_cities($sort = "c.name", $order = "ASC", $search = "", $limit = NULL, $offset = NULL)
    {
        $multipleWhere = '';
        $where = array();
        if (!empty($search)) {
            $multipleWhere = [
                '`c.name`' => $search
            ];
        }

        $search_res = $this->db->select('c.*');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }
        $cities = $search_res->group_by('c.id')->order_by($sort, $order)->limit($limit, $offset)->get('cities c')->result_array();
        $bulkData = $cities_data = array();
        $bulkData['error'] = (empty($cities)) ? true : false;
        $bulkData['message'] = (empty($cities)) ? 'City(s) does not exist' : 'City(s) retrieved successfully';

        if (!empty($cities)) {
            foreach ($cities as $row) {
                $row = output_escaping($row);
                $tempRow['id'] = $row['id'];
                $tempRow['name'] = $row['name'];
                $tempRow['latitude'] = $row['latitude'];
                $tempRow['longitude'] = $row['longitude'];
                $tempRow['geolocation_type'] = $row['geolocation_type'];
                $tempRow['radius'] = $row['radius'];
                $tempRow['max_deliverable_distance'] = $row['max_deliverable_distance'];
                $tempRow['delivery_charge_method'] = $row['delivery_charge_method'];
                $tempRow['fixed_charge'] = $row['fixed_charge'];
                $tempRow['per_km_charge'] = $row['per_km_charge'];
                $tempRow['range_wise_charges'] = $row['range_wise_charges'];
                $tempRow['time_to_travel'] = $row['time_to_travel'];
                $tempRow = array_map(function ($value) {
                    return $value === NULL ? "" : $value;
                }, $tempRow);
                $cities_data[] = $tempRow;
            }
        }
        $bulkData['data'] = (empty($cities_data)) ? [] : $cities_data;
        return $bulkData;
    }
}
