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
	}

	public function index()
	{
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
			$this->data['main_page'] = FORMS . 'tag';
			$settings = get_settings('system_settings', true);
			$this->data['title'] = 'Add Tags | ' . $settings['app_name'];
			$this->data['meta_description'] = 'Add Tags | ' . $settings['app_name'];
			if (isset($_GET['edit_id'])) {
				$this->data['fetched_data'] = fetch_details(['id' => $_GET['edit_id']], 'tags');
			}
			$this->load->view('partner/template', $this->data);
		} else {
			redirect('partner/login', 'refresh');
		}
	}

	public function manage_tag()
	{
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
			$this->data['main_page'] = TABLES . 'manage-tag';
			$settings = get_settings('system_settings', true);
			$this->data['title'] = 'Manage Tags | ' . $settings['app_name'];
			$this->data['meta_description'] = 'Manage Tags  | ' . $settings['app_name'];
			$this->load->view('partner/template', $this->data);
		} else {
			redirect('partner/login', 'refresh');
		}
	}

	public function add_tags()
	{
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {

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
				$tag_id = $this->Tag_model->add_tags($_POST);
                insert_details(['partner_id' => $this->ion_auth->get_user_id(),'tag_id' => $tag_id],"partner_tags");
				$this->response['error'] = false;
				$this->response['csrfName'] = $this->security->get_csrf_token_name();
				$this->response['csrfHash'] = $this->security->get_csrf_hash();
				$message = (isset($_POST['edit_tag'])) ? 'Tag Updated Successfully' : 'Tag Added Successfully';
				$this->response['message'] = $message;
				print_r(json_encode($this->response));
			}
		} else {
			redirect('partner/login', 'refresh');
		}
	}

	public function tag_list()
	{
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $partner_id = $this->ion_auth->get_user_id();
			return $this->Tag_model->get_tag_list($partner_id);
		} else {
			redirect('partner/login', 'refresh');
		}
	}

    public function get_tags()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {

            $limit = (isset($_GET['limit'])) ? $this->input->post('limit', true) : 25;
            $offset = (isset($_GET['offset'])) ? $this->input->post('offset', true) : 0;
            $search =  (isset($_GET['search'])) ? $_GET['search'] : null;
            $tags = $this->Tag_model->get_tags($search, $limit, $offset);
            $this->response['data'] = $tags['data'];
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            print_r(json_encode($this->response));
        } else {
            redirect('partner/login', 'refresh');
        }
    }

    public function delete_tag()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner() && ($this->ion_auth->partner_status() == 1 || $this->ion_auth->partner_status() == 0)) {
            $partner_id = $this->ion_auth->get_user_id();
            if (delete_details(['tag_id' => $_GET['id'],"partner_id" => $partner_id], 'partner_tags') == TRUE) {
                $this->response['error'] = false;
                $this->response['message'] = 'Deleted Succesfully';
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'Something Went Wrong';
            }
            print_r(json_encode($this->response));
        } else {
            redirect('partner/login', 'refresh');
        }
    }

}
