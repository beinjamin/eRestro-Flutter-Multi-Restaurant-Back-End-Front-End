<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Home extends CI_Controller {

	public function __construct()
	{
		parent::__construct();
		$this->load->database();
		$this->load->library(['ion_auth', 'form_validation']);
		$this->load->helper(['url', 'language']);
		$this->load->model('Home_model');		
	}

	public function index()
	{
		if($this->ion_auth->logged_in() && $this->ion_auth->is_rider())
		{
			$user_id = $this->session->userdata('user_id');
            $user_res = fetch_details(['id' =>$user_id],"users",'balance,commission,username');
			$this->data['main_page'] = FORMS.'home';
			$settings=get_settings('system_settings',true);
            $this->data['curreny'] = get_settings('currency');
			$this->data['title'] = 'Rider Panel | '.$settings['app_name'];
			$this->data['order_counter'] = $this->Home_model->count_new_orders();
			$this->data['balance'] = ( $user_res[0]['balance']==NULL) ? 0 : $user_res[0]['balance'];
			$this->data['commission'] = ( $user_res[0]['commission']==NULL)  ? 0 : $user_res[0]['commission'];
			$this->data['username'] =  $user_res[0]['username'];
			$this->data['meta_description'] = 'Rider Panel | '.$settings['app_name'];
			$this->load->view('rider/template',$this->data);
		}
		else{
			redirect('rider/login','refresh');
		}
	}
    
    public function profile(){
		if($this->ion_auth->logged_in() && $this->ion_auth->is_rider())
		{
            $identity_column = $this->config->item('identity', 'ion_auth');
		    $this->data['users'] = $this->ion_auth->user()->row();
			$settings=get_settings('system_settings',true);			
			$this->data['identity_column'] = $identity_column;
			$this->data['main_page'] = FORMS.'profile';
            $this->data['title'] = 'Change Password | '.$settings['app_name'];            
			$this->data['meta_description'] = 'Change Password | '.$settings['app_name'];	
            $this->data['curreny'] = get_settings('currency');			
			$this->load->view('rider/template',$this->data);
		}
		else{
			redirect('rider/home','refresh');
		}
	}
    
    public function logout(){
		$this->ion_auth->logout();
		redirect('rider/login', 'refresh');			
	}
	
}
?>