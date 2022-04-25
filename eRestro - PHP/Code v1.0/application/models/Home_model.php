<?php
if (!defined('BASEPATH')) exit('No direct script access allowed');
class Home_model extends CI_Model
{

    public function count_new_orders()
    {
        $res = $this->db->select('count(id) as counter');
        $user_id = $this->session->userdata('user_id');
        if ($this->ion_auth->is_rider()) {
            $this->db->where('o.rider_id', $user_id);
        }
        $res = $this->db->get('`orders` o')->result_array();
        return $res[0]['counter'];
    }

    public function count_orders_by_status($status)
    {
        $res = $this->db->select('count(id) as counter');
        $this->db->where('active_status', $status);
        $res = $this->db->get('`orders` o')->result_array();
        return $res[0]['counter'];
    }

    public function count_new_users()
    {
        $res = $this->db->select('count(u.id) as counter')->join('users_groups ug', ' ug.`user_id` = u.`id` ')
            ->where('ug.group_id=2')
            ->get('`users u`')->result_array();
        return $res[0]['counter'];
    }

    public function count_riders()
    {
        $res = $this->db->select('count(u.id) as counter')->where('ug.group_id', '3')->join('users_groups ug', 'ug.user_id=u.id')
            ->get('`users` u')->result_array();
        return $res[0]['counter'];
    }
    public function count_partners()
    {
        $res = $this->db->select('count(u.id) as counter')->where('ug.group_id', '4')->join('users_groups ug', 'ug.user_id=u.id')
            ->get('`users` u')->result_array();
        return $res[0]['counter'];
    }

    public function count_products($partner_id = "")
    {
        $res = $this->db->select('count(id) as counter ');
        if (!empty($partner_id) && $partner_id != '') {
            $res->where('partner_id=' . $partner_id);
        }
        $count = $res->get('`products`')->result_array();
        return $count[0]['counter'];
    }

    public function count_products_stock_low_status($partner_id = "")
    {
        $settings = get_settings('system_settings', true);
        $low_stock_limit = isset($settings['low_stock_limit']) ? $settings['low_stock_limit'] : 5;
        $count_res = $this->db->select(' COUNT( distinct(p.id)) as `total` ')->join('product_variants', 'product_variants.product_id = p.id');
        $where = "p.stock_type is  NOT NULL";

        $count_res->where($where);
        $count_res->where('p.stock  <=', $low_stock_limit);
        $count_res->where('p.availability  =', '1');
        $count_res->or_where('product_variants.stock  <=', $low_stock_limit);
        $count_res->where('product_variants.availability  =', '1');
        if (!empty($partner_id) && $partner_id != '') {
            $count_res->where('p.partner_id  =', $partner_id);
        }
        $product_count = $count_res->get('products p')->result_array();
        return $product_count[0]['total'];
    }

    public function count_products_availability_status($partner_id = "")
    {
        $count_res = $this->db->select(' COUNT( distinct(p.id)) as `total` ')->join('product_variants', 'product_variants.product_id = p.id');
        $where = "p.stock_type is  NOT NULL";
        $count_res->where($where);
        $count_res->where('p.stock ', '0');
        $count_res->where('p.availability ', '0');
        $count_res->or_where('product_variants.stock ', '0');
        $count_res->where('product_variants.availability', '0');
        if (!empty($partner_id) && $partner_id != '') {
            $count_res->where('p.partner_id  =', $partner_id);
        }
        $product_count = $count_res->get('products p')->result_array();
        return $product_count[0]['total'];
    }
    public function total_earnings($type = "admin")
    {
        $select = "";
        if($type == "admin"){
            $select = "SUM(admin_commission_amount) as total ";
        }
        if($type == "partner"){
            $select = "SUM(partner_commission_amount) as total ";
        }
        if($type == "overall"){
            $select = "SUM(final_total) as total ";
        }
        $count_res = $this->db->select($select);
        $where = "is_credited=1";
        $count_res->where($where);
       
        $product_count = $count_res->get('orders')->result_array();
        return $product_count[0]['total'];
    }    
}
