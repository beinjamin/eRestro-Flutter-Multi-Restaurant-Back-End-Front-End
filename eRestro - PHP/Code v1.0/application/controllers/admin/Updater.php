<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Updater extends CI_Controller
{

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library(['ion_auth', 'form_validation', 'upload']);
        $this->load->helper(['url', 'language', 'file']);
        $this->load->model('Transaction_model');
    }

    public function index()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            $this->data['main_page'] = FORMS . 'updater';
            $settings = get_settings('system_settings', true);
            $this->data['title'] = 'Auto Update The System | ' . $settings['app_name'];
            $this->data['meta_description'] = ' Auto Update The System  | ' . $settings['app_name'];
            $this->data['system'] = get_system_update_info();
            $this->load->view('admin/template', $this->data);
        } else {
            redirect('admin/login', 'refresh');
        }
    }

    public function is_dir_empty($dir)
    {
        if (!is_readable($dir)) return NULL;
        return (count(scandir($dir)) == 2);
    }

    public function upload_update_file()
    {
        if ($this->ion_auth->logged_in() && $this->ion_auth->is_admin()) {
            if (print_msg(!has_permissions('update', 'system_update'), PERMISSION_ERROR_MSG, 'system_update')) {
                return false;
            }
            if (!empty($_FILES['update_file']['name'][0])) {
                if (!file_exists(FCPATH . UPDATE_PATH)) {
                    mkdir(FCPATH . UPDATE_PATH, 0777, true);
                }
                // Set preference 
                $config = [
                    'upload_path' =>   FCPATH . UPDATE_PATH,
                    'allowed_types' => 'zip',
                    'max_size' => 0,
                    'file_name' => $_FILES['update_file']['name'][0],
                ];

                // Load upload library 
                $this->upload->initialize($config);
                $files = $_FILES;

                $_FILES['file']['name'] = (isset($files['update_file']['name'][0]) && !empty($files['update_file']['name'][0])) ? $files['update_file']['name'][0] : "";
                $_FILES['file']['type'] = (isset($files['update_file']['type'][0]) && !empty($files['update_file']['type'][0])) ? $files['update_file']['type'][0] : "";
                $_FILES['file']['tmp_name'] = (isset($files['update_file']['tmp_name'][0]) && !empty($files['update_file']['tmp_name'][0])) ? $files['update_file']['tmp_name'][0] : "";
                $_FILES['file']['error'] = (isset($files['update_file']['error'][0]) && !empty($files['update_file']['error'][0])) ? $files['update_file']['error'][0] : "";
                $_FILES['file']['size'] = (isset($files['update_file']['size'][0]) && !empty($files['update_file']['size'][0])) ? $files['update_file']['size'][0] : "";
                // File upload
                if ($this->upload->do_upload('file')) {
                    // Get data about the file
                    $uploadData = $this->upload->data();
                    $filename = $uploadData['file_name'];

                    ## Extract the zip file ---- start
                    $zip = new ZipArchive;
                    $res = $zip->open(FCPATH . UPDATE_PATH . $filename);
                    if ($res === TRUE) {

                        // Unzip path
                        $extractpath = FCPATH . UPDATE_PATH;

                        // Extract file
                        $zip->extractTo($extractpath);
                        $zip->close();
                        unlink(FCPATH . UPDATE_PATH . $filename);

                        if (file_exists(UPDATE_PATH . "package.json") || file_exists(UPDATE_PATH . "plugin/package.json")) {
                            /* Plugin / Module installer script */
                            $sub_directory = (file_exists(UPDATE_PATH . "plugin/package.json")) ? "plugin/" : "";

                            if (file_exists(UPDATE_PATH . $sub_directory . "package.json")) {
                                $package_data = file_get_contents(UPDATE_PATH . $sub_directory . "package.json");
                                $package_data = json_decode($package_data, true);
                                if (!empty($package_data)) {
                                    /* Folders Creation - check if folders.json is set if yes then create folders listed in that file */
                                    if (isset($package_data['folders']) && !empty($package_data['folders'])) {
                                        /* create folders in the destination as set in the file */
                                        if (file_exists(UPDATE_PATH . $sub_directory . $package_data['folders'])) {
                                            $lines_array = file_get_contents(UPDATE_PATH . $sub_directory . $package_data['folders']);
                                            if (!empty($lines_array)) {
                                                $lines_array = json_decode($lines_array);
                                                foreach ($lines_array as $key => $line) {
                                                    if (!is_dir($line) && !file_exists($line)) {
                                                        mkdir($line, 0777, true);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    /* Files Copy - check if files.json is set if yes then copy the files listed in that file */
                                    if (isset($package_data['files']) && !empty($package_data['files'])) {
                                        /* copy files from source to destination as set in the file */
                                        if (file_exists(UPDATE_PATH . $sub_directory . $package_data['files'])) {
                                            $lines_array = file_get_contents(UPDATE_PATH . $sub_directory . $package_data['files']);
                                            if (!empty($lines_array)) {
                                                $lines_array = json_decode($lines_array);
                                                foreach ($lines_array as $key => $line) {
                                                    copy($sub_directory . $key, $line);
                                                }
                                            }
                                        }
                                    }
                                    /* ZIP Extraction - check if archives.json is set if yes then extract the files on destination as mentioned */
                                    if (isset($package_data['archives']) && !empty($package_data['archives'])) {
                                        /* extract the archives in the destination folder as set in the file */
                                        if (file_exists(UPDATE_PATH . $sub_directory . $package_data['archives'])) {
                                            $lines_array = file_get_contents(UPDATE_PATH . $sub_directory . $package_data['archives']);
                                            if (!empty($lines_array)) {
                                                $lines_array = json_decode($lines_array);
                                                $zip = new ZipArchive;
                                                foreach ($lines_array as $source => $destination) {
                                                    $source = UPDATE_PATH . $sub_directory . $source;
                                                    $res = $zip->open($source);
                                                    if ($res === TRUE) {
                                                        $destination = $source = $destination;
                                                        $zip->extractTo($destination);
                                                        $zip->close();
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    /* run the migration if there is any */
                                    if (is_dir(FCPATH . "\\application\\migrations") && !$this->is_dir_empty(FCPATH . "\\application\\migrations")) {
                                            /* the folder is NOT empty run the migration */;
                                        $this->load->library('migration');
                                        $this->migration->latest();
                                    }

                                    delete_files(FCPATH . UPDATE_PATH, true);
                                    $this->response['error'] = false;
                                    $this->response['message'] = 'Congratulations! The ' . $package_data['name'] . ' is installed successfully on your system. ' . $package_data['message_on_success'];
                                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                                    print_r(json_encode($this->response));
                                    return;
                                } else {
                                    $this->response['error'] = true;
                                    $this->response['message'] = 'Invalid plugin installer file!. No package data found / missing package data.';
                                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                                    delete_files(FCPATH . UPDATE_PATH, true);
                                    print_r(json_encode($this->response));
                                    return;
                                }
                            } else {
                                $this->response['error'] = true;
                                $this->response['message'] = 'Invalid plugin installer file!. It seems like you are using some invalid file.';
                                $this->response['csrfName'] = $this->security->get_csrf_token_name();
                                $this->response['csrfHash'] = $this->security->get_csrf_hash();
                                delete_files(FCPATH . UPDATE_PATH, true);
                                print_r(json_encode($this->response));
                                return;
                            }
                        } else if (file_exists(UPDATE_PATH . "folders.json") || file_exists(UPDATE_PATH . "update/folders.json")) {
                            /* System update script goes here */
                            $system_info = get_system_update_info();
                            if (isset($system_info['is_updatable']) && $system_info['is_updatable'] == false) {
                                if (isset($system_info['db_current_version']) && $system_info['db_current_version'] == $system_info['file_current_version']) {
                                    $this->response['error'] = true;
                                    $this->response['message'] = 'Oops!. This version is already updated into your system. Try another one';
                                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                                    delete_files(FCPATH . UPDATE_PATH, true);
                                    print_r(json_encode($this->response));
                                    return;
                                } else {
                                    $this->response['error'] = true;
                                    $this->response['message'] = 'It seems like you are trying to update the system using wrong file.';
                                    $this->response['csrfName'] = $this->security->get_csrf_token_name();
                                    $this->response['csrfHash'] = $this->security->get_csrf_hash();
                                    delete_files(FCPATH . UPDATE_PATH, true);
                                    print_r(json_encode($this->response));
                                    return;
                                }
                            }
                            $sub_directory = (file_exists(UPDATE_PATH . "update/folders.json")) ? "update/" : "";
                            if (file_exists(UPDATE_PATH . "folders.json") || file_exists(UPDATE_PATH . "update/folders.json")) {
                                $lines_array = file_get_contents(UPDATE_PATH . $sub_directory . "folders.json");
                                $lines_array = json_decode($lines_array);
                                foreach ($lines_array as $key => $line) {
                                    if (!is_dir($line) && !file_exists($line)) {
                                        mkdir($line, 0777, true);
                                    }
                                }
                            }

                            if (file_exists(UPDATE_PATH . "files.json") || file_exists(UPDATE_PATH . "update/files.json")) {
                                $lines_array = file_get_contents(UPDATE_PATH . $sub_directory . "files.json");
                                $lines_array = json_decode($lines_array);
                                foreach ($lines_array as $key => $line) {
                                    copy($sub_directory . $key, $line);
                                }
                            }
							
							/* ZIP Extraction - check if archives.json is set if yes then extract the files on destination as mentioned */
							$archives = (file_exists(UPDATE_PATH . "files.json"))? UPDATE_PATH . "files.json" : "";
							$archives = (file_exists(UPDATE_PATH . "files.json"))? UPDATE_PATH . "update/files.json" : "";
							
							if (isset($archives) && !empty($archives)) {
								/* extract the archives in the destination folder as set in the file */
								if (file_exists(UPDATE_PATH . $sub_directory . $archives)) {
									$lines_array = file_get_contents(UPDATE_PATH . $sub_directory . $archives);
									if (!empty($lines_array)) {
										$lines_array = json_decode($lines_array);
										$zip = new ZipArchive;
										foreach ($lines_array as $source => $destination) {
											$source = UPDATE_PATH . $sub_directory . $source;
											// $source = str_replace("/", "\\", FCPATH . UPDATE_PATH . $sub_directory . $source);
											// $source = "C:\\xampp\\htdocs\\infinitie\\eshop-test\\plugin\\update-files\\assets\\front_end.zip";
											$res = $zip->open($source);
											if ($res === TRUE) {
												$destination = $source = $destination;
												// $destination = $source = str_replace("/", "\\", FCPATH . $destination);
												$zip->extractTo($destination);
												$zip->close();
											}
										}
									}
								}
							}

                            $data = array('version' => $system_info['file_current_version']);
                            $data = escape_array($data);
                            $this->db->insert('updates', $data);

                            /* run the migration if there is any */
                            if (!$this->is_dir_empty(FCPATH . "\\application\\migrations")) {
                                    /* the folder is NOT empty run the migration */;
                                $this->load->library('migration');
                                $this->migration->latest();
                            }

                            delete_files(FCPATH . UPDATE_PATH, true);
                            $this->response['error'] = false;
                            $this->response['message'] = 'Congratulations! The system is updated From  version ' . $system_info['db_current_version'] . ' to ' . $system_info['file_current_version'] . ' version successfully';
                        } else {
                            $this->response['error'] = true;
                            $this->response['message'] = 'Invalid update file!. It seems like you are trying to update the system using wrong file.';
                            delete_files(FCPATH . UPDATE_PATH, true);
                        }
                    } else {
                        $this->response['error'] = true;
                        $this->response['message'] = $this->upload->display_errors();
                    }
                } else {
                    $this->response['error'] = true;
                    $this->response['message'] = $this->upload->display_errors();
                }
            } else {
                $this->response['error'] = true;
                $this->response['message'] = 'You did not select a file to upload';
            }
            $this->response['csrfName'] = $this->security->get_csrf_token_name();
            $this->response['csrfHash'] = $this->security->get_csrf_hash();
            print_r(json_encode($this->response));
            return;
        } else {
            redirect('admin/login', 'refresh');
        }
    }
}
