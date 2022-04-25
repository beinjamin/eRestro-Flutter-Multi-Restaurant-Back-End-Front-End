<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Cart_model extends CI_Model
{
    function add_to_cart($data, $check_status = TRUE)
    {
        $data = escape_array($data);
        $product_variant_id = explode(',', $data['product_variant_id']);
        $qty = explode(',', $data['qty']);
        $add_on_id = (isset($data['add_on_id']) && !empty($data['add_on_id'])) ? explode(',', $data['add_on_id']) : NULL;
        $add_on_qty = (isset($data['add_on_qty']) && !empty($data['add_on_qty'])) ? explode(',', $data['add_on_qty'])  : 1;

        if ($check_status == TRUE) {
            $check_current_stock_status = validate_stock($product_variant_id, $qty);
            if (!empty($check_current_stock_status) && $check_current_stock_status['error'] == true) {
                $check_current_stock_status['csrfName'] = $this->security->get_csrf_token_name();
                $check_current_stock_status['csrfHash'] = $this->security->get_csrf_hash();
                print_r(json_encode($check_current_stock_status));
                return true;
            }
        }
        $product_id = 0;

        for ($i = 0; $i < count($product_variant_id); $i++) {
            $cart_data = [
                'user_id' => $data['user_id'],
                'product_variant_id' => $product_variant_id[$i],
                'qty' => $qty[$i],
                'is_saved_for_later' => (isset($data['is_saved_for_later']) && !empty($data['is_saved_for_later']) && $data['is_saved_for_later'] == '1') ? $data['is_saved_for_later'] : '0',
            ];
            if (isset($add_on_id) && !empty($add_on_id)) {
                $product_id = fetch_details(['id' => $product_variant_id[$i]], "product_variants", 'product_id');
                /** set data for product add ons */
                $j = 0;
                foreach ($add_on_id as $row) {
                    $tempRow['user_id'] = $data['user_id'];
                    $tempRow['product_id'] = $product_id[0]['product_id'];
                    $tempRow['product_variant_id'] = $product_variant_id[$i];
                    $tempRow['add_on_id'] = $row;
                    $tempRow['qty'] = $add_on_qty[$j];
                    $add_on_data[] = $tempRow;
                    $j++;
                }
            }

            if ($qty[$i] == 0) {
                if (isset($add_on_id) && !empty($add_on_id)) {
                    $cart_data['product_id'] = $product_id[0]['product_id'];
                }
                $this->remove_from_cart($cart_data);
            } else {
                if ($this->db->select('id')->where(['user_id' => $data['user_id'], 'product_variant_id' => $product_variant_id[$i]])->get('cart')->num_rows() > 0) {
                    $this->db->set($cart_data)->where(['user_id' => $data['user_id'], 'product_variant_id' => $product_variant_id[$i]])->update('cart');
                } else {
                    $this->db->insert('cart', $cart_data);
                }
                if (isset($add_on_id) && !empty($add_on_id)) {
                    /** update or add add_ons */
                    if ($this->db->select('id')->where(['user_id' => $data['user_id'], 'product_variant_id' => $product_variant_id[$i]])->where_in("add_on_id", $add_on_id)->get('cart_add_ons')->num_rows() > 0) {
                        delete_details(['product_variant_id' => $product_variant_id[$i],'user_id' => $data['user_id']], 'cart_add_ons');
                    }
                    // $this->db->update_batch('cart_add_ons', $add_on_data,"add_on_id");
                    $this->db->insert_batch('cart_add_ons', $add_on_data);
                }else{
                    if ($this->db->select('id')->where(['user_id' => $data['user_id'], 'product_variant_id' => $product_variant_id[$i]])->get('cart_add_ons')->num_rows() > 0) {
                        delete_details(['product_variant_id' => $product_variant_id[$i],'user_id' => $data['user_id']], 'cart_add_ons');
                    }
                }
            }
        }
        return false;
    }

    function remove_from_cart($data)
    {
        if (isset($data['user_id']) && !empty($data['user_id'])) {
            $this->db->where('user_id', $data['user_id']);
            if (isset($data['product_variant_id'])) {
                $product_variant_id = explode(',', $data['product_variant_id']);
                $this->db->where_in('product_variant_id', $product_variant_id);
            }
            $this->db->delete('cart');
            if (isset($data['product_variant_id'])) {
                $product_variant_id = explode(',', $data['product_variant_id']);
                delete_details(['user_id' => $data['user_id']], "cart_add_ons", "product_variant_id", $product_variant_id);
            }
        } else {
            return false;
        }
    }

    function get_user_cart($user_id, $is_saved_for_later = 0, $product_variant_id = '')
    {

        $q = $this->db->join('product_variants pv', 'pv.id=c.product_variant_id')
            ->join('products p', 'p.id=pv.product_id')
            ->join('`taxes` tax', 'tax.id = p.tax', 'LEFT')
            ->join('`partner_data` sd', 'sd.user_id = p.partner_id')
            ->where(['c.user_id' => $user_id, 'p.status' => '1', 'pv.status' => 1, 'sd.status' => 1, 'qty !=' => '0', 'is_saved_for_later' => $is_saved_for_later]);
        if (!empty($product_variant_id)) {
            $q->where('c.product_variant_id', $product_variant_id);
        }
        $res =  $q->select('c.*,p.is_prices_inclusive_tax,p.name,p.id,p.image,p.short_description,p.minimum_order_quantity,p.quantity_step_size,p.total_allowed_quantity,pv.price,pv.special_price,pv.id as product_variant_id,tax.percentage as tax_percentage')->order_by('c.id', 'DESC')->get('cart c')->result_array();


        if (!empty($res)) {

            $res = array_map(function ($d) {
                $percentage = (isset($d['tax_percentage']) && intval($d['tax_percentage']) > 0 && $d['tax_percentage'] != null) ? $d['tax_percentage'] : '0';
                if ((isset($d['is_prices_inclusive_tax']) && $d['is_prices_inclusive_tax'] == 0) || (!isset($d['is_prices_inclusive_tax'])) && $percentage > 0) {
                    $price_tax_amount = $d['price'] * ($percentage / 100);
                    $special_price_tax_amount = $d['special_price'] * ($percentage / 100);
                } else {
                    $price_tax_amount = 0;
                    $special_price_tax_amount = 0;
                }
                $d['price'] =  $d['price'] + $price_tax_amount;
                $d['special_price'] =  $d['special_price'] + $special_price_tax_amount;
                $d['minimum_order_quantity'] =  isset($d['minimum_order_quantity']) && !empty($d['minimum_order_quantity']) ? $d['minimum_order_quantity'] : 1;
                $d['image'] =  isset($d['image']) && !empty($d['image']) ? base_url() . $d['image'] : "";
                $d['quantity_step_size'] =  isset($d['quantity_step_size']) && !empty($d['quantity_step_size']) ? $d['quantity_step_size'] : 1;
                $d['total_allowed_quantity'] =  isset($d['total_allowed_quantity']) && !empty($d['total_allowed_quantity']) ? $d['total_allowed_quantity'] : '';
                $d['product_variants'] = get_variants_values_by_id($d['product_variant_id']);
                return $d;
            }, $res);
        }
        return $res;
    }
}
