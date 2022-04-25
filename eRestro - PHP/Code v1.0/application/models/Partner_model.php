<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Partner_model extends CI_Model
{

    public function __construct()
    {
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function add_partner($data, $profile = [], $timing = [], $tags = [])
    {
        $data = escape_array($data);
        $profile = (!empty($profile)) ? escape_array($profile) : [];
        $timing = (!empty($timing)) ? escape_array($timing) : [];
        $tags = (!empty($tags)) ? escape_array($tags) : [];
        $tempRow = $rows = array();
        $gallery = (isset($data['gallery']) && !empty($data['gallery']) && $data['gallery'] != "") ? $data['gallery'] : [];

        $partner_data = [
            'user_id' => $data['user_id'],
            'national_identity_card' => $data['national_identity_card'],
            'address_proof' => $data['address_proof'],
            'profile' => $data['profile'],
            'commission' => (isset($data['global_commission']) && $data['global_commission'] != "") ? $data['global_commission'] : 0,
            'partner_name' => $data['partner_name'],
            'description' => $data['description'],
            'address' => $data['address'],
            'type' => $data['type'],
            'tax_name' => $data['tax_name'],
            'tax_number' => $data['tax_number'],
            'account_number' => $data['account_number'],
            'account_name' => $data['account_name'],
            'bank_code' => $data['bank_code'],
            'bank_name' => $data['bank_name'],
            'cooking_time' => $data['cooking_time'],
            'pan_number' => $data['pan_number'],
            'gallery' =>  json_encode($gallery),
            'status' => (isset($data['status']) && $data['status'] != "") ? $data['status'] : 2,
            'permissions' => (isset($data['permissions']) && $data['permissions'] != "") ? json_encode($data['permissions']) : null,
            'slug' => $data['slug']
        ];
        if (isset($data['permissions']) && $data['permissions'] == "restro_profile") {
            unset($partner_data['permissions']);
        }

        if (!empty($profile)) {

            $partner_profile = [
                'username' => $profile['name'],
                'email' => $profile['email'],
                'mobile' => $profile['mobile'],
                'latitude' => $profile['latitude'],
                'longitude' => $profile['longitude'],
                'city' => $profile['city'],
            ];
        }
        if (isset($data['edit_restro_data_id'])) {
            if (!empty($timing)) {
                // process working hours for edited hours and new added timings
                delete_details(['partner_id' => $data['user_id']], 'partner_timings');
                foreach ($timing as $row) {
                    $tempRow['partner_id'] = $data['user_id'];
                    $tempRow['day'] = $row['day'];
                    $tempRow['opening_time'] = $row['opening_time'];
                    $tempRow['closing_time'] = $row['closing_time'];
                    $tempRow['is_open'] = $row['is_open'];
                    $rows[] = $tempRow;
                }
                $this->db->insert_batch('partner_timings', $rows);
            }
            if (!empty($tags)) {
                // process tags for edited and newly added tags
                delete_details(['partner_id' => $data['user_id']], 'partner_tags');

                $this->db->insert_batch('partner_tags', $tags);
            }
            if ($this->db->set($partner_profile)->where('id', $data['user_id'])->update('users')) {
                $this->db->set($partner_data)->where('id', $data['edit_restro_data_id'])->update('partner_data');
                return true;
            } else {
                return false;
            }
        } else {
            $this->db->insert('partner_data', $partner_data);
            $insert_id = $this->db->insert_id();
            if (!empty($timing) && !empty($insert_id)) {
                foreach ($timing as $row) {
                    $tempRow['partner_id'] = $data['user_id'];
                    $tempRow['day'] = $row['day'];
                    $tempRow['opening_time'] = $row['opening_time'];
                    $tempRow['closing_time'] = $row['closing_time'];
                    $tempRow['is_open'] = $row['is_open'];
                    $rows[] = $tempRow;
                }
                $this->db->insert_batch('partner_timings', $rows);
            }

            if (isset($tags) && !empty($tags)) {
                $this->db->insert_batch('partner_tags', $tags);
            }
            if (!empty($insert_id)) {
                return  $insert_id;
            } else {
                return false;
            }
        }
    }

    function get_partners_list()
    {
        $offset = 0;
        $limit = 10;
        $sort = 'u.id';
        $order = 'DESC';
        $multipleWhere = '';
        $where = ['u.active' => 1];

        if (isset($_GET['offset']))
            $offset = $_GET['offset'];
        if (isset($_GET['limit']))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($_GET['sort'] == 'id') {
                $sort = "u.id";
            } else {
                $sort = $_GET['sort'];
            }
        if (isset($_GET['order']))
            $order = $_GET['order'];

        if (isset($_GET['search']) and $_GET['search'] != '') {
            $search = $_GET['search'];
            $multipleWhere = ['u.`id`' => $search, 'u.`username`' => $search, 'sd.`partner_name`' => $search, 'u.`email`' => $search, 'u.`mobile`' => $search, 'u.`address`' => $search, 'u.`balance`' => $search];
        }
        if (isset($_GET['status_filter']) and $_GET['status_filter'] != '') {
            $where['sd.status'] = $_GET['status_filter'];
        }

        $count_res = $this->db->select(' COUNT(u.id) as `total` ')->join('users_groups ug', ' ug.user_id = u.id ')->join('partner_data sd', ' sd.user_id = u.id ');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $where['ug.group_id'] = '4';
            $count_res->where($where);
        }

        $offer_count = $count_res->get('users u')->result_array();
        foreach ($offer_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' u.*,sd.* ')->join('users_groups ug', ' ug.user_id = u.id ')->join('partner_data sd', ' sd.user_id = u.id ');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $where['ug.group_id'] = '4';
            $search_res->where($where);
        }

        $offer_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('users u')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        foreach ($offer_search_res as $row) {
            $row = output_escaping($row);
            $operate = " <a href='manage-partner?edit_id=" . $row['user_id'] . "' data-id=" . $row['user_id'] . " class='btn btn-success btn-xs mr-1 mb-1' title='Edit' ><i class='fa fa-pen'></i></a>";
            $operate .= '<a  href="javascript:void(0)" class="delete-restro btn btn-danger btn-xs mr-1 mb-1" title="Delete Restro"   data-id="' . $row['user_id'] . '" ><i class="fa fa-trash"></i></a>';
            if ($row['status'] == '1' || $row['status'] == '0' || $row['status'] == '2') {
                $operate .= '<a  href="javascript:void(0)" class="remove-restro btn btn-warning btn-xs mr-1 mb-1" title="Remove Restro"  data-id="' . $row['user_id'] . '" data-restro_status="' . $row['status'] . '" ><i class="fas fa-user-slash"></i></a>';
            } else if ($row['status'] == '7') {
                $operate .= '<a  href="javascript:void(0)" class="remove-restro btn btn-secondary btn-xs mr-1 mb-1" title="Restore Restro"  data-id="' . $row['user_id'] . '" data-restro_status="' . $row['status'] . '" ><i class="fas fa-user"></i></a>';
            }
            $operate .= '<a href="' . base_url('admin/orders?partner_id=' . $row['user_id']) . '" class="btn btn-primary btn-xs mr-1 mb-1" title="View Orders" ><i class="fa fa-eye"></i></a>';

            $tempRow['id'] = $row['user_id'];
            $tempRow['name'] = $row['username'];
            if (isset($row['email']) && !empty($row['email']) && $row['email'] != "" && $row['email'] != " ") {
                $tempRow['email'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['email']) - 3) . substr($row['email'], -3) : $row['email'];
            } else {
                $tempRow['email'] = "";
            }
            $tempRow['mobile'] = (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($row['mobile']) - 3) . substr($row['mobile'], -3) :  $row['mobile'];
            $tempRow['address'] = $row['address'];
            $tempRow['partner_name'] = $row['partner_name'];
            $tempRow['description'] = $row['description'];
            $tempRow['working_days'] = get_working_hour_format($row['user_id']);
            $tempRow['type'] = $row['type'];
            $tempRow['gallery'] = $row['gallery'];
            $tempRow['account_number'] = $row['account_number'];
            $tempRow['commission'] = $row['commission'];
            $tempRow['account_name'] = $row['account_name'];
            $tempRow['bank_code'] = $row['bank_code'];
            $tempRow['bank_name'] = $row['bank_name'];
            $tempRow['latitude'] = $row['latitude'];
            $tempRow['longitude'] = $row['longitude'];
            $tempRow['tax_name'] = $row['tax_name'];
            $tempRow['rating'] = ' <p> (' . intval($row['rating']) . '/' . $row['no_of_ratings'] . ') </p>';
            $tempRow['tax_number'] = $row['tax_number'];
            $tempRow['pan_number'] = $row['pan_number'];

            // seller status
            if ($row['status'] == 2)
                $tempRow['status'] = "<label class='badge badge-warning'>Not-Approved</label>";
            else if ($row['status'] == 1)
                $tempRow['status'] = "<label class='badge badge-success'>Approved</label>";
            else if ($row['status'] == 0)
                $tempRow['status'] = "<label class='badge badge-danger'>Deactive</label>";
            else if ($row['status'] == 7)
                $tempRow['status'] = "<label class='badge badge-danger'>Removed</label>";


            $row['profile'] = base_url() . $row['profile'];
            $tempRow['profile'] = '<div class="mx-auto product-image"><a href=' . $row['profile'] . ' data-toggle="lightbox" data-gallery="gallery"><img src=' . $row['profile'] . ' class="img-fluid rounded"></a></div>';

            $row['national_identity_card'] = get_image_url($row['national_identity_card']);
            $tempRow['national_identity_card'] = '<div class="mx-auto product-image"><a href=' . $row['national_identity_card'] . ' data-toggle="lightbox" data-gallery="gallery"><img src=' . $row['national_identity_card'] . ' class="img-fluid rounded"></a></div>';

            $row['address_proof'] = get_image_url($row['address_proof']);
            $tempRow['address_proof'] = '<div class="mx-auto product-image"><a href=' . $row['address_proof'] . ' data-toggle="lightbox" data-gallery="gallery"><img src=' . $row['address_proof'] . ' class="img-fluid rounded"></a></div>';

            $tempRow['balance'] = ($row['balance'] == null || $row['balance'] == 0 || empty($row['balance'])) ? "0" : number_format($row['balance'], 2);
            $tempRow['date'] = $row['created_at'];
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }

    function update_balance($amount, $seller_id, $action)
    {
        /**
         * @param
         * action = deduct / add
         */

        if ($action == "add") {
            $this->db->set('balance', 'balance+' . $amount, FALSE);
        } elseif ($action == "deduct") {
            $this->db->set('balance', 'balance-' . $amount, FALSE);
        }
        return $this->db->where('id', $seller_id)->update('users');
    }
    public function get_partners($filter = null, $limit = NULL, $offset = '', $sort = 'u.id', $order = 'DESC', $search = NULL)
    {
        $multipleWhere = '';
        $where = ['u.active' => 1, 'sd.status' => 1, ' p.status' => 1];
        // filter by slug 
        if (isset($filter) && !empty($filter['slug']) && $filter['slug'] != "") {
            $where['sd.slug'] = $filter['slug'];
        }

        //filter by type
        if (isset($filter) && !empty($filter['type']) && $filter['type'] != "") {
            $where['sd.type'] = $filter['type'];
        }
        if (isset($filter) && !empty($filter['city_id']) && $filter['city_id'] != "") {
            $where['u.city'] = $filter['city_id'];
        }
        if (isset($filter) && !empty($filter['id']) && $filter['id'] != "") {
            $where['sd.user_id'] = $filter['id'];
        }
        if (isset($filter) && !empty($filter['vegetarian']) && $filter['vegetarian'] != "") {
            $where['sd.type'] = $filter['vegetarian'];
        }

        if (isset($filter) && !empty($filter['top_rated_partner']) && $filter['top_rated_partner'] == 1) {
            $sort = 'sd.rating';
            $order = "DESC";
        }

        if (isset($search) and $search != '') {
            $multipleWhere = ['u.`id`' => $search, 'u.`username`' => $search, 'u.`email`' => $search, 'u.`mobile`' => $search, 'u.`address`' => $search, 'sd.`address`' => $search, 'u.`balance`' => $search, 'sd.`partner_name`' => $search, 'sd.`description`' => $search];
        }

        $count_res = $this->db->select(' COUNT(DISTINCT u.id) as `total` ')
            ->join('users_groups ug', ' ug.user_id = u.id ')
            ->join('partner_data sd', ' sd.user_id = u.id ')
            ->join('products p', ' p.partner_id = u.id ')
            ->join('cities c', 'c.id = u.city')
            ->join('partner_timings rt', 'rt.partner_id = sd.user_id');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($filter) && !empty($filter['only_opened_partners']) && $filter['only_opened_partners'] != "") {
            $count_res->where("day = DAYNAME(CURDATE())  and opening_time < CURTIME() and is_open=1");
        }
        if (isset($where) && !empty($where)) {
            $where['ug.group_id'] = '4';
            $count_res->where($where);
        }

        $offer_count = $count_res->get('users u')->result_array();
        foreach ($offer_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select(' `u`.username as owner_name,u.id as partner_id,u.email,u.mobile,u.balance,sd.address as partner_address,u.city as city_id,c.name as city_name,u.fcm_id,u.latitude,u.longitude,`sd`.* ')
            ->join('users_groups ug', ' ug.user_id = u.id ')
            ->join('partner_data sd', ' sd.user_id = u.id ')
            ->join('products p', ' p.partner_id = u.id ')
            ->join('cities c', 'c.id = u.city')
            ->join('partner_timings rt', 'rt.partner_id = sd.user_id');


        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($filter) && !empty($filter['only_opened_partners']) && $filter['only_opened_partners'] != "") {
            $search_res->where("day = DAYNAME(CURDATE())  and opening_time < CURTIME() and is_open=1");
        }
        if (isset($where) && !empty($where)) {
            $where['ug.group_id'] = '4';
            $search_res->where($where);
        }

        if (isset($city_id) && !empty($city_id) && $city_id != "") {
            $where['u.city'] = $city_id;
        }

        $restro_search_res = $search_res->group_by('u.id')->order_by($sort, $order)->limit($limit, $offset)->get('users u')->result_array();

        $bulkData = array();
        $bulkData['error'] = (empty($restro_search_res)) ? true : false;
        $bulkData['message'] = (empty($restro_search_res)) ? 'partner(s) does not exist' : 'partner retrieved successfully';
        $bulkData['total'] = (empty($restro_search_res)) ? 0 : $total;
        $rows = $tempRow = array();
        foreach ($restro_search_res as $row) {
            $row = output_escaping($row);
            $gallery = json_decode($row['gallery']);
            $gallery = array_map(function ($value) {
                return base_url() . $value;
            }, $gallery);
            $tempRow['partner_id'] = $row['partner_id'];
            $tempRow['is_restro_open'] = (is_restro_open($row['partner_id']) == true) ? "1" : "0";
            $tempRow['owner_name'] = $row['owner_name'];
            $tempRow['email'] = $row['email'];
            $tempRow['mobile'] = $row['mobile'];
            $tempRow['partner_address'] = $row['partner_address'];
            $tempRow['city_id'] = $row['city_id'];
            $tempRow['city_name'] = $row['city_name'];
            $tempRow['fcm_id'] = $row['fcm_id'];
            $tempRow['latitude'] = $row['latitude'];
            $tempRow['longitude'] = $row['longitude'];
            $tempRow['balance'] =  $row['balance'] == null || $row['balance'] == 0 || empty($row['balance']) ? "0" : number_format($row['balance'], 2);
            $tempRow['slug'] = $row['slug'];
            $tempRow['partner_name'] = $row['partner_name'];
            $tempRow['description'] = $row['description'];
            $tempRow['type'] = $row['type'];
            $tempRow['gallery'] = $gallery;
            $tempRow['partner_rating'] = $row['rating'];
            $tempRow['no_of_ratings'] = $row['no_of_ratings'];
            $tempRow['account_number'] = $row['account_number'];
            $tempRow['account_name'] = $row['account_name'];
            $tempRow['bank_code'] = $row['bank_code'];
            $tempRow['bank_name'] = $row['bank_name'];
            $tempRow['status'] = $row['status'];
            $tempRow['commission'] = $row['commission'];
            $tempRow['partner_profile'] = base_url() . $row['profile'];
            $tempRow['national_identity_card'] = base_url() . $row['national_identity_card'];
            $tempRow['address_proof'] = base_url() . $row['address_proof'];
            $tempRow['tax_number'] = $row['tax_number'];
            $tempRow['date_added'] = $row['date_added'];

            $rows[] = $tempRow;
        }
        $bulkData['data'] = $rows;
        if (!empty($bulkData)) {
            return $bulkData;
        } else {
            return $bulkData;
        }
    }

    function settle_partner_commission()
    {
        $settings = get_settings('system_settings', true);
        $where = "o.active_status='delivered' AND is_credited=0 ";

        $data = $this->db->select(" o.id as order_id,date(o.date_added) as order_date,oi.product_variant_id,oi.partner_id,o.final_total ")
            ->join('product_variants pv', 'pv.id=oi.product_variant_id', 'left')
            ->join('products p', 'p.id=pv.product_id')
            ->join('orders o', 'o.id=oi.order_id')
            ->where($where)->group_by('o.id')
            ->get('order_items oi')->result_array();

        if (empty($data)) {
            $response_data['error'] = false;
            $response_data['message'] = 'All Commission settled or not delivered yet.';
            print_r(json_encode($response_data));
            return false;
        }
        $wallet_updated = false;
        foreach ($data as $row) {
            $global_comm = fetch_details(['user_id' => $row['partner_id']], 'partner_data', 'commission');
            $commission_pr = $global_comm[0]['commission'];
            $commission_amt = intval($row['final_total']) * ($commission_pr / 100);
            $transfer_amt = $row['final_total'] - $commission_amt;

            $response = update_wallet_balance('credit', $row['partner_id'], $transfer_amt, 'Commission Amount Credited for Order ID  : ' . $row['order_id']);
            if ($response['error'] == false) {
                update_details(['is_credited' => 1, 'admin_commission_amount' => $commission_amt, "partner_commission_amount" => $transfer_amt], ['id' => $row['order_id']], 'orders');
                $wallet_updated = true;
                $response_data['error'] = false;
                $response_data['message'] = 'Commission settled Successfully';
            } else {
                $wallet_updated = false;
                $response_data['error'] =  true;
                $response_data['message'] =  'Commission not settled';
            }
        }
        if ($wallet_updated == true) {
            $partner_ids = array_values(array_unique(array_column($data, "partner_id")));
            foreach ($partner_ids as $seller) {
                $settings = get_settings('system_settings', true);
                $app_name = isset($settings['app_name']) && !empty($settings['app_name']) ? $settings['app_name'] : '';
                $user_res = fetch_details(['id' => $seller], 'users', 'username,fcm_id,email');
                send_mail($user_res[0]['email'], 'Commission Amount Credited', 'Commission Amount Credited, which orders are delivered. Please take note of it! Regards ' . $app_name . '');
                $fcm_ids = array();
                if (!empty($user_res[0]['fcm_id'])) {
                    $fcmMsg = array(
                        'title' => "Commission Amount Credited",
                        'body' => 'Hello Dear ' . $user_res[0]['username'] . ' Commission Amount Credited, which orders are delivered. Please take note of it! Regards ' . $app_name . '',
                        'type' => "commission",
                        'content_available' => true
                    );
                    $fcm_ids[0][] = $user_res[0]['fcm_id'];
                    send_notification($fcmMsg, $fcm_ids);
                }
            }
        } else {
            $response_data['error'] =  true;
            $response_data['message'] =  'Commission not settled!';
        }
        print_r(json_encode($response_data));
    }
}
