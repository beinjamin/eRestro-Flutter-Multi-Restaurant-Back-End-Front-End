<?php
class Migrate extends CI_Controller{
    public function index(){
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
			$this->load->library('migration');
			if ($this->migration->latest() === FALSE) {
				show_error($this->migration->error_string());
			}else{
				echo "Migration Successfully";
			}
		}else{
			echo "You are not authorized to do this";
		}
    }
    public function rollback($version = ''){
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin() && defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 1) {
			$this->load->library('migration');
			if(!empty($version) && is_numeric($version)){
				$this->migration->version($version);
			}else{
				show_error($this->migration->error_string());
			}
		}else{
			echo "You are not authorized to do this";
		}
    }
}
