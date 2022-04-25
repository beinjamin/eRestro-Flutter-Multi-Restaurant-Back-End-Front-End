<?php
/* 
    Google Search Library v1.0 for codeigniter 3
*/

/* 
    1. get_credentials()
    2. search_places 
    https://maps.googleapis.com/maps/api/place/autocomplete/json?input=hill garden,bhuj&types=geocode&key=YOUR_API_KEY
    https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=bhuj&inputtype=textquery&fields=formatted_address%2Cname%2Copening_hours%2Cgeometry&key=YOUR_API_KEY

    3. find_distance
    https://maps.googleapis.com/maps/api/distancematrix/json?origins=23.24114205388701, 69.66720847135304&destinations=23.235700208395272, 69.7287490771754&key=YOUR_API_KEY

    4. curl($url, $method = 'GET', $data = [])
*/
class Google_maps
{
    private $secret_key = "";
    private $url = "";

    function __construct()
    {
        $this->CI = &get_instance();
        $this->CI->load->helper('url');
        $this->CI->load->helper('form');
        $system_settings = get_settings('system_settings', true);

        $this->secret_key = $system_settings['google_map_api_key'];
        $this->url = "https://maps.googleapis.com/maps/api/";
    }
    public function get_credentials()
    {
        $data['secret_key'] = $this->secret_key;
        $data['url'] = $this->url;
        return $data;
    }

    public function search_places($input = "", $types = "textquery")
    {
        $input = trim($input);
        $final_url = $this->url . 'place/findplacefromtext/json?input=' . $input . '&inputtype=' . $types . '&fields=formatted_address%2Cname%2Copening_hours%2Cgeometry&key=' . $this->secret_key;
        $result = curl($final_url,"GET");
        return $result;
    }
    public function find_google_map_distance($origins = "", $destinations = "")
    {
        $origins = trim($origins);
        $destinations = trim($destinations);
        $final_url = $this->url . 'distancematrix/json?origins=' . $origins . '&destinations=' . $destinations . '&key=' . $this->secret_key;
        $result = curl($final_url,"GET");
        return $result;
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
                'Authorization: Basic ' . base64_encode($this->secret_key . ':')
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
