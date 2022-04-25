<?php

defined('BASEPATH') OR exit('No direct script access allowed');

class Transaction extends CI_Controller {

	public function __construct(){
		parent::__construct();
		$this->load->database();
		$this->load->library(['ion_auth', 'form_validation','upload']);
		$this->load->helper(['url', 'language','file']);		
        $this->load->model('Transaction_model');	
	}

	public function customer_wallet()
	{
		if($this->ion_auth->logged_in() && $this->ion_auth->is_admin())
		{
			$this->data['main_page'] = TABLES.'customer-wallet';
			$settings=get_settings('system_settings',true);
			$this->data['title'] = 'Customer wallet | '.$settings['app_name'];
			$this->data['meta_description'] = ' Customer wallet  | '.$settings['app_name'];	
			$this->load->view('admin/template',$this->data);
		}
		else{
			redirect('admin/login','refresh');
		}
	}

    public function wallet_transactions()
	{
		if($this->ion_auth->logged_in() && $this->ion_auth->is_admin())
		{
			$this->data['main_page'] = TABLES.'partner-wallet';
			$settings=get_settings('system_settings',true);
			$this->data['title'] = 'Partner Wallet | '.$settings['app_name'];
			$this->data['meta_description'] = 'Partner Wallet  | '.$settings['app_name'];	
            $this->data['partners'] = $this->db->select(' sd.partner_name,u.id as partner_id,sd.id as partner_data_id  ')
            ->join('users_groups ug', ' ug.user_id = u.id ')
            ->join('partner_data sd', ' sd.user_id = u.id ')
            ->where(['ug.group_id' => '4'])
            ->get('users u')->result_array();
			$this->load->view('admin/template',$this->data);
		}
		else{
			redirect('admin/login','refresh');
		}
	}

	public function view_transaction()
	{
		if($this->ion_auth->logged_in() && $this->ion_auth->is_admin())
		{
			$this->data['main_page'] = TABLES.'transaction';
			$settings=get_settings('system_settings',true);
			$this->data['title'] = 'View Transaction | '.$settings['app_name'];
			$this->data['meta_description'] = ' View Transaction  | '.$settings['app_name'];	
			$this->load->view('admin/template',$this->data);
		}
		else{
			redirect('admin/login','refresh');
		}
	}

	public function view_transactions()
	{
		if($this->ion_auth->logged_in() && $this->ion_auth->is_admin())
		{			
			return $this->Transaction_model->get_transactions_list();
		}
		else{
			redirect('admin/login','refresh');
		}
	}
}
