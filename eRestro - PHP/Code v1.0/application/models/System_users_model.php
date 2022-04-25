<?php

defined('BASEPATH') or exit('No direct script access allowed');
class System_users_model extends CI_Model
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function update_user($data)
    {
        $data = escape_array($data);

        if (isset($data['edit_system_user'])) {

            $user_data = [
                'ip_address' => $this->input->ip_address(),
                'mobile' => $data['mobile'],
                'email' => $data['email'],
                'username' => $data['username'],
                'active' => 1
            ];
            if (isset($data['password']) && !empty($data['password'])) {
                $password = $this->ion_auth->hash_password($data['password']);
                $user_data['password'] = $password;
            }
            $permission_data = [
                'role' => $data['role']             
            ];
            if($data['role'] > 0){
                $permission_data['permissions'] = json_encode($data['permissions']);
            }else{
                $permission_data['permissions'] = NULL;
            }
            $this->db->set($permission_data)->where('user_id', $data['edit_system_user'])->update('user_permissions');
            $this->db->set($user_data)->where('id', $data['edit_system_user'])->update('users');
        } else {

            $password = $this->ion_auth->hash_password($data['password']);

            $user_data = [
                'ip_address' => $this->input->ip_address(),
                'mobile' => $data['mobile'],
                'email' => $data['email'],
                'username' => $data['username'],
                'password' => $password,
                'active' => 1
            ];

            $permission_data = [
                'role' => $data['role']
            ];

            if($data['role'] > 0){
                $permission_data['permissions'] = json_encode($data['permissions']);
            }else{
                $permission_data['permissions'] = NULL;
            }

            $this->db->insert('users', $user_data);
            $last_id = $this->db->insert_id();
            $this->db->insert('users_groups', ['user_id' => $last_id, 'group_id' => '1']);
            $permission_data['user_id'] = $last_id;
            $this->db->insert('user_permissions', $permission_data);
        }
    }


    function get_users_list()
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
            $multipleWhere = ['up.`id`' => $search, '`u.username`' => $search , 'u.`mobile`' => $search ];
        }

        $count_res = $this->db->select(' COUNT(up.id) as `total` ')->join('users u', 'up.user_id=u.id');


        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $sys_user_count = $count_res->get('user_permissions up')->result_array();

        foreach ($sys_user_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('up.id,u.id as user_id,u.username,u.email,up.role,u.mobile,,up.permissions,u.active')->join('users u', 'up.user_id=u.id');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $sys_search_res = $search_res->order_by($sort, "asc")->limit($limit, $offset)->get('user_permissions up')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();
        $current_user_id = $this->ion_auth->user()->row()->id;
        $userData = fetch_details(['user_id'=>$current_user_id],'user_permissions');
        foreach ($sys_search_res as $row) {

            $operate = '';     
            if($current_user_id != $row['user_id'] && $userData[0]['role'] == 0 ){
                $operate .= ' <a href="javascript:void(0)" class="edit_btn btn btn-success btn-xs mr-1 mb-1"  title="Edit" data-id="' . $row['id'] . '" data-url="admin/system_users/add_system_users"><i class="fa fa-pen"></i></a>';                
                $operate .= ' <a  href="javascript:void(0)" class="btn btn-danger btn-xs mr-1 mb-1"  title="Delete" id="delete-system-users" data-id="' . $row['user_id'] . '"  ><i class="fa fa-trash"></i></a>';

                if ($row['active'] == '1') {
                    $tempRow['status'] = '<a class="badge badge-success text-white" >Active</a>';
                    $operate .= '<a class="btn btn-warning btn-xs update_active_status mr-1" data-table="users" title="Deactivate" href="javascript:void(0)" data-id="' . $row['user_id'] . '" data-status="' . $row['active'] . '" ><i class="fa fa-eye-slash"></i></a>';
                } else {
                    $tempRow['active'] = '<a class="badge badge-danger text-white" >Inactive</a>';
                    $operate .= '<a class="btn btn-primary mr-1 btn-xs update_active_status" data-table="users" href="javascript:void(0)" title="Active" data-id="' . $row['user_id'] . '" data-status="' . $row['active'] . '" ><i class="fa fa-eye"></i></a>';
                }
            }
            
            $tempRow['id'] = $row['id'];
            $tempRow['username'] = ucfirst($row['username']);
            $tempRow['email'] = $row['email'];
            $tempRow['mobile'] = ucfirst($row['mobile']);

            if ($row['role'] == '0') {
                $row['role'] = "<span class='badge badge-primary'>Super Admin</span>";
            }
            if ($row['role'] == '1') {
                $row['role'] = "<span class='badge badge-danger'>Admin</span>";
            }
            if ($row['role'] == '2') {
                $row['role'] = "<span class='badge badge-warning'>Editor</span>";
            }

            $tempRow['role'] = $row['role'];
            $tempRow['permissions'] = $row['permissions'];
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }

        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
