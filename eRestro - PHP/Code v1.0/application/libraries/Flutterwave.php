<?php
/*
    Flutterwave API v3 - new API with new endpoints
    -----------------------------------------------
    1. get_credentials()
    2. verify_transaction($transaction_id)
    3. create_payment($data)

*/

class Flutterwave{
	private $secret_key,$public_key,$curl;
	public $temp = array();
	function __construct($mode='live') {
		$this->CI =& get_instance();
        $settings = get_settings('payment_method',true);
        $this->public_key = (isset($settings['flutterwave_public_key']))?$settings['flutterwave_public_key']:"";
		$this->secret_key = (isset($settings['flutterwave_secret_key']))?$settings['flutterwave_secret_key']:"";
		$this->encryption_key = (isset($settings['flutterwave_encryption_key']))?$settings['flutterwave_encryption_key']:"";
		$this->currency_code = (isset($settings['flutterwave_currency_code']))?$settings['flutterwave_currency_code']:"";
    }
    public function get_credentials(){
        $credentials = array(
            'public_key' => $this->public_key,
            'secret_key' => $this->secret_key,
            'encryption_key' => $this->encryption_key,
            'currency_code' => $this->currency_code,
        );
        return $credentials;
    }
    
    function verify_transaction($transaction_id){
        /*
    		transaction_id=FLUTTERWAVE_TXN_ID
	    */
		$url = "https://api.flutterwave.com/v3/transactions/$transaction_id/verify";
		$method = "GET";
		$create_transfer = $this->curl_request($url,$method);
        return $create_transfer;
    }
    
    function create_payment($data){
        /*
    		To be passed in an array not in JSON
            {
                "tx_ref":"hooli-tx-1920bbtytty",
                "amount":"100",
                "currency":"NGN",
                "redirect_url":"https://webhook.site/9d0b00ba-9a69-44fa-a43d-a82c33c36fdc",
                "payment_options":"card",
                "meta":{
                    "consumer_id":23,
                    "consumer_mac":"92a3-912ba-1192a"
                },
                "customer":{
                    "email":"user@gmail.com",
                    "phonenumber":"080****4528",
                    "name":"Yemi Desola"
                },
                "customizations":{
                    "title":"Pied Piper Payments",
                    "description":"Middleout isn't free. Pay the price",
                    "logo":"https://assets.piedpiper.com/logo.png"
                }
            }
	    */
		$url = "https://api.flutterwave.com/v3/payments";
		$method = "POST";
		$create_transfer = $this->curl_request($url,$method,$data);
        return $create_transfer;
    }
	
	public function curl_request($end_point,$method,$data = array()){
		$this->curl = curl_init();
		$data['seckey'] = $this->secret_key;
        curl_setopt_array($this->curl, array(
            CURLOPT_URL => $end_point,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => "",
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 0,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => strtoupper($method),
            CURLOPT_POSTFIELDS => json_encode($data),
            CURLOPT_HTTPHEADER => array(
                "Content-Type: application/json",
                "Authorization: Bearer ".$this->secret_key
            ),
        ));
		
		$response = curl_exec($this->curl);
		curl_close($this->curl);
		return $response;
	}
}
?>