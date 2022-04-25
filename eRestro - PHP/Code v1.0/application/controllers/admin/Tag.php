<?php
defined('BASEPATH') or exit('No direct script access allowed');

class Tag extends CI_Controller
{

	public function __construct()
	{
		parent::__construct();
		$this->load->database();
		$this->load->helper(['url', 'language', 'timezone_helper']);
		$this->load->model('Tag_model');
		if (!has_permissions('read', 'tags')) {
			$this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
			redirect('admin/home', 'refresh');
		}
	}

	public function index()
	{
		if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
			$this->data['main_page'] = FORMS . 'tag';
			$settings = get_settings('system_settings', true);
			$this->data['title'] = 'Add Tags | ' . $settings['app_name'];
			$this->data['meta_description'] = 'Add Tags | ' . $settings['app_name'];
			if (isset($_GET['edit_id'])) {
				$this->data['fetched_data'] = fetch_details(['id' => $_GET['edit_id']], 'tags');
			}
			$this->load->view('admin/template', $this->data);
		} else {
			redirect('admin/login', 'refresh');
		}
	}

	public function manage_tag()
	{
		if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
			$this->data['main_page'] = TABLES . 'manage-tag';
			$settings = get_settings('system_settings', true);
			$this->data['title'] = 'Manage Tags | ' . $settings['app_name'];
			$this->data['meta_description'] = 'Manage Tags  | ' . $settings['app_name'];
			$this->load->view('admin/template', $this->data);
		} else {
			redirect('admin/login', 'refresh');
		}
	}

	public function add_tags()
	{
		if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

			if (isset($_POST['edit_tag'])) {

				if (print_msg(!has_permissions('update', 'tags'), PERMISSION_ERROR_MSG, 'tags')) {
					return false;
				}
			} else {
				if (print_msg(!has_permissions('create', 'tags'), PERMISSION_ERROR_MSG, 'tags')) {
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
				if (isset($_POST['edit_tag'])) {
					if (is_exist(['title' => $this->input->post('title',true)], 'tags', $this->input->post('edit_tag',true))) {
						$response["error"]   = true;
						$response['csrfName'] = $this->security->get_csrf_token_name();
						$response['csrfHash'] = $this->security->get_csrf_hash();
						$response["message"] = "This Tag Already Exist.";
						$response["data"] = array();
						echo json_encode($response);
						return false;
					}
				} else {
					if (is_exist(['title' => $this->input->post('title',true)], 'tags')) {
						$response["error"]   = true;
						$response['csrfName'] = $this->security->get_csrf_token_name();
						$response['csrfHash'] = $this->security->get_csrf_hash();
						$response["message"] = "This Tag Already Exist.";
						$response["data"] = array();
						echo json_encode($response);
						return false;
					}
				}
				$this->Tag_model->add_tags($_POST);
				$this->response['error'] = false;
				$this->response['csrfName'] = $this->security->get_csrf_token_name();
				$this->response['csrfHash'] = $this->security->get_csrf_hash();
				$message = (isset($_POST['edit_tag'])) ? 'Tag Updated Successfully' : 'Tag Added Successfully';
				$this->response['message'] = $message;
				print_r(json_encode($this->response));
			}
		} else {
			redirect('admin/login', 'refresh');
		}
	}

	public function tag_list()
	{
		if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
			return $this->Tag_model->get_tag_list();
		} else {
			redirect('admin/login', 'refresh');
		}
	}

    public function get_tags()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

            $limit = (isset($_GET['limit'])) ? $this->input->get('limit', true) : 25;
            $offset = (isset($_GET['offset'])) ? $this->input->get('offset', true) : 0;
            $search =  (isset($_GET['search'])) ? $_GET['search'] : null;
            $tags = $this->Tag_model->get_tags($search, $limit, $offset);
            $this->response['data'] = $tags['data'];
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            print_r(json_encode($this->response));
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function delete_tag()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $tag_id = $this->input->get('id',true);
            if (is_exist(['tag_id' => $tag_id], 'partner_tags')) {
                delete_details(['tag_id' => $tag_id], 'partner_tags');
            }
            if (is_exist(['tag_id' => $tag_id], 'product_tags')) {
                delete_details(['tag_id' => $tag_id], 'product_tags');
            }
            if (delete_details(['id' => $tag_id], 'tags') == TRUE) {
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

}
