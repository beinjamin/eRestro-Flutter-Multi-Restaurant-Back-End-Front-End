<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Address_model extends CI_Model
{

    function set_address($data)
    {

        $data = escape_array($data);
        $address_data = [];

        if (isset($data['user_id'])) {
            $address_data['user_id'] = $data['user_id'];
        }
        if (isset($data['id'])) {
            $address_data['id'] = $data['id'];
        }
        if (isset($data['type'])) {
            $address_data['type'] = $data['type'];
        }
        if (isset($data['name'])) {
            $address_data['name'] = $data['name'];
        }
        if (isset($data['mobile'])) {
            $address_data['mobile'] = $data['mobile'];
        }
        $address_data['country_code'] = (isset($data['country_code']) && !empty($data['country_code']) && is_numeric($data['country_code'])) ? $data['country_code'] : 0;

        if (isset($data['alternate_mobile'])) {
            $address_data['alternate_mobile'] = $data['alternate_mobile'];
        }

        if (isset($data['address'])) {
            $address_data['address'] = $data['address'];
        }

        if (isset($data['landmark'])) {
            $address_data['landmark'] = $data['landmark'];
        }

        if (isset($data['area'])) {
            $address_data['area'] = $data['area'];
        }

        if (isset($data['city_id'])) {
            $address_data['city_id'] = $data['city_id'];
        }

        if (isset($data['pincode'])) {
            $address_data['pincode'] = $data['pincode'];
        }

        if (isset($data['state'])) {
            $address_data['state'] = $data['state'];
        }

        if (isset($data['country'])) {
            $address_data['country'] = $data['country'];
        }
        if (isset($data['latitude'])) {
            $address_data['latitude'] = $data['latitude'];
        }
        if (isset($data['longitude'])) {
            $address_data['longitude'] = $data['longitude'];
        }


        if (isset($data['id']) && !empty($data['id'])) {
            if (isset($data['is_default']) && $data['is_default'] == true) {
                $address = fetch_details(['id' => $data['id']], 'addresses', '*');
                $this->db->where('user_id', $address[0]['user_id'])->set(['is_default' => '0'])->update('addresses');
                $this->db->where('id', $data['id'])->set(['is_default' => '1'])->update('addresses');
            }

            $this->db->set($address_data)->where('id', $data['id'])->update('addresses');
        } else {
            $this->db->insert('addresses', escape_array($address_data));
            $last_added_id = $this->db->insert_id();
            if (isset($data['is_default']) && $data['is_default'] == true) {
                $this->db->where('user_id', $data['user_id'])->set('is_default', '0')->update('addresses');
                $this->db->where('id', $last_added_id)->set('is_default', '1')->update('addresses');
            }
        }
    }

    function delete_address($data)
    {
        $this->db->delete('addresses', ['id' => $data['id']]);
    }

    function get_address($user_id, $id = false, $fetch_latest = false, $is_default = false, $partner_id = NULL)
    {
        $where = [];
        if (isset($user_id) || $id != false) {
            if (isset($user_id) && $user_id != null && !empty($user_id)) {
                $where['user_id'] = $user_id;
            }
            if ($id != false) {
                $where['addr.id'] = $id;
            }
            $this->db->select('addr.*,c.name as city,c.latitude as city_latitude,c.longitude as city_longitude,c.geolocation_type as geolocation_type,c.radius,c.boundary_points')
                ->where($where)
                ->join('cities c', 'addr.city_id=c.id', 'inner')
                ->group_by('addr.id')->order_by('addr.id', 'DESC');
            if ($fetch_latest == true) {
                $this->db->limit('1');
            }
            if (!empty($is_default)) {
                $this->db->where('is_default', 1);
            }
            $res = $this->db->get('addresses addr')->result_array();
            $rows = $tempRow = array();
            if (!empty($res)) {
                foreach ($res as $row) {
                    $boundary_points = json_decode($row['boundary_points'], true);
                    unset($row['boundary_points']);
                    $row = output_escaping($row);
                    $tempRow['id'] = $row['id'];
                    $tempRow['user_id'] = $row['user_id'];
                    $tempRow['name'] = $row['name'];
                    $tempRow['type'] = $row['type'];
                    $tempRow['mobile'] = $row['mobile'];
                    $tempRow['alternate_mobile'] = $row['alternate_mobile'];
                    $tempRow['address'] = $row['address'];
                    $tempRow['landmark'] = $row['landmark'];
                    $tempRow['area'] = $row['area'];
                    $tempRow['city_id'] = $row['city_id'];
                    $tempRow['pincode'] = $row['pincode'];
                    $tempRow['country_code'] = $row['country_code'];
                    $tempRow['state'] = $row['state'];
                    $tempRow['country'] = $row['country'];
                    if (isset($partner_id) && !empty($partner_id)) {
                        if (is_order_deliverable($row['id'], $row['latitude'], $row['longitude'], $partner_id, "address")) {
                            $tempRow['is_deliverable'] = "1";
                        } else {
                            $tempRow['is_deliverable'] = "0";
                        }
                    } else {
                        $tempRow['is_deliverable'] = "0";
                    }

                    $tempRow['latitude'] = $row['latitude'];
                    $tempRow['longitude'] = $row['longitude'];
                    $tempRow['is_default'] = $row['is_default'];
                    $tempRow['city'] = $row['city'];
                    $tempRow['city_latitude'] = $row['city_latitude'];
                    $tempRow['city_longitude'] = $row['city_longitude'];
                    $tempRow['geolocation_type'] = $row['geolocation_type'];
                    $tempRow['radius'] = $row['radius'];
                    $tempRow['boundary_points'] = $boundary_points;
                    $rows[] = $tempRow;
                }
            }
            return $rows;
        }
    }

    public function get_address_list($user_id = '')
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'ASC';
        $multipleWhere = '';

        if (isset($_GET['user_id']) && !empty($_GET['user_id'])) {
            $where['user_id'] = $_GET['user_id'];
        }

        if (!empty($user_id)) {
            $where['user_id'] = $user_id;
        }

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
            $multipleWhere = ['addr.name' => $search, 'addr.address' => $search, 'mobile' => $search, 'a.name' => $search, 'c.name' => $search, 'state' => $search, 'country' => $search, 'pincode' => $search];
        }

        $count_res = $this->db->select(' COUNT(addr.id) as `total` ,addr.*,c.name as city')->join('cities c', 'addr.city_id=c.id', 'left');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $address_count = $count_res->get('addresses addr')->result_array();

        foreach ($address_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('addr.*,c.name as city')->join('cities c', 'addr.city_id=c.id', 'left');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $search_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $address_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('addresses addr')->result_array();
        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();
        foreach ($address_search_res as $row) {
            $row = output_escaping($row);
            $default = $row['is_default'] == 1 ? 'Default' : 'Set as default';
            $btn = $row['is_default'] == 1 ? 'info' : 'secondary';
            $class = $row['is_default'] == 1 ? '' : 'default-address ';
            $operate = '<a href="javascript:void(0)" class="edit-address btn btn-success btn-xs mr-1 mb-1" title="Edit" data-id="' . $row['id'] . '" data-toggle="modal" data-target="#address-modal"><i class="fa fa-pen"></i></a>';
            $operate .= '<a href="javascript:void(0)" class="delete-address btn btn-danger btn-xs mr-1 mb-1" title="Delete" data-id="' . $row['id'] . '"><i class="fa fa-trash"></i></a>';
            $operate .= '<a href="javascript:void(0)" class="' . $class . ' btn btn-' . $btn . ' btn-xs mr-1 mb-1" title="' . $default . '" data-id="' . $row['id'] . '"><i class="fa fa-check-square"></i></a>';
            $tempRow['id'] = $row['id'];
            $tempRow['name'] = $row['name'];
            $tempRow['type'] = $row['type'];
            $tempRow['mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['mobile']) - 3) . substr($row['mobile'], -3) : $row['mobile'];
            $tempRow['alternate_mobile'] = $row['alternate_mobile'];
            if (isset($row['alternate_mobile']) && !empty($row['alternate_mobile']) && $row['alternate_mobile'] != "" && $row['alternate_mobile'] != " ") {
                $tempRow['alternate_mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['alternate_mobile']) - 3) . substr($row['alternate_mobile'], -3) : $row['alternate_mobile'];
            } else {
                $tempRow['alternate_mobile'] = "";
            }
            $tempRow['address'] = $row['address'];
            $tempRow['landmark'] = $row['landmark'];
            $tempRow['area'] = $row['area'];
            $tempRow['city'] = $row['city'];
            $tempRow['city_id'] = $row['city_id'];
            $tempRow['state'] = $row['state'];
            $tempRow['pincode'] = $row['pincode'];
            $tempRow['country'] = $row['country'];
            $tempRow['action'] = $operate;
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
