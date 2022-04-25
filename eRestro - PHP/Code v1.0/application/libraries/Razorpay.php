<?php
/* 
    1. get_credentials()
    2. create_order($amount,$receipt='')
    3. fetch_payments($id ='')
    4. capture_payment($amount, $id, $currency = "INR")
    5. verify_payment($order_id, $razorpay_payment_id, $razorpay_signature)

    0. curl($url, $method = 'GET', $data = [])
*/
class Razorpay
{
    private $key_id = "";
    private $secret_key = "";
    private $url = "";

    function __construct()
    {
        $settings = get_settings('payment_method', true);
        $system_settings = get_settings('system_settings', true);

        $this->key_id = (isset($settings['razorpay_key_id'])) ? $settings['razorpay_key_id'] : "";
        $this->secret_key = (isset($settings['razorpay_secret_key'])) ? $settings['razorpay_secret_key'] : "";
        $this->url = "https://api.razorpay.com/v1/";
    }
    public function get_credentials()
    {
        $data['key_id'] = $this->key_id;
        $data['secret_key'] = $this->secret_key;
        $data['url'] = $this->url;
        return $data;
    }
    public function create_order($amount, $receipt = '', $currency = "INR")
    {
        $data = array(
            'amount' => $amount,
            'receipt' => $receipt,
            'currency' => $currency,
        );
        $url = $this->url . 'orders';
        $method = 'POST';
        $response = $this->curl($url, $method, $data);
        $res = json_decode($response['body'], true);
        return $res;
    }

    public function fetch_payments($id = '')
    {
        $url = $this->url . 'payments';
        $url .= (!empty(trim($id))) ? '/' . $id : '';
        $method = 'GET';
        $response = $this->curl($url, $method);
        $res = json_decode($response['body'], true);
        return $res;
    }

    public function capture_payment($amount, $id, $currency = "INR")
    {
        $data = array(
            'amount' => $amount,
            'currency' => $currency,
        );
        $url = $this->url . 'payments/' . $id . '/capture';
        $method = 'POST';
        $response = $this->curl($url, $method, $data);
        $res = json_decode($response['body'], true);
        return $res;
    }

    public function verify_payment($order_id, $razorpay_payment_id, $razorpay_signature)
    {
        $generated_signature = hash_hmac('sha256', $order_id . "|" . $razorpay_payment_id, $this->secret_key);
        if ($generated_signature == $razorpay_signature) {
            return true;
        } else {
            return false;
        }
    }

    public function curl($url, $method = 'GET', $data = [])
    {
        $ch = curl_init();
        $curl_options = array(
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => 1,
            CURLOPT_HEADER => 0,
            CURLOPT_HTTPHEADER => array(
                'Content-Type: application/x-www-form-urlencoded',
                'Authorization: Basic ' . base64_encode($this->key_id . ':' . $this->secret_key)
            )
        );
        if (strtolower($method) == 'post') {
            $curl_options[CURLOPT_POST] = 1;
            $curl_options[CURLOPT_POSTFIELDS] = http_build_query($data);
        } else {
            $curl_options[CURLOPT_CUSTOMREQUEST] = 'GET';
        }
        curl_setopt_array($ch, $curl_options);
        $result = array(
            'body' => curl_exec($ch),
            'http_code' => curl_getinfo($ch, CURLINFO_HTTP_CODE),
        );
        return $result;
    }
}
