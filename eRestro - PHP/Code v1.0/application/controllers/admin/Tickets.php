<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Tickets extends CI_Controller
{


    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model('ticket_model');
        // unset($_SESSION['authorize_flag']); before
        if (!has_permissions('read', 'support_tickets')) {
            $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
            redirect('admin/home', 'refresh');
        }else{
            $this->session->set_flashdata('authorize_flag', "");
        }

    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'tickets';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Ticket System | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Ticket System  | ' . $settings['app_name'];
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function ticket_types()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = TABLES . 'manage-ticket-types';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Ticket Types | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Ticket Types  | ' . $settings['app_name'];
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public function manage_ticket_types()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (!has_permissions('read', 'support_tickets')) {
                $this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
                redirect('admin/home', 'refresh');
            }
            $this->data['main_page'] = FORMS . 'ticket-type';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Add Ticket Type | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Add Ticket Type  | ' . $settings['app_name'];
            if (isset($_GET['edit_id'])) {
                $this->data['fetched_data'] = fetch_details(['id' => $_GET['edit_id']], 'ticket_types');
            }
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    function delete_ticket_type()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('delete', 'support_tickets'), PERMISSION_ERROR_MSG, 'support_tickets')) {
                return false;
            }
            if (delete_details(['id' => $_GET['id']], "ticket_types")) {
                $response['error'] = false;
                $response['message'] = 'Deleted Successfully';
            } else {
                $response['error'] = true;
                $response['message'] = 'Something went wrong';
            }
            echo json_encode($response);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function add_ticket_type()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (isset($_POST['edit_ticket_types'])) {
                if (print_msg(!has_permissions('update', 'support_tickets'), PERMISSION_ERROR_MSG, 'support_tickets')) {
                    return false;
                }
            } else {
                if (print_msg(!has_permissions('create', 'support_tickets'), PERMISSION_ERROR_MSG, 'support_tickets')) {
                    return false;
                }
            }
            $this->form_validation->set_rules('title', 'Title', 'trim|required|xss_clean');
            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['message'] = validation_errors();
                print_r(json_encode($this->response));
            } else {
                $this->ticket_model->add_ticket_type($_POST);
                $this->response['error'] = false;
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $message = (isset($_POST['edit_ticket_types'])) ? 'Ticket Types Updated Successfully' : 'Ticket Types Added Successfully';
                $this->response['message'] = $message;
                print_r(json_encode($this->response));
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function view_ticket_list()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            return $this->ticket_model->get_ticket_list();
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public function view_ticket_type_list()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            return $this->ticket_model->get_ticket_type_list();
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function send_message()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            if (print_msg(!has_permissions('update', 'support_tickets'), PERMISSION_ERROR_MSG, 'support_tickets')) {
                return false;
            }

            $this->form_validation->set_rules('ticket_id', 'Ticket id', 'trim|required|numeric|xss_clean');
            if(!isset($_POST['attachments']) && empty($_POST['attachments'])){
                $this->form_validation->set_rules('message', 'Message', 'trim|required|xss_clean');
            }

            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['message'] = strip_tags(validation_errors());
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                print_r(json_encode($this->response));
                return false;
            } else {
                $user_id = $this->session->userdata('user_id');
                $ticket_id = (isset($_POST['ticket_id']) && !empty(trim($_POST['ticket_id']))) ? $this->input->post('ticket_id', true) : "";
                $message = (isset($_POST['message']) && !empty(trim($_POST['message']))) ? $this->input->post('message', true) : "";
                $attachments = (isset($_POST['attachments']) && !empty($_POST['attachments'])) ? $this->input->post('attachments', true) : "";

                $user = fetch_users($user_id);
                if (empty($user)) {
                    $this->response['error'] = true;
                    $this->response['message'] = "User not found!";
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = [];
                    print_r(json_encode($this->response));
                    return false;
                }

                $data = array(
                    'user_type' => "admin",
                    'user_id' => $user_id,
                    'ticket_id' => $ticket_id,
                    'message' => $message,
                    'attachments' => $attachments
                );
                $insert_id = $this->ticket_model->add_ticket_message($data);

                if (!empty($insert_id)) {
                    $data1 = $this->config->item('type');
                    $result = $this->ticket_model->get_messages($ticket_id, $user_id, "", "", "1", "", "", $data1, $insert_id);
                    $this->response['error'] = false;
                    $this->response['message'] =  'Ticket message sent successfully';
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = $result['data'][0];
                    print_r(json_encode($this->response));
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] =  'Ticket message could not be sent!';
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = (!empty($this->response['data'])) ? $this->response['data'] : [];
                    print_r(json_encode($this->response));
                }
            }
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public function get_ticket_messages()
    {
        $this->form_validation->set_data($this->input->get());
        $this->form_validation->set_rules('ticket_id', 'Ticket ID', 'trim|numeric|required|xss_clean');
        if (!$this->form_validation->run()) {
            $this->response['error'] = true;
            $this->response['message'] = strip_tags(validation_errors());
            $this->response['data'] = array();
            print_r(json_encode($this->response));
        } else {
            $ticket_id = (isset($_GET['ticket_id']) && is_numeric($_GET['ticket_id']) && !empty(trim($_GET['ticket_id']))) ? $this->input->get('ticket_id', true) : "";
            $user_id = (isset($_GET['user_id']) && is_numeric($_GET['user_id']) && !empty(trim($_GET['user_id']))) ? $this->input->get('user_id', true) : "";
            $search = (isset($_GET['search']) && !empty(trim($_GET['search']))) ? $this->input->get('search', true) : "";
            $limit = (isset($_GET['limit']) && is_numeric($_GET['limit']) && !empty(trim($_GET['limit']))) ? $this->input->get('limit', true) : 50;
            $offset = (isset($_GET['offset']) && is_numeric($_GET['offset']) && !empty(trim($_GET['offset']))) ? $this->input->get('offset', true) : 0;
            $order = (isset($_GET['order']) && !empty(trim($_GET['order']))) ? $this->input->get('order', true) : 'DESC';
            $sort = (isset($_GET['sort']) && !empty(trim($_GET['sort']))) ? $this->input->get('sort', true) : 'id';
            $data = $this->config->item('type');
            $this->response =  $this->ticket_model->get_message_list($ticket_id, $user_id, $search, $offset, $limit, $sort, $order, $data, "");
        }
    }
    public function delete_ticket()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('delete', 'support_tickets'), PERMISSION_ERROR_MSG, 'support_tickets')) {
                return false;
            }
            $ticket_id = $_GET['id'];
            $result = $this->ticket_model->delete_ticket($ticket_id);
            if ($result == true) {
                $this->response['error'] = false;
                $this->response['message'] = 'Deleted Succesfully';
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Something Went Wrong';
            }
            print_r(json_encode($this->response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }
    public function edit_ticket_status()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('update', 'support_tickets'), PERMISSION_ERROR_MSG, 'support_tickets')) {
                return false;
            }
            $this->form_validation->set_rules('ticket_id', 'Ticket Id', 'trim|required|xss_clean');
            $this->form_validation->set_rules('status', 'Status', 'trim|required|xss_clean');


            if (!$this->form_validation->run()) {
                $this->response['error'] = true;
                $this->response['message'] = strip_tags(validation_errors());
                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                $this->response['data'] = array();
            } else {
                $status = $this->input->post('status', true);
                $ticket_id = $this->input->post('ticket_id', true);
                $res = fetch_details('id=' . $ticket_id, 'tickets', '*');
                if (empty($res)) {
                    $this->response['error'] = true;
                    $this->response['message'] = "User id is changed you can not udpate the ticket.";
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
                if ($status == PENDING && $res[0]['status'] == OPENED) {
                    $this->response['error'] = true;
                    $this->response['message'] = "Current status is opened.";
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
                if ($status == OPENED && ($res[0]['status'] == RESOLVED || $res[0]['status'] == CLOSED)) {
                    $this->response['error'] = true;
                    $this->response['message'] = "Can't be OPEN but you can REOPEN the ticket.";
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
                if ($status == RESOLVED && $res[0]['status'] == CLOSED) {
                    $this->response['error'] = true;
                    $this->response['message'] = "Current status is closed.";
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }
                if ($status == REOPEN && ($res[0]['status'] == PENDING || $res[0]['status'] == OPENED)) {
                    $this->response['error'] = true;
                    $this->response['message'] = "Current status is pending or opened.";
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = array();
                    print_r(json_encode($this->response));
                    return false;
                }

                $data = array(
                    'status' => $status,
                    'edit_ticket_status' => $ticket_id
                );
                if (!$this->ticket_model->add_ticket($data)) {
                    $result = $this->ticket_model->get_tickets($ticket_id);
                    if (!empty($result)) {
                        /* Send notification */
                        $ticket_res = fetch_details(['user_type' => 'user', 'ticket_id' => $ticket_id], 'ticket_messages', 'user_id');

                        $user_res = fetch_details(['id' => $ticket_res[0]['user_id']], "users", 'fcm_id', '',  '', '', '');
                        $fcm_ids[0][] = $user_res[0]['fcm_id'];
                        $fcm_admin_msg =  "Your Ticket status has been changed";
                        $fcm_admin_subject = (!empty($result['data'][0]['subject'])) ? $result['data'][0]['subject'] : "Ticket Message";
                        if (!empty($fcm_ids)) {
                            $fcmMsg = array(
                                'title' => $fcm_admin_subject,
                                'body' => $fcm_admin_msg,
                                'type' => "ticket_status",
                                'type_id' => $ticket_id
                            );
                            send_notification($fcmMsg, $fcm_ids);
                        }
                    }
                    $this->response['error'] = false;
                    $this->response['message'] =  'Ticket updated Successfully';
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = $result['data'];
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] =  'Ticket Not Added';
                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                    $this->response['data'] = (!empty($this->response['data'])) ? $this->response['data'] : [];
                }
            }
            print_r(json_encode($this->response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
