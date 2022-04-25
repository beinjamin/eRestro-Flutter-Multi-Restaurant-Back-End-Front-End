<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Product extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model(['product_model', 'category_model', 'rating_model']);

        if (!has_permissions('read', 'product')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }
    }
    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-product';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Product Management | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Product Management |' . $settings['app_name'];
            $this->data['categories'] = $this->category_model->get_categories();
            $this->data['partners'] = $this->db->select(' sd.partner_name,u.id as partner_id,sd.id as partner_data_id  ')
                ->join('users_groups ug', ' ug.user_id = u.id ')
                ->join('partner_data sd', ' sd.user_id = u.id ')
                ->where(['ug.group_id' => '4'])
                ->get('users u')->result_array();
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function create_product()
    {

        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'product';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Add Product | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Add Product | ' . $settings['app_name'];
            $this->data['taxes'] = fetch_details(null, 'taxes', '*');
            $this->data['default_tax_id'] = (isset($settings['tax']) && !empty($settings['tax'])) ?  $settings['tax'] : 0;
            $this->data['partners'] = $this->db->select(' sd.partner_name,u.id as partner_id,sd.id as partner_data_id  ')
                ->join('users_groups ug', ' ug.user_id = u.id ')
                ->join('partner_data sd', ' sd.user_id = u.id ')
                ->where(['ug.group_id' => '4'])
                ->get('users u')->result_array();

            $this->data['add_on_snaps'] = fetch_details(NULL, 'product_add_ons', '*', '', '','','','', '',"","",false,"title");
            if (isset($_GET['edit_id']) && !empty($_GET['edit_id'])) {
                $this->data['title'] = 'Update Product | ' . $settings['app_name'];
                $this->data['meta_description'] = 'Update Product | ' . $settings['app_name'];
                $product_details = fetch_details(['id' => $_GET['edit_id']], 'products', '*');
                $this->data['tags'] = fetch_details(["pt.product_id" => $_GET['edit_id']], "product_tags pt", "pt.*,t.title", null, null, null, "DESC", "", '', "tags t", "t.id=pt.tag_id");
                if (!empty($product_details)) {
                    $this->data['product_details'] = $product_details;
                    $this->data['product_variants'] = get_variants_values_by_pid($_GET['edit_id']);
                    $product_attributes = fetch_details(['product_id' => $_GET['edit_id']], 'product_attributes');
                    if (!empty($product_attributes) && !empty($product_details)) {
                        $this->data['product_attributes'] = $product_attributes;
                    }
                } else {
                    redirect('admin/product/create_product', 'refresh');
                }
            }

            if (!isset($_GET['edit_id']) && empty($_GET['edit_id'])) {
                $where = ['attr_val.status' => 1,'attr.status' => 1];
            }else{
                $where = [];
            }

            $query = $this->db->select('attr_val.id,attr.name as attr_name ,attr_val.value');
            if (isset($where) && !empty($where)) {
                $query->where($where);
            }
            $attributes = $query->join('attributes attr', 'attr.id=attr_val.attribute_id')
                ->get('attribute_values attr_val')->result_array();

            $attributes_refind = array();

            for ($i = 0; $i < count($attributes); $i++) {
                if (!array_key_exists($attributes[$i]['attr_name'], $attributes_refind)) {
                    for ($j = 0; $j < count($attributes); $j++) {
                        if ($attributes[$i]['attr_name'] == $attributes[$j]['attr_name']) {
                            if (!array_key_exists($attributes[$j]['attr_name'], $attributes_refind)) {
                                $attributes_refind[$attributes[$j]['attr_name']] = array();
                            }
                            $attributes_refind[$attributes[$j]['attr_name']][$j]['id'] = $attributes[$j]['id'];
                            $attributes_refind[$attributes[$j]['attr_name']][$j]['text'] = $attributes[$j]['value'];
                            $attributes_refind[$attributes[$j]['attr_name']][$j]['data-values'] = $attributes[$j]['value'];
                            $attributes_refind[$attributes[$j]['attr_name']] = array_values($attributes_refind[$attributes[$j]['attr_name']]);
                        }
                    }
                }
            }
            $this->data['categories'] = $this->category_model->get_categories();
            $this->data['attributes_refind'] = $attributes_refind;

            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }


    public function product_order()
    {

        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (!has_permissions('read', 'product_order')) {
                $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
                redirect('admin/home', 'refresh');
            }

            $this->data['main_page'] = TABLES . 'products-order';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Product Order | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Product Order | ' . $settings['app_name'];
            $this->data['categories'] = $this->category_model->get_categories();
            $products = $this->db->select('*')->order_by('row_order')->get('products')->result_array();
            $this->data['product_result'] = $products;
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function get_variants_by_id()
    {
        $attr_values = array();
        $final_variant_ids = array();
        $variant_ids = json_decode($this->input->get('variant_ids'));
        $attributes_values = json_decode($this->input->get('attributes_values'));
        foreach ($attributes_values as $a => $b) {
            foreach ($b as $key => $value) {
                array_push($attr_values, $value);
            }
        }
        $res = $this->db->select('id,value')->where_in('id', $attr_values)->get('attribute_values')->result_array();

        for ($i = 0; $i < count($variant_ids); $i++) {
            for ($j = 0; $j < count($variant_ids[$i]); $j++) {
                $k = array_search($variant_ids[$i][$j], array_column($res, 'id'));
                $final_variant_ids[$i][$j] = $res[$k];
            }
        }
        $response['result'] = $final_variant_ids;
        print_r(json_encode($response));
    }

    public function fetch_attributes_by_id()
    {
        $variants = get_variants_values_by_pid($_GET['edit_id']);
        $res['attr_values'] = get_attribute_values_by_pid($_GET['edit_id']);
        $res['pre_selected_variants_names'] = (!empty($variants)) ? $variants[0]['attr_name'] : null;
        $res['pre_selected_variants_ids'] = $variants;
        $response['csrfName'] = $this->security->get_csrf_token_name();
        $response['csrfHash'] = $this->security->get_csrf_hash();
        $response['result'] = $res;
        print_r(json_encode($response));
    }

    public function fetch_attribute_values_by_id($id = NULL)
    {
        if (isset($id) && !empty($id)) {
            $aid = $id;
        } else {
            $aid = $_GET['id'];
        }
        $variant_ids = get_attribute_values_by_id($aid);
        print_r(json_encode($variant_ids));
    }

    public function fetch_variants_values_by_pid()
    {
        $res = get_variants_values_by_pid($_GET['edit_id']);
        $response['result'] = $res;
        print_r(json_encode($response));
    }



    public function update_product_order()
    {

        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('update', 'product_order'), PERMISSION_ERROR_MSG, 'product_order', false)) {
                return false;
            }

            $i = 0;
            $temp = array();
            foreach ($_GET['product_id'] as $row) {
                $temp[$row] = $i;
                $data = [
                    'row_order' => $i
                ];
                $data = escape_array($data);
                $this->db->where(['id' => $row])->update('products', $data);
                $i++;
            }

            $response['error'] = false;
            $response['message'] = 'Product Order Saved !';

            print_r(json_encode($response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }


    public function search_category_wise_products()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            $this->db->select('p.*');
            if ($_GET['cat_id'] == 0) {
                $data = "";
            } else {
                $this->db->where('p.category_id', $_GET['cat_id']);
                $this->db->or_where('c.parent_id', $_GET['cat_id']);
            }

            $product_data = json_encode($this->db->order_by('row_order')->join('categories c', 'p.category_id = c.id')->get('products p')->result_array());
            print_r($product_data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function delete_product()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('delete', 'product'), PERMISSION_ERROR_MSG, 'product')) {
                return false;
            }
            if (delete_details(['product_id' => $_GET['id']], 'product_variants')) {

                delete_details(['id' => $_GET['id']], 'products');
                delete_details(['product_id' => $_GET['id']], 'product_attributes');
                delete_details(['product_id' => $_GET['id']], 'product_tags');
                delete_details(['product_id' => $_GET['id']], 'product_rating');
                delete_details(['product_id' => $_GET['id']], 'product_add_ons');
                $response['error'] = false;
                $response['message'] = 'Deleted Succesfully';
            } else {
                $response['error'] = true;
                $response['message'] = 'Something Went Wrong';
            }
            print_r(json_encode($response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function add_product()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (isset($_POST['edit_product_id'])) {
                if (print_msg(!has_permissions('update', 'product'), PERMISSION_ERROR_MSG, 'product')) {
                    return false;
                }
            } else {
                if (print_msg(!has_permissions('create', 'product'), PERMISSION_ERROR_MSG, 'product')) {
                    return false;
                }
            }

            $this->form_validation->set_rules('pro_input_name', 'Product Name', 'trim|required|xss_clean');
            $this->form_validation->set_rules('indicator', 'Product Indicator', 'trim|required|xss_clean');
            $this->form_validation->set_rules('short_description', 'Short Description', 'trim|required|xss_clean');
            $this->form_validation->set_rules('product_category_id', 'Category Id', 'trim|required|xss_clean', array('required' => 'Category is required'));
            $this->form_validation->set_rules('pro_input_tax', 'Tax', 'trim|xss_clean');
            $this->form_validation->set_rules('pro_input_image', 'Image', 'trim|required|xss_clean', array('required' => 'Image is required'));
            $this->form_validation->set_rules('product_type', 'Product type', 'trim|required|xss_clean');
            $this->form_validation->set_rules('partner_id', 'Partner', 'trim|required|xss_clean');
            $this->form_validation->set_rules('tags[]', 'tags', 'trim|required|xss_clean');
            $this->form_validation->set_rules('total_allowed_quantity', 'Total Allowed Quantity', 'trim|xss_clean');
            $this->form_validation->set_rules('calories', 'calories', 'trim|xss_clean|numeric');
            $this->form_validation->set_rules('minimum_order_quantity', 'Minimum Order Quantity', 'trim|xss_clean');
            $this->form_validation->set_rules('quantity_step_size', 'Quantity Step Size', 'trim|xss_clean');

            if (isset($_POST['highlights']) && $_POST['highlights'] != '') {
                $_POST['highlights'] = json_decode($_POST['highlights'], 1);
                $highlights = array_column($_POST['highlights'], 'value');
                $_POST['highlights'] = implode(",", $highlights);
            }
            if (isset($_POST['product_add_ons']) && $_POST['product_add_ons'] != '') {
                $_POST['product_add_ons'] = json_decode($_POST['product_add_ons'], 1);
            }

            if (isset($_POST['is_cancelable']) && $_POST['is_cancelable'] == '1') {
                $this->form_validation->set_rules('cancelable_till', 'Till which status', 'trim|required|xss_clean');
            }
            if (isset($_POST['cod_allowed'])) {
                $this->form_validation->set_rules('cod_allowed', 'COD allowed', 'trim|xss_clean');
            }
            if (isset($_POST['is_prices_inclusive_tax'])) {
                $this->form_validation->set_rules('is_prices_inclusive_tax', 'Tax included in prices', 'trim|xss_clean');
            }

            // If product type is simple			
            if (isset($_POST['product_type']) && $_POST['product_type'] == 'simple_product') {
                $this->form_validation->set_rules('simple_price', 'Price', 'trim|required|numeric|greater_than_equal_to[' . $this->input->post('simple_special_price') . ']|xss_clean');
                $this->form_validation->set_rules('simple_special_price', 'Special Price', 'trim|numeric|less_than_equal_to[' . $this->input->post('simple_price') . ']|xss_clean');

                if (isset($_POST['simple_product_stock_status']) && in_array($_POST['simple_product_stock_status'], array('0', '1'))) {
                    $this->form_validation->set_rules('product_total_stock', 'Total Stock', 'trim|required|numeric|xss_clean');
                    $this->form_validation->set_rules('simple_product_stock_status', 'Stock Status', 'trim|required|numeric|xss_clean');
                }
            } elseif (isset($_POST['product_type']) && $_POST['product_type'] == 'variable_product') { //If product type is variant	
                if (isset($_POST['variant_stock_status']) && $_POST['variant_stock_status'] == '0') {
                    if ($_POST['variant_stock_level_type'] == "product_level") {
                        $this->form_validation->set_rules('total_stock_variant_type', 'Total Stock', 'trim|required|xss_clean');
                        $this->form_validation->set_rules('variant_stock_status', 'Stock Status', 'trim|required|xss_clean');
                        if (isset($_POST['variant_price']) && isset($_POST['variant_special_price'])) {
                            foreach ($_POST['variant_price'] as $key => $value) {
                                $this->form_validation->set_rules('variant_price[' . $key . ']', 'Price', 'trim|required|numeric|xss_clean|greater_than_equal_to[' . $this->input->post('variant_special_price[' . $key . ']') . ']');
                                $this->form_validation->set_rules('variant_special_price[' . $key . ']', 'Special Price', 'trim|numeric|xss_clean|less_than_equal_to[' . $this->input->post('variant_price[' . $key . ']') . ']');
                            }
                        } else {
                            $this->form_validation->set_rules('variant_price', 'Price', 'trim|required|numeric|xss_clean|greater_than_equal_to[' . $this->input->post('variant_special_price') . ']');
                            $this->form_validation->set_rules('variant_special_price', 'Special Price', 'trim|numeric|xss_clean|less_than_equal_to[' . $this->input->post('variant_price') . ']');
                        }
                    }
                } else {
                    if (isset($_POST['variant_price']) && isset($_POST['variant_special_price'])) {
                        foreach ($_POST['variant_price'] as $key => $value) {
                            $this->form_validation->set_rules('variant_price[' . $key . ']', 'Price', 'trim|required|numeric|xss_clean|greater_than_equal_to[' . $this->input->post('variant_special_price[' . $key . ']') . ']');
                            $this->form_validation->set_rules('variant_special_price[' . $key . ']', 'Special Price', 'trim|numeric|xss_clean|less_than_equal_to[' . $this->input->post('variant_price[' . $key . ']') . ']');
                        }
                    } else {
                        $this->form_validation->set_rules('variant_price', 'Price', 'trim|required|numeric|xss_clean|greater_than_equal_to[' . $this->input->post('variant_special_price') . ']');
                        $this->form_validation->set_rules('variant_special_price', 'Special Price', 'trim|numeric|xss_clean|less_than_equal_to[' . $this->input->post('variant_price') . ']');
                    }
                }
            }

            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                $this->product_model->add_product($_POST);
                $this->response['error'] = false;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $message = (isset($_POST['edit_product_id'])) ? 'Product Updated Successfully' : 'Product Added Successfully';
                $this->response['message'] = $message;
                print_r(json_encode($this->response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function get_product_data()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $partner_id =  (isset($_GET['partner_id']) && !empty($_GET['partner_id'])) ? $this->input->get('partner_id', true) : NULL;
            $status =  (isset($_GET['status']) && $_GET['status'] != "") ? $this->input->get('status', true) : NULL;
            if (isset($_GET['flag']) && !empty($_GET['flag'])) {
                return $this->product_model->get_product_details($_GET['flag'], $partner_id, $status);
            }
            return $this->product_model->get_product_details(null, $partner_id, $status);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function get_product_data_list()
    {

        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            return $this->product_model->get_product_details('low');
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function get_rating_list()
    {

        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            return $this->rating_model->get_rating();
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function fetch_attributes()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $attributes = $this->db->select('attr_val.id,attr.name as attr_name ,attr_set.name as attr_set_name,attr_val.value')->join('attributes attr', 'attr.id=attr_val.attribute_id')->join('attribute_set attr_set', 'attr_set.id=attr_val.attribute_set_id')->get('attribute_values attr_val')->result_array();
            $attributes_refind = array();
            for ($i = 0; $i < count($attributes); $i++) {

                if (!array_key_exists($attributes[$i]['attr_set_name'], $attributes_refind)) {
                    $attributes_refind[$attributes[$i]['attr_set_name']] = array();

                    for ($j = 0; $j < count($attributes); $j++) {

                        if ($attributes[$i]['attr_set_name'] == $attributes[$j]['attr_set_name']) {

                            if (!array_key_exists($attributes[$j]['attr_name'], $attributes_refind[$attributes[$i]['attr_set_name']])) {

                                $attributes_refind[$attributes[$i]['attr_set_name']][$attributes[$j]['attr_name']] = array();
                            }
                            $attributes_refind[$attributes[$i]['attr_set_name']][$attributes[$j]['attr_name']][$j]['id'] = $attributes[$j]['id'];

                            $attributes_refind[$attributes[$i]['attr_set_name']][$attributes[$j]['attr_name']][$j]['text'] = $attributes[$j]['value'];

                            $attributes_refind[$attributes[$i]['attr_set_name']][$attributes[$j]['attr_name']] = array_values($attributes_refind[$attributes[$i]['attr_set_name']][$attributes[$j]['attr_name']]);
                        }
                    }
                }
            }
            print_r(json_encode($attributes_refind));
        } else {
            redirect('admin/login', 'refresh');
        }
    }


    public function view_product()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (isset($_GET['edit_id']) && !empty($_GET['edit_id'])) {
                $this->data['main_page'] = VIEW . 'products';
                $settings = get_settings('system_settings', true);
                $this->data['title'] = 'View Product | ' . $settings['app_name'];
                $this->data['meta_description'] = 'View Product | ' . $settings['app_name'];
                $res = fetch_product($user_id = NULL, $filter = NULL, $this->input->get('edit_id', true));
                if (empty($res['product'])) {
                    redirect(base_url('admin/product'));
                }
                $this->data['product_details'] = $res['product'];
                $this->data['product_attributes'] = get_attribute_values_by_pid($_GET['edit_id']);
                $this->data['product_variants'] = get_variants_values_by_pid($_GET['edit_id'], [0, 1, 7]);
                $this->data['product_rating'] = $this->rating_model->fetch_rating((isset($_GET['edit_id'])) ? $_GET['edit_id'] : '', '');
                $this->data['currency'] = $settings['currency'];
                $this->data['category_result'] = fetch_details(['status' => '1'], 'categories', 'id,name');
                if (!empty($res['product'])) {
                    $this->load->view('admin/template', $this->data);
                } else {
                    redirect('admin/product', 'refresh');
                }
            } else {
                redirect('admin/product', 'refresh');
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }


    public function delete_rating()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (print_msg(!has_permissions('delete', 'product'), PERMISSION_ERROR_MSG, 'product', false)) {
                return false;
            }

            $this->rating_model->delete_rating($_GET['id']);

            $this->response['error'] = false;
            $this->response['message'] = 'Deleted Succesfully';

            print_r(json_encode($this->response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function change_variant_status($id = '', $status = '', $product_id = '')
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (print_msg(!has_permissions('update', 'product'), PERMISSION_ERROR_MSG, 'product', false)) {
                return false;
            }

            $status = (trim($status) != '' && is_numeric(trim($status))) ? trim($status) : "";
            $id = (!empty(trim($id)) && is_numeric(trim($id))) ? trim($id) : "";

            if (empty($id) || $status == '') {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = "Invalid Status or ID value supplied";

                $this->session->set_flashdata('message', $this->response['message']);
                $this->session->set_flashdata('message_type', 'error');
                if (!empty($product_id)) {
                    $callback_url = base_url("admin/product/view-product?edit_id=$product_id");
                    header("location:$callback_url");
                    return false;
                } else {
                    print_r(json_encode($this->response));
                    return false;
                }
            }
            $all_status = [0, 1, 7];
            if (!in_array($status, $all_status)) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = "Invalid Status value supplied";

                $this->session->set_flashdata('message', $this->response['message']);
                $this->session->set_flashdata('message_type', 'error');
                if (!empty($product_id)) {
                    $callback_url = base_url("admin/product/view-product?edit_id=$product_id");
                    header("location:$callback_url");
                    return false;
                } else {
                    print_r(json_encode($this->response));
                    return false;
                }
            }

            /* change variant status to the new status */
            update_details(['status' => $status], ['id' => $id], 'product_variants');

            $this->response['error'] = false;
            $this->response['message'] = 'Variant status changed successfully';
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();

            $this->session->set_flashdata('message', $this->response['message']);
            $this->session->set_flashdata('message_type', 'success');
            if (!empty($product_id)) {
                $callback_url = base_url("admin/product/view-product?edit_id=$product_id");
                header("location:$callback_url");
                return false;
            } else {
                print_r(json_encode($this->response));
                return false;
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function get_product_add_ons()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (isset($_GET['product_id']) && !empty($_GET['product_id'])) {
                return $this->product_model->get_product_add_ons($this->input->get('product_id', true));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function update_add_ons()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->form_validation->set_rules('title', 'title', 'trim|required|xss_clean');
            $this->form_validation->set_rules('description', 'description', 'trim|xss_clean');
            $this->form_validation->set_rules('price', 'price', 'trim|required|xss_clean');
            $this->form_validation->set_rules('calories', 'calories', 'trim|xss_clean');
            $this->form_validation->set_rules('product_id', 'product_id', 'trim|required|xss_clean');
            $this->form_validation->set_rules('add_on_id', 'add_on_id', 'trim|xss_clean');
            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                $data = array(
                    'title' => $this->input->post('title', true),
                    'product_id' => $this->input->post('product_id', true),
                    'description' => $this->input->post('description', true),
                    'price' => $this->input->post('price', true),
                    'calories' => $this->input->post('calories', true),
                );
                if (isset($_POST['add_on_id']) && !empty($_POST['add_on_id'])) {
                    // update add_ons
                    if (update_details($data, ['id' => $this->input->post('add_on_id', true)], 'product_add_ons') == TRUE) {
                        $this->response['error'] = false;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['message'] = "Add On details Update Successfuly.";
                    } else {
                        $this->response['error'] = true;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['message'] = "Not Updated. Try again later.";
                    }
                } else {
                    if (!is_exist(['title' => $this->input->post('title', true), 'product_id' => $this->input->post('product_id', true)], 'product_add_ons', null)) {
                        // add new add_ons
                        if (insert_details($data, 'product_add_ons')) {
                            $this->response['error'] = false;
                            $this->response['csrfName'] = $this->security->get_csrf_token_name();
                            $this->response['csrfHash'] = $this->security->get_csrf_hash();
                            $this->response['message'] = "Add On details Insert Successfuly.";
                        } else {
                            $this->response['error'] = true;
                            $this->response['csrfName'] = $this->security->get_csrf_token_name();
                            $this->response['csrfHash'] = $this->security->get_csrf_hash();
                            $this->response['message'] = "Not Inserted. Try again later.";
                        }
                    } else {
                        $this->response['error'] = true;
                        $this->response['csrfName'] = $this->security->get_csrf_token_name();
                        $this->response['csrfHash'] = $this->security->get_csrf_hash();
                        $this->response['message'] = "Already have this add on.";
                    }
                }
                print_r(json_encode($this->response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function delete_add_on()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('delete', 'product'), PERMISSION_ERROR_MSG, 'product')) {
                return false;
            }
            if (delete_details(['id' => $_GET['id']], 'product_add_ons')) {
                // delete add ons if user have in cart add ons table
                if (is_exist(['add_on_id' =>  $_GET['id']], "cart_add_ons")) {
                    delete_details(['add_on_id' =>  $_GET['id']], "cart_add_ons");
                }
                $response['error'] = false;
                $response['message'] = 'Deleted Succesfully';
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
            } else {
                $response['error'] = true;
                $response['message'] = 'Something Went Wrong';
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
            }
            print_r(json_encode($response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
