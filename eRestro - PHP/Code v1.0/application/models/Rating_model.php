<?php
if (!defined('BASEPATH')) exit('No direct script access allowed');
class Rating_model extends CI_Model
{

    public function set_rating($data)
    {
        $data = escape_array($data);

        $rating = array(
            'user_id' => $data['user_id'],
            'product_id' => $data['product_id'],
        );
        if (isset($data['rating']) && !empty($data['rating'])) {
            $rating['rating'] = $data['rating'];
        }
        if (isset($data['comment']) && !empty($data['comment'])) {
            $rating['comment'] = $data['comment'];
        }
        if (isset($data['images']) && !empty($data['images'])) {
            $rating['images'] = json_encode($data['images']);
        }
        if ($this->db->where(['user_id' => $data['user_id'], 'product_id' => $data['product_id']])->get('product_rating')->num_rows() > 0) {
            $this->db->where(['user_id' => $data['user_id'], 'product_id' => $data['product_id']])->update('product_rating', $rating);
        } else {
            $this->db->insert('product_rating', $rating);
        }

        if (isset($data['rating']) && !empty($data['rating'])) {
            
            // updateing product rating
            $product_rating = $this->db->select('rating,(select count(rating) from product_rating where product_id=' . $data['product_id'] . ')as no_of_ratings,(select sum(rating) from product_rating where product_id=' . $data['product_id'] . ') as sum_of_rating')->where('id', $data['product_id'])->get('products')->result_array();
            $totalrating = ($product_rating[0]['sum_of_rating'] != null) ? $product_rating[0]['sum_of_rating'] : $data['rating'];
            $no_of_rating = intval($product_rating[0]['no_of_ratings']);
            if ($no_of_rating > 0) {
                $newrating = round($totalrating / $no_of_rating, 1, PHP_ROUND_HALF_UP);
            } else {
                $newrating = 0;
            }
            $this->db->set(['rating' => $newrating, 'no_of_ratings' => $no_of_rating])->where('id', $data['product_id'])->update('products');

            // updateing seller rating
            $partner_id = fetch_details(['id' => $data['product_id']], 'products', 'partner_id');
            $partner_id = $partner_id[0]['partner_id'];
            $where = "partner_id = $partner_id and rating > 0";
            $seller_rating = $this->db->select('rating,count(rating) as no_of_ratings,sum(rating) as sum_of_rating')->where($where)->get('products')->result_array();

            $total_rating = ($seller_rating[0]['sum_of_rating'] != null) ? $seller_rating[0]['sum_of_rating'] : $data['rating'];
            $no_of_ratings = intval($seller_rating[0]['no_of_ratings']);
            if ($no_of_ratings > 0) {
                $new_rating = round($total_rating / $no_of_ratings, 1, PHP_ROUND_HALF_UP);
            } else {
                $new_rating = 0;
            }
            $this->db->set(['rating' => $new_rating, 'no_of_ratings' => $no_of_ratings])->where('user_id', $partner_id)->update('partner_data');
        }
    }
    public function set_rider_rating($data)
    {
        $data = escape_array($data);

        $rating = array(
            'user_id' => $data['user_id'],
            'rider_id' => $data['rider_id'],
        );
        if (isset($data['rating']) && !empty($data['rating'])) {
            $rating['rating'] = $data['rating'];
        }
        if (isset($data['comment']) && !empty($data['comment'])) {
            $rating['comment'] = $data['comment'];
        }
       
        if ($this->db->where(['user_id' => $data['user_id'], 'rider_id' => $data['rider_id']])->get('rider_rating')->num_rows() > 0) {
            $this->db->where(['user_id' => $data['user_id'], 'rider_id' => $data['rider_id']])->update('rider_rating', $rating);
        } else {
            $this->db->insert('rider_rating', $rating);
        }

        if (isset($data['rating']) && !empty($data['rating'])) {
            
            // updateing rider rating
            $rider_rating = $this->db->select('rating,(select count(rating) from rider_rating where rider_id=' . $data['rider_id'] . ')as no_of_ratings,(select sum(rating) from rider_rating where rider_id=' . $data['rider_id'] . ') as sum_of_rating')->where('id', $data['rider_id'])->get('users')->result_array();

            $totalrating = ($rider_rating[0]['sum_of_rating'] != null) ? $rider_rating[0]['sum_of_rating'] : $data['rating'];
            $no_of_rating = intval($rider_rating[0]['no_of_ratings']);
            if ($no_of_rating > 0) {
                $newrating = round($totalrating / $no_of_rating, 1, PHP_ROUND_HALF_UP);
            } else {
                $newrating = 0;
            }
            $this->db->set(['rating' => $newrating, 'no_of_ratings' => $no_of_rating])->where('id', $data['rider_id'])->update('users');
        }
    }

    public function delete_rating($rating_id)
    {
        $rating_id = escape_array($rating_id);
        $rating_details = fetch_details(['id' => $rating_id], 'product_rating', '*');
        $images = json_decode($rating_details[0]['images'], 1);
        if (!empty($images)) {
            for ($i = 0; $i < count($images); $i++) {
                unlink(FCPATH . $images[$i]);
            }
        }

        $this->db->delete('product_rating', ['id' => $rating_id]);

        $product_rating = $this->db->select('rating,(select count(rating) from product_rating where product_id=' . $rating_details[0]['product_id'] . ')as no_of_ratings,(select sum(rating) from product_rating where product_id=' . $rating_details[0]['product_id'] . ') as sum_of_rating')->where('id', $rating_details[0]['product_id'])->get('products')->result_array();
        $totalrating = ($product_rating[0]['sum_of_rating'] != null) ? $product_rating[0]['sum_of_rating'] : 0;
        $no_of_rating = intval($product_rating[0]['no_of_ratings']);

        if ($no_of_rating > 0) {
            $newrating = round($totalrating / $no_of_rating, 1, PHP_ROUND_HALF_UP);
        } else {
            $newrating = 0;
        }

        $this->db->set(['rating' => $newrating, 'no_of_ratings' => $no_of_rating])->where('id', $rating_details[0]['product_id'])->update('products');

        $partner_id = fetch_details(['id' => $rating_details[0]['product_id']], 'products', 'partner_id');
        $partner_id = $partner_id[0]['partner_id'];
        $where = "partner_id = $partner_id and rating > 0";

        $partner_rating = $this->db->select('rating,count(rating) as no_of_ratings,sum(rating) as sum_of_rating')->where($where)->get('products')->result_array();

        $total_rating = ($partner_rating[0]['sum_of_rating'] != null) ? $partner_rating[0]['sum_of_rating'] : 0;
        $no_of_ratings = intval($partner_rating[0]['no_of_ratings']);
        if ($no_of_ratings > 0) {
            $new_rating = round($total_rating / $no_of_ratings, 1, PHP_ROUND_HALF_UP);
        } else {
            $new_rating = 0;
        }
        $this->db->set(['rating' => $new_rating, 'no_of_ratings' => $no_of_ratings])->where('user_id', $partner_id)->update('partner_data');
    }

    public function delete_rider_rating($rating_id)
    {
        $rating_id = escape_array($rating_id);
        $rating_details = fetch_details(['id' => $rating_id], 'rider_rating', '*');
       

        $this->db->delete('rider_rating', ['id' => $rating_id]);

        $rider_rating = $this->db->select('rating,(select count(rating) from rider_rating where rider_id=' . $rating_details[0]['rider_id'] . ')as no_of_ratings,(select sum(rating) from rider_rating where rider_id=' . $rating_details[0]['rider_id'] . ') as sum_of_rating')->where('id', $rating_details[0]['rider_id'])->get('users')->result_array();
        $totalrating = ($rider_rating[0]['sum_of_rating'] != null) ? $rider_rating[0]['sum_of_rating'] : 0;
        $no_of_rating = intval($rider_rating[0]['no_of_ratings']);

        if ($no_of_rating > 0) {
            $newrating = round($totalrating / $no_of_rating, 1, PHP_ROUND_HALF_UP);
        } else {
            $newrating = 0;
        }
        $this->db->set(['rating' => $newrating, 'no_of_ratings' => $no_of_rating])->where('id', $rating_details[0]['rider_id'])->update('users');
    }

    function fetch_rating($product_id = NULL, $user_id = NULL, $limit = Null, $offset = Null, $sort = Null, $order = Null, $rating_id = null, $has_images = null)
    {
        $t = &get_instance();
        $where = $images = [];
        if (isset($product_id) && !empty($product_id)) {
            $t->db->select('pr.*,u.username as user_name,u.image as user_profile');
            $where['product_id'] = $product_id;
        }
        if (isset($user_id) && !empty($user_id)) {
            $where['user_id'] = $user_id;
        }
        if (isset($rating_id) && !empty($rating_id)) {
            $where['id'] = $rating_id;
        }
        $t->db->order_by($sort, $order);
        if (!empty($limit && $offset != "")) {
            $t->db->limit($limit, $offset);
        }
        if (isset($has_images) && $has_images == 1) {
            $where['pr.images !='] =  null;
        }
        $t->db->where($where);
        $product_rating = $t->db->join('users u', 'u.id = pr.user_id', 'left')->get('product_rating pr')->result_array();
        if (!empty($product_rating)) {
            $total_rating = $t->db->select(' count(pr.id) as no_of_rating ')->join('users u', 'u.id=pr.user_id')->where('product_id', $product_id)->get('product_rating pr')->result_array();
            // $total_images = $t->db->select(' SUM(JSON_LENGTH(`images`)) as total ')->where('product_id', $product_id)->get('product_rating pr')->result_array();
            $total_images = $t->db->select(' ROUND (((LENGTH(`images`) - LENGTH(REPLACE(`images`, ",", ""))) / LENGTH(","))+1) as total ')->where('product_id', $product_id)->get('product_rating pr')->result_array();
            $total_review_with_images = $t->db->select(' count(pr.id) as total ')->where('product_id', $product_id)->where('pr.images !=', null)->get('product_rating pr')->result_array();
            $total_reviews = $t->db->select(' count(pr.id) as total,sum(case when CEILING(rating) = 1 AND product_id = '.$product_id.' then 1 else 0 end) as rating_1,sum(case when CEILING(rating) = 2 AND product_id = '.$product_id.' then 1 else 0 end) as rating_2,sum(case when CEILING(rating) = 3 AND product_id = '.$product_id.' then 1 else 0 end) as rating_3,sum(case when CEILING(rating) = 4 AND product_id = '.$product_id.' then 1 else 0 end) as rating_4,sum(case when CEILING(rating) = 5 AND product_id = '.$product_id.' then 1 else 0 end) as rating_5 ')->where('product_id', $product_id)->get('product_rating pr')->result_array();
            for ($i = 0; $i < count($product_rating); $i++) {
                $product_rating[$i] = output_escaping($product_rating[$i]);
                if (isset($product_rating[$i]['images']) && ($product_rating[$i]['images'] != null || !empty($product_rating[$i]['images']))) {
                    $images = json_decode($product_rating[$i]['images'], 1);
                    // for ($k = 0; $k < count($images); $k++) {
                    //     $images[$k] = base_url() . $images[$k];
                    // }
                    $images = array_map(function ($value) {
                        return base_url() . $value;
                    }, $images);
                    $product_rating[$i]['images'] = (!empty($images)) ? $images : array();
                } else {
                    $product_rating[$i]['images'] = array();
                }
                if(isset( $product_rating[$i]['user_profile']) && !empty( $product_rating[$i]['user_profile'])){
                    $product_rating[$i]['user_profile'] =  base_url() . USER_IMG_PATH . $product_rating[$i]['user_profile'];
                } 
            }
            if (!$total_images) {
                $res['total_images'] = $total_rating[0]['no_of_rating'];
            } else {
                $res['total_images'] = $total_images[0]['total'];
            }
            $res['total_reviews_with_images'] = $total_review_with_images[0]['total'];
            $res['no_of_rating'] = $total_rating[0]['no_of_rating'];
            $res['total_reviews'] = $total_reviews[0]['total'];
            $res['star_1'] = $total_reviews[0]['rating_1'];
            $res['star_2'] = $total_reviews[0]['rating_2'];
            $res['star_3'] = $total_reviews[0]['rating_3'];
            $res['star_4'] = $total_reviews[0]['rating_4'];
            $res['star_5'] = $total_reviews[0]['rating_5'];
            $res['product_rating'] = $product_rating;

            return $res;
        }
    }

    function fetch_rider_rating($rider_id = NULL, $user_id = NULL, $limit = Null, $offset = Null, $sort = Null, $order = Null, $rating_id = null)
    {
        $t = &get_instance();
        $where = $images = [];
        if (isset($rider_id) && !empty($rider_id)) {
            $t->db->select('pr.*,u.username as user_name,u.image as user_profile,ud.rating as rider_rating');
            $where['rider_id'] = $rider_id;
        }
        if (isset($user_id) && !empty($user_id)) {
            $where['user_id'] = $user_id;
        }
        if (isset($rating_id) && !empty($rating_id)) {
            $where['id'] = $rating_id;
        }
        $t->db->order_by($sort, $order);
        if (!empty($limit && $offset != "")) {
            $t->db->limit($limit, $offset);
        }
       
        $t->db->where($where);
        $product_rating = $t->db->join('users u', 'u.id = pr.user_id', 'left')->join('users ud', 'ud.id = pr.rider_id', 'left')->get('rider_rating pr')->result_array();
        if (!empty($product_rating)) {
            $total_rating = $t->db->select(' count(pr.id) as no_of_rating ')->join('users u', 'u.id=pr.user_id')->where('rider_id', $rider_id)->get('rider_rating pr')->result_array();
            $total_reviews = $t->db->select(' count(pr.id) as total,sum(case when CEILING(rating) = 1 AND rider_id = '.$rider_id.' then 1 else 0 end) as rating_1,sum(case when CEILING(rating) = 2 AND rider_id = '.$rider_id.' then 1 else 0 end) as rating_2,sum(case when CEILING(rating) = 3 AND rider_id = '.$rider_id.' then 1 else 0 end) as rating_3,sum(case when CEILING(rating) = 4 AND rider_id = '.$rider_id.' then 1 else 0 end) as rating_4,sum(case when CEILING(rating) = 5 AND rider_id = '.$rider_id.' then 1 else 0 end) as rating_5 ')->where('rider_id', $rider_id)->get('rider_rating pr')->result_array();
            for ($i = 0; $i < count($product_rating); $i++) {
                $product_rating[$i] = output_escaping($product_rating[$i]);
                if(isset( $product_rating[$i]['user_profile']) && !empty( $product_rating[$i]['user_profile'])){
                    $product_rating[$i]['user_profile'] =  base_url() . USER_IMG_PATH . $product_rating[$i]['user_profile'];
                } 
            }
           
            $res['no_of_rating'] = $total_rating[0]['no_of_rating'];
            $res['rating'] = $product_rating[0]['rider_rating'];
            $res['total_reviews'] = $total_reviews[0]['total'];
            $res['star_1'] = $total_reviews[0]['rating_1'];
            $res['star_2'] = $total_reviews[0]['rating_2'];
            $res['star_3'] = $total_reviews[0]['rating_3'];
            $res['star_4'] = $total_reviews[0]['rating_4'];
            $res['star_5'] = $total_reviews[0]['rating_5'];
            $res['rider_rating'] = $product_rating;

            return $res;
        }
    }


    public function get_rating()
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'DESC';

        $multipleWhere = '';

        if (isset($offset))
            $offset = $_GET['offset'];
        if (isset($limit))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($sort == 'id') {
                $sort = "id";
            } else {
                $sort = $sort;
            }

        if (isset($order) and $order != '') {
            $search = $order;
        }
        if (isset($_GET['product_id']) && $_GET['product_id'] != null) {
            $where['product_id'] = $_GET['product_id'];
        }
        if (isset($_GET['user_id']) && $_GET['user_id'] != null) {
            $where['user_id'] = $_GET['user_id'];
        }

        $count_res = $this->db->select(' COUNT(pr.id) as total  ')->join('users u', 'u.id=pr.user_id');
        if (isset($_GET['search']) && trim($_GET['search'])) {
            $search = trim($_GET['search']);
            $multipleWhere = ['u.username' => $search, 'pr.comment' => $search, 'pr.rating' => $search];
        }
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_start();
            $count_res->or_like($multipleWhere);
            $this->db->group_end();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $rating_count = $count_res->get('product_rating pr')->result_array();
        foreach ($rating_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('pr.*,u.username as user_name')->join('users u', 'u.id=pr.user_id');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_start();
            $search_res->or_like($multipleWhere);
            $this->db->group_end();
        }

        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $rating_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('product_rating pr')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        $i = 0;
        foreach ($rating_search_res as $row) {
            $row = output_escaping($row);
            $date = new DateTime($row['data_added']);
            $operate = '<a class="btn btn-danger btn-xs mr-1 mb-1 delete-product-rating" href="javascript:void(0)" title="Delete" data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';
            $tempRow['id'] = $row['id'];
            $tempRow['username'] = $row['user_name'];
            if (isset($row['images']) && !empty($row['images'])) {
                $images = json_decode($row['images']);
                $tempRow['images'] = '';
                for ($j = 0; $j < count($images); $j++) {
                    $image_unique_name = 'rating-image-' . $i;
                    $image_url  =  get_image_url($images[$j], 'thumb', 'sm');
                    if ($j == 0) {
                        $counter = count($images) - 1;
                        $counter = (count($images) > 1) ? '+ ' . $counter : ' ';
                        $tempRow['images'] = '<div class="row"><div class="col-md-6"><div class="mx-auto product-image "><a href=' . $image_url . ' data-toggle="lightbox" data-gallery=' . $image_unique_name . '> <img src=' . $image_url . ' class="img-fluid rounded"> </a></div></div><div class="col-md-6 my-auto "> <span class="text-primary">  ' . $counter . '</span></div></div>';
                    } else {
                        $tempRow['images'] .= '<div class="mx-auto product-image d-none"><a href=' . $image_url . ' data-toggle="lightbox" data-gallery=' . $image_unique_name . '><img src=' . $image_url . ' class="img-fluid rounded"></a></div>';
                    }
                }
            } else {
                $tempRow['images'] = '-';
            }

            $tempRow['rating'] = '<input type="text" class="kv-fa rating-loading" value="' . $row['rating'] . '" data-size="xs" title="" readonly>';
            $tempRow['comment'] = $row['comment'];
            $tempRow['data_added'] = $date->format('d-M-Y g:i A');
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $i++;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }

    public function get_rider_rating()
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'DESC';

        $multipleWhere = '';

        if (isset($offset))
            $offset = $_GET['offset'];
        if (isset($limit))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($sort == 'id') {
                $sort = "id";
            } else {
                $sort = $sort;
            }

        if (isset($order) and $order != '') {
            $search = $order;
        }
        if (isset($_GET['rider_id']) && $_GET['rider_id'] != null) {
            $where['rider_id'] = $_GET['rider_id'];
        }
        if (isset($_GET['user_id']) && $_GET['user_id'] != null) {
            $where['user_id'] = $_GET['user_id'];
        }

        $count_res = $this->db->select(' COUNT(pr.id) as total  ')->join('users u', 'u.id=pr.user_id');
        if (isset($_GET['search']) && trim($_GET['search'])) {
            $search = trim($_GET['search']);
            $multipleWhere = ['u.username' => $search, 'pr.comment' => $search, 'pr.rating' => $search];
        }
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_start();
            $count_res->or_like($multipleWhere);
            $this->db->group_end();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $rating_count = $count_res->get('rider_rating pr')->result_array();
        foreach ($rating_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('pr.*,u.username as user_name')->join('users u', 'u.id=pr.user_id');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $this->db->group_start();
            $search_res->or_like($multipleWhere);
            $this->db->group_end();
        }

        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $rating_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('rider_rating pr')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();

        $i = 0;
        foreach ($rating_search_res as $row) {
            $row = output_escaping($row);
            $date = new DateTime($row['data_added']);
            $operate = '<a class="btn btn-danger btn-xs mr-1 mb-1 delete-product-rating" href="javascript:void(0)" title="Delete" data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';
            $tempRow['id'] = $row['id'];
            $tempRow['username'] = $row['user_name'];
            $tempRow['rating'] = '<input type="text" class="kv-fa rating-loading" value="' . $row['rating'] . '" data-size="xs" title="" readonly>';
            $tempRow['comment'] = $row['comment'];
            $tempRow['data_added'] = $date->format('d-M-Y g:i A');
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $i++;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
