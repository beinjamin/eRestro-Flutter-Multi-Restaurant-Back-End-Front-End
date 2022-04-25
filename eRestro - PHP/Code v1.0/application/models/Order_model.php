<?php
error_reporting(0);
defined('BASEPATH') or exit('No direct script access allowed');

class Order_model extends CI_Model
{

    public function update_order($set, $where, $isjson = false, $table = 'orders')
    {
        $set = escape_array($set);

        if ($isjson == true) {
            $field = array_keys($set); // active_status
            $current_status = $set[$field[0]]; //processed

            $res = fetch_details($where, $table, '*');
            $priority_status = [
                'pending' => 0,
                'confirmed' => 1,
                'preparing' => 2,
                'out_for_delivery' => 3,
                'delivered' => 4,
                'cancelled' => 5,
            ];
            if (count($res) >= 1) {
                $i = $rider_id = 0;
                foreach ($res  as $row) {
                    $set = $temp = $active_status = array();
                    $active_status[$i] = json_decode($row['status'], 1);
                    $current_selected_status = end($active_status[$i]);
                    $temp = $active_status[$i];
                    $cnt = count($temp);
                    $currTime = date('Y-m-d H:i:s');
                    $min_value = (!empty($temp)) ? $priority_status[$current_selected_status[0]] : -1;
                    $max_value = $priority_status[$current_status];
                    if ($current_status == 'cancelled') {
                        $temp[$cnt] = [$current_status, $currTime];
                    } else {
                        foreach ($priority_status  as $key => $value) {
                            if ($value > $min_value && $value <= $max_value) {
                                $temp[$cnt] = [$key, $currTime];
                            }
                            ++$cnt;
                        }
                    }
                    $set = [$field[0] => json_encode(array_values($temp))];
                    $this->db->trans_start();
                    $this->db->set($set)->where(['id' => $row['id']])->update($table);
                    $this->db->trans_complete();
                    $response = FALSE;
                    if ($this->db->trans_status() === TRUE) {
                        $response = TRUE;
                    }
                    $order = fetch_details($where, 'orders', 'rider_id');
                    $rider_id = (isset($row['rider_id']) && !empty($row['rider_id'])) ? $row['rider_id'] : "";

                    if ((isset($rider_id) && $rider_id != "" && !empty($rider_id)) || ($current_status == 'cancelled')) {
                        // delete record
                        if (is_exist(['order_id' => $row['id']], "pending_orders")) {
                            delete_details(['order_id' => $row['id']], "pending_orders");
                        }
                    } else {
                        // insert data to pending orders table
                        if (!is_exist(['order_id' => $row['id']], "pending_orders")) {
                            $pending_orders = ['order_id' => $row['id'], "city_id" => $row['city_id']];
                            insert_details($pending_orders, "pending_orders");
                            // notify all Rider
                            $body = 'New order confirmed if you are near by then please confirm it.';
                            $title = 'New order confirmed ID #' . $row['id'];
                            send_notifications("", "rider", $title, $body, "order", $row['city_id']);
                        }
                    }
                    $commission = 0;
                    /* give commission to the Rider if the order is delivered */
                    if ($current_status == 'delivered') {
                        $order = fetch_details($where, 'orders', 'rider_id,final_total,payment_method,total_payable,delivery_tip,delivery_charge');
                        if (!empty($order)) {
                            $rider_id = $order[0]['rider_id'];
                            if ($rider_id > 0) {
                                $rider = fetch_details("id = $rider_id", 'users', 'commission_method,commission');
                                $final_total = $order[0]['final_total'];
                                /* get commission on commission method  */
                                if (!empty($rider)) {
                                    if (isset($rider[0]['commission_method']) && $rider[0]['commission_method'] == 'fixed_commission_per_order') {
                                        $commission = (isset($rider[0]['commission']) && !empty($rider[0]['commission']) && $rider[0]['commission'] > 0) ? $rider[0]['commission'] : 0;
                                    }
                                    if (isset($rider[0]['commission_method']) && $rider[0]['commission_method'] == 'percentage_on_delivery_charges') {
                                        $order_charge =  $order[0]['delivery_charge'];
                                        $commission_val = (isset($rider[0]['commission']) && !empty($rider[0]['commission']) && $rider[0]['commission'] > 0) ? $rider[0]['commission'] : 0;
                                        $commission = intval($order_charge) * ($commission_val / 100);
                                    }
                                } else {
                                    $commission = 0;
                                }
                                /* give tip to rider if set in order */
                                if ($order[0]['delivery_tip'] > 0) {
                                    $commission += intval($order[0]['delivery_tip']);
                                }
                                /* commission must be greater then zero to be credited into the account */
                                if ($commission > 0) {
                                    $this->load->model("transaction_model");
                                    $msg = ($order[0]['delivery_tip'] > 0) ? "Order delivery bonus for order ID: #" . $row['id'] . " with Delivery Tip: " . $order[0]['delivery_tip'] : "Order delivery bonus for order ID: #" . $row['id'];

                                    $transaction_data = [
                                        'transaction_type' => "wallet",
                                        'user_id' => $rider_id,
                                        'order_id' => $row['id'],
                                        'type' => "credit",
                                        'txn_id' => "",
                                        'amount' => $commission,
                                        'status' => "success",
                                        'message' => $msg,
                                    ];
                                    $this->transaction_model->add_transaction($transaction_data);
                                    $this->load->model('customer_model');
                                    $this->customer_model->update_balance($commission, $rider_id, 'add');

                                    if (strtolower($order[0]['payment_method']) == "cod") {
                                        $transaction_data = [
                                            'transaction_type' => "transaction",
                                            'user_id' => $rider_id,
                                            'order_id' => $row['id'],
                                            'type' => "rider_cash",
                                            'txn_id' => "",
                                            'amount' => $final_total,
                                            'status' => "1",
                                            'message' => "Rider collected COD",
                                        ];
                                        $this->transaction_model->add_transaction($transaction_data);
                                        $this->load->model('customer_model');
                                        update_cash_received($final_total, $rider_id, "add");
                                    }
                                } else {
                                    $response = TRUE;
                                }
                            } else {
                                $response = TRUE;
                            }
                        } else {
                            $response = TRUE;
                        }
                    }
                    ++$i;
                }
                return $response;
            }
        } else {
            $this->db->trans_start();
            $this->db->set($set)->where($where)->update($table);
            $this->db->trans_complete();
            $response = FALSE;
            if ($this->db->trans_status() === TRUE) {
                $response = TRUE;
            }
            return $response;
        }
    }

    public function place_order($data)
    {
        $data = escape_array($data);

        $CI = &get_instance();
        $CI->load->model('Address_model');

        $response = array();
        $product_variant_id = explode(',', $data['product_variant_id']);
        $quantity = explode(',', $data['quantity']);
        $otp = mt_rand(100000, 999999);

        $check_current_stock_status = validate_stock($product_variant_id, $quantity);

        if (isset($check_current_stock_status['error']) && $check_current_stock_status['error'] == true) {
            return json_encode($check_current_stock_status);
        }

        /* Calculating Final Total */

        $total = 0;
        $product_variant = $this->db->select('pv.*,tax.percentage as tax_percentage,tax.title as tax_name,p.partner_id,p.name as product_name,p.is_prices_inclusive_tax')
            ->join('products p ', 'pv.product_id=p.id', 'left')
            ->join('categories c', 'p.category_id = c.id', 'left')
            ->join('`taxes` tax', 'tax.id = p.tax', 'LEFT')
            ->where_in('pv.id', $product_variant_id)->order_by('FIELD(pv.id,' . $data['product_variant_id'] . ')')->get('product_variants pv')->result_array();

        if (!empty($product_variant)) {
            $partner_ids = array_values(array_unique(array_column($product_variant, "partner_id")));

            /* check for restro not empty */
            if (!isset($partner_ids) || empty($partner_ids)) {
                $response['error'] = true;
                $response['message'] = 'Opps! Product not available or restro is not providing this item anymore.';
                return $response;
            }
            /* check for single seller permission */
            if (isset($partner_ids) && count($partner_ids) > 1) {
                $response['error'] = true;
                $response['message'] = 'Only one partner foods are allow in one order.';
                return $response;
            }

            $delivery_charge = isset($data['delivery_charge']) && !empty($data['delivery_charge']) ? $data['delivery_charge'] : 0;
            $gross_total = 0;
            $cart_data = [];
            for ($i = 0; $i < count($product_variant); $i++) {
                $pv_price[$i] = ($product_variant[$i]['special_price'] > 0 && $product_variant[$i]['special_price'] != null) ? $product_variant[$i]['special_price'] : $product_variant[$i]['price'];
                $tax_percentage[$i] = (isset($product_variant[$i]['tax_percentage']) && intval($product_variant[$i]['tax_percentage']) > 0 && $product_variant[$i]['tax_percentage'] != null) ? $product_variant[$i]['tax_percentage'] : '0';
                if ((isset($product_variant[$i]['is_prices_inclusive_tax']) && $product_variant[$i]['is_prices_inclusive_tax'] == 0) || (!isset($product_variant[$i]['is_prices_inclusive_tax'])) && $tax_percentage[$i] > 0) {
                    $tax_amount[$i] = $pv_price[$i] * ($tax_percentage[$i] / 100);
                    $pv_price[$i] = $pv_price[$i] + $tax_amount[$i];
                }

                $subtotal[$i] = ($pv_price[$i])  * $quantity[$i];
                $pro_name[$i] = $product_variant[$i]['product_name'];
                $variant_info = get_variants_values_by_id($product_variant[$i]['id']);
                $product_variant[$i]['variant_name'] = (isset($variant_info[0]['variant_values']) && !empty($variant_info[0]['variant_values'])) ? $variant_info[0]['variant_values'] : "";

                $tax_percentage[$i] = (!empty($product_variant[$i]['tax_percentage'])) ? $product_variant[$i]['tax_percentage'] : 0;
                if ($tax_percentage[$i] != NUll && $tax_percentage[$i] > 0) {
                    $tax_amount[$i] = round($subtotal[$i] *  $tax_percentage[$i] / 100, 2);
                } else {
                    $tax_amount[$i] = 0;
                    $tax_percentage[$i] = 0;
                }
                // process add-ons
                $add_ons = get_cart_add_ons($product_variant[$i]['id'], $product_variant[$i]['product_id'], $data['user_id']);
                if (!empty($add_ons)) {
                    $sum = 0;
                    for ($j = 0; $j < count($add_ons); $j++) {
                        $sum += floatval($add_ons[$j]['price']) * intval($add_ons[$j]['qty']);
                    }
                    $subtotal[$i] += $sum;
                }

                $gross_total += $subtotal[$i];
                $total += $subtotal[$i];
                $total = round($total, 2);
                $gross_total  = round($gross_total, 2);
                array_push($cart_data, array(
                    'name' => $pro_name[$i],
                    'tax_amount' => $tax_amount[$i],
                    'qty' => $quantity[$i],
                    'sub_total' => $subtotal[$i],
                ));
            }
            $system_settings = get_settings('system_settings', true);
            /* Calculating Promo Discount */
            if (isset($data['promo_code']) && !empty($data['promo_code'])) {

                $promo_code = validate_promo_code($data['promo_code'], $data['user_id'], $data['final_total']);

                if ($promo_code['error'] == false) {

                    if ($promo_code['data'][0]['discount_type'] == 'percentage') {
                        $promo_code_discount =  floatval($total  * $promo_code['data'][0]['discount'] / 100);
                    } else {
                        $promo_code_discount = $promo_code['data'][0]['discount'];
                        // $promo_code_discount = floatval($total - $promo_code['data'][0]['discount']);
                    }
                    if ($promo_code_discount <= $promo_code['data'][0]['max_discount_amount']) {
                        $total = floatval($total) - $promo_code_discount;
                    } else {
                        $total = floatval($total) - $promo_code['data'][0]['max_discount_amount'];
                        $promo_code_discount = $promo_code['data'][0]['max_discount_amount'];
                    }
                } else {
                    return $promo_code;
                }
            }
            $delivery_tip = (isset($data['delivery_tip']) && !empty($data['delivery_tip'])) ? $data['delivery_tip'] : 0;

            $final_total = $total + $delivery_charge + $delivery_tip;
            $final_total = round($final_total, 2);
            /* Calculating Wallet Balance */
            $total_payable = $final_total;
            if ($data['is_wallet_used'] == '1' && $data['wallet_balance_used'] <= $final_total) {

                /* function update_wallet_balance($operation,$user_id,$amount,$message="Balance Debited") */
                $wallet_balance = update_wallet_balance('debit', $data['user_id'], $data['wallet_balance_used'], "Used against Order Placement");
                if ($wallet_balance['error'] == false) {
                    $total_payable -= $data['wallet_balance_used'];
                    $Wallet_used = true;
                } else {
                    $response['error'] = true;
                    $response['message'] = $wallet_balance['message'];
                    return $response;
                }
            } else {
                if ($data['is_wallet_used'] == 1) {
                    $response['error'] = true;
                    $response['message'] = 'Wallet Balance should not exceed the total amount';
                    return $response;
                }
            }

            $status = (isset($data['active_status'])) ? $data['active_status'] : 'pending';
            $order_data = [
                'user_id' => $data['user_id'],
                'mobile' => $data['mobile'],
                'total' => $gross_total,
                'promo_discount' => (isset($promo_code_discount) && $promo_code_discount != NULL) ? $promo_code_discount : '0',
                'total_payable' => $total_payable,
                'delivery_charge' => $delivery_charge,
                'is_delivery_charge_returnable' => $data['is_delivery_charge_returnable'],
                'wallet_balance' => (isset($Wallet_used) && $Wallet_used == true) ? $data['wallet_balance_used'] : '0',
                'final_total' => $final_total,
                'discount' => '0',
                'payment_method' => $data['payment_method'],
                'promo_code' => (isset($data['promo_code'])) ? $data['promo_code'] : ' ',
                'otp' => $otp,
                'status' =>  json_encode(array(array($status, date("d-m-Y h:i:sa")))),
                'active_status' => $status,
            ];
            $order_data['delivery_tip'] = $delivery_tip;

            // if address not saved then get current latitude and longitude
            if (isset($data['address_id']) && !empty($data['address_id'])) {
                $order_data['address_id'] = $data['address_id'];
                $address_data = $CI->address_model->get_address('', $data['address_id'], true);
                if (!empty($address_data)) {
                    $order_data['latitude'] = $address_data[0]['latitude'];
                    $order_data['longitude'] = $address_data[0]['longitude'];
                    $order_data['address'] = (!empty($address_data[0]['address'])) ? $address_data[0]['address'] . ', ' : '';
                    $order_data['address'] .= (!empty($address_data[0]['landmark'])) ? $address_data[0]['landmark'] . ', ' : '';
                    $order_data['address'] .= (!empty($address_data[0]['area'])) ? $address_data[0]['area'] . ', ' : '';
                    $order_data['address'] .= (!empty($address_data[0]['city'])) ? $address_data[0]['city'] . ', ' : '';
                    $order_data['address'] .= (!empty($address_data[0]['state'])) ? $address_data[0]['state'] . ', ' : '';
                    $order_data['address'] .= (!empty($address_data[0]['country'])) ? $address_data[0]['country'] . ', ' : '';
                    $order_data['address'] .= (!empty($address_data[0]['pincode'])) ? $address_data[0]['pincode'] : '';
                }
                $order_data['mobile'] = (!empty($address_data[0]['mobile'])) ? $address_data[0]['mobile'] : $data['mobile'];
                $order_data['city_id'] =  $address_data[0]['city_id'];
            } else {
                $order_data['address_id'] = "";
                $order_data['mobile'] = $data['mobile'];
                $order_data['city_id'] = 0;
            }
            if (!empty($_POST['latitude']) && !empty($_POST['longitude'])) {
                $order_data['latitude'] = $_POST['latitude'];
                $order_data['longitude'] = $_POST['longitude'];
            }
            /* check whether points are in delivarable area or not */
            if (!is_order_deliverable($data['address_id'], $order_data['latitude'], $order_data['longitude'], $partner_ids[0])) {
                $response['error'] = true;
                $response['message'] = "Sorry, We are not delivering on selected address!";
                $response['balance'] = "0";
                return $response;
            }
            $order_data['notes'] = $data['order_note'];

            $this->db->insert('orders', $order_data);
            $last_order_id = $this->db->insert_id();

            for ($i = 0; $i < count($product_variant); $i++) {
                $add_ons = get_cart_add_ons($product_variant[$i]['id'], $product_variant[$i]['product_id'], $data['user_id']);
                if ($add_ons == false) {
                    $add_ons = [];
                }
                $product_variant_data[$i] = [
                    'user_id' => $data['user_id'],
                    'order_id' => $last_order_id,
                    'partner_id' => $product_variant[$i]['partner_id'],
                    'product_name' => $product_variant[$i]['product_name'],
                    'variant_name' => $product_variant[$i]['variant_name'],
                    'product_variant_id' => $product_variant[$i]['id'],
                    'quantity' => $quantity[$i],
                    'price' => $pv_price[$i],
                    'tax_percent' => $tax_percentage[$i],
                    'tax_amount' => 0,
                    'sub_total' => $subtotal[$i],
                    'add_ons' => (isset($add_ons) && !empty($add_ons)) ? json_encode($add_ons) : '[]',
                ];
                $this->db->insert('order_items', $product_variant_data[$i]);
                $product_variant_data[$i]['add_ons'] = (isset($add_ons) && !empty($add_ons)) ? $add_ons : [];
            }
            $product_variant_ids = explode(',', $data['product_variant_id']);

            $qtns = explode(',', $data['quantity']);
            update_stock($product_variant_ids, $qtns);

            $this->cart_model->remove_from_cart($data);

            $user_balance = fetch_details(['id' => $data['user_id']], 'users', 'balance');

            $response['error'] = false;
            $response['message'] = 'Order Placed Successfully. It will confirm when partner will accept order. Please, Wait for it!';
            $response['order_id'] = $last_order_id;
            $response['order_item_data'] = $product_variant_data;
            $response['balance'] = $user_balance;
            return $response;
        } else {
            $user_balance = fetch_details(['id' => $data['user_id']], 'users', 'balance');

            $response['error'] = true;
            $response['message'] = "Product(s) Not Found!";
            $response['balance'] = $user_balance;
            return $response;
        }
    }

    public function get_order_details($where = NULL, $status = false)
    {
        $res = $this->db->select('oi.*,o.city_id as user_city,o.latitude as user_lat,o.longitude as user_lng,o.otp as item_otp,a.name as user_name,u.balance as user_balance,oi.id as order_item_id,p.*,v.product_id,o.*,o.id as order_id,o.total as order_total,o.wallet_balance,o.active_status ,u.email,u.username as uname,o.status as order_status,p.name as pname,p.type,p.image as product_image,p.is_prices_inclusive_tax,(SELECT username FROM users db where db.id=o.rider_id ) as rider ')
            ->join('product_variants v ', ' oi.product_variant_id = v.id', 'left')
            ->join('products p ', ' p.id = v.product_id ', 'left')
            ->join('users u ', ' u.id = oi.user_id', 'left')
            ->join('orders o ', 'o.id=oi.order_id', 'left')
            ->join('addresses a', 'a.id=o.address_id', 'left');

        if (isset($where) && $where != NULL) {
            $res->where($where);
            if ($status == true) {
                $res->group_Start()
                    ->where_not_in(' `o`.active_status ', array('cancelled', 'returned'))
                    ->group_End();
            }
        }
        if (!isset($where) && $status == true) {
            $res->where_not_in(' `o`.active_status ', array('cancelled', 'returned'));
        }
        $order_result = $res->get(' `order_items` oi')->result_array();
        if (!empty($order_result)) {
            for ($i = 0; $i < count($order_result); $i++) {
                $order_result[$i] = output_escaping($order_result[$i]);
            }
        }
        return $order_result;
    }

    public function get_orders_list(
        $rider_id = NULL,
        $is_pending = false,
        $rider_city_id = null,
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
                'db.username' => $search,
                'u.email' => $search,
                'o.id' => $search,
                'o.mobile' => $search,
                'o.address' => $search,
                'o.wallet_balance' => $search,
                'o.total' => $search,
                'o.final_total' => $search,
                'o.total_payable' => $search,
                'o.payment_method' => $search,
                'o.delivery_charge' => $search,
                'o.delivery_time' => $search,
                'o.status' => $search,
                'o.active_status' => $search,
                'o.date_added' => $search
            ];
        }

        $count_res = $this->db->select(' COUNT( DISTINCT  o.id) as `total` ')
            ->join(' `users` u', 'u.id= o.user_id', 'left')
            ->join(' `order_items` oi', 'oi.order_id= o.id', 'left')
            ->join('users db ', ' db.id = o.rider_id', 'left');

        if (isset($is_pending)) {
            if ($is_pending == true && !empty($rider_city_id)) {
                $count_res->join('pending_orders po', 'po.order_id=o.id');
                $count_res->where(['po.city_id' => $rider_city_id]);
                $count_res->where_in('o.active_status', ['confirmed', 'preparing']);
            }
        }

        if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {

            $count_res->where(" DATE(o.date_added) >= DATE('" . $_GET['start_date'] . "') ");
            $count_res->where(" DATE(o.date_added) <= DATE('" . $_GET['end_date'] . "') ");
        }

        if (isset($filters) && !empty($filters)) {
            $this->db->group_Start();
            $count_res->or_like($filters);
            $this->db->group_End();
        }

        if (isset($rider_id)) {
            $count_res->where("o.rider_id", $rider_id);
        }

        if (isset($_GET['user_id']) && $_GET['user_id'] != null) {
            $count_res->where("o.user_id", $_GET['user_id']);
        }
        if (isset($_GET['partner_id']) && !empty($_GET['partner_id'])) {
            $count_res->where("oi.partner_id", $_GET['partner_id']);
        }


        $product_count = $count_res->get('`orders` o')->result_array();

        foreach ($product_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' o.* , u.username, db.username as rider')
            ->join(' `users` u', 'u.id= o.user_id', 'left')
            ->join(' `order_items` oi', 'oi.order_id= o.id', 'left')
            ->join('users db ', ' db.id = o.rider_id', 'left');

        if (!empty($_GET['start_date']) && !empty($_GET['end_date'])) {
            $search_res->where(" DATE(o.date_added) >= DATE('" . $_GET['start_date'] . "') ");
            $search_res->where(" DATE(o.date_added) <= DATE('" . $_GET['end_date'] . "') ");
        }

        if (isset($is_pending)) {
            if ($is_pending == true && !empty($rider_city_id)) {
                $search_res->join('pending_orders po', 'po.order_id=o.id');
                $search_res->where(['po.city_id' => $rider_city_id]);
                $search_res->where_in('o.active_status', ['confirmed', 'preparing']);
            }
        }

        if (isset($filters) && !empty($filters)) {
            $search_res->group_Start();
            $search_res->or_like($filters);
            $search_res->group_End();
        }

        if (isset($rider_id)) {
            $search_res->where("o.rider_id", $rider_id);
        }

        if (isset($_GET['order_status']) && !empty($_GET['order_status'])) {
            $search_res->where('o.active_status', $_GET['order_status']);
        }
        if (isset($_GET['user_id']) && !empty($_GET['user_id'])) {
            $search_res->where("o.user_id", $_GET['user_id']);
        }

        if (isset($_GET['partner_id']) && !empty($_GET['partner_id'])) {
            $search_res->where("oi.partner_id", $_GET['partner_id']);
        }

        $user_details = $search_res->group_by('o.id')->order_by($sort, "DESC")->limit($limit, $offset)->get('`orders` o')->result_array();
        $i = 0;
        foreach ($user_details as $row) {
            $user_details[$i]['items'] = $this->db->select('oi.*,p.name as name,p.id as product_id, u.username as uname, us.partner_name as partner , (SELECT status FROM orders o where o.id=oi.order_id  ) as order_status ')
                ->join('product_variants v ', ' oi.product_variant_id = v.id', 'left')
                ->join('products p ', ' p.id = v.product_id ', 'left')
                ->join('users u ', ' u.id = oi.user_id', 'left')
                ->join('partner_data us ', ' us.user_id = oi.partner_id', 'left')
                ->where('oi.order_id', $row['id'])
                ->get(' `order_items` oi  ')->result_array();
            ++$i;
        }

        $bulkData = $rows = $tempRow = array();
        $bulkData['total'] = $total;
        $tota_amount = 0;
        $final_tota_amount = 0;
        $currency_symbol = get_settings('currency');
        foreach ($user_details as $row) {
            if (!empty($row['items'])) {
                $items = $row['items'];
                $items1 = $temp = '';
                $total_amt = $total_qty = 0;
                $partner = $items[0]['partner'];
                $food_name = implode(',', array_column($items, 'product_name'));
                foreach ($items as $item) {
                    $product_variants = get_variants_values_by_id($item['product_variant_id']);
                    $variants = isset($product_variants[0]['variant_values']) && !empty($product_variants[0]['variant_values']) ? str_replace(',', ' | ', $product_variants[0]['variant_values']) : '-';
                    $temp .= "<b>ID :</b>" . $item['id'] . "<b> Product Variant Id :</b> " . $item['product_variant_id'] . "<b> Variants :</b> " . $variants . "<b> Name : </b>" . $item['name'] . " <b>Price : </b>" . $item['price'] . " <b>QTY : </b>" . $item['quantity'] . " <b>Subtotal : </b>" . $item['quantity'] * $item['price'] . "<br>------<br>";
                    $total_amt += $item['sub_total'];
                    $total_qty += $item['quantity'];
                }

                $items1 = $temp;
                $temp = $active_status = '';
                $status = [];
                if (!empty($row['items'][0]['order_status'])) {
                    $status = json_decode($row['items'][0]['order_status'], 1);
                    foreach ($status as $st) {
                        $temp .= @$st[0] . " : " . @$st[1] . "<br>------<br>";
                    }
                }
                if (trim($row['active_status']) == 'pending') {
                    $active_status = '<label class="badge badge-secondary">' . ucwords(str_replace('_', ' ', $row['active_status'])) . '</label>';
                }
                if (trim($row['active_status']) == 'awaiting') {
                    $active_status = '<label class="badge badge-dark">' .ucwords(str_replace('_', ' ', $row['active_status'])) . '</label>';
                }
                if ($row['active_status'] == 'confirmed') {
                    $active_status = '<label class="badge badge-primary">' . ucwords(str_replace('_', ' ', $row['active_status'])) . '</label>';
                }
                if ($row['active_status'] == 'preparing') {
                    $active_status = '<label class="badge badge-info">' . ucwords(str_replace('_', ' ', $row['active_status'])) . '</label>';
                }
                if ($row['active_status'] == 'out_for_delivery') {
                    $active_status = '<label class="badge badge-warning">' . ucwords(str_replace('_', ' ', $row['active_status'])) . '</label>';
                }
                if ($row['active_status'] == 'delivered') {
                    $active_status = '<label class="badge badge-success">' . ucwords(str_replace('_', ' ', $row['active_status'])) . '</label>';
                }
                if ($row['active_status'] == 'cancelled') {
                    $active_status = '<label class="badge badge-danger">' . ucwords(str_replace('_', ' ', $row['active_status'])) . '</label>';
                }
                $discounted_amount = $row['total'] * $row['items'][0]['discount'] / 100;
                $final_total = $row['total'] - $discounted_amount;
                $discount_in_rupees = $row['total'] - $final_total;
                $discount_in_rupees = floor($discount_in_rupees);
                $tempRow['id'] = $row['id'];
                $tempRow['user_id'] = $row['user_id'];
                $tempRow['commission_credited'] = (isset($row['is_credited']) && $row['is_credited'] == 1) ? "<label class='badge badge-success'>Credited </label>" : "<label class='badge badge-secondary'>Not Credited </label>";
                $tempRow['food_name'] = output_escaping(str_replace('\r\n', '</br>', $food_name));;
                $tempRow['delivery_tip'] = (isset($row['delivery_tip']) && !empty($row['delivery_tip'])) ? $row['delivery_tip'] : "0";
                $tempRow['name'] = $row['items'][0]['uname'];
                $tempRow['mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['mobile']) - 3) . substr($row['mobile'], -3) :  $row['mobile'];
                $tempRow['delivery_charge'] = $currency_symbol . ' ' . $row['delivery_charge'];
                $tempRow['items'] = $items1;
                $tempRow['partner'] = output_escaping(str_replace('\r\n', '</br>',  $partner));;
                $tempRow['total'] = $currency_symbol . ' ' . $row['total'];
                $tota_amount += intval($row['total']);
                $tempRow['wallet_balance'] = $currency_symbol . ' ' . $row['wallet_balance'];
                $tempRow['discount'] = $currency_symbol . ' ' . $discount_in_rupees . '(' . $row['items'][0]['discount'] . '%)';
                $tempRow['promo_discount'] = $currency_symbol . ' ' . $row['promo_discount'];
                $tempRow['promo_code'] = $row['promo_code'];
                $tempRow['notes'] = $row['notes'];
                $tempRow['qty'] =  $total_qty;
                $tempRow['final_total'] = $currency_symbol . ' ' . $row['total_payable'];
                $final_tota_amount += intval($row['final_total']);
                $tempRow['deliver_by'] = $row['rider'];
                $tempRow['payment_method'] = $row['payment_method'];
                $tempRow['address'] = output_escaping(str_replace('\r\n', '</br>', $row['address']));
                $tempRow['delivery_date'] = $row['delivery_date'];
                $tempRow['delivery_time'] = $row['delivery_time'];
                $tempRow['admin_commission_amount'] = (isset($row['admin_commission_amount']) && !empty($row['admin_commission_amount'])) ? $row['admin_commission_amount'] : "0";
                $tempRow['partner_commission_amount'] =  (isset($row['partner_commission_amount']) && !empty($row['partner_commission_amount'])) ? $row['partner_commission_amount'] : "0";
                $tempRow['status'] = $status;
                $tempRow['active_status'] = $active_status;
                $tempRow['date_added'] = date('d-m-Y', strtotime($row['date_added']));
                $operate = "";
                if ($this->ion_auth->is_rider()) {
                    if ($is_pending == true) {
                        $operate .= '<a class="btn btn-success btn-xs order_request mr-1" title="Accept" href="javascript:void(0)" data-id="' . $row['id'] . '" data-req_status="1" ><i class="fa fa-check"></i></a>';
                        $operate .= '<a class="btn btn-danger btn-xs order_request mr-1" title="Reject" href="javascript:void(0)" data-id="' . $row['id'] . '" data-req_status="0" ><i class="fa fa-ban"></i></a>';
                    } else {
                        $operate .= '<a href=' . base_url('rider/orders/edit_orders') . '?edit_id=' . $row['id'] . ' class="btn btn-primary btn-xs mr-1 mb-1" title="View"><i class="fa fa-eye"></i></a>';
                    }
                } else if ($this->ion_auth->is_partner()) {
                    $operate = '<a href=' . base_url('partner/orders/edit_orders') . '?edit_id=' . $row['id'] . ' class="btn btn-primary btn-xs mr-1 mb-1" title="View"><i class="fa fa-eye"></i></a>';
                    $operate .= '<a href="' . base_url() . 'partner/invoice?edit_id=' . $row['id'] . '" class="btn btn-info btn-xs mr-1 mb-1" title="Invoice" ><i class="fa fa-file"></i></a>';
                } else if ($this->ion_auth->is_admin()) {
                    $operate = '<a href=' . base_url('admin/orders/edit_orders') . '?edit_id=' . $row['id'] . ' class="btn btn-primary btn-xs mr-1 mb-1" title="View" ><i class="fa fa-eye"></i></a>';
                    $operate .= '<a href="javascript:void(0)" class="delete-orders btn btn-danger btn-xs mr-1 mb-1" data-id=' . $row['id'] . ' title="Delete" ><i class="fa fa-trash"></i></a>';
                    $operate .= '<a href="' . base_url() . 'admin/invoice?edit_id=' . $row['id'] . '" class="btn btn-info btn-xs mr-1 mb-1" title="Invoice" ><i class="fa fa-file"></i></a>';
                } else {
                    $operate = "";
                }
                $tempRow['operate'] = $operate;
                $rows[] = $tempRow;
            }
        }
        if (!empty($user_details)) {
            $tempRow['id'] = '-';
            $tempRow['user_id'] = '-';
            $tempRow['commission_credited'] = '-';
            $tempRow['food_name'] = '-';
            $tempRow['delivery_tip'] = '-';
            $tempRow['name'] = '-';
            $tempRow['mobile'] = '-';
            $tempRow['delivery_charge'] = '-';
            $tempRow['items'] = '-';
            $tempRow['partner'] = '-';
            $tempRow['total'] = '<span class="badge badge-danger">' . $currency_symbol . ' ' . $tota_amount . '</span>';
            $tempRow['wallet_balance'] = '-';
            $tempRow['discount'] = '-';
            $tempRow['promo_discount'] = '-';
            $tempRow['notes'] = '-';
            $tempRow['qty'] = '-';
            $tempRow['final_total'] = '<span class="badge badge-danger">' . $currency_symbol . ' ' . $final_tota_amount . '</span>';
            $tempRow['deliver_by'] = '-';
            $tempRow['payment_method'] = '-';
            $tempRow['address'] = '-';
            $tempRow['delivery_time'] = '-';
            $tempRow['admin_commission_amount'] = '-';
            $tempRow['partner_commission_amount'] = '-';
            $tempRow['status'] = '-';
            $tempRow['active_status'] = '-';
            $tempRow['wallet_balance'] = '-';
            $tempRow['date_added'] = '-';
            $tempRow['operate'] = '-';
            array_push($rows, $tempRow);
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
