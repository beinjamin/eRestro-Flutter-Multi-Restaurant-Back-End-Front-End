<?php
defined('BASEPATH') or exit('No direct script access allowed');

/*
	1. create_unique_slug($string,$table,$field='slug',$key=NULL,$value=NULL)
	2. get_settings($type = 'store_settings', $is_json = false)
	3. get_logo()
	4. fetch_details($where = NULL,$table,$fields = '*')
	5. fetch_product($user_id = NULL, $filter = NULL, $id = NULL, $category_id = NULL, $limit = NULL, $offset = NULL, $sort = NULL, $order = NULL, $return_count = NULL)
	6. update_details($set,$where,$table)
	7. delete_image($id,$path,$field,$img_name,$table_name,$isjson = TRUE)
	8. delete_details($where,$table)
	9. is_json($data=NULL)
   10. validate_promo_code($promo_code,$user_id,$final_total)
   11. update_wallet_balance($operation,$user_id,$amount,$message="Balance Debited")
   12. send_notification($fcmMsg, $registrationIDs_chunks)
   13. get_attribute_values_by_pid($id)
   14. get_attribute_values_by_id($id)
   15. get_variants_values_by_pid($id)
   16. update_stock($product_variant_ids, $qtns)
   17. validate_stock($product_variant_ids, $qtns)
   18. stock_status($product_variant_id)
   19. verify_user($data)
   20. edit_unique($field,$table,$except)
   21. validate_order_status($order_ids, $status, $table = 'order_items', $user_id = null)
   22. is_exist($where,$table) 
   23. get_categories_option_html($categories, $selected_vals = null)
   24. get_subcategory_option_html($subcategories, $selected_vals)
   25. get_cart_total($user_id,$product_variant_id)
   26. get_frontend_categories_html()
   27. get_frontend_subcategories_html($subcategories)
   28. resize_image($image_data, $source_path, $id = false)
   29. has_permissions($role,$module) 
   30. print_msg($error,$message)
   31. get_system_update_info()
   32. send_mail($to,$subject,$message)
   33. fetch_orders($order_id = NULL, $user_id = NULL, $status = NULL, $rider_id = NULL, $limit = NULL, $offset = NULL, $sort = NULL, $order = NULL, $download_invoice = false)
   34. find_media_type($extenstion)
   35. formatBytes($size, $precision = 2)
   36. delete_images($subdirectory, $image_name)
   37. get_image_url($path, $image_type = '', $image_size = '')
   38. fetch_users($id)
   39. escape_array($array)
   40. allowed_media_types()
   41. get_current_version()
   42. resize_review_images($image_data, $source_path, $id = false)
   43. get_invoice_html($order_id)
   44. is_modification_allowed($module)
   45. output_escaping($array)
   46. get_min_max_price_of_product($product_id = '')
   47. find_discount_in_percentage($special_price, $price)
   48. get_attribute_ids_by_value($values,$names)
   49. insert_details($data,$table)
   50. get_category_id_by_slug($slug)
   51. get_variant_attributes($product_id)
   52. get_product_variant_details($product_variant_id)
   53. get_cities($id = NULL, $limit = NULL, $offset = NULL)
   54. get_favorites($user_id, $type = 'products', $limit = NULL, $offset = NULL)
   55. current_theme($id='',$name='',$slug='',$is_default=1,$status='')
   56. get_languages($id='',$language_name='',$code='',$is_rtl='')
   60. verify_payment_transaction($txn_id,$payment_method)
   61. process_referral_bonus($user_id, $order_id, $status)
   62. process_refund($id, $status, $type = 'order_items')
   63. get_user_balance($id)
   64. get_stock()
   65. get_delivery_charge($address_id)
   66. validate_otp($order_id, $otp)
   67. is_product_delivarable($type, $type_id, $product_id)
   68. check_cart_products_delivarable($area_id, $user_id)
   69. orders_count($status = "")
   70. curl($url, $method = 'GET', $data = [], $authorization = "")
   71. get_partner_permission($seller_id, $permit = NULL)
   72. get_price($type = "max")
   73. check_for_parent_id($category_id)
   74. update_balance($amount, $rider_id, $action)
   75. get_working_hour_format($restro_id, $is_time = false)
   76. get_working_hour_html($restro_id = "", $is_time = true)
   77. is_in_polygon($points_polygon, $vertices_x, $vertices_y, $longitude_x, $latitude_y)
   78. is_restro_open($id)
   79. is_order_in_valid_area($address_id, $longitude_x, $latitude_y)
   80. distance($lat1, $lon1, $lat2, $lon2, $unit)
   81. is_single_seller($product_variant_id, $user_id)
*/

function create_unique_slug($string, $table, $field = 'slug', $key = NULL, $value = NULL)
{
    $t = &get_instance();
    $slug = url_title($string);
    $slug = strtolower($slug);
    $i = 0;
    $params = array();
    $params[$field] = $slug;

    if ($key) $params["$key !="] = $value;

    while ($t->db->where($params)->get($table)->num_rows()) {
        if (!preg_match('/-{1}[0-9]+$/', $slug))
            $slug .= '-' . ++$i;
        else
            $slug = preg_replace('/[0-9]+$/', ++$i, $slug);

        $params[$field] = $slug;
    }
    return $slug;
}

function get_settings($type = 'system_settings', $is_json = false)
{
    $t = &get_instance();

    $res = $t->db->select(' * ')->where('variable', $type)->get('settings')->result_array();
    if (!empty($res)) {
        if ($is_json) {
            return json_decode($res[0]['value'], true);
        } else {
            return output_escaping($res[0]['value']);
        }
    }
}


function get_logo()
{
    $t = &get_instance();
    $res = $t->db->select(' * ')->where('variable', 'logo')->get('settings')->result_array();
    if (!empty($res)) {
        $logo['is_null'] = FALSE;
        $logo['value'] = base_url() . $res[0]['value'];
    } else {
        $logo['is_null'] = TRUE;
        $logo['value'] = base_url() . NO_IMAGE;
    }
    return $logo;
}

function fetch_details($where = NULL, $table, $fields = '*', $limit = '', $offset = '', $sort = '', $order = '', $where_in_key = '', $where_in_value = '', $join_table_with_alias = "", $on = "", $is_left = false, $group_by = NULL)
{
    $t = &get_instance();
    $t->db->select($fields);
    if (!empty($join_table_with_alias) && !empty($on) && $on != "" && $join_table_with_alias != "") {
        $t->db->join($join_table_with_alias, $on, $is_left);
    }
    if (!empty($where)) {
        $t->db->where($where);
    }

    if (!empty($where_in_key) && !empty($where_in_value)) {
        $t->db->where_in($where_in_key, $where_in_value);
    }

    if (!empty($limit)) {
        $t->db->limit($limit);
    }

    if (!empty($offset)) {
        $t->db->offset($offset);
    }

    if (!empty($order) && !empty($sort)) {
        $t->db->order_by($sort, $order);
    }
    if (!empty($group_by) && !empty($group_by) && $group_by != "") {
        $t->db->group_by($group_by);
    }

    $res = $t->db->get($table)->result_array();
    return $res;
}

function fetch_product($user_id = NULL, $filter = NULL, $id = NULL, $category_id = NULL, $limit = NULL, $offset = NULL, $sort = NULL, $order = NULL, $return_count = NULL, $is_deliverable = NULL, $partner_id = NULL, $sort_by = "sd.user_id")
{
    $settings = get_settings('system_settings', true);
    $low_stock_limit = isset($settings['low_stock_limit']) ? $settings['low_stock_limit'] : 5;
    $t = &get_instance();

    // 1. sort product wise done
    if ($sort == 'pv.price' && !empty($sort) && $sort != NULL) {
        $t->db->order_by("IF( pv.special_price > 0 , pv.special_price , pv.price )" . $order, False);
    }

    //2. status wise products done
    if (isset($filter['show_only_active_products']) && $filter['show_only_active_products'] == 0) {
        $where = [];
    } else {
        $where = ['p.status' => '1', 'pv.status' => 1, 'sd.status' => 1];
    }

    // 3. discount filter done
    $discount_filter_data = (isset($filter['discount']) && !empty($filter['discount'])) ? ' ( if(pv.special_price > 0,( (pv.price-pv.special_price)/pv.price)*100,0)) as cal_discount_percentage, ' : '';

    $t->db->select($discount_filter_data . ' (select count(id)  from products where products.category_id=c.id ) as total,count(p.id) as sales, p.stock_type,p.calories,p.status ,p.is_prices_inclusive_tax,p.tax as tax_id, p.type ,GROUP_CONCAT(DISTINCT(pa.attribute_value_ids)) as attr_value_ids, p.partner_id,p.id,p.stock,p.name,p.category_id,p.short_description,p.slug,p.total_allowed_quantity,p.minimum_order_quantity,p.quantity_step_size,p.cod_allowed,p.row_order,p.rating,p.no_of_ratings,p.image,p.is_cancelable,p.cancelable_till,p.indicator, p.highlights,p.availability,c.name as category_name,tax.percentage as tax_percentage ')
        ->join(" categories c", "p.category_id=c.id ", 'LEFT')
        ->join(" partner_data sd", "p.partner_id=sd.user_id ")
        ->join(" users u", "p.partner_id=u.id")
        ->join('`product_variants` pv', 'p.id = pv.product_id', 'LEFT')
        ->join('`taxes` tax', 'tax.id = p.tax', 'LEFT')
        ->join('`product_attributes` pa', ' pa.product_id = p.id ', 'LEFT');

    // 4. feature section most selling products remain
    if (isset($filter) && !empty($filter['product_type']) && strtolower($filter['product_type']) == 'most_ordered_foods') {
        $t->db->join('`order_items` oi', 'oi.product_variant_id = pv.id', 'LEFT');
        $sort = 'count( DISTINCT p.id)';
        $order = 'DESC';
    }

    // 5. search highlights wise done
    if (isset($filter) && !empty($filter['search'])) {
        $highlights = explode(" ", $filter['search']);
        $t->db->group_Start();
        foreach ($highlights as $i => $tag) {
            if ($i == 0) {
                $t->db->like('p.highlights', trim($tag));
            } else {
                $t->db->or_like('p.highlights', trim($tag));
            }
        }
        $t->db->or_like('p.name', trim($filter['search']));
        $t->db->or_like('sd.partner_name', trim($filter['search']));
        $t->db->group_end();
    }

    // search by tags done
    if (isset($filter) && !empty($filter['tags'])) {
        $p_tags = explode(",", $filter['tags']);
        $t->db->join('`product_tags` pt', 'pt.product_id = p.id', 'LEFT');
        $t->db->join('`partner_tags` rt', 'rt.partner_id = sd.user_id', 'LEFT');
        $t->db->join('`tags` tg', 'tg.id = pt.tag_id', 'LEFT');
        $t->db->join('`tags` tg2', 'tg2.id = rt.tag_id', 'LEFT');
        $t->db->group_Start();
        foreach ($p_tags as $i => $tag) {
            if ($i == 0) {
                $t->db->like('tg.title', trim($tag));
            } else {
                $t->db->or_like('tg.title', trim($tag));
            }
        }
        $t->db->group_end();
    }

    // 6 limit stock and out of stock filter
    if (isset($filter) && !empty($filter['flag']) && $filter['flag'] != "null" && $filter['flag'] != "") {
        $flag = $filter['flag'];
        if ($flag == 'low') {
            $t->db->group_Start();
            $where1 = "p.stock_type is  NOT NULL";
            $t->db->where($where1);
            $t->db->where('p.stock <=', $low_stock_limit);
            $t->db->where('p.availability =', '1');
            $t->db->group_End();
        } else {
            $where2 = "p.stock_type is  NOT NULL";
            $t->db->where($where2);
            $t->db->where('p.stock ', '0');
            $t->db->where('p.availability ', '0');
            $t->db->or_where('pv.stock ', '0');
            $t->db->where('pv.availability', '0');
        }
    }

    // 7. min price and mx price (range) filter done
    if (isset($filter['min_price']) && $filter['min_price'] > 0) {
        $min_price = $filter['min_price'];
        $where_min = "if( pv.special_price > 0 , pv.special_price , pv.price ) >=$min_price";
        $t->db->group_Start();
        $t->db->where($where_min);
        $t->db->group_End();
    }
    if (isset($filter['max_price']) && $filter['max_price'] > 0 && isset($filter['min_price']) && $filter['min_price'] > 0) {
        $max_price = $filter['max_price'];
        $where_max = "if( pv.special_price > 0 , pv.special_price , pv.price ) <=$max_price";
        $t->db->group_Start();
        $t->db->where($where_max);
        $t->db->group_End();
    }

    // 8. highlights filter done
    if (isset($filter) && !empty($filter['highlights'])) {
        $highlights = explode(",", $filter['highlights']);
        $t->db->group_Start();
        foreach ($highlights as $i => $tag) {
            if ($i == 0) {
                $t->db->like('p.highlights', trim($tag));
            } else {
                $t->db->or_like('p.highlights', trim($tag));
            }
        }
        $t->db->group_end();
    }

    // 9. slug filter done
    if (isset($filter) && !empty($filter['slug'])) {
        $where['p.slug'] = $filter['slug'];
    }

    // 10. reasturant wise products done
    if (isset($partner_id) && !empty($partner_id) && $partner_id != "") {
        $where['p.partner_id'] = $partner_id;
    }

    //city wise products and restro done
    if (isset($filter) && !empty($filter['city_id']) && $filter['city_id'] != "") {
        $where['u.city'] = $filter['city_id'];
    }

    // 11. attribute id wise filter  done
    if (isset($filter) && !empty($filter['attribute_value_ids'])) {
        /* https://stackoverflow.com/questions/5015403/mysql-find-in-set-with-multiple-search-string */
        $str = str_replace(',', '|', $filter['attribute_value_ids']); //str_replace(find,replace,string,count)
        $t->db->where('CONCAT(",", pa.attribute_value_ids , ",") REGEXP ",(' . $str . ')," !=', 0, false);
    }

    // 12 category id wise done
    if (isset($category_id) && !empty($category_id)) {
        if (is_array($category_id) && !empty($category_id)) {
            $t->db->group_Start();
            $t->db->where_in('p.category_id', $category_id);
            $t->db->or_where_in('c.parent_id', $category_id);
            $t->db->group_End();
            $t->db->where($where);
        } else {
            $where['p.category_id'] = $category_id;
        }
    }

    // 13 featured section filter  
    if (isset($filter) && !empty($filter['product_type']) && strtolower($filter['product_type']) == 'food_on_offer') {
        $t->db->where('pv.special_price >', '0');
        $t->db->where('pv.price > pv.special_price');
    }

    // vegetarian filter 
    if (isset($filter) && $filter['vegetarian'] != "") {
        if ($filter['vegetarian'] == "3") {
            $t->db->where('sd.type ', $filter['vegetarian']);
        } else {
            $t->db->where('p.indicator ', $filter['vegetarian']);
            $t->db->where('sd.type ', $filter['vegetarian']);
        }
    }

    // 14 featured section filter 
    if (isset($filter) && !empty($filter['product_type']) && strtolower($filter['product_type']) == 'top_rated_foods') {
        $sort = null;
        $order = null;
        $t->db->order_by("p.rating", "desc");
        $t->db->order_by("p.no_of_ratings", "desc");
        // $where = ['p.no_of_ratings > ' => 0];
        $where['p.no_of_ratings > '] = 0;
    }

    // 15 top_rated products of feature section 
    if (isset($filter) && !empty($filter['product_type']) && strtolower($filter['product_type']) == 'top_rated_foods_including_all_foods') {
        $sort = null;
        $order = null;
        $t->db->order_by("p.rating", "desc");
        $t->db->order_by("p.no_of_ratings", "desc");
        $where['p.no_of_ratings > '] = 0;
    }

    //16 feature section filter  
    if (isset($filter) && !empty($filter['product_type']) && $filter['product_type'] == 'new_added_foods') {
        $sort = 'p.id';
        $order = 'desc';
    }

    //17 varient id wise filter done
    if (isset($filter) && !empty($filter['product_variant_ids'])) {
        if (is_array($filter['product_variant_ids'])) {
            $t->db->where_in('pv.id', $filter['product_variant_ids']);
        }
    }

    // filter array of product id, similar product and  perticular id done
    if (isset($id) && !empty($id) && $id != null) {
        if (is_array($id) && !empty($id)) {
            $t->db->where_in('p.id', $id);
            $t->db->where($where);
        } else {
            if (isset($filter) && !empty($filter['is_similar_products']) && $filter['is_similar_products'] == '1') {
                $where[' p.id != '] = $id;
            } else {
                $where['p.id'] = $id;
            }
            $t->db->where($where);
        }
    } else {
        $t->db->where($where);
    }
    if (!isset($filter['flag']) && empty($filter['flag'])) {
        $t->db->group_Start();
        $t->db->or_where('c.status', '1');
        $t->db->or_where('c.status', '0');
        $t->db->group_End();
    }

    // discount filter group by
    if (isset($filter['discount']) && !empty($filter['discount']) && $filter['discount'] != "") {
        $discount_pr = $filter['discount'];
        $t->db->group_by($sort_by)->having("cal_discount_percentage  <= " . $discount_pr, null, false)->having("cal_discount_percentage  > 0 ", null, false);
    } else {
        $t->db->group_by($sort_by);
    }


    if ($limit != null || $offset != null) {
        $t->db->limit($limit, $offset);
    }
    if (isset($filter['discount']) && !empty($filter['discount']) && $filter['discount'] != "") {
        $t->db->order_by('cal_discount_percentage', 'DESC');
    } else {
        if ($sort != null || $order != null && $sort != 'pv.price') {
            $t->db->order_by($sort, $order);
        }
        $t->db->order_by('p.row_order', 'ASC');
    }

    if (!empty($return_count)) {
        return $t->db->count_all_results('products p');
    } else {
        $product = $t->db->get('products p')->result_array();
    }
    $discount_filter = (isset($filter['discount']) && !empty($filter['discount'])) ? ' , GROUP_CONCAT( IF( ( IF( pv.special_price > 0, ((pv.price - pv.special_price) / pv.price) * 100, 0 ) ) > ' . $filter['discount'] . ', ( IF( pv.special_price > 0, ((pv.price - pv.special_price) / pv.price) * 100, 0 ) ), 0 ) ) AS cal_discount_percentage ' : '';
    $product_count = $t->db->select('count(DISTINCT(p.id)) as total , GROUP_CONCAT(pa.attribute_value_ids) as attr_value_ids' . $discount_filter)
        ->join(" categories c", "p.category_id=c.id ", 'LEFT')
        ->join(" partner_data sd", "p.partner_id=sd.user_id ")
        ->join('`product_variants` pv', 'p.id = pv.product_id', 'LEFT')
        ->join(" users u", "p.partner_id=u.id")
        ->join('`taxes` tax', 'tax.id = p.tax', 'LEFT')
        ->join('`product_attributes` pa', ' pa.product_id = p.id ', 'LEFT');

    if (isset($filter) && !empty($filter['search'])) {
        $highlights = explode(" ", $filter['search']);
        $t->db->group_Start();
        foreach ($highlights as $i => $tag) {
            if ($i == 0) {
                $t->db->like('p.highlights', trim($tag));
            } else {
                $t->db->or_like('p.highlights', trim($tag));
            }
        }
        $product_count->or_like('p.name', $filter['search']);
        $product_count->or_like('sd.partner_name', $filter['search']);
        $t->db->group_End();
    }
    if (isset($filter) && !empty($filter['flag'])) {
        $flag = $filter['flag'];
        if ($flag == 'low') {
            $t->db->group_Start();
            $where1 = "p.stock_type is  NOT NULL";
            $t->db->where($where1);
            $t->db->where('p.stock <=', $low_stock_limit);
            $t->db->where('p.availability =', '1');
            $t->db->group_End();
        } else {
            $t->db->group_Start();
            $t->db->or_where('p.availability ', '0');
            $t->db->where('p.stock ', '0');
            $t->db->group_End();
        }
    }

    if (isset($filter) && !empty($filter['highlights'])) {
        $highlights = explode(",", $filter['highlights']);
        $t->db->group_Start();
        foreach ($highlights as $i => $tag) {
            if ($i == 0) {
                $t->db->like('p.highlights', trim($tag));
            } else {
                $t->db->or_like('p.highlights', trim($tag));
            }
        }
        $t->db->group_End();
    }

    if (isset($filter) && !empty($filter['attribute_value_ids'])) {
        $str = str_replace(',', '|', $filter['attribute_value_ids']); // Ids should be in string and comma separated 
        $product_count->where('CONCAT(",", pa.attribute_value_ids, ",") REGEXP ",(' . $str . ')," !=', 0, false);
    }
    if (isset($filter) && !empty($filter['product_type']) && strtolower($filter['product_type']) == 'most_selling_products') {
        $product_count->join('`order_items` oi', 'oi.product_variant_id = pv.id', 'LEFT');
    }
    if (isset($category_id) && !empty($category_id)) {
        if (is_array($category_id) && !empty($category_id)) {
            $product_count->where_in('p.category_id', $category_id);
            $product_count->or_where_in('c.parent_id', $category_id);
            $product_count->where($where);
        }
    }

    if (isset($filter) && !empty($filter['product_type']) && strtolower($filter['product_type']) == 'food_on_offer') {
        $product_count->where('pv.special_price >', '0');
        $product_count->where('pv.price > pv.special_price');
    }
    if (isset($id) && !empty($id) && $id != null) {
        if (is_array($id) && !empty($id)) {
            $product_count->where_in('p.id', $id);
        }
    }
    if (isset($partner_id) && !empty($partner_id) && $partner_id != "") {
        $where['p.partner_id'] = $partner_id;
    }

    $product_count->where($where);
    if (!isset($filter['flag']) && empty($filter['flag'])) {
        $product_count->group_Start();
        $product_count->or_where('c.status', '1');
        $product_count->or_where('c.status', '0');
        $product_count->group_End();
    }

    $count_res = $product_count->get('products p')->result_array();

    $attribute_values_ids = array();
    $min_price = get_price('min');
    $max_price = get_price('max');

    if (!empty($product)) {
        $t->load->model('rating_model');
        for ($i = 0; $i < count($product); $i++) {
            $rating = $t->rating_model->fetch_rating($product[$i]['id'], '', 8, 0, 'pr.id', 'desc', '', 1);
            $product[$i]['review_images'] = (!empty($rating)) ? [$rating] : array();
            $product[$i]['tax_percentage'] = (isset($product[$i]['tax_percentage']) && intval($product[$i]['tax_percentage']) > 0) ? $product[$i]['tax_percentage'] : '0';
            $product[$i]['attributes'] = get_attribute_values_by_pid($product[$i]['id']);
            $product[$i]['product_add_ons'] = fetch_details(['product_id' => $product[$i]['id'], 'status' => 1], 'product_add_ons', 'id,product_id,title,description,price,calories');
            $product[$i]['variants'] = get_variants_values_by_pid($product[$i]['id']);
            $product[$i]['min_max_price'] = get_min_max_price_of_product($product[$i]['id']);
            $product[$i]['stock_type'] = isset($product[$i]['stock_type']) && !empty($product[$i]['stock_type']) ? $product[$i]['stock_type'] : '';
            $product[$i]['indicator'] = isset($product[$i]['indicator']) && !empty($product[$i]['indicator']) ? $product[$i]['indicator'] : '';
            $product[$i]['stock'] = isset($product[$i]['stock']) && !empty($product[$i]['stock']) ? $product[$i]['stock'] : '';
            $product[$i]['calories'] = isset($product[$i]['calories']) && !empty($product[$i]['calories']) ? $product[$i]['calories'] : '0';
            $product[$i]['total_allowed_quantity'] = isset($product[$i]['total_allowed_quantity']) && !empty($product[$i]['total_allowed_quantity']) ? $product[$i]['total_allowed_quantity'] : '';
            $product[$i]['relative_path'] = isset($product[$i]['image']) && !empty($product[$i]['image']) ? $product[$i]['image'] : [];
            $product[$i]['other_images_relative_path'] = isset($product[$i]['other_images']) && !empty($product[$i]['other_images']) ? json_decode($product[$i]['other_images']) : [];
            /* outputing escaped data */
            $product[$i]['name'] = output_escaping($product[$i]['name']);
            $product[$i]['status'] = $product[$i]['status'];

            /* fetch restro details */
            $restro_filter['id'] = $product[$i]['partner_id'];
            if (isset($filter) && !empty($filter['latitude']) && !empty($filter['longitude'])) {
                $restro_filter['latitude'] = $filter['latitude'];
                $restro_filter['longitude'] = $filter['longitude'];
            }
            $user_id_restro = "";
            if (isset($user_id) && !empty($user_id) && $user_id != "") {
                $user_id_restro = $user_id;
            }
            $restro_data = fetch_partners($restro_filter, $user_id_restro);
            if (!empty($restro_data) && !empty($restro_data['data'])) {
                $product[$i]['partner_details'] = $restro_data['data'];
            } else {
                $product[$i]['partner_details'] = [];
            }
            $product[$i]['short_description'] = output_escaping($product[$i]['short_description']);

            if (isset($filter['discount']) && !empty($filter['discount']) && $filter['discount'] != "") {
                $product[$i]['cal_discount_percentage'] = output_escaping(number_format($product[$i]['cal_discount_percentage'], 2));
            }

            $product[$i]['cancelable_till'] = isset($product[$i]['cancelable_till']) && !empty($product[$i]['cancelable_till']) ? $product[$i]['cancelable_till'] : '';
            $product[$i]['availability'] = (isset($product[$i]['availability']) && $product[$i]['availability'] != "") ? strval($product[$i]['availability']) : '';
            $product[$i]['rating'] = output_escaping(number_format($product[$i]['rating'], 2));

            $product[$i]['category_name'] =  isset($product[$i]['category_name']) && !empty($product[$i]['category_name']) ? output_escaping($product[$i]['category_name']) : ''; //zipcode123            
            $product[$i]['highlights'] = (!empty($product[$i]['highlights'])) ? explode(",", $product[$i]['highlights']) : [];

            $product[$i]['minimum_order_quantity'] = isset($product[$i]['minimum_order_quantity']) && (!empty($product[$i]['minimum_order_quantity'])) ? $product[$i]['minimum_order_quantity'] : 1;
            $product[$i]['quantity_step_size'] = isset($product[$i]['quantity_step_size']) && (!empty($product[$i]['quantity_step_size'])) ? $product[$i]['quantity_step_size'] : 1;
            if (!empty($product[$i]['variants'])) {
                $count_stock = array();
                $is_purchased_count = array();
                for ($k = 0; $k < count($product[$i]['variants']); $k++) {

                    unset($product[$i]['variants'][$k]['images']);
                    if (($product[$i]['stock_type'] == 0  || $product[$i]['stock_type'] == null)) {
                        if ($product[$i]['availability'] != null) {
                            $product[$i]['variants'][$k]['availability'] = $product[$i]['availability'];
                        }
                    } else {
                        $product[$i]['variants'][$k]['availability'] = ($product[$i]['variants'][$k]['availability'] != null) ? $product[$i]['variants'][$k]['availability'] : "1";
                        array_push($count_stock, $product[$i]['variants'][$k]['availability']);
                    }
                    if (($product[$i]['stock_type'] == 0)) {
                        $product[$i]['variants'][$k]['stock'] = get_stock($product[$i]['id'], 'product');
                    } else {
                        $product[$i]['variants'][$k]['stock'] = get_stock($product[$i]['variants'][$k]['id'], 'variant');
                    }
                    $percentage = (isset($product[$i]['tax_percentage']) && intval($product[$i]['tax_percentage']) > 0 && $product[$i]['tax_percentage'] != null) ? $product[$i]['tax_percentage'] : '0';
                    if ((isset($product[$i]['is_prices_inclusive_tax']) && $product[$i]['is_prices_inclusive_tax'] == 0) || (!isset($product[$i]['is_prices_inclusive_tax'])) && $percentage > 0) {
                        $price_tax_amount = $product[$i]['variants'][$k]['price'] * ($percentage / 100);
                        $product[$i]['variants'][$k]['price'] =  strval($product[$i]['variants'][$k]['price'] + $price_tax_amount);
                        $special_price_tax_amount = $product[$i]['variants'][$k]['special_price'] * ($percentage / 100);
                        $product[$i]['variants'][$k]['special_price'] =  strval($product[$i]['variants'][$k]['special_price'] + $special_price_tax_amount);
                    }
                    $product[$i]['variants'][$k]['stock'] =  isset($product[$i]['variants'][$k]['stock']) && !empty($product[$i]['variants'][$k]['stock']) ? $product[$i]['variants'][$k]['stock'] : '';

                    /* check user details if user id passed */
                    if (isset($user_id) && $user_id != NULL) {
                        /* get cart total */
                        $user_cart_data = get_cart_total($user_id, $product[$i]['variants'][$k]['id']);
                        if (!empty($user_cart_data)) {
                            $product[$i]['variants'][$k]['cart_count'] = $user_cart_data['quantity'];
                        } else {
                            $product[$i]['variants'][$k]['cart_count'] = "0";
                        }
                        /** get add details of user */
                        $add_ons_data = get_product_add_ons($product[$i]['variants'][$k]['id'], $product[$i]['variants'][$k]['product_id'], $user_id);
                        if (!empty($add_ons_data)) {
                            $product[$i]['variants'][$k]['add_ons_data'] = $add_ons_data;
                        } else {
                            $product[$i]['variants'][$k]['add_ons_data'] = [];
                        }
                        /* get purchase status of product */
                        $is_purchased = $t->db->where(['oi.product_variant_id' => $product[$i]['variants'][$k]['id'], 'oi.user_id' => $user_id])->limit(1)->get('order_items oi')->result_array();
                        if (!empty($is_purchased)) {
                            array_push($is_purchased_count, 1);
                            $product[$i]['variants'][$k]['is_purchased'] = 1;
                        } else {
                            array_push($is_purchased_count, 0);
                            $product[$i]['variants'][$k]['is_purchased'] = 0;
                        }

                        $user_rating = $t->db->select('rating,comment')->where(['user_id' => $user_id, 'product_id' => $product[$i]['id']])->get('product_rating')->result_array();
                        if (!empty($user_rating)) {

                            $product[$i]['user']['user_rating'] = $user_rating[0]['rating'];
                            $product[$i]['user']['user_comment'] = (isset($user_rating[0]['comment']) && !empty($user_rating[0]['comment'])) ? output_escaping($user_rating[0]['comment']) : '';
                        }
                    } else {
                        $product[$i]['variants'][$k]['cart_count'] = "0";
                    }
                }
            }

            $is_purchased_count = array_count_values($is_purchased_count);
            $is_purchased_count = array_keys($is_purchased_count);
            $product[$i]['is_purchased'] = (isset($is_purchased) && array_sum($is_purchased_count) == 1) ? true : false;

            if (($product[$i]['stock_type'] != null && !empty($product[$i]['stock_type']))) {
                //Case 2 & 3 : Product level(variable product) ||  Variant level(variable product)
                if ($product[$i]['stock_type'] == 1 || $product[$i]['stock_type'] == 2) {
                    $counts = array_count_values($count_stock);
                    $counts = array_keys($counts);
                    if (isset($counts)) {
                        $product[$i]['availability'] = strval(array_sum($counts));
                    }
                }
            }

            if (isset($user_id) && $user_id != null) {
                $fav = $t->db->where(['type_id' => $product[$i]['id'], 'type' => 'products', 'user_id' => $user_id])->get('favorites')->num_rows();
                $product[$i]['is_favorite'] = strval($fav);
            } else {
                $product[$i]['is_favorite'] = '0';
            }

            $product[$i]['image_md'] = get_image_url($product[$i]['image'], 'thumb', 'md');
            $product[$i]['image_sm'] = get_image_url($product[$i]['image'], 'thumb', 'sm');
            $product[$i]['image'] = get_image_url($product[$i]['image']);

            $variant_attributes = [];
            $attributes_array = explode(',', $product[$i]['variants'][0]['attr_name']);

            foreach ($attributes_array as $attribute) {
                $attribute = trim($attribute);
                $key = array_search($attribute, array_column($product[$i]['attributes'], 'name'), false);
                if (($key === 0 || !empty($key)) && isset($product[0]['attributes'][$key])) {
                    $variant_attributes[$key]['ids'] = $product[0]['attributes'][$key]['ids'];
                    $variant_attributes[$key]['values'] = $product[0]['attributes'][$key]['value'];
                    $variant_attributes[$key]['swatche_type'] = $product[0]['attributes'][$key]['swatche_type'];
                    $variant_attributes[$key]['swatche_value'] = $product[0]['attributes'][$key]['swatche_value'];
                    $variant_attributes[$key]['attr_name'] = $attribute;
                }
            }
            $product[$i]['variant_attributes'] = array_values($variant_attributes);
        }
        if (isset($count_res[0]['cal_discount_percentage'])) {
            $dicounted_total = array_values(array_filter(explode(',', $count_res[0]['cal_discount_percentage'])));
        } else {
            $dicounted_total = 0;
        }
        $response['total'] = (isset($filter) && !empty($filter['discount'])) ? count($dicounted_total) : $count_res[0]['total'];

        array_push($attribute_values_ids, $count_res[0]['attr_value_ids']);
        $attribute_values_ids = implode(",", $attribute_values_ids);
        $attr_value_ids = array_filter(array_unique(explode(',', $attribute_values_ids)));
    }

    // fetch restro tags
    $restro_tags = $product_tags = array();
    $restro_ids = array_column($product, "partner_id");
    if (isset($restro_ids) && !empty($restro_ids)) {
        $restro_tags = get_tags_by_id($restro_ids, "partner_tags");
    }

    // fetch product tags
    $product_ids = array_column($product, "id");
    if (isset($restro_ids) && !empty($restro_ids)) {
        $product_tags = get_tags_by_id($product_ids);
    }

    // fetch product categories
    $category_ids = array_column($product, "category_id");
    $category_names = array_column($product, "category_name");
    $categories[] = array_combine($category_ids, $category_names);
    $category_list = array_map(function ($value, $key) {
        $final_cat["id"] = strval($key);
        $final_cat["name"] = $value;
        return $final_cat;
    }, $categories[0], array_keys($categories[0]));

    $response['min_price'] = (isset($min_price)) ? $min_price : "0";
    $response['categories'] = (isset($category_list) && !empty($category_list)) ? $category_list : [];
    $response['max_price'] = (isset($max_price)) ? $max_price : "0";
    $response['product_tags'] = $product_tags;
    $response['partner_tags'] = $restro_tags;
    $response['product'] = $product;
    if (isset($filter) && $filter != null) {
        if (!empty($attr_value_ids)) {
            $response['filters'] = get_attribute_values_by_id($attr_value_ids);
        }
    } else {
        $response['filters'] = [];
    }

    return $response;
}
// partner_tags
function get_tags_by_id($type_id = "", $type = "product_tags")
{
    $t = &get_instance();
    $p_tags = [];
    if ($type_id != "") {
        $column = ($type == "product_tags") ? "product_id" : "partner_id";
        $tags = $t->db->select("title")
            ->join('tags t', 't.id = tg.tag_id ', 'inner')
            ->where_in($column, $type_id)->group_by('`t`.`title`')->get($type . ' tg')->result_array();
        if (!empty($tags)) {
            $p_tags = array_column($tags, "title");
            $p_tags = array_map(function ($value) {
                return output_escaping($value);
            }, $p_tags);
            return $p_tags;
        } else {
            return [];
        }
    } else {
        return [];
    }
}

function update_details($set, $where, $table, $escape = true)
{
    $t = &get_instance();
    $t->db->trans_start();
    if ($escape) {
        $set = escape_array($set);
    }
    $t->db->set($set)->where($where)->update($table);
    $t->db->trans_complete();
    $response = FALSE;
    if ($t->db->trans_status() === TRUE) {
        $response = TRUE;
    }
    return $response;
}

function delete_image($id, $path, $field, $img_name, $table_name, $isjson = TRUE)
{
    $t = &get_instance();
    $t->db->trans_start();
    if ($isjson == TRUE) {
        $image_set = fetch_details(['id' => $id], $table_name, $field);
        $new_image_set = escape_array(array_diff(json_decode($image_set[0][$field]), array($img_name)));
        $new_image_set = json_encode($new_image_set);
        $t->db->set([$field => $new_image_set])->where('id', $id)->update($table_name);
        $t->db->trans_complete();
        $response = FALSE;
        if ($t->db->trans_status() === TRUE) {
            $response = TRUE;
        }
    } else {
        $t->db->set([$field => ' '])->where(['id' => $id])->update($table_name);
        $t->db->trans_complete();
        $response = FALSE;
        if ($t->db->trans_status() === TRUE) {
            $response = TRUE;
        }
    }
    return $response;
}

function delete_details($where, $table, $where_in_key = 0, $where_in_value = [])
{
    $t = &get_instance();
    if (!empty($where_in_key) && !empty($where_in_value)) {
        $t->db->where_in($where_in_key, $where_in_value);
    }
    if (!empty($where) && !empty($where)) {
        $t->db->where($where);
    }
    if ($where != "") {
        if ($t->db->delete($table)) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

//JSON Validator function
function is_json($data = NULL)
{
    if (!empty($data)) {
        @json_decode($data);
        return (json_last_error() === JSON_ERROR_NONE);
    }
    return false;
}

//validate_promo_code
function validate_promo_code($promo_code, $user_id, $final_total)
{
    if (isset($promo_code) && !empty($promo_code)) {
        $t = &get_instance();

        //Fetch Promo Code Details
        $promo_code = $t->db->select('pc.*,count(o.id) as promo_used_counter ,( SELECT count(user_id) from orders where user_id =' . $user_id . ' and promo_code ="' . $promo_code . '") as user_promo_usage_counter ')
            ->join('orders o', 'o.promo_code=pc.promo_code', 'left')
            ->where(['pc.promo_code' => $promo_code, 'pc.status' => '1', ' start_date <= ' => date('Y-m-d'), '  end_date >= ' => date('Y-m-d')])
            ->get('promo_codes pc')->result_array();
        if (!empty($promo_code[0]['id'])) {

            if (intval($promo_code[0]['promo_used_counter']) < intval($promo_code[0]['no_of_users'])) {

                if ($final_total >= intval($promo_code[0]['minimum_order_amount'])) {

                    if ($promo_code[0]['repeat_usage'] == 1 && ($promo_code[0]['user_promo_usage_counter'] <= $promo_code[0]['no_of_repeat_usage'])) {
                        if (intval($promo_code[0]['user_promo_usage_counter']) <= intval($promo_code[0]['no_of_repeat_usage'])) {

                            $response['error'] = false;
                            $response['message'] = 'The promo code is valid';

                            if ($promo_code[0]['discount_type'] == 'percentage') {
                                $promo_code_discount =  floatval($final_total  * $promo_code[0]['discount'] / 100);
                            } else {
                                $promo_code_discount = $promo_code[0]['discount'];
                            }
                            if ($promo_code_discount <= $promo_code[0]['max_discount_amount']) {
                                $total = floatval($final_total) - $promo_code_discount;
                            } else {
                                $total = floatval($final_total) - $promo_code[0]['max_discount_amount'];
                                $promo_code_discount = $promo_code[0]['max_discount_amount'];
                            }
                            $promo_code[0]['final_total'] = strval(floatval($total));
                            $promo_code[0]['final_discount'] = strval(floatval($promo_code_discount));
                            $response['data'] = $promo_code;
                            return $response;
                        } else {

                            $response['error'] = true;
                            $response['message'] = 'This promo code cannot be redeemed as it exceeds the usage limit';
                            $response['data']['final_total'] = strval(floatval($final_total));
                            return $response;
                        }
                    } else if ($promo_code[0]['repeat_usage'] == 0 && ($promo_code[0]['user_promo_usage_counter'] <= 0)) {
                        if (intval($promo_code[0]['user_promo_usage_counter']) <= intval($promo_code[0]['no_of_repeat_usage'])) {

                            $response['error'] = false;
                            $response['message'] = 'The promo code is valid';

                            if ($promo_code[0]['discount_type'] == 'percentage') {
                                $promo_code_discount =  floatval($final_total  * $promo_code[0]['discount'] / 100);
                            } else {
                                $promo_code_discount = floatval($final_total - $promo_code[0]['discount']);
                            }
                            if ($promo_code_discount <= $promo_code[0]['max_discount_amount']) {
                                $total = floatval($final_total) - $promo_code_discount;
                            } else {
                                $total = floatval($final_total) - $promo_code[0]['max_discount_amount'];
                                $promo_code_discount = $promo_code[0]['max_discount_amount'];
                            }
                            $promo_code[0]['final_total'] = strval(floatval($total));
                            $promo_code[0]['final_discount'] = strval(floatval($promo_code_discount));
                            $response['data'] = $promo_code;
                            return $response;
                        } else {

                            $response['error'] = true;
                            $response['message'] = 'This promo code cannot be redeemed as it exceeds the usage limit';
                            $response['data']['final_total'] = strval(floatval($final_total));
                            return $response;
                        }
                    } else {
                        $response['error'] = true;
                        $response['message'] = 'The promo has already been redeemed. cannot be reused';
                        $response['data']['final_total'] = strval(floatval($final_total));
                        return $response;
                    }
                } else {

                    $response['error'] = true;
                    $response['message'] = 'This promo code is applicable only for amount greater than or equal to ' . $promo_code[0]['minimum_order_amount'];
                    $response['data']['final_total'] = strval(floatval($final_total));
                    return $response;
                }
            } else {

                $response['error'] = true;
                $response['message'] = "This promo code is applicable only for first " . $promo_code[0]['no_of_users'] . " users";
                $response['data']['final_total'] = strval(floatval($final_total));
                return $response;
            }
        } else {
            $response['error'] = true;
            $response['message'] = 'The promo code is not available or expired';
            $response['data']['final_total'] = strval(floatval($final_total));
            return $response;
        }
    }
}

//update_wallet_balance
function update_wallet_balance($operation, $user_id, $amount, $message = "Balance Debited")
{

    $t = &get_instance();
    $user_balance = $t->db->select('balance')->where(['id' => $user_id])->get('users')->result_array();
    if (!empty($user_balance)) {

        if ($operation == 'debit' && $amount > $user_balance[0]['balance']) {
            $response['error'] = true;
            $response['message'] = "Debited amount can't exceeds the user balance !";
            $response['data'] = array();
            return $response;
        }

        if ($user_balance[0]['balance'] >= 0) {
            $t = &get_instance();
            $data = [
                'transaction_type' => 'wallet',
                'user_id' => $user_id,
                'type' => $operation,
                'amount' => $amount,
                'message' => $message,
            ];
            if ($operation == 'debit') {
                $data['message'] = (isset($message)) ? $message : 'Balance Debited';
                $data['type'] = 'debit';
                $t->db->set('balance', '`balance` - ' . $amount, false)->where('id', $user_id)->update('users');
            } else {
                $data['message'] = (isset($message)) ? $message : 'Balance Credited';
                $data['type'] = 'credit';
                $t->db->set('balance', '`balance` + ' . $amount, false)->where('id', $user_id)->update('users');
            }
            $data = escape_array($data);
            $t->db->insert('transactions', $data);
            $response['error'] = false;
            $response['message'] = "Balance Update Successfully";
            $response['data'] = array();
        } else {
            $response['error'] = true;
            $response['message'] = ($user_balance[0]['balance'] != 0) ? "User's Wallet balance less than " . $user_balance[0]['balance'] . " can be used only" : "Doesn't have sufficient wallet balance to proceed further.";
            $response['data'] = array();
        }
    } else {
        $response['error'] = true;
        $response['message'] = "User does not exist";
        $response['data'] = array();
    }
    return $response;
}

function send_notification($fcmMsg, $registrationIDs_chunks)
{
    $fcmFields = [];
    foreach ($registrationIDs_chunks as $registrationIDs) {
        $fcmFields = array(
            'registration_ids' => $registrationIDs,  // expects an array of ids
            'priority' => 'high',
            'notification' => $fcmMsg,
            'data' => $fcmMsg,
        );

        $headers = array(
            'Authorization: key=' . get_settings('fcm_server_key'),
            'Content-Type: application/json'
        );

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fcmFields));
        $result = curl_exec($ch);
        curl_close($ch);
    }
    return $fcmFields;
}

function get_attribute_values_by_pid($id)
{
    $t = &get_instance();
    $swatche_type = $swatche_values1 =  array();
    $attribute_values = $t->db->select(" group_concat(`av`.`id`) as ids,group_concat(' ',`av`.`value`) as value ,`a`.`name` as attr_name, a.name, GROUP_CONCAT(av.swatche_type ORDER BY av.id ASC ) as swatche_type , GROUP_CONCAT(av.swatche_value  ) as swatche_value")
        ->join('attribute_values av ', 'FIND_IN_SET(av.id, pa.attribute_value_ids ) > 0', 'inner')
        ->join('attributes a', 'a.id = av.attribute_id', 'inner')
        ->where('pa.product_id', $id)->group_by('`a`.`name`')->get('product_attributes pa')->result_array();
    if (!empty($attribute_values)) {
        for ($i = 0; $i < count($attribute_values); $i++) {
            $swatche_type = array();
            $swatche_values1 = array();
            $swatche_type =  explode(",", $attribute_values[$i]['swatche_type']);
            $swatche_values =  explode(",", $attribute_values[$i]['swatche_value']);
            for ($j = 0; $j < count($swatche_type); $j++) {
                if ($swatche_type[$j] == "2") {
                    $swatche_values1[$j]  = get_image_url($swatche_values[$j], 'thumb', 'sm');
                } else if ($swatche_type[$j] == "0") {
                    $swatche_values1[$j] = '0';
                } else if ($swatche_type[$j] == "1") {
                    $swatche_values1[$j] = $swatche_values[$j];
                }
                $row = implode(',', $swatche_values1);
                $attribute_values[$i]['swatche_value'] = $row;
            }
            $attribute_values[$i] = output_escaping($attribute_values[$i]);
        }
    }
    return $attribute_values;
}

function get_attribute_values_by_id($id)
{
    $t = &get_instance();
    $attribute_values = $t->db->select(" GROUP_CONCAT(av.value  ORDER BY av.id ASC) as attribute_values ,GROUP_CONCAT(av.id ORDER BY av.id ASC ) as attribute_values_id ,a.name , GROUP_CONCAT(av.swatche_type ORDER BY av.id ASC ) as swatche_type , GROUP_CONCAT(av.swatche_value ORDER BY av.id ASC ) as swatche_value")
        ->join(' attributes a ', 'av.attribute_id = a.id ', 'inner')
        ->where_in('av.id', $id)->group_by('`a`.`name`')->get('attribute_values av')->result_array();
    if (!empty($attribute_values)) {
        for ($i = 0; $i < count($attribute_values); $i++) {
            if ($attribute_values[$i]['swatche_type'] != "") {
                $swatche_type = array();
                $swatche_values1 = array();
                $swatche_type =  explode(",", $attribute_values[$i]['swatche_type']);
                $swatche_values =  explode(",", $attribute_values[$i]['swatche_value']);

                for ($j = 0; $j < count($swatche_type); $j++) {
                    if ($swatche_type[$j] == "2") {
                        $swatche_values1[$j]  = get_image_url($swatche_values[$j], 'thumb', 'sm');
                    } else if ($swatche_type[$j] == "0") {
                        $swatche_values1[$j] = '0';
                    } else if ($swatche_type[$j] == "1") {
                        $swatche_values1[$j] = $swatche_values[$j];
                    }
                    $row = implode(',', $swatche_values1);
                    $attribute_values[$i]['swatche_value'] = $row;
                }
            }
            $attribute_values[$i] = output_escaping($attribute_values[$i]);
        }
    }
    return $attribute_values;
}

function get_variants_values_by_pid($id, $status = [1])
{
    $t = &get_instance();
    $varaint_values = $t->db->select("pv.*,pv.`product_id`,group_concat(`av`.`id`  ORDER BY av.id ASC) as variant_ids,group_concat( ' ' ,`a`.`name` ORDER BY av.id ASC) as attr_name, group_concat(`av`.`value` ORDER BY av.id ASC) as variant_values , pv.price as price , GROUP_CONCAT(av.swatche_type ORDER BY av.id ASC ) as swatche_type , GROUP_CONCAT(av.swatche_value ORDER BY av.id ASC ) as swatche_value")
        ->join('attribute_values av ', 'FIND_IN_SET(av.id, pv.attribute_value_ids ) > 0', 'left')
        ->join('attributes a', 'a.id = av.attribute_id', 'left')
        ->where(['pv.product_id' => $id])->where_in('pv.status', $status)->group_by('`pv`.`id`')->order_by('pv.id')->get('product_variants pv')->result_array();
    if (!empty($varaint_values)) {
        for ($i = 0; $i < count($varaint_values); $i++) {
            if ($varaint_values[$i]['swatche_type'] != "") {
                $swatche_type = array();
                $swatche_values1 = array();
                $swatche_type =  explode(",", $varaint_values[$i]['swatche_type']);
                $swatche_values =  explode(",", $varaint_values[$i]['swatche_value']);

                for ($j = 0; $j < count($swatche_type); $j++) {
                    if ($swatche_type[$j] == "2") {
                        $swatche_values1[$j]  = get_image_url($swatche_values[$j], 'thumb', 'sm');
                    } else if ($swatche_type[$j] == "0") {
                        $swatche_values1[$j] = '0';
                    } else if ($swatche_type[$j] == "1") {
                        $swatche_values1[$j] = $swatche_values[$j];
                    }
                    $row = implode(',', $swatche_values1);
                    $varaint_values[$i]['swatche_value'] = $row;
                }
            }
            $varaint_values[$i] = output_escaping($varaint_values[$i]);
            $varaint_values[$i]['availability'] = isset($varaint_values[$i]['availability']) && ($varaint_values[$i]['availability'] != "") ? $varaint_values[$i]['availability'] : '';
        }
    }
    return $varaint_values;
}

function get_variants_values_by_id($id)
{
    $t = &get_instance();
    $varaint_values = $t->db->select("pv.*,pv.`product_id`,group_concat(`av`.`id` separator ', ') as varaint_ids,group_concat(`a`.`name` separator ', ') as attr_name, group_concat(`av`.`value` separator ', ') as variant_values")
        ->join('attribute_values av ', 'FIND_IN_SET(av.id, pv.attribute_value_ids ) > 0', 'inner')
        ->join('attributes a', 'a.id = av.attribute_id', 'inner')
        ->where('pv.id', $id)->group_by('`pv`.`id`')->order_by('pv.id')->get('product_variants pv')->result_array();
    if (!empty($varaint_values)) {
        for ($i = 0; $i < count($varaint_values); $i++) {
            $varaint_values[$i] = output_escaping($varaint_values[$i]);
            $varaint_values[$i] = array_map(function ($value) {
                return $value === NULL ? "" : $value;
            }, $varaint_values[$i]);
        }
    }
    return $varaint_values;
}

//Used in form validation(API)
function userrating_check()
{
    $t = &get_instance();
    $user_id = $t->input->post('user_id', true);
    $product_id = $t->input->post('product_id', true);
    $res = $t->db->select('*')->where(['user_id' => $user_id, 'product_id' => $product_id])->get('product_rating');
    if ($res->num_rows() > 0) {
        return false;
    } else {
        return true;
    }
}

//update_stock()
function update_stock($product_variant_ids, $qtns, $type = '')
{
    /*
		--First Check => Is stock management active (Stock type != NULL) 
		Case 1 : Simple Product 		
		Case 2 : Variable Product (Product Level,Variant Level) 			

		Stock Type :
			0 => Simple Product(simple product)
			  	-Stock will be stored in (product)master table	
			1 => Product level(variable product)
				-Stock will be stored in product_variant table	
			2 => Variant level(variable product)		
				-Stock will be stored in product_variant table	
		*/
    $t = &get_instance();
    $res = $t->db->select('p.*,pv.*,p.id as p_id,pv.id as pv_id,p.stock as p_stock,pv.stock as pv_stock')->where_in('pv.id', $product_variant_ids)->join('products p', 'pv.product_id = p.id')->get('product_variants pv')->result_array();

    for ($i = 0; $i < count($res); $i++) {
        if (($res[$i]['stock_type'] != null || $res[$i]['stock_type'] != "")) {

            /* Case 1 : Simple Product(simple product) */
            if ($res[$i]['stock_type'] == 0) {
                if ($type == 'plus') {
                    if ($res[$i]['p_stock'] != null) {
                        $stock = intval($res[$i]['p_stock']) + intval($qtns[$i]);
                        $t->db->where('id', $res[$i]['p_id'])->update('products', ['stock' => $stock]);
                        if ($stock > 0) {
                            $t->db->where('id', $res[$i]['p_id'])->update('products', ['availability' => '1']);
                        }
                    }
                } else {
                    if ($res[$i]['p_stock'] != null && $res[$i]['p_stock'] > 0) {
                        $stock = intval($res[$i]['p_stock']) - intval($qtns[$i]);
                        $t->db->where('id', $res[$i]['p_id'])->update('products', ['stock' => $stock]);
                        if ($stock == 0) {
                            $t->db->where('id', $res[$i]['p_id'])->update('products', ['availability' => '0']);
                        }
                    }
                }
            }

            /* Case 2 : Product level(variable product) */
            if ($res[$i]['stock_type'] == 1) {
                if ($type == 'plus') {
                    if ($res[$i]['pv_stock'] != null) {
                        $stock = intval($res[$i]['pv_stock']) + intval($qtns[$i]);
                        $t->db->where('product_id', $res[$i]['p_id'])->update('product_variants', ['stock' => $stock]);
                        if ($stock > 0) {
                            $t->db->where('product_id', $res[$i]['p_id'])->update('product_variants', ['availability' => '1']);
                        }
                    }
                } else {
                    if ($res[$i]['pv_stock'] != null && $res[$i]['pv_stock'] > 0) {
                        $stock = intval($res[$i]['pv_stock']) - intval($qtns[$i]);
                        $t->db->where('product_id', $res[$i]['p_id'])->update('product_variants', ['stock' => $stock]);
                        if ($stock == 0) {
                            $t->db->where('product_id', $res[$i]['p_id'])->update('product_variants', ['availability' => '0']);
                        }
                    }
                }
            }

            /* Case 3 : Variant level(variable product) */
            if ($res[$i]['stock_type'] == 2) {
                if ($type == 'plus') {
                    if ($res[$i]['pv_stock'] != null) {

                        $stock = intval($res[$i]['pv_stock']) + intval($qtns[$i]);
                        $t->db->where('id', $res[$i]['id'])->update('product_variants', ['stock' => $stock]);
                        if ($stock > 0) {
                            $t->db->where('id', $res[$i]['id'])->update('product_variants', ['availability' => '1']);
                        }
                    }
                } else {
                    if ($res[$i]['pv_stock'] != null && $res[$i]['pv_stock'] > 0) {

                        $stock = intval($res[$i]['pv_stock']) - intval($qtns[$i]);
                        $t->db->where('id', $res[$i]['id'])->update('product_variants', ['stock' => $stock]);
                        if ($stock == 0) {
                            $t->db->where('id', $res[$i]['id'])->update('product_variants', ['availability' => '0']);
                        }
                    }
                }
            }
        }
    }
}

function validate_stock($product_variant_ids, $qtns)
{
    /*
		--First Check => Is stock management active (Stock type != NULL) 
		Case 1 : Simple Product 		
		Case 2 : Variable Product (Product Level,Variant Level) 			

		Stock Type :
			0 => Simple Product(simple product)
			  	-Stock will be stored in (product)master table	
			1 => Product level(variable product)
				-Stock will be stored in product_variant table	
			2 => Variant level(variable product)		
				-Stock will be stored in product_variant table	
		*/
    $t = &get_instance();
    $response = array();
    $is_exceed_allowed_quantity_limit = false;
    $error = false;
    for ($i = 0; $i < count($product_variant_ids); $i++) {
        $res = $t->db->select('p.*,pv.*,pv.id as pv_id,p.stock as p_stock,p.availability as p_availability,pv.stock as pv_stock,pv.availability as pv_availability')->where('pv.id = ', $product_variant_ids[$i])->join('products p', 'pv.product_id = p.id')->get('product_variants pv')->result_array();
        if ($res[0]['total_allowed_quantity'] != null && $res[0]['total_allowed_quantity'] >= 0) {
            $total_allowed_quantity = intval($res[0]['total_allowed_quantity']) - intval($qtns[$i]);
            if ($total_allowed_quantity < 0) {
                $error = true;
                $is_exceed_allowed_quantity_limit = true;
                break;
            }
        }

        if (($res[0]['stock_type'] != null && $res[0]['stock_type'] != '')) {
            //Case 1 : Simple Product(simple product)
            if ($res[0]['stock_type'] == 0) {
                if ($res[0]['p_stock'] != null && $res[0]['p_stock'] != '') {
                    $stock = intval($res[0]['p_stock']) - intval($qtns[$i]);
                    if ($stock < 0 || $res[0]['p_availability'] == 0) {
                        $error = true;
                        break;
                    }
                }
            }
            //Case 2 & 3 : Product level(variable product) ||  Variant level(variable product)
            if ($res[0]['stock_type'] == 1 || $res[0]['stock_type'] == 2) {
                if ($res[0]['pv_stock'] != null && $res[0]['pv_stock'] != '') {
                    $stock = intval($res[0]['pv_stock']) - intval($qtns[$i]);
                    if ($stock < 0 || $res[0]['pv_availability'] == 0) {
                        $error = true;
                        break;
                    }
                }
            }
        }
    }

    if ($error) {
        $response['error'] = true;
        if ($is_exceed_allowed_quantity_limit) {
            $response['message'] = "One of the products quantity exceeds the allowed limit.Please deduct some quanity in order to purchase the item";
        } else {
            $response['message'] = "One of the product is out of stock.";
        }
    } else {
        $response['error'] = false;
        $response['message'] = "Stock available for purchasing.";
    }
    return $response;
}

//stock_status()
function stock_status($product_variant_id)
{
    /*
		--First Check => Is stock management active (Stock type != NULL) 
		Case 1 : Simple Product 		
		Case 2 : Variable Product (Product Level,Variant Level) 			

		Stock Type :
			0 => Simple Product(simple product)
			  	-Stock will be stored in (product)master table	
			1 => Product level(variable product)
				-Stock will be stored in product_variant table	
			2 => Variant level(variable product)		
				-Stock will be stored in product_variant table	
		*/
    $t = &get_instance();
    $res = $t->db->select('p.*,pv.*,pv.id as pv_id,p.stock as p_stock,pv.stock as pv_stock')->where_in('pv.id', $product_variant_id)->join('products p', 'pv.product_id = p.id')->get('product_variants pv')->result_array();
    $out_of_stock = false;
    for ($i = 0; $i < count($res); $i++) {
        if (($res[$i]['stock_type'] != null && !empty($res[$i]['stock_type']))) {
            //Case 1 : Simple Product(simple product)
            if ($res[$i]['stock_type'] == 0) {

                if ($res[$i]['p_stock'] == null || $res[$i]['p_stock'] == 0) {
                    $out_of_stock = true;
                    break;
                }
            }
            //Case 2 & 3 : Product level(variable product) ||  Variant level(variable product)
            if ($res[$i]['stock_type'] == 1 || $res[$i]['stock_type'] == 2) {
                if ($res[$i]['pv_stock'] == null || $res[$i]['pv_stock'] == 0) {
                    $out_of_stock = true;
                    break;
                }
            }
        }
    }
    return $out_of_stock;
}

//verify_user()
function verify_user($data)
{
    $t = &get_instance();
    $res = $t->db->where('mobile', $data['mobile'])->get('users')->result_array();
    return $res;
}

//edit_unique($value, $params)
function edit_unique($value, $params)
{
    $CI = &get_instance();

    $CI->form_validation->set_message('edit_unique', "Sorry, that %s is already being used.");

    list($table, $field, $current_id) = explode(".", $params);

    $query = $CI->db->select()->from($table)->where($field, $value)->limit(1)->get();
    if ($query->row() && $query->row()->id != $current_id) {
        return FALSE;
    } else {
        return TRUE;
    }
}

function validate_order_status($order_ids, $status, $table = 'order_items', $user_id = null)
{
    $t = &get_instance();
    $error = $cancelable_count = 0;
    $cancelable_till = '';
    $check_status = ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'];
    $group = array('admin', 'rider', 'partner');
    if (in_array(strtolower(trim($status)), $check_status)) {

        $t->db->select('p.*,o.active_status,pv.*,oi.id as order_item_id,oi.user_id as user_id,oi.product_variant_id as product_variant_id, o.status as order_status,oi.order_id as order_id')
            ->join('product_variants pv', 'pv.id=oi.product_variant_id', 'left')
            ->join('products p', 'pv.product_id=p.id', 'left')
            ->join('orders o', 'oi.order_id=o.id');
        if ($table == 'orders') {
            $t->db->where('oi.order_id', $order_ids);
        }
        $product_data = $t->db->get('order_items oi')->result_array();

        $priority_status = [
            'pending' => 0,
            'confirmed' => 1,
            'preparing' => 2,
            'out_for_delivery' => 3,
            'delivered' => 4,
            'cancelled' => 5,
        ];

        $is_posted_status_set = $canceling_delivered_item = $returning_non_delivered_item = false;
        $is_posted_status_set_count = $update_old_status = 0;
        for ($i = 0; $i < count($product_data); $i++) {
            $current_status = $priority_status[$status]; //max
            $old_status = $priority_status[$product_data[$i]['active_status']]; // min

            if ($old_status > $current_status) {
                $error = 1;
                $update_old_status = 1;
                break;
            }
            /* check if there are any products returnable or cancellable products available in the list or not */
            if ($product_data[$i]['is_cancelable'] == 1) {
                $cancelable_count += 1;
            }

            /* check if the posted status is present in any of the variants */
            $product_data[$i]['order_status'] = json_decode($product_data[$i]['order_status'], true);
            $order_status = array_column($product_data[$i]['order_status'], '0');

            /* check if posted status is already present in how many of the order items */
            if (in_array($status, $order_status)) {
                $is_posted_status_set_count++;
            }
            /* if all are marked as same as posted status set the flag */
            if ($is_posted_status_set_count == count($product_data)) {
                $is_posted_status_set = true;
            }

            /* check if user is cancelling the order after it is delivered */
            if (($status == "cancelled") && in_array("delivered", $order_status)) {
                $canceling_delivered_item = true;
            }
        }

        if ($is_posted_status_set == true) {
            /* status posted is already present in any of the order item */
            $response['error'] = true;
            $response['message'] = "Order is already marked as $status. You cannot set it again!";
            $response['data'] = array();
            return $response;
        }

        if ($canceling_delivered_item == true) {
            /* when user is trying cancel delivered order / item */
            $response['error'] = true;
            $response['message'] = "You cannot cancel delivered or returned order / item.";
            $response['data'] = array();
            return $response;
        }
        $is_cancelable = ($cancelable_count >= 1) ? 1 : 0;

        for ($i = 0; $i < count($product_data); $i++) {

            if ($product_data[$i]['active_status'] == 'cancelled') {
                $error = 1;
                $is_already_cancelled = 1;
                break;
            }

            if ($status == 'cancelled' && $product_data[$i]['is_cancelable'] == 1) {
                $max = $priority_status[$product_data[$i]['cancelable_till']];
                $min = $priority_status[$product_data[$i]['active_status']];

                if ($min > $max) {
                    $error = 1;
                    $cancelable_till = $product_data[$i]['cancelable_till'];
                    break;
                }
            }

            if ($status == 'cancelled' && $product_data[$i]['is_cancelable'] == 0) {
                $error = 1;
                break;
            }
        }

        if ($status == 'cancelled' && $error == 1 && !empty($cancelable_till) && !$t->ion_auth->logged_in() && !$t->ion_auth->in_group($group, $user_id)) {
            $response['error'] = true;
            $response['message'] = (count($product_data) > 1) ? " One of the order item can be cancelled till " . $cancelable_till . " only " : "The order item can be cancelled till " . $cancelable_till . " only";
            $response['data'] = array();
            return $response;
        }

        if ($update_old_status == 1 && $error == 1) {
            $response['error'] = true;
            $response['message'] = "order can not be update in backword manner!";
            $response['data'] = array();
            return $response;
        }

        if ($status == 'cancelled' && $error == 1 && !$t->ion_auth->logged_in() && !$t->ion_auth->in_group($group, $user_id)) {
            $response['error'] = true;
            $response['message'] = (count($product_data) > 1) ? "One of the order item can't be cancelled !" : "The order item can't be cancelled !";
            $response['data'] = array();
            return $response;
        }

        $response['error'] = false;
        $response['message'] = " ";
        $response['data'] = array();

        return $response;
    } else {
        $response['error'] = true;
        $response['message'] = "Invalid Status Passed";
        $response['data'] = array();
        return $response;
    }
}

function is_exist($where, $table, $update_id = null)
{
    $t = &get_instance();
    $where_tmp = [];
    foreach ($where as $key => $val) {
        $where_tmp[$key] = $val;
    }

    if (($update_id == null)  ? $t->db->where($where_tmp)->get($table)->num_rows() > 0 : $t->db->where($where_tmp)->where_not_in('id', $update_id)->get($table)->num_rows() > 0) {
        return true;
    } else {
        return false;
    }
}

function set_user_return_request($data, $table = 'orders')
{
    $data = escape_array($data);

    $t = &get_instance();

    if ($table == 'orders') {
        for ($i = 0; $i < count($data); $i++) {
            $request_data = [
                'user_id' => $data[$i]['user_id'],
                'product_id' => $data[$i]['product_id'],
                'product_variant_id' => $data[$i]['product_variant_id'],
                'order_id' => $data[$i]['order_id'],
                'order_item_id' => $data[$i]['order_item_id']
            ];
            $t->db->insert('return_requests', $request_data);
        }
    } else {
        $request_data = [
            'user_id' => $data['user_id'],
            'product_id' => $data['product_id'],
            'product_variant_id' => $data['product_variant_id'],
            'order_id' => $data['order_id'],
            'order_item_id' => $data['order_item_id']
        ];
        $t->db->insert('return_requests', $request_data);
    }
}

function get_categories_option_html($categories, $selected_vals = null)
{
    $html = "";
    for ($i = 0; $i < count($categories); $i++) {
        $pre_selected = (!empty($selected_vals) && in_array($categories[$i]['id'], $selected_vals)) ? "selected" : "";
        $html .= '<option value="' . $categories[$i]['id'] . '" class="l' . $categories[$i]['level'] . '" ' . $pre_selected . '  >' . output_escaping($categories[$i]['name']) . '</option>';
        if (!empty($categories[$i]['children'])) {
            $html .= get_subcategory_option_html($categories[$i]['children'], $selected_vals);
        }
    }

    return $html;
}

function get_subcategory_option_html($subcategories, $selected_vals)
{
    $html = "";
    for ($i = 0; $i < count($subcategories); $i++) {
        $pre_selected = (!empty($selected_vals) && in_array($subcategories[$i]['id'], $selected_vals)) ? "selected" : "";
        $html .= '<option value="' . $subcategories[$i]['id'] . '" class="l' . $subcategories[$i]['level'] . '" ' . $pre_selected . '  >' . $subcategories[$i]['name'] . '</option>';
        if (!empty($subcategories[$i]['children'])) {
            $html .=  get_subcategory_option_html($subcategories[$i]['children'], $selected_vals);
        }
    }
    return $html;
}

function get_cart_total($user_id, $product_variant_id = false, $is_saved_for_later = '0', $address_id = '')
{
    $t = &get_instance();
    $t->db->select('(select sum(c.qty)  from cart c join product_variants pv on c.product_variant_id=pv.id join products p on p.id=pv.product_id join partner_data sd on sd.user_id=p.partner_id  where c.user_id="' . $user_id . '" and qty!=0  and  is_saved_for_later = "' . $is_saved_for_later . '" and p.status=1 AND pv.status=1 AND sd.status=1) as total_items,(select count(c.id) from cart c join product_variants pv on c.product_variant_id=pv.id join products p on p.id=pv.product_id join partner_data sd on sd.user_id=p.partner_id where c.user_id="' . $user_id . '" and qty!=0 and  is_saved_for_later = "' . $is_saved_for_later . '" and p.status=1 AND pv.status=1 AND sd.status=1) as cart_count,`c`.qty,p.is_prices_inclusive_tax,p.cod_allowed,p.minimum_order_quantity,p.slug,p.quantity_step_size,p.total_allowed_quantity, p.name, p.image,p.short_description,`c`.user_id,pv.*,tax.percentage as tax_percentage,tax.title as tax_title');

    if ($product_variant_id == true) {
        $t->db->where(['c.product_variant_id' => $product_variant_id, 'c.user_id' => $user_id, 'c.qty !=' => '0']);
    } else {
        $t->db->where(['c.user_id' => $user_id, 'c.qty !=' => '0']);
    }

    if ($is_saved_for_later == 0) {
        $t->db->where('is_saved_for_later', 0);
    } else {
        $t->db->where('is_saved_for_later', 1);
    }

    $t->db->join('product_variants pv', 'pv.id=c.product_variant_id');
    $t->db->join('products p ', 'pv.product_id=p.id');
    $t->db->join('partner_data sd ', 'sd.user_id=p.partner_id');
    $t->db->join('`taxes` tax', 'tax.id = p.tax', 'LEFT');
    $t->db->join('categories ctg', 'p.category_id = ctg.id', 'left');
    $t->db->where(['p.status' => '1', 'pv.status' => 1, 'sd.status' => 1]);
    $t->db->group_by('c.id')->order_by('c.id', "DESC");
    $data = $t->db->get('cart c')->result_array();
    $total = $variant_id =  $quantity = $percentage = $amount = array();
    $cart_add_on_total = 0;

    for ($i = 0; $i < count($data); $i++) {

        $tax_title = (isset($data[$i]['tax_title']) && !empty($data[$i]['tax_title'])) ? $data[$i]['tax_title'] : '';
        $prctg = (isset($data[$i]['tax_percentage']) && intval($data[$i]['tax_percentage']) > 0 && $data[$i]['tax_percentage'] != null) ? $data[$i]['tax_percentage'] : '0';
        $data[$i]['item_tax_percentage'] = $prctg;
        $data[$i]['tax_title'] = $tax_title;
        if ((isset($data[$i]['is_prices_inclusive_tax']) && $data[$i]['is_prices_inclusive_tax'] == 0) || (!isset($data[$i]['is_prices_inclusive_tax'])) && $prctg > 0) {
            $price_tax_amount = $data[$i]['price'] * ($prctg / 100);
            $special_price_tax_amount = $data[$i]['special_price'] * ($prctg / 100);
        } else {
            $price_tax_amount = 0;
            $special_price_tax_amount = 0;
        }
        $data[$i]['image_sm'] = get_image_url($data[$i]['image'], 'thumb', 'sm');
        $data[$i]['image_md'] = get_image_url($data[$i]['image'], 'thumb', 'md');
        $data[$i]['image'] = get_image_url($data[$i]['image']);
        // if ($data[$i]['availability'] != null && $data[$i]['availability'] == 0) {
        //     continue;
        // }
        if ($data[$i]['cod_allowed'] == 0) {
            $cod_allowed = 0;
        }
        $variant_id[$i] = $data[$i]['id'];
        $quantity[$i] = intval($data[$i]['qty']);
        if (floatval($data[$i]['special_price']) > 0) {
            $total[$i] = floatval($data[$i]['special_price'] + $special_price_tax_amount) * $data[$i]['qty'];
        } else {
            $total[$i] = floatval($data[$i]['price'] + $price_tax_amount) * $data[$i]['qty'];
        }
        $add_ons = get_cart_add_ons($data[$i]['id'], $data[$i]['product_id'], $user_id);
        if (!empty($add_ons)) {
            $sum = 0;
            for ($j = 0; $j < count($add_ons); $j++) {
                $sum += floatval($add_ons[$j]['price']) * intval($add_ons[$j]['qty']);
            }
            $cart_add_on_total += $sum;
        }
        $data[$i]['special_price'] = $data[$i]['special_price'] + $special_price_tax_amount;
        $data[$i]['price'] = $data[$i]['price'] + $price_tax_amount;

        $percentage[$i] = (isset($data[$i]['tax_percentage']) && floatval($data[$i]['tax_percentage']) > 0) ? $data[$i]['tax_percentage'] : 0;
        if ($percentage[$i] != NUll && $percentage[$i] > 0) {
            // $amount[$i] = round($total[$i] *  $percentage[$i] / 100, 2);
            $amount[$i] = (!empty($special_price_tax_amount)) ? $special_price_tax_amount : $price_tax_amount;
        } else {
            $amount[$i] = 0;
            $percentage[$i] = 0;
        }

        $data[$i]['product_variants'] = get_variants_values_by_id($data[$i]['id']);
    }
    array_push($total, $cart_add_on_total);
    $total = array_sum($total);
    $data['sub_total'] = strval($total);
    $data['quantity'] = strval(array_sum($quantity));
    $data['tax_percentage'] = strval(array_sum($percentage));
    $data['tax_amount'] = strval(array_sum($amount));
    $data['total_arr'] = $total;
    $data['variant_id'] = $variant_id;
    $data['overall_amount'] = strval($total);
    return $data;
}

function get_cart_add_ons($variant_id, $product_id, $user_id)
{
    $data = fetch_details(['ca.user_id' => $user_id, "ca.product_id" => $product_id, "ca.product_variant_id" => $variant_id], "cart_add_ons ca", "*", null, null, null, null, null, null, "product_add_ons pa", "pa.id=ca.add_on_id", false, "ca.add_on_id");
    if (!empty($data)) {
        return $data;
    } else {
        return false;
    }
}
function get_product_add_ons($variant_id, $product_id, $user_id)
{
    $data = fetch_details(['ca.user_id' => $user_id, "ca.product_id" => $product_id, "ca.product_variant_id" => $variant_id], "cart_add_ons ca", "*", null, null, null, null, null, null, "product_add_ons pa", "pa.id=ca.add_on_id", false, "ca.add_on_id");
    if (!empty($data)) {
        return $data;
    } else {
        return false;
    }
}

function get_frontend_categories_html()
{
    $t = &get_instance();
    $t->load->model('category_model');

    $limit =  8;
    $offset =  0;
    $sort = 'row_order';
    $order =  'ASC';
    $has_child_or_item = 'false';


    $categories = $t->category_model->get_categories('', $limit, $offset, $sort, $order, trim($has_child_or_item));
    $nav = '<div class="cd-morph-dropdown"><a href="#0" class="nav-trigger">Open Nav<span aria-hidden="true"></span></a><nav class="main-nav"><ul>';
    $html = "<div class='morph-dropdown-wrapper'><div class='dropdown-list'><ul>";

    for ($i = 0; $i < count($categories); $i++) {
        $nav .= '<li class="has-dropdown" data-content="' . str_replace(' ', '', str_replace('&', '-', trim(strtolower(strip_tags(str_replace('\'', '', $categories[$i]['name'])))))) . '">';
        $nav .= '<a href="' . base_url('products/category/' . $categories[$i]['slug']) . '">' . Ucfirst($categories[$i]['name']) . '</a></li>';
        $html .= "<li id='" . str_replace(' ', '', str_replace('&', '-', trim(strtolower(strip_tags($categories[$i]['name']))))) . "' class='dropdown'> <a href='#0' class='label'>" . $categories[$i]['name'] . "</a><div class='content'><ul>";

        if (!empty($categories[$i]['children'])) {
            $html .= get_frontend_subcategories_html($categories[$i]['children']);
        }
        $html .= "</ul></div>";
    }
    $nav .= '<li><a href="' . base_url('home/categories') . '">See All</a></li>';
    $html .= "</ul><div class='bg-layer' aria-hidden='true'></div></div></div></div>";
    $nav .= '</ul></nav>';
    return $nav . $html;
}

function get_frontend_subcategories_html($subcategories)
{
    $html = "";

    for ($i = 0; $i < count($subcategories); $i++) {
        $html .= "<li><a href='#0'>" . $subcategories[$i]['name'] . "</a>";
        if (!empty($subcategories[$i]['children'])) {
            $html .= '<ul>' . get_frontend_subcategories_html($subcategories[$i]['children']) . '</ul>';
        }
        $html .= "</li>";
    }

    return $html;
}

function resize_image($image_data, $source_path, $id = false)
{
    if ($image_data['is_image']) {

        $t = &get_instance();

        $image_type = ['thumb', 'cropped'];
        $image_size = ['md' => array('width' => 800, 'height' => 800), 'sm' => array('width' => 450, 'height' => 450)];
        $target_path = $source_path; // Target path will be under source path
        $image_name = $image_data['file_name']; // original image's name    
        $w = $image_data['image_width']; // original image's width    
        $h = $image_data['image_height']; // original images's height 

        $t->load->library('image_lib');

        if ($id != false && is_numeric($id)) {
            // Resize the original images            
            $config['maintain_ratio'] = true;
            $config['create_thumb'] = FALSE;
            $config['source_image'] =  $source_path . $image_name;
            $config['new_image'] = $target_path . $image_name;
            $config['quality'] = '80%';
            $config['width'] = $w - 1;
            $config['height'] = $h - 1;
            $t->image_lib->initialize($config);
            if ($t->image_lib->resize()) {

                $size = filesize($config['new_image']);
                update_details(['size' => $size], ['id' => $id], 'media');
            } else {
                return $t->image_lib->display_errors();
            }
            $t->image_lib->clear();
        }

        for ($i = 0; $i < count($image_type); $i++) {

            if (file_exists($source_path . $image_name)) {  //check if the image file exist 
                foreach ($image_size as $image_size_key => $image_size_value) {
                    if (!file_exists($target_path . $image_type[$i] . '-' . $image_size_key)) {
                        mkdir($target_path . $image_type[$i] . '-' . $image_size_key, 0777);
                    }

                    $n_w = $image_size_value['width']; // destination image's width //800
                    $n_h = $image_size_value['height']; // destination image's height //800
                    $config['image_library'] = 'gd2';
                    $config['create_thumb'] = FALSE;
                    $config['source_image'] =  $source_path . $image_name;
                    $config['new_image'] = $target_path . $image_type[$i] . '-' . $image_size_key . '/' . $image_name;
                    if (($w >= $n_w || $h >= $n_h) && $image_type[$i] == 'cropped') {
                        $y = date('Y');
                        $thumb_type = ($image_size_key == 'sm') ? 'thumb-sm/' : 'thumb-md/';
                        $thumb_path = $source_path . $thumb_type . $image_name;

                        $data = getimagesize($thumb_path);
                        $width = $data[0];
                        $height = $data[1];
                        $config['source_image'] = (file_exists($thumb_path)) ?  $thumb_path : $image_name;

                        /*  x-axis : (left)   
                        width : (right)   
                        y-axis : (top)    
                        height : (bottom) */
                        $config['maintain_ratio'] = false;

                        if ($width > $height) {
                            $config['width'] = $height;
                            $config['height'] = round($height);
                            $config['x_axis'] = (($width / 4) - ($n_w / 4));
                        } else {
                            $config['width'] = $width;
                            $config['height'] = $width;
                            $config['y_axis'] = (($height / 4) - ($n_h / 4));
                        }

                        $t->image_lib->initialize($config);
                        $t->image_lib->crop();
                        $t->image_lib->clear();
                    }

                    if (($w >= $n_w || $h >= $n_h) && $image_type[$i] == 'thumb') {
                        $config['maintain_ratio'] = true;
                        $config['create_thumb'] = FALSE;
                        $config['width'] = $n_w;
                        $config['height'] = $n_h;
                        $t->image_lib->initialize($config);
                        if (!$t->image_lib->resize()) {
                            return $t->image_lib->display_errors();
                        }
                        $t->image_lib->clear();
                    }
                }
            }
        }
    }
}

function get_user_permissions($id)
{
    $userData = fetch_details(['user_id' => $id], 'user_permissions');
    return $userData;
}

function has_permissions($role, $module)
{
    $role = trim($role);
    $module = trim($module);

    if (!is_modification_allowed($module) && in_array($role, ['create', 'update', 'delete'])) {
        return false; //Modification not allowed
    }
    $t = &get_instance();
    $id = $t->session->userdata('user_id');
    $t->load->config('erestro');
    $general_system_permissions  = $t->config->item('system_modules');
    $userData = get_user_permissions($id);
    if (!empty($userData)) {

        if (intval($userData[0]['role']) > 0) {
            $permissions = json_decode($userData[0]['permissions'], 1);
            if (array_key_exists($module, $general_system_permissions) && array_key_exists($module, $permissions)) {
                if (array_key_exists($module, $permissions)) {
                    if (in_array($role, $general_system_permissions[$module])) {
                        if (!array_key_exists($role, $permissions[$module])) {
                            return false; //User has no permission
                        }
                    }
                }
            } else {
                return false; //User has no permission
            }
        }
        return true; //User has permission
    }
}


function print_msg($error, $message, $module = false, $is_csrf_enabled = true)
{
    $t = &get_instance();
    if ($error) {

        $response['error'] = true;
        $response['message'] = (is_modification_allowed($module)) ? $message : DEMO_VERSION_MSG;
        if ($is_csrf_enabled) {
            $response['csrfName'] = $t->security->get_csrf_token_name();
            $response['csrfHash'] = $t->security->get_csrf_hash();
        }
        print_r(json_encode($response));
        return true;
    }
}

function get_system_update_info()
{
    $t = &get_instance();
    $db_version_data = $t->db->from('updates')->order_by("id", "desc")->get()->result_array();
    if (!empty($db_version_data) && isset($db_version_data[0]['version'])) {
        $db_current_version = $db_version_data[0]['version'];
    }
    if ($t->db->table_exists('updates') && !empty($db_current_version)) {
        $data['db_current_version'] = $db_current_version;
    } else {
        $data['db_current_version'] = $db_current_version = 1.0;
    }

    if (file_exists(UPDATE_PATH . "update/updater.txt") || file_exists(UPDATE_PATH . "updater.txt")) {
        $sub_directory = (file_exists(UPDATE_PATH . "update/folders.json")) ? "update/" : "";
        $lines_array = file(UPDATE_PATH . $sub_directory . "updater.txt");

        $search_string = "version";

        foreach ($lines_array as $line) {
            if (strpos($line, $search_string) !== false) {
                list(, $new_str) = explode(":", $line);
                // If you don't want the space before the word bong, uncomment the following line.
                $new_str = trim($new_str);
            }
        }
        $data['file_current_version'] = $file_current_version = $new_str;
    } else {
        $data['file_current_version'] = $file_current_version = false;
    }

    if ($file_current_version != false && $file_current_version > $db_current_version) {

        $data['is_updatable'] =  true;
    } else {
        $data['is_updatable'] =  false;
    }

    return $data;
}

function send_mail($to, $subject, $message)
{
    $t = &get_instance();
    $settings = get_settings('system_settings', true);
    $t->load->library('email');
    $config = $t->config->item('email_config');
    $t->email->initialize($config);
    $t->email->set_newline("\r\n");

    $t->email->from($config['smtp_user'], $settings['app_name']);
    $t->email->to($to);
    $t->email->subject($subject);
    $t->email->message($message);
    if ($t->email->send()) {
        $response['error'] = false;
        $response['config'] = $config;
        $response['message'] = 'Email Sent';
    } else {
        $response['error'] = true;
        $response['config'] = $config;
        $response['message'] = $t->email->print_debugger();
    }
    return $response;
}

function fetch_orders($order_id = NULL, $user_id = NULL, $status = NULL, $rider_id = NULL, $limit = NULL, $offset = NULL, $sort = NULL, $order = NULL, $download_invoice = false, $start_date = null, $end_date = null, $search = null, $city_id = null, $area_id = null, $partner_id = null, $is_pending = false, $rider_city_id = NULL)
{

    $t = &get_instance();
    $where = [];

    $count_res = $t->db->select(' COUNT(distinct o.id) as `total`')
        ->join(' `users` u', 'u.id= o.user_id', 'left')
        ->join(' `order_items` oi', 'o.id= oi.order_id', 'left')
        ->join('product_variants pv', 'pv.id=oi.product_variant_id', 'left')
        ->join('products p', 'pv.product_id=p.id', 'left')
        ->join('addresses a', 'a.id=o.address_id', 'left');
    if (isset($order_id) && $order_id != null) {
        $where['o.id'] = $order_id;
    }

    if (isset($rider_id) && $rider_id != NULL) {
        $where['o.rider_id'] = $rider_id;
    }

    if (isset($user_id) && $user_id != null) {
        $where['o.user_id'] = $user_id;
    }
    if (isset($city_id) && $city_id != null) {
        $where['a.city_id'] = $city_id;
    }
    if (isset($partner_id) && $partner_id != null) {
        $where['oi.partner_id'] = $partner_id;
    }
    if ($is_pending == true) {
        $count_res->join('pending_orders po', 'po.order_id=o.id');
        $count_res->where(['po.city_id' => $rider_city_id]);
        $count_res->where_in('o.active_status', ['confirmed', 'preparing']);
    }

    if (isset($status) &&  is_array($status) &&  count($status) > 0) {
        $status = array_map('trim', $status);
        $count_res->where_in('o.active_status', $status);
    }

    if (isset($start_date) && $start_date != null && isset($end_date) && $end_date != null) {
        $count_res->where(" DATE(o.date_added) >= DATE('" . $start_date . "') ");
        $count_res->where(" DATE(o.date_added) <= DATE('" . $end_date . "') ");
    }

    if (isset($search) and $search != null) {

        $filters = [
            'u.username' => $search,
            'u.email' => $search,
            'o.id' => $search,
            'o.mobile' => $search,
            'o.address' => $search,
            'o.payment_method' => $search,
            'o.delivery_time' => $search,
            'o.date_added' => $search,
            'p.name' => $search,
            'o.active_status' => $search,
        ];
    }
    if (isset($filters) && !empty($filters)) {
        $count_res->group_Start();
        $count_res->or_like($filters);
        $count_res->group_End();
    }

    $count_res->where($where);

    if ($sort == 'date_added') {
        $sort = 'o.date_added';
    }
    $count_res->order_by($sort, $order);

    $order_count = $count_res->get('`orders` o')->result_array();
    $total = "0";
    foreach ($order_count as $row) {
        $total = $row['total'];
    }

    $search_res = $t->db->select(' o.*, u.username,u.country_code, p.name')
        ->join(' `users` u', 'u.id= o.user_id', 'left')
        ->join(' `order_items` oi', 'o.id= oi.order_id', 'left')
        ->join('product_variants pv', 'pv.id=oi.product_variant_id', 'left')
        ->join('addresses a', 'a.id=o.address_id', 'left')
        ->join('products p', 'pv.product_id=p.id', 'left');
    $search_res->where($where);

    if ($is_pending == true) {
        $search_res->join('pending_orders po', 'po.order_id=o.id');
        $search_res->where(['po.city_id' => $rider_city_id]);
        $search_res->where_in('o.active_status', ['confirmed', 'preparing']);
    }

    if (isset($start_date) && $start_date != null && isset($end_date) && $end_date != null) {
        $search_res->where(" DATE(o.date_added) >= DATE('" . $start_date . "') ");
        $search_res->where(" DATE(o.date_added) <= DATE('" . $end_date . "') ");
    }

    if (isset($status) &&  is_array($status) &&  count($status) > 0) {
        $status = array_map('trim', $status);
        $search_res->where_in('o.active_status', $status);
    }

    if (isset($filters) && !empty($filters)) {
        $search_res->group_Start();
        $search_res->or_like($filters);
        $search_res->group_End();
    }
    if (empty($sort)) {
        $sort = `o.date_added`;
    }
    $search_res->group_by('o.id');
    $search_res->order_by($sort, $order);
    if ($limit != null || $offset != null) {
        $search_res->limit($limit, $offset);
    }

    $order_details = $search_res->get('`orders` o')->result_array();
    for ($i = 0; $i < count($order_details); $i++) {
        $t->db->select('oi.*,p.id as product_id,p.is_cancelable,p.partner_id as partner_id ,p.is_returnable,p.image,p.name,p.type,(Select count(id) from order_items where order_id = oi.order_id ) as order_counter')
            ->join('product_variants pv', 'pv.id=oi.product_variant_id', "left")
            ->join('products p', 'pv.product_id=p.id', 'left')
            ->join('users u', 'u.id=oi.partner_id');

        $t->db->or_where_in('oi.order_id', $order_details[$i]['id']);
        if (isset($partner_id) && $partner_id != null) {
            $t->db->where('oi.partner_id=' . $partner_id);
        }
        $order_item_data = $t->db->get('order_items oi')->result_array();

        $order_details[$i]['status'] = json_decode($order_details[$i]['status']);
        for ($k = 0; $k < count($order_details[$i]['status']); $k++) {
            $order_details[$i]['status'][$k][1] = date('d-m-Y h:i:sa', strtotime($order_details[$i]['status'][$k][1]));
        }

        $order_details[$i]['notes'] = (isset($order_details[$i]['notes']) && !empty($order_details[$i]['notes'])) ? $order_details[$i]['notes'] : "";
        if (isset($order_details[$i]['rider_id']) && !empty($order_details[$i]['rider_id'])) {
            $rider_data = fetch_details(['id' => $order_details[$i]['rider_id']], "users", "mobile,username,image,rating,no_of_ratings,balance");
            $order_details[$i]['rider_mobile'] = $rider_data[0]['mobile'];
            $order_details[$i]['rider_name'] = $rider_data[0]['username'];
            $order_details[$i]['rider_image'] = (isset($rider_data[0]['image']) && !empty($rider_data[0]['image'])) ? base_url() . $rider_data[0]['image'] : base_url() . NO_IMAGE;
            $order_details[$i]['rider_rating'] = (isset($rider_data[0]['rating']) && !empty($rider_data[0]['rating'])) ? $rider_data[0]['rating'] : "0";
            $order_details[$i]['rider_balance'] = (isset($rider_data[0]['balance']) && !empty($rider_data[0]['balance'])) ? $rider_data[0]['balance'] : "0";
            $order_details[$i]['rider_no_of_ratings'] = (isset($rider_data[0]['no_of_ratings']) && !empty($rider_data[0]['no_of_ratings'])) ? $rider_data[0]['no_of_ratings'] : "0";
        } else {
            $order_details[$i]['rider_mobile'] = "";
            $order_details[$i]['rider_name'] = "";
            $order_details[$i]['rider_image'] = base_url() . NO_IMAGE;
            $order_details[$i]['rider_rating'] = "0";
            $order_details[$i]['rider_no_of_ratings'] = "0";
            $order_details[$i]['rider_balance'] = "0";
        }
        $order_details[$i]['payment_method'] = $order_details[$i]['payment_method'];
        $total_tax_percent = $total_tax_amount = $item_subtotal = 0;
        for ($k = 0; $k < count($order_item_data); $k++) {

            if (!empty($order_item_data)) {
                $item_subtotal += $order_item_data[$k]['sub_total'];
                $filter['id'] = $order_item_data[$k]['partner_id'];
                $filter['latitude'] = $order_details[$i]['latitude'];
                $filter['longitude'] = $order_details[$i]['longitude'];
                $filter['ignore_status'] = true;
                $restro_data = fetch_partners($filter);
                if (!empty($restro_data) && !empty($restro_data['data'])) {
                    $order_item_data[$k]['partner_details'] = $restro_data['data'];
                } else {
                    $order_item_data[$k]['partner_details'] = [];
                }
                $varaint_data = get_variants_values_by_id($order_item_data[$k]['product_variant_id']);
                $order_item_data[$k]['varaint_ids'] = (!empty($varaint_data)) ? $varaint_data[0]['varaint_ids'] : '';
                $order_item_data[$k]['variant_values'] = (!empty($varaint_data)) ? $varaint_data[0]['variant_values'] : '';
                $order_item_data[$k]['attr_name'] = (!empty($varaint_data)) ? $varaint_data[0]['attr_name'] : '';
                $order_item_data[$k]['name'] = (!empty($order_item_data[$k]['name'])) ? $order_item_data[$k]['name'] : $order_item_data[$k]['product_name'];
                $order_item_data[$k]['add_ons'] = (!empty($order_item_data[$k]['add_ons'])) ? json_decode($order_item_data[$k]['add_ons']) : [];
                $order_item_data[$k]['variant_values'] = (!empty($order_item_data[$k]['variant_values'])) ? $order_item_data[$k]['variant_values'] : $order_item_data[$k]['variant_name'];
                $order_item_data[$k]['image_sm'] = (empty($order_item_data[$k]['image']) || file_exists(FCPATH . $order_item_data[$k]['image']) == FALSE) ? base_url(NO_IMAGE) : get_image_url($order_item_data[$k]['image'], 'thumb', 'sm');
                $order_item_data[$k]['image_md'] = (empty($order_item_data[$k]['image']) || file_exists(FCPATH . $order_item_data[$k]['image']) == FALSE) ? base_url(NO_IMAGE) : get_image_url($order_item_data[$k]['image'], 'thumb', 'md');
                $order_item_data[$k]['image'] = (empty($order_item_data[$k]['image']) || file_exists(FCPATH . $order_item_data[$k]['image']) == FALSE) ? base_url(NO_IMAGE) : get_image_url($order_item_data[$k]['image']);
                $order_item_data[$k] = array_map(function ($value) {
                    return $value === NULL ? "" : $value;
                }, $order_item_data[$k]);
            }
        }


        if ((isset($rider_id) && $rider_id != null) || (isset($partner_id) && $partner_id != null)) {
            $order_details[$i]['total'] = strval($item_subtotal - $total_tax_amount);
            $order_details[$i]['final_total'] = strval($item_subtotal - $total_tax_amount +  $order_details[$i]['delivery_charge']);
            $order_details[$i]['total_payable'] = strval($item_subtotal - $total_tax_amount +  $order_details[$i]['delivery_charge']);
        } else {
            $order_details[$i]['total'] = strval($order_details[$i]['total'] - $total_tax_amount);
        }
        $order_details[$i]['address'] = output_escaping($order_details[$i]['address']);
        $order_details[$i]['username'] = output_escaping($order_details[$i]['username']);
        $order_details[$i]['total_tax_percent'] = strval($total_tax_percent);
        $order_details[$i]['total_tax_amount'] = strval($total_tax_amount);

        if ($download_invoice == true || $download_invoice == 1) {
            $order_details[$i]['invoice_html'] =  get_invoice_html($order_details[$i]['id']);
        }
        if (!empty($order_item_data)) {
            $order_details[$i]['order_items'] = $order_item_data;
        }
        $order_details[$i] = array_map(function ($value) {
            return $value === NULL ? "" : $value;
        }, $order_details[$i]);
    }

    $order_data['total'] = $total;
    $order_data['order_data'] = (isset($order_details) && !empty($order_details)) ? array_values($order_details) : [];
    return $order_data;
}

function find_media_type($extenstion)
{
    $t = &get_instance();
    $t->config->load('erestro');
    $type = $t->config->item('type');
    foreach ($type as $main_type => $extenstions) {
        foreach ($extenstions['types'] as $k => $v) {
            if ($v === strtolower($extenstion)) {
                return array($main_type, $extenstions['icon']);
            }
        }
    }
    return false;
}

function formatBytes($size, $precision = 2)
{
    $base = log($size, 1024);
    $suffixes = array('', 'KB', 'MB', 'GB', 'TB');

    return round(pow(1024, $base - floor($base)), $precision) . ' ' . $suffixes[floor($base)];
}

function delete_images($subdirectory, $image_name)
{
    $image_types = ['thumb-md/', 'thumb-sm/', 'cropped-md/', 'cropped-sm/'];
    $main_dir = FCPATH . $subdirectory;

    foreach ($image_types as $types) {
        $path = $main_dir . $types . $image_name;
        if (file_exists($path)) {
            unlink($path);
        }
    }

    if (file_exists($main_dir . $image_name)) {
        unlink($main_dir . $image_name);
    }
}

function get_image_url($path, $image_type = '', $image_size = '', $file_type = 'image')
{
    $path = explode('/', $path);
    $subdirectory = '';
    for ($i = 0; $i < count($path) - 1; $i++) {
        $subdirectory .= $path[$i] . '/';
    }
    $image_name = end($path);

    $file_main_dir = FCPATH . $subdirectory;
    $image_main_dir = base_url() . $subdirectory;
    if ($file_type == 'image') {
        $types = ['thumb', 'cropped'];
        $sizes = ['md', 'sm'];
        if (in_array(trim(strtolower($image_type)), $types) &&  in_array(trim(strtolower($image_size)), $sizes)) {
            $filepath = $file_main_dir . $image_type . '-' . $image_size . '/' . $image_name;
            $imagepath = $image_main_dir . $image_type . '-' . $image_size . '/' . $image_name;
            if (file_exists($filepath)) {
                return  $imagepath;
            } else if (file_exists($file_main_dir . $image_name)) {
                return  $image_main_dir . $image_name;
            } else {
                return  base_url() . NO_IMAGE;
            }
        } else {
            if (file_exists($file_main_dir . $image_name)) {
                return  $image_main_dir . $image_name;
            } else {
                return  base_url() . NO_IMAGE;
            }
        }
    } else {
        $file = new SplFileInfo($file_main_dir . $image_name);
        $ext  = $file->getExtension();

        $media_data =  find_media_type($ext);
        $image_placeholder = $media_data[1];
        $filepath = FCPATH .  $image_placeholder;
        $extensionpath = base_url() .  $image_placeholder;
        if (file_exists($filepath)) {
            return  $extensionpath;
        } else {
            return  base_url() . NO_IMAGE;
        }
    }
}

function fetch_users($id)
{
    $t = &get_instance();
    $user_details = $t->db->select('u.id,username,email,u.mobile,balance,dob, referral_code, friends_code, c.name as city_name,a.area as area,a.landmark,a.pincode')
        ->join('addresses a', 'u.id = a.user_id', 'left')
        ->join('cities c', 'u.city = c.id', 'left')
        ->where('u.id', $id)->limit(1)->get('users u')
        ->result_array();
    $user_details = array_map(function ($value) {
        return $value === NULL ? "" : $value;
    }, $user_details[0]);
    return $user_details;
}


function escape_array($array)
{
    $t = &get_instance();
    $posts = array();
    if (!empty($array)) {
        if (is_array($array)) {
            foreach ($array as $key => $value) {
                $posts[$key] = $t->db->escape_str($value);
            }
        } else {
            return $t->db->escape_str($array);
        }
    }
    return $posts;
}


function allowed_media_types()
{
    $t = &get_instance();
    $t->config->load('erestro');
    $type = $t->config->item('type');
    $general = [];
    foreach ($type as $main_type => $extenstions) {
        $general = array_merge_recursive($general, $extenstions['types']);
    }
    return $general;
}


function get_current_version()
{
    $t = &get_instance();
    $version = $t->db->select('max(version) as version')->get('updates')->result_array();
    return $version[0]['version'];
}

function resize_review_images($image_data, $source_path, $id = false)
{
    if ($image_data['is_image']) {

        $t = &get_instance();

        $target_path = $source_path; // Target path will be under source path        
        $image_name = $image_data['file_name']; // original image's name    
        $w = $image_data['image_width']; // original image's width    
        $h = $image_data['image_height']; // original images's height 

        $t->load->library('image_lib');

        if (file_exists($source_path . $image_name)) {  //check if the image file exist 

            if (!file_exists($target_path)) {
                mkdir($target_path, 0777);
            }

            $n_w = 800;
            $n_h = 800;
            $config['image_library'] = 'gd2';
            $config['create_thumb'] = FALSE;
            $config['maintain_ratio'] = TRUE;
            $config['quality'] = '90%';
            $config['source_image'] =  $source_path . $image_name;
            $config['new_image'] = $target_path . $image_name;
            $config['width'] = $n_w;
            $config['height'] = $n_h;
            $t->image_lib->clear();
            $t->image_lib->initialize($config);
            if (!$t->image_lib->resize()) {
                return $t->image_lib->display_errors();
            }
        }
    }
}

function get_invoice_html($order_id)
{
    $t = &get_instance();
    $invoice_generated_html = '';
    $t->data['main_page'] = VIEW . 'api-order-invoice';
    $settings = get_settings('system_settings', true);
    $t->data['title'] = 'Invoice Management |' . $settings['app_name'];
    $t->data['meta_description'] = 'eRestro | Invoice Management';
    if (isset($order_id) && !empty($order_id)) {
        $res = $t->Order_model->get_order_details(['o.id' => $order_id], true);
        if (!empty($res)) {
            $items = [];
            $promo_code = [];
            if (!empty($res[0]['promo_code'])) {
                $promo_code = fetch_details(['promo_code' => trim($res[0]['promo_code'])], 'promo_codes');
            }
            foreach ($res as $row) {
                $row = output_escaping($row);
                $temp['product_id'] = $row['product_id'];
                $temp['add_ons'] = $row['add_ons'];
                $temp['partner_id'] = $row['partner_id'];
                $temp['product_variant_id'] = $row['product_variant_id'];
                $temp['pname'] = $row['pname'];
                $temp['quantity'] = $row['quantity'];
                $temp['discounted_price'] = $row['discounted_price'];
                $temp['tax_percent'] = $row['tax_percent'];
                $temp['tax_amount'] = $row['tax_amount'];
                $temp['price'] = $row['price'];
                $temp['rider'] = $row['rider'];
                $temp['active_status'] = $row['oi_active_status'];
                array_push($items, $temp);
            }
            $t->data['order_detls'] = $res;
            $t->data['items'] = $items;
            $t->data['promo_code'] = $promo_code;
            $t->data['settings'] = get_settings('system_settings', true);
            $invoice_generated_html = $t->load->view('admin/invoice-template', $t->data, TRUE);
        } else {
            $invoice_generated_html = '';
        }
    } else {
        $invoice_generated_html = '';
    }
    return $invoice_generated_html;
}

function is_modification_allowed($module)
{
    $allow_modification = ALLOW_MODIFICATION;
    $allow_modification = ($allow_modification == 0) ? 0 : 1;
    $excluded_modules = ['orders'];
    if (isset($allow_modification) && $allow_modification == 0) {
        if (!in_array(strtolower($module), $excluded_modules)) {
            return false;
        }
    }
    return true;
}
function output_escaping($array)
{
    $exclude_fields = ["images", "other_images"];
    $t = &get_instance();

    if (!empty($array)) {
        if (is_array($array)) {
            $data = array();
            foreach ($array as $key => $value) {
                if (!in_array($key, $exclude_fields)) {
                    $data[$key] = stripcslashes($value);
                } else {
                    $data[$key] = $value;
                }
            }
            return $data;
        } else if (is_object($array)) {
            $data = new stdClass();
            foreach ($array as $key => $value) {
                if (!in_array($key, $exclude_fields)) {
                    $data->$key = stripcslashes($value);
                } else {
                    $data[$key] = $value;
                }
            }
            return $data;
        } else {
            return stripcslashes($array);
        }
    }
}
function get_min_max_price_of_product($product_id = '')
{
    $t = &get_instance();
    $t->db->join('`product_variants` pv', 'p.id = pv.product_id')->join('`taxes` tax', 'tax.id = p.tax', 'LEFT');
    if (!empty($product_id)) {
        $t->db->where('p.id', $product_id);
    }
    $response = $t->db->select('is_prices_inclusive_tax,price,special_price,tax.percentage as tax_percentage')->get('products p')->result_array();
    $percentage = (isset($response[0]['tax_percentage']) && intval($response[0]['tax_percentage']) > 0 && $response[0]['tax_percentage'] != null) ? $response[0]['tax_percentage'] : '0';
    if ((isset($response[0]['is_prices_inclusive_tax']) && $response[0]['is_prices_inclusive_tax'] == 0) || (!isset($response[0]['is_prices_inclusive_tax'])) && $percentage > 0) {
        $price_tax_amount = $response[0]['price'] * ($percentage / 100);
        $special_price_tax_amount = $response[0]['special_price'] * ($percentage / 100);
    } else {
        $price_tax_amount = 0;
        $special_price_tax_amount = 0;
    }
    $data['min_price'] = min(array_column($response, 'price')) + $price_tax_amount;
    $data['max_price'] = max(array_column($response, 'price')) + $price_tax_amount;
    $data['special_price'] = min(array_column($response, 'special_price')) + $special_price_tax_amount;
    $data['max_special_price'] = max(array_column($response, 'special_price')) + $special_price_tax_amount;
    $data['discount_in_percentage'] = find_discount_in_percentage($data['special_price'] + $special_price_tax_amount, $data['min_price'] + $price_tax_amount);
    return $data;
}
function get_price_range_of_product($product_id = '')
{
    $system_settings = get_settings('system_settings', true);
    $currency = (isset($system_settings['currency']) && !empty($system_settings['currency'])) ? $system_settings['currency'] : '';
    $t = &get_instance();
    $t->db->join('`product_variants` pv', 'p.id = pv.product_id')->join('`taxes` tax', 'tax.id = p.tax', 'LEFT');
    if (!empty($product_id)) {
        $t->db->where('p.id', $product_id);
    }
    $response = $t->db->select('is_prices_inclusive_tax,price,special_price,tax.percentage as tax_percentage')->get('products p')->result_array();

    if (count($response) == 1) {
        $percentage = (isset($response[0]['tax_percentage']) && intval($response[0]['tax_percentage']) > 0 && $response[0]['tax_percentage'] != null) ? $response[0]['tax_percentage'] : '0';
        if ((isset($response[0]['is_prices_inclusive_tax']) && $response[0]['is_prices_inclusive_tax'] == 0) || (!isset($response[0]['is_prices_inclusive_tax'])) && $percentage > 0) {
            $price_tax_amount = $response[0]['price'] * ($percentage / 100);
            $special_price_tax_amount = $response[0]['special_price'] * ($percentage / 100);
        } else {
            $price_tax_amount = 0;
            $special_price_tax_amount = 0;
        }
        $price_tax_amount = $price_tax_amount;
        $special_price_tax_amount = $special_price_tax_amount;
        $price = $response[0]['special_price'] == 0 ? $response[0]['price'] + $price_tax_amount : $response[0]['special_price'] + $special_price_tax_amount;
        $data['range'] =  $currency . ' ' . number_format($price, 2);
    } else {
        for ($i = 0; $i < count($response); $i++) {
            $is_all_specical_price_zero = 1;
            if ($response[$i]['special_price'] != 0) {
                $is_all_specical_price_zero = 0;
            }

            // $price_tax_amount = $price_tax_amount;
            // $special_price_tax_amount = $special_price_tax_amount;

            if ($is_all_specical_price_zero == 1) {
                $min = min(array_column($response, 'price'));
                $max = max(array_column($response, 'price'));
                $percentage = (isset($response[$i]['tax_percentage']) && intval($response[$i]['tax_percentage']) > 0 && $response[$i]['tax_percentage'] != null) ? $response[$i]['tax_percentage'] : '0';
                if ((isset($response[$i]['is_prices_inclusive_tax']) && $response[$i]['is_prices_inclusive_tax'] == 0) || (!isset($response[$i]['is_prices_inclusive_tax'])) && $percentage > 0) {
                    $min_price_tax_amount = $min * ($percentage / 100);
                    $min = $min + $min_price_tax_amount;

                    $max_price_tax_amount = $max * ($percentage / 100);
                    $max = $max + $max_price_tax_amount;
                }

                $data['range'] = $currency . ' ' . number_format($min, 2) . ' - ' . $currency . ' ' . number_format($max, 2);
            } else {

                $min_special_price = array_column($response, 'special_price');
                for ($j = 0; $j < count($min_special_price); $j++) {
                    if ($min_special_price[$j] == 0) {
                        unset($min_special_price[$j]);
                    }
                }
                $min_special_price = min($min_special_price);
                $max = max(array_column($response, 'price'));
                $percentage = (isset($response[$i]['tax_percentage']) && intval($response[$i]['tax_percentage']) > 0 && $response[$i]['tax_percentage'] != null) ? $response[$i]['tax_percentage'] : '0';
                if ((isset($response[$i]['is_prices_inclusive_tax']) && $response[$i]['is_prices_inclusive_tax'] == 0) || (!isset($response[$i]['is_prices_inclusive_tax'])) && $percentage > 0) {
                    $min_price_tax_amount = $min_special_price * ($percentage / 100);
                    $min_special_price = $min_special_price + $min_price_tax_amount;

                    $max_price_tax_amount = $max * ($percentage / 100);
                    $max = $max + $max_price_tax_amount;
                }
                $data['range'] = $currency . ' ' . number_format($min_special_price, 2) . ' - ' . $currency . ' ' . number_format($max, 2);
            }
        }
    }

    return $data;
}
function find_discount_in_percentage($special_price, $price)
{
    $diff_amount = $price - $special_price;
    return intval(($diff_amount * 100) / $price);
}
function get_attribute_ids_by_value($values, $names)
{
    $t = &get_instance();
    $attribute_ids = $t->db->select("av.id")
        ->join('attributes a ', 'av.attribute_id = a.id ')
        ->where_in('av.value', $values)
        ->where_in('a.name', $names)
        ->get('attribute_values av')->result_array();
    return array_column($attribute_ids, 'id');
}

function insert_details($data, $table)
{
    $t = &get_instance();
    return $t->db->insert($table, $data);
}

function get_category_id_by_slug($slug)
{
    $t = &get_instance();
    $slug = urldecode($slug);
    return $t->db->select("id")
        ->where('slug', $slug)
        ->get('categories')->row_array()['id'];
}

function get_variant_attributes($product_id)
{
    $product = fetch_product(NULL, NULL, $product_id);
    if (!empty($product['product'][0]['variants']) && isset($product['product'][0]['variants'])) {
        $attributes_array = explode(',', $product['product'][0]['variants'][0]['attr_name']);
        $variant_attributes = [];
        foreach ($attributes_array as $attribute) {
            $attribute = trim($attribute);

            $key = array_search($attribute, array_column($product['product'][0]['attributes'], 'name'), false);
            if ($key === 0 || !empty(strval($key))) {
                $variant_attributes[$key]['ids'] = $product['product'][0]['attributes'][$key]['ids'];
                $variant_attributes[$key]['values'] = $product['product'][0]['attributes'][$key]['value'];
                $variant_attributes[$key]['attr_name'] = $attribute;
            }
        }
        return $variant_attributes;
    }
}

function get_product_variant_details($product_variant_id)
{
    $CI = &get_instance();
    $res = $CI->db->join('products p', 'p.id=pv.product_id')
        ->where('pv.id', $product_variant_id)
        ->select('p.name,p.id,p.image,p.short_description,pv.*')->get('product_variants pv')->result_array();

    if (!empty($res)) {
        $res = array_map(function ($d) {
            $d['image_sm'] = get_image_url($d['image'], 'sm');
            $d['image_md'] = get_image_url($d['image'], 'md');
            $d['image'] = get_image_url($d['image']);
            return $d;
        }, $res);
    } else {
        return null;
    }
    return $res[0];
}

function get_cities($id = NULL, $limit = NULL, $offset = NULL)
{
    $CI = &get_instance();
    if (!empty($limit) || !empty($offset)) {
        $CI->db->limit($limit, $offset);
    }
    return $CI->db->get('cities')->result_array();
}

function get_favorites($user_id, $type = 'products', $limit = NULL, $offset = NULL)
{
    $CI = &get_instance();
    if (!empty($limit) || !empty($offset)) {
        $CI->db->limit($limit, $offset);
    }
    if ($type == 'products') {
        $q = $CI->db->join('products p', 'p.id=f.type_id')
            ->join('product_variants pv', 'pv.product_id=p.id')
            ->where('f.user_id', $user_id)
            ->where('f.type', $type)
            ->select("(select count(id) from favorites where user_id= $user_id and type='products') as total, ,f.*")
            ->group_by('f.type_id')
            ->limit($limit, $offset)
            ->get('favorites f');
        $res = $q->result_array();
        $final_res = $data = array();
        if (!empty($res)) {
            $data['total'] = $res[0]['total'];
            $product_ids = array_column($res, "type_id");
            $pro_details = fetch_product($user_id, null, $product_ids);
            if (!empty($pro_details)) {
                $final_res[] = $pro_details['product'];
            }
            $data['data'] = $final_res;
            return $data;
        } else {
            return $data;
        }
    } else if ($type == 'partners') {
        $filters['id'] = "";
        $q = $CI->db->select("(select count(id) from favorites where user_id= $user_id and type='partners') as total, ,f.*")
            ->where('f.user_id', $user_id)
            ->where('f.type', $type)
            ->group_by('f.type_id')
            ->limit($limit, $offset)
            ->get('favorites f');
        $res = $q->result_array();
        $data = array();
        if (isset($res) && !empty($res)) {
            $filters['id'] = array_column($res, "type_id");
            $result = fetch_partners((isset($filters)) ? $filters : null, $user_id, $limit, $offset);
            if (isset($result) && !empty($result)) {
                $data['total'] = $result['total'];
                $data['data'] = $result['data'];
                return $data;
            } else {
                return $data;
            }
        } else {
            return $data;
        }
    }
}
function current_theme($id = '', $name = '', $slug = '', $is_default = 1, $status = '')
{
    //If don't pass any params then this function will return the current theme.
    $CI = &get_instance();
    if (!empty($id)) {
        $CI->db->where('id', $id);
    }
    if (!empty($name)) {
        $CI->db->where('name', $name);
    }
    if (!empty($slug)) {
        $CI->db->where('slug', $slug);
    }
    if (!empty($is_default)) {
        $CI->db->where('is_default', $is_default);
    }
    if (!empty($status)) {
        $CI->db->where('status', $status);
    }
    $res = $CI->db->get('themes')->result_array();
    $res = array_map(function ($d) {
        $d['image'] = base_url('assets/front_end/theme-images/' . $d['image']);
        return $d;
    }, $res);
    return $res;
}
function get_languages($id = '', $language_name = '', $code = '', $is_rtl = '')
{
    $CI = &get_instance();
    if (!empty($id)) {
        $CI->db->where('id', $id);
    }
    if (!empty($language_name)) {
        $CI->db->where('language', $language_name);
    }
    if (!empty($code)) {
        $CI->db->where('code', $code);
    }
    if (!empty($is_rtl)) {
        $CI->db->where('is_rtl', $is_rtl);
    }
    $res = $CI->db->get('languages')->result_array();
    return $res;
}

function verify_payment_transaction($txn_id, $payment_method, $additional_data = [])
{
    if (empty(trim($txn_id))) {
        $response['error'] = true;
        $response['message'] = "Transaction ID is required";
        return $response;
    }

    $CI = &get_instance();
    $CI->config->load('erestro');
    $supported_methods = $CI->config->item('supported_payment_methods');

    if (empty(trim($payment_method)) || !in_array($payment_method, $supported_methods)) {
        $response['error'] = true;
        $response['message'] = "Invalid payment method supplied";
        return $response;
    }
    switch ($payment_method) {
        case 'razorpay':
            $CI->load->library("razorpay");
            $payment = $CI->razorpay->fetch_payments($txn_id);
            if (!empty($payment) && isset($payment['status'])) {
                if ($payment['status'] == 'authorized') {

                    /* if the payment is authorized try to capture it using the API */
                    $capture_response = $CI->razorpay->capture_payment($payment['amount'], $txn_id, $payment['currency']);
                    if ($capture_response['status'] == 'captured') {
                        $response['error'] = false;
                        $response['message'] = "Payment captured successfully";
                        $response['amount'] = $capture_response['amount'] / 100;
                        $response['data'] = $capture_response;
                        return $response;
                    } else if ($capture_response['status'] == 'refunded') {
                        $response['error'] = true;
                        $response['message'] = "Payment is refunded.";
                        $response['amount'] = $capture_response['amount'] / 100;
                        $response['data'] = $capture_response;
                        return $response;
                    } else {
                        $response['error'] = true;
                        $response['message'] = "Payment could not be captured.";
                        $response['amount'] = (isset($capture_response['amount'])) ? $capture_response['amount'] / 100 : 0;
                        $response['data'] = $capture_response;
                        return $response;
                    }
                } else if ($payment['status'] == 'captured') {
                    $response['error'] = false;
                    $response['message'] = "Payment captured successfully";
                    $response['amount'] = $payment['amount'] / 100;
                    $response['data'] = $payment;
                    return $response;
                } else if ($payment['status'] == 'created') {
                    $response['error'] = true;
                    $response['message'] = "Payment is just created and yet not authorized / captured!";
                    $response['amount'] = $payment['amount'] / 100;
                    $response['data'] = $payment;
                    return $response;
                } else {
                    $response['error'] = true;
                    $response['message'] = "Payment is " . ucwords($payment['status']) . "! ";
                    $response['amount'] = (isset($payment['amount'])) ? $payment['amount'] / 100 : 0;
                    $response['data'] = $payment;
                    return $response;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Payment not found by the transaction ID!";
                $response['amount'] = 0;
                $response['data'] = [];
                return $response;
            }
            break;

        case 'paystack':
            $CI->load->library("paystack");
            $payment = $CI->paystack->verify_transation($txn_id);
            if (!empty($payment)) {
                $payment = json_decode($payment, true);
                if (isset($payment['data']['status']) && $payment['data']['status'] == 'success') {
                    $response['error'] = false;
                    $response['message'] = "Payment is successful";
                    $response['amount'] = (isset($payment['data']['amount'])) ? $payment['data']['amount'] / 100 : 0;
                    $response['data'] = $payment;
                    return $response;
                } elseif (isset($payment['data']['status']) && $payment['data']['status'] != 'success') {
                    $response['error'] = true;
                    $response['message'] = "Payment is " . ucwords($payment['data']['status']) . "! ";
                    $response['amount'] = (isset($payment['data']['amount'])) ? $payment['data']['amount'] / 100 : 0;
                    $response['data'] = $payment;
                    return $response;
                } else {
                    $response['error'] = true;
                    $response['message'] = "Payment is unsuccessful! ";
                    $response['amount'] = (isset($payment['data']['amount'])) ? $payment['data']['amount'] / 100 : 0;
                    $response['data'] = $payment;
                    return $response;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Payment not found by the transaction ID!";
                $response['amount'] = 0;
                $response['data'] = [];
                return $response;
            }
            break;

        case 'flutterwave':
            $CI->load->library("flutterwave");
            $transaction = $CI->flutterwave->verify_transaction($txn_id);
            if (!empty($transaction)) {
                $transaction = json_decode($transaction, true);
                if ($transaction['status'] == 'error') {
                    $response['error'] = true;
                    $response['message'] = $transaction['message'];
                    $response['amount'] = (isset($transaction['data']['amount'])) ? $transaction['data']['amount'] : 0;
                    $response['data'] = $transaction;
                    return $response;
                }

                if ($transaction['status'] == 'success' && $transaction['data']['status'] == 'successful') {
                    $response['error'] = false;
                    $response['message'] = "Payment has been completed successfully";
                    $response['amount'] = $transaction['data']['amount'];
                    $response['data'] = $transaction;
                    return $response;
                } else if ($transaction['status'] == 'success' && $transaction['data']['status'] != 'successful') {
                    $response['error'] = true;
                    $response['message'] = "Payment is " . $transaction['data']['status'];
                    $response['amount'] = $transaction['data']['amount'];
                    $response['data'] = $transaction;
                    return $response;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Payment not found by the transaction ID!";
                $response['amount'] = 0;
                $response['data'] = [];
                return $response;
            }
            break;

        case 'stripe':
            # code...
            return "stripe is supplied";
            break;


        case 'paytm':
            $CI->load->library('paytm');
            $payment = $CI->paytm->transaction_status($txn_id); /* We are using order_id created during the generation of txn token */
            if (!empty($payment)) {
                $payment = json_decode($payment, true);
                if (
                    isset($payment['body']['resultInfo']['resultCode'])
                    && ($payment['body']['resultInfo']['resultCode'] == '01' && $payment['body']['resultInfo']['resultStatus'] == 'TXN_SUCCESS')
                ) {
                    $response['error'] = false;
                    $response['message'] = "Payment is successful";
                    $response['amount'] = (isset($payment['body']['txnAmount'])) ? $payment['body']['txnAmount'] : 0;
                    $response['data'] = $payment;
                    return $response;
                } elseif (
                    isset($payment['body']['resultInfo']['resultCode'])
                    && ($payment['body']['resultInfo']['resultStatus'] == 'TXN_FAILURE')
                ) {
                    $response['error'] = true;
                    $response['message'] = $payment['body']['resultInfo']['resultMsg'];
                    $response['amount'] = (isset($payment['body']['txnAmount'])) ? $payment['body']['txnAmount'] : 0;
                    $response['data'] = $payment;
                    return $response;
                } else if (
                    isset($payment['body']['resultInfo']['resultCode'])
                    && ($payment['body']['resultInfo']['resultStatus'] == 'PENDING')
                ) {
                    $response['error'] = true;
                    $response['message'] = $payment['body']['resultInfo']['resultMsg'];
                    $response['amount'] = (isset($payment['body']['txnAmount'])) ? $payment['body']['txnAmount'] : 0;
                    $response['data'] = $payment;
                    return $response;
                } else {
                    $response['error'] = true;
                    $response['message'] = "Payment is unsuccessful!";
                    $response['amount'] = (isset($payment['body']['txnAmount'])) ? $payment['body']['txnAmount'] : 0;
                    $response['data'] = $payment;
                    return $response;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Payment not found by the Order ID!";
                $response['amount'] = 0;
                $response['data'] = [];
                return $response;
            }
            break;

        case 'paypal':
            # code...
            return "paypal is supplied";
            break;

        default:
            # code...
            $response['error'] = true;
            $response['message'] = "Could not validate the transaction with the supplied payment method";
            return $response;
            break;
    }
}

function process_referral_bonus($user_id, $order_id, $status)
{
    /* 
        $user_id = 99;              << user ID of the person whose order is being marked not the friend's ID who is going to get the bonus  
        $status = "delivered";      << current status of the order 
        $order_id = 644;            << Order which is being marked as delivered

    */
    $CI = &get_instance();
    $settings = get_settings('system_settings', true);
    if (isset($settings['is_refer_earn_on']) && $settings['is_refer_earn_on'] == 1 && $status == "delivered") {
        $user = fetch_users($user_id);

        /* check if user has set friends code or not */
        if (isset($user[0]['friends_code']) && !empty($user[0]['friends_code'])) {

            /* find number of previous orders of the user */
            $total_orders = fetch_details(['user_id' => $user_id], 'orders', 'COUNT(id) as total');
            $total_orders = $total_orders[0]['total'];

            if ($total_orders < $settings['refer_earn_bonus_times']) {

                /* find a friends account details */
                $friend_user = fetch_details(['referral_code' => $user[0]['friends_code']], 'users', 'id,username,email,mobile,balance');
                if (!empty($friend_user)) {
                    $order = fetch_orders($order_id);
                    $final_total = $order['order_data'][0]['final_total'];
                    if ($final_total >= $settings['min_refer_earn_order_amount']) {

                        $referral_bonus = 0;
                        if ($settings['refer_earn_method'] == 'percentage') {
                            $referral_bonus = $final_total * ($settings['refer_earn_bonus'] / 100);
                            if ($referral_bonus > $settings['max_refer_earn_amount']) {
                                $referral_bonus = $settings['max_refer_earn_amount'];
                            }
                        } else {
                            $referral_bonus = $settings['refer_earn_bonus'];
                        }

                        $referral_id = "refer-and-earn-" . $order_id;
                        $previous_referral = fetch_details(['order_id' => $referral_id], 'transactions', 'id,amount');
                        if (empty($previous_referral)) {
                            $CI->load->model("transaction_model");
                            $transaction_data = [
                                'transaction_type' => "wallet",
                                'user_id' => $friend_user[0]['id'],
                                'order_id' => $referral_id,
                                'type' => "credit",
                                'txn_id' => "",
                                'amount' => $referral_bonus,
                                'status' => "success",
                                'message' => "Refer and Earn bonus on " . $user[0]['username'] . "'s order",
                            ];
                            $CI->transaction_model->add_transaction($transaction_data);
                            $CI->load->model('customer_model');
                            if ($CI->customer_model->update_balance($referral_bonus, $friend_user[0]['id'], 'add')) {
                                $response['error'] = false;
                                $response['message'] = "User's wallet credited successfully";
                                return $response;
                            }
                        } else {
                            $response['error'] = true;
                            $response['message'] = "Bonus is already given for the following order!";
                            return $response;
                        }
                    } else {
                        $response['error'] = true;
                        $response['message'] = "This order amount is not eligible refer and earn bonus!";
                        return $response;
                    }
                } else {
                    $response['error'] = true;
                    $response['message'] = "Friend user not found for the used referral code!";
                    return $response;
                }
            } else {
                $response['error'] = true;
                $response['message'] = "Number of orders have exceeded the eligible first few orders!";
                return $response;
            }
        } else {
            $response['error'] = true;
            $response['message'] = "No friends code found!";
            return $response;
        }
    } else {
        if ($status == "delivered") {
            $response['error'] = true;
            $response['message'] = "Referred and earn system is turned off";
            return $response;
        } else {
            $response['error'] = true;
            $response['message'] = "Status must be set to delivered to get the bonus";
            return $response;
        }
    }
}

function process_refund($id, $status, $type = 'orders')
{
    /**
     * @param
     * type : orders
     */
    $possible_status = array("cancelled");
    if (!in_array($status, $possible_status)) {
        $response['error'] = true;
        $response['message'] = 'Refund cannot be processed. Invalid status';
        $response['data'] = array();
        return $response;
    }

    $order_details =  fetch_orders($id);
    $order_details = $order_details['order_data'];
    $payment_method = $order_details[0]['payment_method'];
    $promo_discount = (isset($order_details[0]['promo_discount']) && !empty($order_details[0]['promo_discount'])) ? $order_details[0]['promo_discount'] : 0;
    $is_delivery_charge_returnable = isset($order_details[0]['is_delivery_charge_returnable']) && $order_details[0]['is_delivery_charge_returnable'] == 1 ? '1' : '0';
    $payment_method = trim(strtolower($payment_method));
    $wallet_balance = $order_details[0]['wallet_balance'];
    $currency = (isset($system_settings['currency']) && !empty($system_settings['currency'])) ? $system_settings['currency'] : '';
    $user_id = $order_details[0]['user_id'];
    $fcmMsg = array(
        'title' => "Amount Credited To Wallet",
    );
    $user_res = fetch_details(['id' => $user_id], 'users', 'fcm_id');
    $fcm_ids = array();
    if (!empty($user_res[0]['fcm_id'])) {
        $fcm_ids[0][] = $user_res[0]['fcm_id'];
    }
    if ($payment_method != 'cod') {
        /* update user's wallet */
        if ($is_delivery_charge_returnable == 1) {
            $returnable_amount =  $order_details[0]['total'] +  $order_details[0]['delivery_charge'] - $promo_discount;
        } else {
            $returnable_amount =  $order_details[0]['total'];
        }
        $fcmMsg = array(
            'title' => "Amount Credited To Wallet",
            'body' => $currency . ' ' . $returnable_amount,
            'type' => "wallet"
        );
        send_notification($fcmMsg, $fcm_ids);
        update_wallet_balance('credit', $user_id, $returnable_amount, 'Wallet Amount Credited for Order Item ID  : ' . $id);
    } else {
        if ($wallet_balance != 0) {
            /* update user's wallet */
            $returnable_amount = $wallet_balance;
            $fcmMsg = array(
                'title' => "Amount Credited To Wallet",
                'body' => $currency . ' ' . $returnable_amount,
                'type' => "wallet"
            );
            send_notification($fcmMsg, $fcm_ids);
            $re =  update_wallet_balance('credit', $user_id, $returnable_amount, 'Wallet Amount Credited for Order Item ID  : ' . $id);
        }
    }
}

function get_sliders($id = '', $type = '', $type_id = '')
{
    $ci = &get_instance();
    if (!empty($id)) {
        $ci->db->where('id', $id);
    }
    if (!empty($type)) {
        $ci->db->where('type', $type);
    }
    if (!empty($type_id)) {
        $ci->db->where('type_id', $type_id);
    }
    $res = $ci->db->get('sliders')->result_array();
    $res = array_map(function ($d) {
        $ci = &get_instance();
        $d['link'] = '';
        if (!empty($d['type'])) {
            if ($d['type'] == "categories") {
                $type_details = $ci->db->where('id', $d['type_id'])->select('slug')->get('categories')->row_array();
                if (!empty($type_details)) {
                    $d['link'] = base_url('products/category/' . $type_details['slug']);
                }
            } elseif ($d['type'] == "products") {
                $type_details = $ci->db->where('id', $d['type_id'])->select('slug')->get('products')->row_array();
                if (!empty($type_details)) {
                    $d['link'] = base_url('products/details/' . $type_details['slug']);
                }
            }
        }
        return $d;
    }, $res);
    return $res;
}

function get_offers($id = '', $type = '', $type_id = '')
{
    $ci = &get_instance();
    if (!empty($id)) {
        $ci->db->where('id', $id);
    }
    if (!empty($type)) {
        $ci->db->where('type', $type);
    }
    if (!empty($type_id)) {
        $ci->db->where('type_id', $type_id);
    }
    $res = $ci->db->get('offers')->result_array();
    $res = array_map(function ($d) {
        $ci = &get_instance();
        $d['link'] = '';
        if (!empty($d['type'])) {
            if ($d['type'] == "categories") {
                $type_details = $ci->db->where('id', $d['type_id'])->select('slug')->get('categories')->row_array();
                if (!empty($type_details)) {
                    $d['link'] = base_url('products/category/' . $type_details['slug']);
                }
            } elseif ($d['type'] == "products") {
                $type_details = $ci->db->where('id', $d['type_id'])->select('slug')->get('products')->row_array();
                if (!empty($type_details)) {
                    $d['link'] = base_url('products/details/' . $type_details['slug']);
                }
            }
        }
        return $d;
    }, $res);
    return $res;
}
function get_cart_count($user_id)
{
    $ci = &get_instance();
    if (!empty($user_id)) {
        $ci->db->where('user_id', $user_id);
    }
    $ci->db->where('qty !=', 0);
    $ci->db->where('is_saved_for_later =', 0);
    $ci->db->distinct();
    $ci->db->select('count(id) as total');
    $res = $ci->db->get('cart')->result_array();
    return $res;
}
function is_variant_available_in_cart($product_variant_id, $user_id)
{
    $ci = &get_instance();
    $ci->db->where('product_variant_id', $product_variant_id);
    $ci->db->where('user_id', $user_id);
    $ci->db->where('qty !=', 0);
    $ci->db->where('is_saved_for_later =', 0);
    $ci->db->select('id');
    $res = $ci->db->get('cart')->result_array();
    if (!empty($res[0]['id'])) {
        return true;
    } else {
        return false;
    }
}
function get_user_balance($user_id)
{
    $ci = &get_instance();
    $ci->db->where('id', $user_id);
    $ci->db->select('balance');
    $res = $ci->db->get('users')->result_array();
    if (!empty($res[0]['balance'])) {
        return $res[0]['balance'];
    } else {
        return "0";
    }
}

function get_stock($id, $type)
{
    $t = &get_instance();
    $t->db->where('id', $id);
    if ($type == 'variant') {
        $response = $t->db->select('stock')->get('product_variants')->result_array();
    } else {
        $response = $t->db->select('stock')->get('products')->result_array();
    }
    $stock = isset($response[0]['stock']) ? $response[0]['stock'] : null;
    return $stock;
}
function get_delivery_charge($address_id, $user_id)
{
    $t = &get_instance();
    $charge = "0";
    if (is_exist(['id' => $address_id], 'addresses')) {
        $city_id = fetch_details(['id' => $address_id], 'addresses', 'city_id,latitude,longitude'); // getting user address points
        $get_methods = fetch_details(['id' => $city_id[0]['city_id']], "cities");
        $charge_method = $get_methods[0]['delivery_charge_method'];

        // get restro id and coordinates from cart data
        $t->db->select('u.latitude,u.longitude,p.partner_id')->join('product_variants pv', 'pv.id=c.product_variant_id')->join('products p', "pv.product_id=p.id")->join("users u", "p.partner_id=u.id");
        $t->db->where('c.user_id', $user_id);
        $points = $t->db->from("cart c")->get()->result_array();

        /* find distnce with google API */
        $result = find_google_map_distance($city_id[0]['latitude'], $city_id[0]['longitude'], $points[0]['latitude'],  $points[0]['longitude']);

        if (isset($result['http_code']) && $result['http_code'] != "200") {
            $response['error'] = true;
            $response['message'] = 'The provided API key is invalid.';
            $response['charge'] = "0";
            $response['distance'] = "0";
            $response['duration'] = "0";
            return $response;
        }
        if (isset($result['body']) && !empty($result['body'])) {
            if (isset($result['body']['status']) && $result['body']['status'] == "REQUEST_DENIED") {
                /* The request is missing an API key */
                $response['error'] = true;
                $response['message'] = 'The provided API key is invalid.';
                $response['charge'] = "0";
                $response['distance'] = "0";
                $response['duration'] = "0";
                return $response;
            } else if (isset($result['body']['status']) && $result['body']['status'] == "OK") {
                // indicating the API request was successful
                // echo "ttttt ".$result['body']['rows'][0]['elements'][0]['status'];
                // print_r($result);

                if (isset($result['body']['rows'][0]['elements'][0]['status']) && $result['body']['rows'][0]['elements'][0]['status'] == "OK") {

                    $distance_text = $result['body']['rows'][0]['elements'][0]['distance']['text'];
                    $distance_in_meter = $result['body']['rows'][0]['elements'][0]['distance']['value'];
                    $distance = round(($distance_in_meter / 1000), 1);
                    $time = $result['body']['rows'][0]['elements'][0]['duration']['text'];

                    if ($charge_method == "fixed_charge") {
                        $charge = $get_methods[0]['fixed_charge'];
                    }
                    if ($charge_method == "per_km_charge") {
                        $charge = (intval($get_methods[0]['per_km_charge']) * intval($distance));
                    }
                    if ($charge_method == "range_wise_charges") {
                        $ranges = json_decode($get_methods[0]['range_wise_charges'], true);
                        $distance = round($distance);
                        foreach ($ranges as $range) {
                            if ($distance >= $range['from_range'] && $distance <= $range['to_range']) {
                                $charge = (intval($range['price']) * intval($distance));
                            }
                        }
                    }

                    $response['error'] = false;
                    $response['message'] = 'Data fetched successfully.';
                    $response['charge'] = $charge;
                    $response['distance'] = $distance_text;
                    $response['duration'] = $time;
                    return $response;
                } else if (isset($result['body']['rows'][0]['elements'][0]['status']) && $result['body']['rows'][0]['elements'][0]['status'] == "ZERO_RESULTS") {
                    $response['error'] = true;
                    $response['message'] = 'Data not found or invalid.Please check!';
                    $response['charge'] = "0";
                    $response['distance'] = "0";
                    $response['duration'] = "0";
                    return $response;
                } else {
                    $response['error'] = true;
                    $response['message'] = 'Something went wrong...';
                    $response['charge'] = "0";
                    $response['distance'] = "0";
                    $response['duration'] = "0";
                    return $response;
                }
            } else if (isset($result['body']['status']) && $result['body']['status'] == "OVER_QUERY_LIMIT") {
                // You have exceeded the QPS limits. Billing has not been enabled on your account
                $response['error'] = true;
                $response['message'] = 'You have exceeded the QPS limits or billing not enabled may be.';
                $response['charge'] = "0";
                $response['distance'] = "0";
                $response['duration'] = "0";
                return $response;
            } else if (isset($result['body']['status']) && $result['body']['status'] == "INVALID_REQUEST") {
                // indicating the API request was malformed, generally due to the missing input parameter
                $response['error'] = true;
                $response['message'] = 'Indicating the API request was malformed.';
                $response['charge'] = "0";
                $response['distance'] = "0";
                $response['duration'] = "0";
                return $response;
            } else if (isset($result['body']['status']) && $result['body']['status'] == "UNKNOWN_ERROR") {
                // indicating an unknown error
                $response['error'] = true;
                $response['message'] = 'An unknown error occure.';
                $response['charge'] = "0";
                $response['distance'] = "0";
                $response['duration'] = "0";
                return $response;
            } else if (isset($result['body']['status']) && $result['body']['status'] == "ZERO_RESULTS") {
                // indicating that the search was successful but returned no results. This may occur if the search was passed a bounds in a remote location.
                $response['error'] = true;
                $response['message'] = 'Data not found or invalid.Please check!';
                $response['charge'] = "0";
                $response['distance'] = "0";
                $response['duration'] = "0";
                return $response;
            } else {
                $response['error'] = true;
                $response['message'] = 'Something went wrong.';
                $response['charge'] = "0";
                $response['distance'] = "0";
                $response['duration'] = "0";
                return $response;
            }
        }
    } else {
        $response['error'] = true;
        $response['message'] = 'Address not available.Please check';
        $response['charge'] = "0";
        $response['distance'] = "0";
        $response['duration'] = "0";
        return $response;
    }
}
function validate_otp($order_id, $otp)
{
    $res = fetch_details(['id' => $order_id], 'orders', 'otp');
    if ($res[0]['otp'] == 0 || $res[0]['otp'] == $otp) {
        return true;
    } else {
        return false;
    }
}

function is_product_delivarable($type, $type_id, $product_id)
{
    $ci = &get_instance();
    $zipcode_id = 0;
    if ($type == 'zipcode') {
        $zipcode_id = $type_id;
    } else if ($type == 'area') {
        $res = fetch_details(['id' => $type_id], 'areas', 'zipcode_id');
        $zipcode_id = $res[0]['zipcode_id'];
    } else {
        return false;
    }
    if (!empty($zipcode_id)) {
        $ci->db->select('id');
        $ci->db->group_Start();
        $where = "((deliverable_type='2' and FIND_IN_SET('$zipcode_id', deliverable_zipcodes)) or deliverable_type = '1') OR (deliverable_type='3' and NOT FIND_IN_SET('$zipcode_id', deliverable_zipcodes)) ";
        $ci->db->where($where);
        $ci->db->group_End();
        $ci->db->where("id = $product_id");
        $product = $ci->db->get('products')->num_rows();
        if ($product > 0) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function check_cart_products_delivarable($area_id, $user_id)
{

    $products = $tmpRow = array();
    $cart = get_cart_total($user_id);
    if (!empty($cart)) {
        for ($i = 0; $i < $cart[0]['total_items']; $i++) {
            $tmpRow['product_id'] = $cart[$i]['product_id'];
            $tmpRow['variant_id'] = $cart[$i]['id'];
            $tmpRow['name'] = $cart[$i]['name'];
            $tmpRow['is_deliverable'] = (is_product_delivarable($type = 'area', $area_id, $cart[$i]['product_id'])) ? true : false;
            $products[] = $tmpRow;
        }
        if (!empty($products)) {
            return $products;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function orders_count($status = "", $partner_id = "")
{
    $t = &get_instance();
    $t->db->select('count(DISTINCT o.id) total')->join('order_items oi', 'oi.order_id = o.id');
    if (!empty($status)) {
        $t->db->where('active_status', $status);
    }
    if (!empty($partner_id)) {
        $t->db->where('partner_id', $partner_id);
    }
    $result = $t->db->from("orders o")->get()->result_array();
    return $result[0]['total'];
}

function curl($url, $method = 'GET', $data = [], $authorization = "")
{
    $ch = curl_init();
    $curl_options = array(
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_HEADER => 0,
        CURLOPT_HTTPHEADER => array(
            'Content-Type: application/x-www-form-urlencoded',
            // 'Authorization: Basic ' . base64_encode($this->key_id . ':' . $this->secret_key)
        )
    );

    if (!empty($authorization)) {
        $curl_options['CURLOPT_HTTPHEADER'][] = $authorization;
    }

    if (strtolower($method) == 'post') {
        $curl_options[CURLOPT_POST] = 1;
        $curl_options[CURLOPT_POSTFIELDS] = http_build_query($data);
    } else {
        $curl_options[CURLOPT_CUSTOMREQUEST] = 'GET';
    }
    curl_setopt_array($ch, $curl_options);

    $result = array(
        'body' => json_decode(curl_exec($ch), true),
        'http_code' => curl_getinfo($ch, CURLINFO_HTTP_CODE),
    );
    return $result;
}

function get_partner_permission($seller_id, $permit = NULL)
{
    $permits = fetch_details(['user_id' => $seller_id], 'partner_data', 'permissions');
    if (!empty($permit)) {
        $s_permits = json_decode($permits[0]['permissions'], true);
        return $s_permits[$permit];
    } else {
        return json_decode($permits[0]['permissions']);
    }
}

function get_price($type = "max")
{
    $t = &get_instance();
    $t->db->select('IF( pv.special_price > 0, `pv`.`special_price`, pv.price ) as pr_price')
        ->join(" categories c", "p.category_id=c.id ", 'LEFT')
        ->join(" partner_data sd", "p.partner_id=sd.user_id ")
        ->join('`product_variants` pv', 'p.id = pv.product_id', 'LEFT')
        ->join('`product_attributes` pa', ' pa.product_id = p.id ', 'LEFT');
    $t->db->where(" `p`.`status` = '1' AND `pv`.`status` = 1 AND `sd`.`status` = 1 AND   (`c`.`status` = '1' OR `c`.`status` = '0')");
    $result = $t->db->from("products p ")->get()->result_array();
    if (isset($result) && !empty($result)) {
        $pr_price = array_column($result, 'pr_price');
        $data = ($type == "min") ? min($pr_price) : max($pr_price);
    } else {
        $data = 0;
    }
    return $data;
}

function check_for_parent_id($category_id)
{
    $t = &get_instance();
    $t->db->select('id,parent_id,name');
    $t->db->where('id', $category_id);
    $result = $t->db->from("categories")->get()->result_array();
    if (!empty($result)) {
        return $result;
    } else {
        return false;
    }
}

function update_balance($amount, $rider_id, $action)
{
    $t = &get_instance();

    if ($action == "add") {
        $t->db->set('balance', 'balance+' . $amount, FALSE);
    } elseif ($action == "deduct") {
        $t->db->set('balance', 'balance-' . $amount, FALSE);
    }
    return $t->db->where('id', $rider_id)->update('users');
}

function get_working_hour_format($restro_id, $is_time = false)
{
    /* for displaying the working details of restro in restro table */
    $temp = "";
    $working_hours = fetch_details(["partner_id" => $restro_id], "partner_timings");
    $days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    for ($i = 0; $i < count($days); $i++) {
        $work = array_column($working_hours, "day");
        if (in_array($days[$i], $work)) {
            for ($j = 0; $j < count($working_hours); $j++) {
                if ($working_hours[$j]['day'] == $days[$i]) {
                    $opening_time = ($is_time == true) ? date('h:i:s A', strtotime($working_hours[$i]['opening_time'])) . " - " : "Opened";
                    $closing_time = ($is_time == true) ? date('h:i:s A', strtotime($working_hours[$i]['closing_time'])) : "";
                    $temp .= "<b>" . $days[$i] . "</b>(" . $opening_time . $closing_time . ") <br> ";
                }
            }
        } else {
            $temp .= "<b>" . $days[$i] . "</b>(Closed)</br>";
        }
    }
    return $temp;
}
function get_working_hour_html($restro_id = "", $is_time = true)
{
    /* for displaying the working hour details while adding partner*/
    $working_hours1 = "";
    $working_hours = [];
    if (isset($restro_id) && !empty($restro_id)) {
        $working_hours = fetch_details(["partner_id" => $restro_id], "partner_timings");
    }
    $days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    for ($i = 0; $i < count($days); $i++) {
        $work = array_column($working_hours, "day");
        if (in_array($days[$i], $work)) {
            for ($j = 0; $j < count($working_hours); $j++) {
                if ($working_hours[$j]['day'] == $days[$i]) {
                    $opening_time = ($is_time == true) ? $working_hours[$j]['opening_time'] : "";
                    $closing_time = ($is_time == true) ? $working_hours[$j]['closing_time'] : "";
                    $is_open = ($working_hours[$j]['is_open'] == true) ? "checked" : "";
                    $is_disabled = ($working_hours[$j]['is_open'] == true) ? "" : "disabled";
                    $working_hours1 .= '<div id="' . $days[$i] . '" class="day"><div id="label" class="col-sm-3 col-form-label">' . $days[$i] . ': </div>
                    <input type="time" id="' . $days[$i] . 'FromH" name="' . $days[$i] . 'FromH" value="' . $opening_time . '"  class="hour from mr-2" ' . $is_disabled . ' >
                    to <input type="time" id="' . $days[$i] . 'ToH" name="' . $days[$i] . 'ToH" value="' . $closing_time . '"  class="hour from mr-2" ' . $is_disabled . ' >
                    <input type="checkbox" name="not_working_days[]" value="' . $days[$i] . '" class="closed" ' . $is_open . ' ><span> Open</span></div>';
                }
            }
        } else {
            $working_hours1 .= '<div id="' . $days[$i] . '" class="day"><div id="label" class="col-sm-3 col-form-label">' . $days[$i] . ': </div>
            <input type="time" id="' . $days[$i] . 'FromH" name="' . $days[$i] . 'FromH" value=""  class="hour from mr-2" disabled >
            to <input type="time" id="' . $days[$i] . 'ToH" name="' . $days[$i] . 'ToH"  class="hour from mr-2" disabled >
            <input type="checkbox" name="not_working_days[]" value="' . $days[$i] . '" class="closed"  ><span> Open</span></div>';
        }
    }
    return $working_hours1;
}

function is_in_polygon($points_polygon, $vertices_x, $vertices_y, $longitude_x, $latitude_y)
{
    $i = $j = $c = 0;
    for ($i = 0, $j = $points_polygon; $i < $points_polygon; $j = $i++) {
        if ((($vertices_y[$i]  >  $latitude_y != ($vertices_y[$j] > $latitude_y)) &&
            ($longitude_x < ($vertices_x[$j] - $vertices_x[$i]) * ($latitude_y - $vertices_y[$i]) / ($vertices_y[$j] - $vertices_y[$i]) + $vertices_x[$i])))
            $c = !$c;
    }
    return $c;
}

function is_restro_open($id)
{
    if (isset($id) && !empty($id)) {
        $t = &get_instance();
        $t->db->select('id');
        $t->db->where("day = DAYNAME(CURDATE())  and opening_time <= CURTIME() and closing_time >= CURTIME() and is_open=1 and partner_id = $id");
        $result = $t->db->from("partner_timings")->get()->result_array();
        if (!empty($result)) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function is_order_deliverable($address_id, $latitude_y, $longitude_x, $partner_id, $type = "address")
{
    if (!empty($partner_id) || $partner_id != "") {
        // echo "hello";
        $data = fetch_details(['id' => $partner_id], "users", "latitude,longitude");
        if ($type == "city") {
            $partner = fetch_details(['id' => $address_id], 'cities', 'geolocation_type,radius,boundary_points,max_deliverable_distance');
        } else {
            $partner = fetch_details(['a.id' => $address_id], 'addresses a', 'a.city_id,c.geolocation_type,c.radius,c.boundary_points,c.max_deliverable_distance', null, null, null, "DESC", "", '', "cities c", "a.city_id=c.id");
        }
        $city_distance = $partner[0]['max_deliverable_distance'];
        if (isset($partner) && !empty($partner) && isset($partner[0]['geolocation_type']) && $partner[0]['geolocation_type'] == "polygon") {
            $vertices_x = array_column(json_decode($partner[0]['boundary_points'], true), "lng");    // lng x-coordinates of the vertices of the polygon
            $vertices_y =  array_column(json_decode($partner[0]['boundary_points'], true), "lat");    // lat y-coordinates of the vertices of the polygon
            $points_polygon = count($vertices_x);  // number vertices - zero-based array
            if (is_in_polygon($points_polygon, $vertices_x, $vertices_y, $longitude_x, $latitude_y)) {
                // check for distance 
                $distance = calculate_distance($data[0]['latitude'], $data[0]['longitude'], $latitude_y, $longitude_x);
                if ($distance <=  $city_distance) {
                    return true;   // in distance
                } else {
                    return false;    // not in distance   
                }
            } else {
                return false;    // not in polygon
            }
        } else if (isset($partner) && !empty($partner) && $partner[0]['geolocation_type'] == "circle") {
            // check for distance
            $distance = calculate_distance($data[0]['latitude'], $data[0]['longitude'], $latitude_y, $longitude_x);
            if ($distance <=  $city_distance) {
                return true;   // in distance
            } else {
                return false;    // not in distance   
            }
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function calculate_distance($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo)
{
    /* distance calculator from two points */
    $long1 = deg2rad($longitudeFrom);
    $long2 = deg2rad($longitudeTo);
    $lat1 = deg2rad($latitudeFrom);
    $lat2 = deg2rad($latitudeTo);

    //Haversine Formula
    $dlong = $long2 - $long1;
    $dlati = $lat2 - $lat1;

    $val = pow(sin($dlati / 2), 2) + cos($lat1) * cos($lat2) * pow(sin($dlong / 2), 2);

    $res = 2 * asin(sqrt($val));

    $radius = 6371;
    $distance = ($res * $radius);
    $final_distance = round($distance + ((23.49 / 100) * $distance));
    return ($final_distance);
}

function find_google_map_distance($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo)
{
    // default mode : driving
    $t = &get_instance();
    $t->load->library('google_maps');
    $origins = implode(",", [$latitudeFrom, $longitudeFrom]);
    $destinations = implode(",", [$latitudeTo, $longitudeTo]);
    $result = $t->google_maps->find_google_map_distance($origins, $destinations);
    return ($result);
}

function is_single_seller($product_variant_id, $user_id)
{
    $t = &get_instance();
    if (isset($product_variant_id) && !empty($product_variant_id) && $product_variant_id != "" && isset($user_id) && !empty($user_id) && $user_id != "") {
        $pv_id = (strpos($product_variant_id, ",")) ? explode(",", $product_variant_id) : $product_variant_id;

        // get exist data from cart if any 
        $exist_data = $t->db->select('`c`.product_variant_id,p.partner_id')
            ->join('product_variants pv ', 'pv.id=c.product_variant_id', 'left')
            ->join('products p ', 'pv.product_id=p.id', 'left')
            ->where(['user_id' => $user_id])->group_by('p.partner_id')->get('cart c')->result_array();
        if (!empty($exist_data)) {
            $partner_id = array_values(array_unique(array_column($exist_data, "partner_id")));
        } else {
            // clear to add cart
            return true;
        }
        // get restro ids of varients
        $new_data = $t->db->select('p.partner_id')
            ->join('products p ', 'pv.product_id=p.id', 'left')
            ->where_in('pv.id', $pv_id)->get('product_variants pv')->result_array();
        $new_partner_id = $new_data[0]["partner_id"];
        if (!empty($partner_id) && !empty($new_partner_id)) {
            if (in_array($new_partner_id, $partner_id)) {
                // clear to add to cart
                return true;
            } else {
                // another restro id verient, give single restro error
                return false;
            }
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function fetch_partners($filter = null, $user_id = null, $limit = NULL, $offset = '', $sort = 'u.id', $order = 'DESC', $search = NULL)
{
    $t = &get_instance();
    $multipleWhere = '';
    $where = ['u.active' => 1, 'sd.status' => 1, ' p.status' => 1, 'ug.group_id' => '4'];

    if (isset($filter) && !empty($filter['slug']) && $filter['slug'] != "") {
        $where['sd.slug'] = $filter['slug'];
    }

    if (isset($filter) && isset($filter['ignore_status']) && $filter['ignore_status'] == TRUE) {
        $where = ['u.active' => 1, 'ug.group_id' => '4'];
    }

    if (isset($filter) && !empty($filter['type']) && $filter['type'] != "") {
        $where['sd.type'] = $filter['type'];
    }
    if (isset($filter) && !empty($filter['city_id']) && $filter['city_id'] != "") {
        $where['u.city'] = $filter['city_id'];
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

    $count_res = $t->db->select(' COUNT(DISTINCT u.id) as `total` ')
        ->join('users_groups ug', ' ug.user_id = u.id ')
        ->join('partner_data sd', ' sd.user_id = u.id ')
        ->join('products p', ' p.partner_id = u.id ', "left")
        ->join('cities c', 'c.id = u.city', "left")
        ->join('partner_timings rt', 'rt.partner_id = sd.user_id');

    if (isset($multipleWhere) && !empty($multipleWhere)) {
        $count_res->group_start();
        $count_res->or_like($multipleWhere);
        $count_res->group_end();
    }
    if (isset($filter) && !empty($filter['only_opened_partners']) && $filter['only_opened_partners'] != "") {
        $count_res->where("day = DAYNAME(CURDATE())  and opening_time < CURTIME() and is_open=1");
    }
    if (isset($filter) && !empty($filter['id']) && $filter['id'] != null) {
        if (is_array($filter['id']) && !empty($filter['id'])) {
            $count_res->where_in('sd.user_id', $filter['id']);
            $count_res->where($where);
        } else {
            $where['sd.user_id'] = $filter['id'];
            $count_res->where($where);
        }
    } else {
        $count_res->where($where);
    }
    if (isset($where) && !empty($where)) {
        $count_res->where($where);
    }

    $offer_count = $count_res->get('users u')->result_array();
    foreach ($offer_count as $row) {
        $total = $row['total'];
    }

    $search_res = $t->db->select(' `u`.username as owner_name,u.id as partner_id,u.email,u.mobile,u.balance,sd.address as partner_address,u.city as city_id,c.name as city_name,c.time_to_travel,u.fcm_id,u.latitude,u.longitude,`sd`.* ')
        ->join('users_groups ug', ' ug.user_id = u.id ')
        ->join('partner_data sd', ' sd.user_id = u.id ')
        ->join('products p', ' p.partner_id = u.id ', "left")
        ->join('cities c', 'c.id = u.city', "left")
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
        $search_res->where($where);
    }
    if (isset($filter) && !empty($filter['id']) && $filter['id'] != null) {
        if (is_array($filter['id']) && !empty($filter['id'])) {
            $search_res->where_in('sd.user_id', $filter['id']);
            $search_res->where($where);
        } else {
            $where['sd.user_id'] = $filter['id'];
            $search_res->where($where);
        }
    }

    $restro_search_res = $search_res->group_by('u.id')->order_by($sort, $order)->limit($limit, $offset)->get('users u')->result_array();
    $bulkData = array();
    $bulkData['error'] = (empty($restro_search_res)) ? true : false;
    $bulkData['message'] = (empty($restro_search_res)) ? 'partner(s) does not exist' : 'partner retrieved successfully';
    $bulkData['total'] = (empty($restro_search_res)) ? 0 : $total;
    $rows = $tempRow = array();
    foreach ($restro_search_res as $row) {
        $row = output_escaping($row);

        // removing null and set base url
        $gallery = json_decode($row['gallery']);
        $gallery = array_map(function ($value) {
            return base_url() . $value;
        }, $gallery);
        $tempRow['partner_id'] = $row['partner_id'];

        // set fevorite count if restro have
        if (isset($user_id) && $user_id != null) {
            $fav = $t->db->where(['type_id' => $row['partner_id'], 'type' => 'partners', 'user_id' => $user_id])->get('favorites')->num_rows();
            $tempRow['is_favorite'] = strval($fav);
        } else {
            $tempRow['is_favorite'] = '0';
        }
        $tempRow['is_restro_open'] = (is_restro_open($row['partner_id']) == true) ? "1" : "0";

        // calculate delivery time and distance for restro
        if (isset($filter) && !empty($filter['latitude']) && !empty($filter['longitude'])) {
            $tempRow['partner_cook_time'] = strval(calculate_delivery_time($row['latitude'], $row['longitude'], $filter['latitude'], $filter['longitude'], $row['time_to_travel'], $row['cooking_time']));
            $tempRow['distance'] = strval(calculate_distance($row['latitude'], $row['longitude'], $filter['latitude'],  $filter['longitude'])) . " km";
        } else {
            $tempRow['partner_cook_time'] = (isset($row['cooking_time']) && !empty($row['cooking_time'])) ? $row['cooking_time'] . " min" : "0";
            $tempRow['distance'] = "0";
        }
        $tempRow['owner_name'] = $row['owner_name'];
        $tempRow['email'] = $row['email'];
        $tempRow['tags'] = get_tags_by_id($row['partner_id'], "partner_tags");
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
        $tempRow['partner_indicator'] = $row['type'];
        $tempRow['gallery'] = $gallery;
        $tempRow['partner_rating'] = $row['rating'];
        $tempRow['permissions'] = (isset($row['permissions']) && $row['permissions'] != "") ? json_decode($row['permissions']) : "";
        $tempRow['no_of_ratings'] = $row['no_of_ratings'];
        $tempRow['account_number'] = $row['account_number'];
        $tempRow['account_name'] = $row['account_name'];
        $tempRow['bank_code'] = $row['bank_code'];
        $tempRow['bank_name'] = $row['bank_name'];
        $tempRow['pan_number'] = $row['pan_number'];
        $tempRow['cooking_time'] = $row['cooking_time'];
        $tempRow['status'] = $row['status'];
        $tempRow['commission'] = $row['commission'];
        $tempRow['partner_profile'] = (isset($row['profile']) && !empty($row['profile'])) ? base_url() . $row['profile'] : base_url() . NO_IMAGE;
        $tempRow['national_identity_card'] = (isset($row['national_identity_card']) && !empty($row['national_identity_card'])) ? base_url() . $row['national_identity_card'] : base_url() . NO_IMAGE;
        $tempRow['address_proof'] = (isset($row['address_proof']) && !empty($row['address_proof'])) ? base_url() . $row['address_proof'] : base_url() . NO_IMAGE;
        $tempRow['tax_number'] = $row['tax_number'];
        $tempRow['tax_name'] = $row['tax_name'];
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

function has_rider_one_order($rider_id, $order_id)
{
    $t = &get_instance();
    $delivery_res =  $t->db->select('id')->where(['rider_id' => $rider_id])->where(['id !=' => $order_id])->where_in('active_status', ['pending', 'confirmed', 'preparing', 'out_for_delivery'])->get('orders')->result_array();
    if (isset($delivery_res) && !empty($delivery_res)) {
        return false;
    } else {
        return true;
    }
}

function send_notifications($role_id = "", $role = "user", $title = "", $body = "", $type = "", $id = "")
{
    $t = &get_instance();
    $settings = get_settings('system_settings', true);
    $fcm_ids = array();
    if ($role == 'admins') {
        // send notification to all system users

        $user_roles = fetch_details("", "user_permissions up", 'u.fcm_id', "", "", "", "", "", "", 'users u', 'u.id=up.user_id');
        foreach ($user_roles as $user) {
            $user_res = fetch_details(['id' => $user['user_id']], 'users', 'fcm_id');
            $fcm_ids[0][] = $user_res[0]['fcm_id'];
        }
        if (!empty($fcm_ids)) {
            $fcmMsg = array(
                'title' => $title,
                'body' => $body,
                'type' => $type,
                'content_available' => true
            );
            send_notification($fcmMsg, $fcm_ids);
        }
        if ($settings['is_email_setting_on'] == "1") {
            send_mail($settings['support_email'], $title, $body);
        }
        return true;
    } else if ($role == 'partner') {
        $partner = fetch_details(['u.id' => $role_id], 'users u', 'u.email,rd.partner_name,u.fcm_id', null, null, null, "DESC", "", '', "partner_data rd", "rd.user_id=u.id");
        $fcm_ids[0][] = $partner[0]['fcm_id'];
        $fcm_restro_msg = (isset($body) && $body != "") ? 'New order placed for ' . $partner[0]['partner_name'] . ' please confirm it.' : $body;

        if (!empty($fcm_ids)) {
            $fcmMsg = array(
                'title' => $title,
                'body' => $fcm_restro_msg,
                'type' => $type,
                'content_available' => true
            );
            send_notification($fcmMsg, $fcm_ids);
        }

        if (get_partner_permission($role_id, 'is_email_setting_on')) {
            send_mail($partner[0]['email'], $title, $fcm_restro_msg);
        }
        return true;
    } else if ($role == "user") {
        $user_res = fetch_details(['id' => $role_id], 'users', 'username,fcm_id,email');

        if (!empty($user_res[0]['fcm_id'])) {
            $fcmMsg = array(
                'title' => $title,
                'body' => 'Hello Dear ' . $user_res[0]['username'] . "\n" . $body,
                'type' => $type,
                'type_id' => $id,
                'content_available' => true
            );
            $fcm_ids[0][] = $user_res[0]['fcm_id'];
            send_notification($fcmMsg, $fcm_ids);
        }
        send_mail($user_res[0]['email'], $title, 'Hello Dear ' . $user_res[0]['username'] . $body);
        return true;
    } else if ($role == "rider") {
        $riders = fetch_details(['serviceable_city' => $id], 'users', 'serviceable_city,fcm_id,username');
        if (!empty($riders[0]['fcm_id'])) {
            $fcmMsg = array(
                'title' => $title,
                'body' => 'Hello Dear ' . $riders[0]['username'] . $body,
                'type' => $type,
                'content_available' => true
            );
            $fcm_ids[0][] = $riders[0]['fcm_id'];
            send_notification($fcmMsg, $fcm_ids);
        }
        return true;
    } else {
        return false;
    }
}

function update_rider($rider_id, $order_id, $status = "accepted")
{
    $t = &get_instance();
    $t->load->model("Order_model");
    $where = ['id' => $order_id];
    $current_rider = fetch_details($where, 'orders', 'rider_id');
    $settings = get_settings('system_settings', true);
    $app_name = isset($settings['app_name']) && !empty($settings['app_name']) ? $settings['app_name'] : '';
    $user_res = fetch_details(['id' => $rider_id], 'users', 'fcm_id,username');
    $fcm_ids = array();
    $msg = "";
    if (isset($user_res[0]) && !empty($user_res[0])) {
        if (is_exist(['order_id' => $order_id], "pending_orders")) {
            delete_details(['order_id' => $order_id], "pending_orders");
        }
        if (isset($current_rider[0]['rider_id']) && $current_rider[0]['rider_id'] == $rider_id) {
            $fcmMsg = array(
                'title' => "Order rider updated",
                'body' => 'Hello Dear ' . $user_res[0]['username'] . ' order status updated to ' . $status . ' for order ID #' . $order_id . ' assigned to you please take note of it! Thank you. Regards ' . $app_name . '',
                'type' => "order"
            );
            $msg = 'Rider Notified. ';
            $delivery_error = false;
        } else {
            if (isset($current_rider[0]['rider_id']) && !empty($current_rider[0]['rider_id']) && $current_rider[0]['rider_id'] != $rider_id) {
                $delivery_error = true;
                $msg = "This order has already assign to other Rider.";
            } else {
                $fcmMsg = array(
                    'title' => "You have new order to deliver",
                    'body' => 'Hello Dear ' . $user_res[0]['username'] . ' you have new order to be deliver order ID #' . $order_id . '. Order details you can take from app order details. Please take note of it! Thank you. Regards ' . $app_name . '',
                    'type' => "order"
                );
                $msg = 'Rider Updated.';
                if ($t->Order_model->update_order(['rider_id' => $rider_id], $where)) {
                    $delivery_error = false;
                } else {
                    $delivery_error = true;
                }
            }
        }
    }
    if (!empty($user_res[0]['fcm_id'])) {
        $fcm_ids[0][] = $user_res[0]['fcm_id'];
        send_notification($fcmMsg, $fcm_ids);
        $delivery_error = false;
    }
    $response['error'] = $delivery_error;
    $response['message'] = $msg;
    $response['data'] = array();
    return $response;
}

function calculate_delivery_time($restro_lat, $restro_lng, $user_lat, $user_lng, $time_to_travel_city, $cooking_time = 0)
{
    // find distance
    $distance = calculate_distance($restro_lat, $restro_lng, $user_lat, $user_lng);
    if ($distance > 0) {
        $time = ($distance * intval($time_to_travel_city)) + intval($cooking_time);
        if ($time >= 60) {
            $time = $time / 60;
            return number_format($time, 2) . " hours";
        } else {
            return number_format($time, 2) . " min";
        }
    } else {
        $time = intval($cooking_time) . " min";
        return $time;
    }
}

function update_cash_received($amount, $rider_id, $action)
{
    $t = &get_instance();

    if ($action == "add") {
        $t->db->set('cash_received', 'cash_received+' . $amount, FALSE);
    } elseif ($action == "deduct") {
        $t->db->set('cash_received', 'cash_received-' . $amount, FALSE);
    }
    return $t->db->where('id', $rider_id)->update('users');
}

function test()
{
    $res = get_invoice_html(100);
    print_r($res);
}
