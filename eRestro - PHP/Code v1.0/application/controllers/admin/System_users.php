<?php
defined('BASEPATH') or exit('No direct script access allowed');


class System_users extends CI_Controller
{

	public function __construct()
	{
		parent::__construct();
		$this->load->database();
		$this->load->helper(['url', 'language', 'timezone_helper']);
		$this->load->model('system_users_model');
		$this->load->config('erestro');
		$userData = get_user_permissions($this->session->userdata('user_id'));
		if (empty($userData) || $userData[0]['role'] > 1) {
			$this->session->set_flashdata('authorize_flag', PERMISSION_ERROR_MSG);
			redirect('admin/home', 'refresh');
		}
	}

	public  function index()
	{
		if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

			$this->data['main_page'] = TABLES . 'manage-system-users';
			$settings = get_settings('system_settings', true);
			$this->data['title'] = 'Manage System Users | ' . $settings['app_name'];
			$this->data['meta_description'] = 'Manage System Users | ' . $settings['app_name'];
			$this->data['system_modules'] = $this->config->item('system_modules');
			$this->load->view('admin/template', $this->data);
		} else {
			redirect('admin/login', 'refresh');
		}
	}


	public function add_system_users()
	{
		if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

			$this->data['main_page'] = FORMS . 'system-users';
			$settings = get_settings('system_settings', true);
			$this->data['title'] = 'Add Sytem User | ' . $settings['app_name'];
			$this->data['meta_description'] = 'Add Sytem User | ' . $settings['app_name'];

			if (isset($_GET['edit_id']) && !empty($_GET['edit_id'])) {
				$user_permissions = $this->db->select('u.id,u.username,u.mobile,u.email,up.role,up.permissions')->join('users u', 'up.user_id=u.id')->where('up.id', $_GET['edit_id'])->get('user_permissions up')->result_array();
				if (!empty($user_permissions)) {
					$this->data['fetched_data'] = $user_permissions;
				}
			}

			$this->data['about_us'] = get_settings('about_us');
			$this->data['system_modules'] = $this->config->item('system_modules');
			$this->load->view('admin/template', $this->data);
		} else {
			redirect('admin/login', 'refresh');
		}
	}


	public function update_system_user()
	{

		if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {

			$edit_id = $this->input->post('edit_system_user', true);

			$this->form_validation->set_rules('username', 'Username', 'trim|required|xss_clean');
			$this->form_validation->set_rules('mobile', 'Mobile', 'trim|required|xss_clean|numeric');
			$this->form_validation->set_rules('email', 'Email', 'trim|required|xss_clean');
			$this->form_validation->set_rules('role', 'role', 'trim|required|xss_clean');

			if (isset($edit_id)) {
				$this->form_validation->set_rules('edit_system_user', 'Id', 'trim|required|numeric|xss_clean');
				if (isset($_POST['password']) && !empty($_POST['password'])) {
					$this->form_validation->set_rules('password', 'Password', 'trim|required|xss_clean|min_length[' . $this->config->item('min_password_length', 'ion_auth') . ']');
				}
			} else {
				$this->form_validation->set_rules('password', 'Password ' . $this->lang->line('change_password_validation_new_password_label'), 'trim|required|xss_clean|min_length[' . $this->config->item('min_password_length', 'ion_auth') . ']|matches[confirm_password]');
				$this->form_validation->set_rules('confirm_password', ' Confirm Password ' . $this->lang->line('change_password_validation_new_password_confirm_label'), 'trim|required|xss_clean');
			}
			if (!$this->form_validation->run()) {

				$this->response['error'] = true;
				$this->response['csrfName'] = $this->security->get_csrf_token_name();
				$this->response['csrfHash'] = $this->security->get_csrf_hash();
				$this->response['message'] = validation_errors();
				print_r(json_encode($this->response));
			} else {

				if (isset($edit_id) && !empty($edit_id)) {					
					if (is_exist(['mobile' => $_POST['mobile']], 'users' , $_POST['edit_system_user'])) {
						$this->response['error'] = true;
						$this->response['message'] = 'Mobile is already registered. Please Provide Unique Number !';
						$this->response['csrfName'] = $this->security->get_csrf_token_name();
						$this->response['csrfHash'] = $this->security->get_csrf_hash();
						$this->response['data'] = array();
						print_r(json_encode($this->response));
						return;
					}
				} else {
					if (is_exist(['mobile' => $_POST['mobile']], 'users')) {
						$this->response['error'] = true;
						$this->response['message'] = 'Mobile is already registered.  Please Provide Unique Number !';
						$this->response['csrfName'] = $this->security->get_csrf_token_name();
						$this->response['csrfHash'] = $this->security->get_csrf_hash();
						$this->response['data'] = array();
						print_r(json_encode($this->response));
						return;
					}
				}

				$this->system_users_model->update_user($_POST);
				$this->response['error'] = false;
				$this->response['csrfName'] = $this->security->get_csrf_token_name();
				$this->response['csrfHash'] = $this->security->get_csrf_hash();
				$this->response['message'] = (isset($edit_id)) ? ' Data Updated Successfully' : 'Data Added Successfully';

				print_r(json_encode($this->response));
			}
		} else {
			redirect('admin/login', 'refresh');
		}
	}

	public function delete_system_user()
	{

		if (print_msg(!has_permissions('delete', 'categories'), PERMISSION_ERROR_MSG, 'categories')) {
			return false;
		}

		if (delete_details(['user_id' => $_GET['id']], 'user_permissions') == TRUE) {
			delete_details(['id' => $_GET['id']], 'users');
			$this->response['error'] = false;
			$this->response['csrfName'] = $this->security->get_csrf_token_name();
			$this->response['csrfHash'] = $this->security->get_csrf_hash();
			$this->response['message'] = 'Deleted Succesfully';
			print_r(json_encode($this->response));
		} else {
			$this->response['error'] = true;
			$this->response['csrfName'] = $this->security->get_csrf_token_name();
			$this->response['csrfHash'] = $this->security->get_csrf_hash();
			$this->response['message'] = 'Something Went Wrong';
			print_r(json_encode($this->response));
		}
	}

	public function view_system_users()
	{

		return $this->system_users_model->get_users_list();
	}
}
