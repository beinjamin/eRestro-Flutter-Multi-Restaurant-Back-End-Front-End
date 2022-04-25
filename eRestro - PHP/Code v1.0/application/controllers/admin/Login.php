<?php defined('BASEPATH') or exit('No direct script access allowed');

class Login extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation']);
        $this->load->helper(['url', 'language']);

        $this->lang->load('auth');
    }
    public function index()
    {

        if (!$this->ion_auth->logged_in() && !$this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'login';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Login Panel | ' . $settings['app_name'];
            $this->data['meta_description'] = 'Login Panel | ' . $settings['app_name'];
            $this->data['logo'] = get_settings('logo');

            $identity = $this->config->item('identity', 'ion_auth');
            if (empty($identity)) {
                $identity_column = 'text';
            } else {
                $identity_column = $identity;
            }
            $this->data['identity_column'] = $identity_column;
            $this->load->view('admin/login', $this->data);
        } else {
            if ($this->session->has_userdata('url')) {
                $url = $this->session->userdata('url');
                $this->session->unset_userdata('url');
                redirect($url, 'refresh');
            } else {
                if ($this->ion_auth->logged_in() && $this->ion_auth->is_partner()) {
                    redirect('partner/home', 'refresh');
                } else if ($this->ion_auth->logged_in() && $this->ion_auth->is_rider()) {
                    redirect('rider/home', 'refresh');
                } else {
                    redirect('admin/home', 'refresh');
                }
            }
        }
    }

    public function forgot_password()
    {
        $this->data['main_page'] = FORMS . 'forgot-password';
        $settings = get_settings('system_settings', true);
        $this->data['title'] = 'Forgot Password | ' . $settings['app_name'];
        $this->data['meta_description'] = 'Forget Password | ' . $settings['app_name'];
        $this->data['logo'] = get_settings('logo');
        $this->load->view('admin/login', $this->data);
    }

    public function update_user()
    {
        if (print_msg(!has_permissions('update', 'profile'), PERMISSION_ERROR_MSG, 'profile')) {
            return false;
        }

        $identity_column = $this->config->item('identity', 'ion_auth');
        $identity = $this->session->userdata('identity');
        $user = $this->ion_auth->user()->row();
        if ($identity_column == 'email') {
            $this->form_validation->set_rules('email', 'Email', 'required|xss_clean|trim|valid_email|edit_unique[users.email.' . $user->id . ']');
        } else {
            $this->form_validation->set_rules('mobile', 'Mobile', 'required|xss_clean|trim|numeric|edit_unique[users.mobile.' . $user->id . ']');
        }
        $this->form_validation->set_rules('username', 'Username', 'required|xss_clean|trim');

        if (!empty($_POST['old']) || !empty($_POST['new']) || !empty($_POST['new_confirm'])) {
            $this->form_validation->set_rules('old', $this->lang->line('change_password_validation_old_password_label'), 'required');
            $this->form_validation->set_rules('new', $this->lang->line('change_password_validation_new_password_label'), 'required|min_length[' . $this->config->item('min_password_length', 'ion_auth') . ']|matches[new_confirm]');
            $this->form_validation->set_rules('new_confirm', $this->lang->line('change_password_validation_new_password_confirm_label'), 'required');
        }


        $tables = $this->config->item('tables', 'ion_auth');
        if (!$this->form_validation->run()) {
            if (validation_errors()) {
                $response['error'] = true;
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                $response['message'] = validation_errors();
                echo json_encode($response);
                return false;
                exit();
            }
            if ($this->session->flashdata('message')) {
                $response['error'] = false;
                $response['csrfName'] = $this->security->get_csrf_token_name();
                $response['csrfHash'] = $this->security->get_csrf_hash();
                $response['message'] = $this->session->flashdata('message');
                echo json_encode($response);
                return false;
                exit();
            }
        } else {

            if (!empty($_POST['old']) || !empty($_POST['new']) || !empty($_POST['new_confirm'])) {
                if (!$this->ion_auth->change_password($identity, $this->input->post('old'), $this->input->post('new'))) {
                    // if the login was un-successful
                    $response['error'] = true;
                    $response['csrfName'] = $this->security->get_csrf_token_name();
                    $response['csrfHash'] = $this->security->get_csrf_hash();
                    $response['message'] = $this->ion_auth->errors();
                    echo json_encode($response);
                    return;
                    exit();
                }
            }
            $set = ['username' => $this->input->post('username'), 'email' => $this->input->post('email')];
            $set = escape_array($set);
            $this->db->set($set)->where($identity_column, $identity)->update($tables['login_users']);
            $response['error'] = false;
            $response['csrfName'] = $this->security->get_csrf_token_name();
            $response['csrfHash'] = $this->security->get_csrf_hash();
            $response['message'] = 'Profile Update Succesfully';
            echo json_encode($response);
            return;
        }
    }


    public function reset_password($code = NULL)
    {
        if (!$code) {
            redirect(base_url());
        }
        $this->data['user'] = $this->ion_auth->forgotten_password_check($code);
        if ($this->data['user']) {
            $settings = get_settings('system_settings', true);
            $this->data['main_page'] = FORMS . 'reset_password';
            $this->data['title'] = 'Reset Password |' . $settings['app_name'];
            $this->data['meta_description'] = 'Reset Password |' . $settings['app_name'];
            $this->data['logo'] = get_settings('logo');
            $this->load->view('admin/login', $this->data);
        } else {
            redirect(base_url('admin/login/forgot_password'), 'refresh');
        }
    }
}
