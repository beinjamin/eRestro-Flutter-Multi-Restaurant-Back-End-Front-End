<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Faq_model extends CI_Model
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function add_faq($data)
    {
        $data = escape_array($data);
        $faq_data = [
            'question' => $data['question'],
            'answer' => $data['answer']
        ];
        if (isset($data['edit_faq'])) {
            $this->db->set($faq_data)->where('id', $data['edit_faq'])->update('faqs');
        } else {
            $this->db->insert('faqs', $faq_data);
        }
    }

    function get_faqs($offset, $limit, $sort, $order)
    {
        $faqs_data = [];
        $count_res = $this->db->select(' COUNT(id) as `total` ')->where('status', '1')->get('faqs')->result_array();
        $search_res = $this->db->select(' * ')->where('status', '1')->order_by($sort, $order)->limit($limit, $offset)->get('faqs')->result_array();
        if (!empty($search_res)) {
            for ($i = 0; $i < count($search_res); $i++) {
                $search_res[$i] = output_escaping($search_res[$i]);
            }
        }
        $faqs_data['total'] = $count_res[0]['total'];
        $faqs_data['data'] = $search_res;
        return  $faqs_data;
    }
}