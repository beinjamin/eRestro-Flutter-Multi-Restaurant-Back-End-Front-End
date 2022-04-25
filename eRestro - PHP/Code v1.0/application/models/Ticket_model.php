<?php

defined('BASEPATH') or exit('No direct script access allowed');
class Ticket_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language', 'function_helper']);
    }

    function add_ticket($data)
    {
        $data = escape_array($data);
        if (isset($data['edit_ticket_status'])) {
            $ticket_data = [
                'status' =>  $data['status'],
            ];
        } else {
            $ticket_data = [
                'ticket_type_id' => $data['ticket_type_id'],
                'user_id' => $data['user_id'],
                'subject' => $data['subject'],
                'email' => $data['email'],
                'description' => $data['description'],
                'status' =>  $data['status'],
            ];
        }
        if (isset($data['edit_ticket'])) {
            $this->db->set($ticket_data)->where('id', $data['edit_ticket'])->update('tickets');
        } else if (isset($data['edit_ticket_status'])) {
            $this->db->set($ticket_data)->where('id', $data['edit_ticket_status'])->update('tickets');
        } else {
            $this->db->insert('tickets', $ticket_data);
            $insert_id = $this->db->insert_id();
            if (!empty($insert_id)) {
                return  $insert_id;
            } else {
                return false;
            }
        }
    }
    function add_ticket_type($data)
    {
        $data = escape_array($data);

        $ticket_data = [
            'title' => $data['title'],
        ];
        if (isset($data['edit_ticket_type'])) {
            $this->db->set($ticket_data)->where('id', $data['edit_ticket_type'])->update('ticket_types');
        } else {
            $this->db->insert('ticket_types', $ticket_data);
            $insert_id = $this->db->insert_id();
            if (!empty($insert_id)) {
                return  $insert_id;
            } else {
                return false;
            }
        }
    }

    function add_ticket_message($data)
    {
        $data = escape_array($data);

        $ticket_msg_data = [
            'user_type' => $data['user_type'],
            'user_id' => $data['user_id'],
            'ticket_id' => $data['ticket_id'],
            'message' => $data['message']
        ];
        if (isset($data['attachments']) && !empty($data['attachments'])) {
            $ticket_msg_data['attachments'] = json_encode($data['attachments']);
        }

        $this->db->insert('ticket_messages', $ticket_msg_data);
        $insert_id = $this->db->insert_id();
        if (!empty($insert_id)) {
            return  $insert_id;
        } else {
            return false;
        }
    }

    function get_ticket_list()
    {
        $offset = 0;
        $limit = 10;
        $sort = 't.id';
        $order = 'ASC';
        $multipleWhere = '';

        if (isset($_GET['offset']))
            $offset = $_GET['offset'];
        if (isset($_GET['limit']))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($_GET['sort'] == 'id') {
                $sort = "t.id";
            } else {
                $sort = $_GET['sort'];
            }
        if (isset($_GET['order']))
            $order = $_GET['order'];

        if (isset($_GET['search']) and $_GET['search'] != '') {
            $search = $_GET['search'];
            $multipleWhere = [
                '`u.id`' => $search, '`u.username`' => $search, '`u.email`' => $search, '`u.mobile`' => $search, '`t.subject`' => $search, '`t.email`' => $search, '`t.description`' => $search, '`tty.title`' => $search
            ];
        }

        $count_res = $this->db->select(' COUNT(u.id) as `total`')->join('ticket_types tty', 'tty.id=t.ticket_type_id', 'left')->join('users u', 'u.id=t.user_id', 'left');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_where($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $cat_count = $count_res->get('tickets t')->result_array();
        foreach ($cat_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('t.*,tty.title,u.username')->join('ticket_types tty', 'tty.id=t.ticket_type_id', 'left')->join('users u', 'u.id=t.user_id', 'left');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $cat_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('tickets t')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $status = "";
        $tempRow = array();
        foreach ($cat_search_res as $row) {
            $row = output_escaping($row);
            $operate = '<a href="javascript:void(0)" class="view_ticket btn btn-success btn-xs mr-1 mb-1" data-id=' . $row['id'] . ' data-username=' . $row['username'] . ' data-date_created=' . $row['date_created'] . ' data-subject=' . $row['subject'] . ' data-status=' . $row['status'] . ' data-ticket_type="' . $row['title'] . '" title="View" data-target="#ticket_modal" data-toggle="modal" ><i class="fa fa-eye"></i></a>';
            $operate .= ' <a href="javascript:void(0)" id="delete-ticket" data-id=' . $row['id'] . ' class="btn btn-danger mr-1 mb-1 btn-xs"><i class="fa fa-trash"></i></a>';

            $tempRow['id'] = $row['id'];
            $tempRow['ticket_type_id'] = $row['ticket_type_id'];
            $tempRow['user_id'] = $row['user_id'];
            $tempRow['subject'] = $row['subject'];
            $tempRow['email'] = $row['email'];
            $tempRow['description'] = $row['description'];
            if ($row['status'] == "1") {
                $status = '<label class="badge badge-secondary">PENDING</label>';
            } else if ($row['status'] == "2") {
                $status = '<label class="badge badge-info">OPENED</label>';
            } else if ($row['status'] == "3") {
                $status = '<label class="badge badge-success">RESOLVED</label>';
            } else if ($row['status'] == "4") {
                $status = '<label class="badge badge-danger">CLOSED</label>';
            } else if ($row['status'] == "5") {
                $status = '<label class="badge badge-warning">REOPENED</label>';
            }
            $tempRow['status'] = $status;
            $tempRow['last_updated'] = $row['last_updated'];
            $tempRow['date_created'] = $row['date_created'];
            $tempRow['username'] = $row['username'];
            $tempRow['ticket_type'] = $row['title'];
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
    function get_message_list($ticket_id = "", $user_id = "", $search = "", $offset = 0, $limit = 50, $sort = "tm.id", $order = "DESC", $data = array(), $msg_id = "")
    {
        $multipleWhere = '';

        if (isset($_GET['offset']))
            $offset = $_GET['offset'];
        if (isset($_GET['limit']))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            if ($_GET['sort'] == 'id') {
                $sort = "tm.id";
            } else {
                $sort = $_GET['sort'];
            }
        if (isset($_GET['order']))
            $order = $_GET['order'];

        if (isset($_GET['search']) and $_GET['search'] != '') {
            $search = $_GET['search'];
            $multipleWhere = [
                '`u.id`' => $search, '`u.username`' => $search, '`t.subject`' => $search, '`tm.message`' => $search
            ];
        }

        if (!empty($ticket_id)) {
            $where['tm.ticket_id'] = $ticket_id;
        }

        if (!empty($user_id)) {
            $where['tm.user_id'] = $user_id;
        }
        if (!empty($msg_id)) {
            $where['tm.id'] = $msg_id;
        }

        $count_res = $this->db->select(' COUNT(tm.id) as `total`')->join('tickets t', 't.id=tm.ticket_id', 'left')->join('users u', 'u.id=tm.user_id', 'left');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_where($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $cat_count = $count_res->get('ticket_messages tm')->result_array();
        foreach ($cat_count as $row) {
            $total = $row['total'];
        }
        $search_res = $this->db->select('tm.*,t.subject,u.username')->join('tickets t', 't.id=tm.ticket_id', 'left')->join('users u', 'u.id=tm.user_id', 'left');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $cat_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('ticket_messages tm')->result_array();
        $rows = $tempRow = $bulkData = array();
        $bulkData['total'] = $total;
        $bulkData['error'] = (empty($cat_search_res)) ? true : false;
        $bulkData['message'] = (empty($cat_search_res)) ? 'Ticket Message(s) does not exist' : 'Message retrieved successfully';
        $bulkData['total'] = (empty($cat_search_res)) ? 0 : $total;
        if (!empty($cat_search_res)) {
            $data = $this->config->item('type');
            foreach ($cat_search_res as $row) {
                $row = output_escaping($row);
                $tempRow['id'] = $row['id'];
                $tempRow['user_type'] = $row['user_type'];
                $tempRow['user_id'] = $row['user_id'];
                $tempRow['ticket_id'] = $row['ticket_id'];
                $tempRow['message'] = (!empty($row['message'])) ? $row['message'] : "";
                $tempRow['name'] = $row['username'];
                if (!empty($row['attachments'])) {
                    $attachments = json_decode($row['attachments'], 1);
                    $counter = 0;
                    foreach ($attachments as $row1) {
                        $tmpRow['media'] = get_image_url($row1);
                        $file = new SplFileInfo($row1);
                        $ext  = $file->getExtension();
                        if (in_array($ext, $data['image']['types'])) {
                            $tmpRow['type'] = "image";
                        } else if (in_array($ext, $data['video']['types'])) {
                            $tmpRow['type'] = "video";
                        } else if (in_array($ext, $data['document']['types'])) {
                            $tmpRow['type'] = "document";
                        } else if (in_array($ext, $data['archive']['types'])) {
                            $tmpRow['type'] = "archive";
                        }
                        $attachments[$counter] = $tmpRow;
                        $counter++;
                    }
                } else {
                    $attachments = array();
                }
                $tempRow['attachments'] = $attachments;
                $tempRow['subject'] = $row['subject'];
                $tempRow['last_updated'] = $row['last_updated'];
                $tempRow['date_created'] = $row['date_created'];
                $rows[] = $tempRow;
            }
            $bulkData['data'] = $rows;
        } else {
            $bulkData['data'] = [];
        }

        print_r(json_encode($bulkData));
    }

    function get_tickets($ticket_id = "", $ticket_type_id = "", $user_id = "", $status = "", $search = "", $offset = "", $limit = "1", $sort = "", $order = "")
    {

        $multipleWhere = '';
        $where = array();
        if (!empty($search)) {
            $multipleWhere = [
                '`u.id`' => $search, '`u.username`' => $search, '`u.email`' => $search, '`u.mobile`' => $search, '`t.subject`' => $search, '`t.email`' => $search, '`t.description`' => $search, '`tty.title`' => $search
            ];
        }
        if (!empty($ticket_id)) {
            $where['t.id'] = $ticket_id;
        }
        if (!empty($ticket_type_id)) {
            $where['t.ticket_type_id'] = $ticket_type_id;
        }
        if (!empty($user_id)) {
            $where['t.user_id'] = $user_id;
        }
        if (!empty($status)) {
            $where['t.status'] = $status;
        }
        $count_res = $this->db->select(' COUNT(u.id) as `total`')->join('ticket_types tty', 'tty.id=t.ticket_type_id', 'left')->join('users u', 'u.id=t.user_id', 'left');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $cat_count = $count_res->get('tickets t')->result_array();
        foreach ($cat_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('t.*,tty.title,u.username')->join('ticket_types tty', 'tty.id=t.ticket_type_id', 'left')->join('users u', 'u.id=t.user_id', 'left');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $cat_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('tickets t')->result_array();
        $rows = $tempRow = $bulkData = array();
        $bulkData['error'] = (empty($cat_search_res)) ? true : false;
        $bulkData['message'] = (empty($cat_search_res)) ? 'Ticket(s) does not exist' : 'Tickets retrieved successfully';
        $bulkData['total'] = (empty($cat_search_res)) ? 0 : $total;
        if (!empty($cat_search_res)) {
            foreach ($cat_search_res as $row) {
                $row = output_escaping($row);
                $tempRow['id'] = $row['id'];
                $tempRow['ticket_type_id'] = $row['ticket_type_id'];
                $tempRow['user_id'] = $row['user_id'];
                $tempRow['subject'] = $row['subject'];
                $tempRow['email'] = $row['email'];
                $tempRow['description'] = $row['description'];
                $tempRow['status'] = $row['status'];
                $tempRow['last_updated'] = $row['last_updated'];
                $tempRow['date_created'] = $row['date_created'];
                $tempRow['name'] = $row['username'];
                $tempRow['ticket_type'] = $row['title'];
                $rows[] = $tempRow;
            }
            $bulkData['data'] = $rows;
        } else {
            $bulkData['data'] = [];
        }
        return $bulkData;
    }

    function get_messages($ticket_id = "", $user_id = "", $search = "", $offset = "", $limit = "", $sort = "", $order = "", $data = array(), $msg_id = "")
    {

        $multipleWhere = '';
        $where = array();
        if (!empty($search)) {
            $multipleWhere = [
                '`u.id`' => $search, '`u.username`' => $search, '`t.subject`' => $search, '`tm.message`' => $search
            ];
        }
        if (!empty($ticket_id)) {
            $where['tm.ticket_id'] = $ticket_id;
        }

        if (!empty($user_id)) {
            $where['tm.user_id'] = $user_id;
        }
        if (!empty($msg_id)) {
            $where['tm.id'] = $msg_id;
        }

        $count_res = $this->db->select(' COUNT(tm.id) as `total`')->join('tickets t', 't.id=tm.ticket_id', 'left')->join('users u', 'u.id=tm.user_id', 'left');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->group_start();
            $count_res->or_like($multipleWhere);
            $count_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $cat_count = $count_res->get('ticket_messages tm')->result_array();
        foreach ($cat_count as $row) {
            $total = $row['total'];
        }
        $search_res = $this->db->select('tm.*,t.subject,u.username')->join('tickets t', 't.id=tm.ticket_id', 'left')->join('users u', 'u.id=tm.user_id', 'left');
        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->group_start();
            $search_res->or_like($multipleWhere);
            $search_res->group_end();
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $cat_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('ticket_messages tm')->result_array();
        $rows = $tempRow = $bulkData = $tmpRow = array();
        $bulkData['error'] = (empty($cat_search_res)) ? true : false;
        $bulkData['message'] = (empty($cat_search_res)) ? 'Ticket Message(s) does not exist' : 'Message retrieved successfully';
        $bulkData['total'] = (empty($cat_search_res)) ? 0 : $total;
        if (!empty($cat_search_res)) {
            foreach ($cat_search_res as $row) {
                $row = output_escaping($row);
                $tempRow['id'] = $row['id'];
                $tempRow['user_type'] = $row['user_type'];
                $tempRow['user_id'] = $row['user_id'];
                $tempRow['ticket_id'] = $row['ticket_id'];
                $tempRow['message'] = (!empty($row['message'])) ? $row['message'] : "";
                $tempRow['name'] = $row['username'];
                if (!empty($row['attachments'])) {
                    $attachments = json_decode($row['attachments'], 1);
                    $counter = 0;
                    foreach ($attachments as $row1) {
                        $tmpRow['media'] = get_image_url($row1);
                        $file = new SplFileInfo($row1);
                        $ext  = $file->getExtension();
                        if (in_array($ext, $data['image']['types'])) {
                            $tmpRow['type'] = "image";
                        } else if (in_array($ext, $data['video']['types'])) {
                            $tmpRow['type'] = "video";
                        } else if (in_array($ext, $data['document']['types'])) {
                            $tmpRow['type'] = "document";
                        } else if (in_array($ext, $data['archive']['types'])) {
                            $tmpRow['type'] = "archive";
                        }
                        $attachments[$counter] = $tmpRow;
                        $counter++;
                    }
                } else {
                    $attachments = array();
                }
                $tempRow['attachments'] = $attachments;
                $tempRow['subject'] = $row['subject'];
                $tempRow['last_updated'] = $row['last_updated'];
                $tempRow['date_created'] = $row['date_created'];
                $rows[] = $tempRow;
            }
            $bulkData['data'] = $rows;
        } else {
            $bulkData['data'] = [];
        }
        return $bulkData;
    }

    function delete_ticket($ticket_id)
    {
        if (delete_details(['id' => $ticket_id], 'tickets') == TRUE) {
            if (delete_details(['ticket_id' => $ticket_id], 'ticket_messages') == TRUE) {
                return true;
            }
        } else {
            return false;
        }
    }

    function get_ticket_type_list()
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
            $multipleWhere = [
                '`id`' => $search, '`title`' => $search
            ];
        }

        $count_res = $this->db->select(' COUNT(id) as `total`');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $count_res->or_where($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $count_res->where($where);
        }

        $cat_count = $count_res->get('ticket_types')->result_array();
        foreach ($cat_count as $row) {
            $total = $row['total'];
        }

        $search_res = $this->db->select('*');

        if (isset($multipleWhere) && !empty($multipleWhere)) {
            $search_res->or_like($multipleWhere);
        }
        if (isset($where) && !empty($where)) {
            $search_res->where($where);
        }

        $cat_search_res = $search_res->order_by($sort, $order)->limit($limit, $offset)->get('ticket_types')->result_array();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $status = "";
        $tempRow = array();
        foreach ($cat_search_res as $row) {
            $row = output_escaping($row);
            $operate = ' <a href="javascript:void(0)" class="edit_btn btn btn-success btn-xs mr-1 mb-1" title="Edit" data-id="' . $row['id'] . '" data-url="admin/tickets/manage_ticket_types/"><i class="fa fa-pen"></i></a>';
            $operate .= '<a class="delete-ticket-type btn btn-danger btn-xs mr-1 mb-1" title="Delete" href="javascript:void(0)" data-id="' . $row['id'] . '" ><i class="fa fa-trash"></i></a>';

            $tempRow['id'] = $row['id'];
            $tempRow['title'] = $row['title'];
            $tempRow['date_created'] = $row['date_created'];
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
        }
        $bulkData['rows'] = $rows;
        print_r(json_encode($bulkData));
    }
}
