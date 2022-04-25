<?php $settings = get_settings('system_settings', true); ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office" style="width:100%;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;padding:0;Margin:0">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1" name="viewport">
    <meta name="x-apple-disable-message-reformatting">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta content="telephone=no" name="format-detection">
    <link rel="icon" type="image/ico" href="#">
    <title>Email - <?= $settings['app_name'] ?></title>

    <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,400i,700,700i" rel="stylesheet">

    <style type="text/css">
        #outlook a {
            padding: 0;
        }

        .ExternalClass {
            width: 100%;
        }

        .ExternalClass,
        .ExternalClass p,
        .ExternalClass span,
        .ExternalClass font,
        .ExternalClass td,
        .ExternalClass div {
            line-height: 100%;
        }

        .es-button {
            mso-style-priority: 100 !important;
            text-decoration: none !important;
        }

        a[x-apple-data-detectors] {
            color: inherit !important;
            text-decoration: none !important;
            font-size: inherit !important;
            font-family: inherit !important;
            font-weight: inherit !important;
            line-height: inherit !important;
        }

        .es-desk-hidden {
            display: none;
            float: left;
            overflow: hidden;
            width: 0;
            max-height: 0;
            line-height: 0;
            mso-hide: all;
        }

        @media only screen and (max-width:600px) {

            p,
            ul li,
            ol li,
            a {
                font-size: 16px !important;
                line-height: 150% !important
            }

            h1 {
                font-size: 32px !important;
                text-align: center;
                line-height: 120% !important
            }

            h2 {
                font-size: 26px !important;
                text-align: center;
                line-height: 120% !important
            }

            h3 {
                font-size: 20px !important;
                text-align: center;
                line-height: 120% !important
            }

            h1 a {
                font-size: 32px !important
            }

            h2 a {
                font-size: 26px !important
            }

            h3 a {
                font-size: 20px !important
            }

            .es-menu td a {
                font-size: 16px !important
            }

            .es-header-body p,
            .es-header-body ul li,
            .es-header-body ol li,
            .es-header-body a {
                font-size: 16px !important
            }

            .es-footer-body p,
            .es-footer-body ul li,
            .es-footer-body ol li,
            .es-footer-body a {
                font-size: 16px !important
            }

            .es-infoblock p,
            .es-infoblock ul li,
            .es-infoblock ol li,
            .es-infoblock a {
                font-size: 12px !important
            }

            *[class="gmail-fix"] {
                display: none !important
            }

            .es-m-txt-c,
            .es-m-txt-c h1,
            .es-m-txt-c h2,
            .es-m-txt-c h3 {
                text-align: center !important
            }

            .es-m-txt-r,
            .es-m-txt-r h1,
            .es-m-txt-r h2,
            .es-m-txt-r h3 {
                text-align: right !important
            }

            .es-m-txt-l,
            .es-m-txt-l h1,
            .es-m-txt-l h2,
            .es-m-txt-l h3 {
                text-align: left !important
            }

            .es-m-txt-r img,
            .es-m-txt-c img,
            .es-m-txt-l img {
                display: inline !important
            }

            .es-button-border {
                display: inline-block !important
            }

            a.es-button {
                font-size: 16px !important;
                display: inline-block !important
            }

            .es-btn-fw {
                border-width: 10px 0px !important;
                text-align: center !important
            }

            .es-adaptive table,
            .es-btn-fw,
            .es-btn-fw-brdr,
            .es-left,
            .es-right {
                width: 100% !important
            }

            .es-content table,
            .es-header table,
            .es-footer table,
            .es-content,
            .es-footer,
            .es-header {
                width: 100% !important;
                max-width: 600px !important
            }

            .es-adapt-td {
                display: block !important;
                width: 100% !important
            }

            .adapt-img {
                width: 100% !important;
                height: auto !important
            }

            .es-m-p0 {
                padding: 0px !important
            }

            .es-m-p0r {
                padding-right: 0px !important
            }

            .es-m-p0l {
                padding-left: 0px !important
            }

            .es-m-p0t {
                padding-top: 0px !important
            }

            .es-m-p0b {
                padding-bottom: 0 !important
            }

            .es-m-p20b {
                padding-bottom: 20px !important
            }

            .es-mobile-hidden,
            .es-hidden {
                display: none !important
            }

            tr.es-desk-hidden,
            td.es-desk-hidden,
            table.es-desk-hidden {
                width: auto !important;
                overflow: visible !important;
                float: none !important;
                max-height: inherit !important;
                line-height: inherit !important
            }

            tr.es-desk-hidden {
                display: table-row !important
            }

            table.es-desk-hidden {
                display: table !important
            }

            td.es-desk-menu-hidden {
                display: table-cell !important
            }

            .es-menu td {
                width: 1% !important
            }

            table.es-table-not-adapt,
            .esd-block-html table {
                width: auto !important
            }

            table.es-social {
                display: inline-block !important
            }

            table.es-social td {
                display: inline-block !important
            }
        }
    </style>
</head>

<body style="width:100%;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;padding:0;Margin:0">
    <div class="es-wrapper-color" style="background-color:#CFE2F3">
        <table class="es-wrapper" width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;padding:0;Margin:0;width:100%;height:100%;background-repeat:repeat;background-position:center top">
            <tr style="border-collapse:collapse">
                <td valign="top" style="padding:0;Margin:0">
                    <table class="es-content" cellspacing="0" cellpadding="0" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%">
                        <tr style="border-collapse:collapse"></tr>
                        <tr style="border-collapse:collapse">
                            <td align="center" style="padding:0;Margin:0">
                                <table class="es-header-body" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#044767;width:720px" cellspacing="0" cellpadding="0" bgcolor="#044767" align="center">
                                    <tr style="border-collapse:collapse">
                                        <td align="left" bgcolor="#1d92ee" style="Margin:0;padding-top:35px;padding-bottom:35px;padding-left:35px;padding-right:35px;background-color:#1D92EE">
                                            <!--[if mso]><table style="width:650px" cellpadding="0" cellspacing="0"><tr><td style="width:400px" valign="top"><![endif]-->
                                            <table class="es-left" cellspacing="0" cellpadding="0" align="left" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left">
                                                <tr style="border-collapse:collapse">
                                                    <td class="es-m-p0r es-m-p20b" valign="top" align="center" style="padding:0;Margin:0;width:400px">
                                                        <table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td class="es-m-txt-c" align="left" style="padding:20px;Margin:0">
                                                                    <h2 style="Margin:0;line-height:60px;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;font-size:30px;font-style:normal;font-weight:bold;color:#FFD966"><?= $settings['app_name'];  ?></h2>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <!--[if mso]></td><td style="width:20px"></td><td style="width:230px" valign="top"><![endif]-->
                                            <table cellspacing="0" cellpadding="0" align="right" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                <tr class="es-hidden" style="border-collapse:collapse">
                                                    <td class="es-m-p20b" align="left" style="padding:0;Margin:0;width:230px">
                                                        <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td style="padding:0;Margin:0">
                                                                    <table cellspacing="0" cellpadding="0" align="right" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                                        <tr style="border-collapse:collapse">
                                                                            <td align="left" style="padding:0;Margin:0">
                                                                                <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                                                    <tr style="border-collapse:collapse">
                                                                                        <td align="center" style="padding:0;Margin:0;display:none"></td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                            <td valign="top" align="left" style="padding:0;Margin:0;padding-left:10px;font-size:0px">
                                                                                <a href="#" target="_blank" style="-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;font-size:14px;text-decoration:none;color:#FFFFFF">
                                                                                    <img src="<?= base_url()  . get_settings('logo')  ?>" alt style="display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic" width="92">
                                                                                </a>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <!--[if mso]></td></tr></table><![endif]-->
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table class="es-content" cellspacing="0" cellpadding="0" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%">
                        <tr style="border-collapse:collapse">
                            <td align="center" style="padding:0;Margin:0">
                                <table class="es-content-body" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#FFFFFF;width:720px">
                                    <tr style="border-collapse:collapse">
                                        <td align="left" style="padding:0;Margin:0;padding-left:35px;padding-right:35px;padding-top:40px">
                                            <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                <tr style="border-collapse:collapse">
                                                    <td valign="top" align="center" style="padding:0;Margin:0;width:650px">
                                                        <table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="center" style="Margin:0;padding-top:10px;padding-bottom:10px;padding-left:35px;padding-right:35px;font-size:0"><a target="_blank" href="#" style="-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;font-size:16px;text-decoration:none;color:#ED8E20">
                                                                        <img src="<?= base_url() . EMAIL_ORDER_SUCCESS_IMG_PATH; ?>" alt style="display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic" width="120"></a></td>
                                                            </tr>
                                                            <tr style="border-collapse:collapse">
                                                                <td align="center" style="padding:0;Margin:0;padding-bottom:10px">
                                                                    <h2 style="Margin:0;line-height:36px;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;font-size:30px;font-style:normal;font-weight:bold;color:#333333"><?= $subject ?></h2>
                                                                </td>
                                                            </tr>
                                                            <tr style="border-collapse:collapse">
                                                                <td align="left" style="padding:0;Margin:0;padding-top:15px;padding-bottom:20px">
                                                                    <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#777777"><?= $user_msg ?></p>
                                                                    <?php if (isset($system_settings['is_rider_otp_setting_on']) && $system_settings['is_rider_otp_setting_on'] == '1') { ?>
                                                                        <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#777777"><?= $otp_msg ?></p><br>
                                                                        <div style="text-align: center;display: block;">
                                                                            <p style="background: #efefef;color: black;padding: 8px 36px;width: 80px;text-align: center;font-size: 20px;font-family: monospace;margin: 0;letter-spacing: 3px;"><?= $order_data['otp'] ?></p>
                                                                        </div>
                                                                    <?php } ?>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr style="border-collapse:collapse">
                            <td align="center" style="padding:0;Margin:0">
                                <table class="es-content-body" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#FFFFFF;width:720px">
                                    <tr style="border-collapse:collapse">
                                        <td align="left" bgcolor="#efefef" style="Margin:0;padding-top:10px;padding-bottom:10px;padding-left:35px;padding-right:35px;background-color:#EFEFEF">
                                            <!--[if mso]><table style="width:650px" cellpadding="0" cellspacing="0"><tr><td style="width:168px" valign="top"><![endif]-->
                                            <table cellpadding="0" cellspacing="0" class="es-left" align="left" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left">
                                                <tr style="border-collapse:collapse">
                                                    <td class="es-m-p0r es-m-p20b" align="center" style="padding:0;Margin:0;width:148px">
                                                        <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="center" style="padding:0;Margin:0">
                                                                    <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><strong>Name</strong></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td class="es-hidden" style="padding:0;Margin:0;width:20px"></td>
                                                </tr>
                                            </table>
                                            <table cellpadding="0" cellspacing="0" class="es-left" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left">
                                                <tr style="border-collapse:collapse">
                                                    <td class="es-m-p20b" align="center" style="padding:0;Margin:0;width:147px">
                                                        <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="center" style="padding:0;Margin:0">
                                                                    <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><strong>QTY</strong></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <table cellpadding="0" cellspacing="0" class="es-right" align="right" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:right">
                                                <tr style="border-collapse:collapse">
                                                    <td align="center" style="padding:0;Margin:0;width:147px">
                                                        <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="left" style="padding:0;Margin:0">
                                                                    <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><strong>Sub total</strong></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <!--[if mso]></td><td style="width:20px"></td><td style="width:147px" valign="top"><![endif]-->
                                            <!-- <table cellpadding="0" cellspacing="0" class="es-right d-none" align="right" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:right">
                                                <tr style="border-collapse:collapse">
                                                    <td align="center" style="padding:0;Margin:0;width:147px">
                                                        <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="left" style="padding:0;Margin:0">
                                                                    <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><strong>Tax Amount</strong></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table> -->
                                            <!--[if mso]></td></tr></table><![endif]-->
                                        </td>
                                    </tr>
                                    <?php foreach ($cart_data as $rows) {
                                        // echo "****rows***";print_r($rows);
                                        // foreach($rows as $row){ 
                                        //     echo "****row***";print_r($row);
                                    ?>
                                        <tr style="border-collapse:collapse">
                                            <td align="left" style="Margin:0;padding-top:5px;padding-bottom:5px;padding-left:10px;padding-right:10px">
                                                <!--[if mso]><table style="width:700px" cellpadding="0" cellspacing="0"><tr><td style="width:194px" valign="top"><![endif]-->
                                                <table cellpadding="0" cellspacing="0" class="es-left" align="left" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left">
                                                    <tr style="border-collapse:collapse">
                                                        <td class="es-m-p0r es-m-p20b" align="center" style="padding:0;Margin:0;width:174px">
                                                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="center" style="padding:0;Margin:0">
                                                                        <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><small><?= $rows['name'] ?></small></p>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                        <td class="es-hidden" style="padding:0;Margin:0;width:20px"></td>
                                                    </tr>
                                                </table>
                                                <!--[if mso]></td><td style="width:184px" valign="top"><![endif]-->
                                                <table cellpadding="0" cellspacing="0" class="es-left" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left">
                                                    <tr style="border-collapse:collapse">
                                                        <td class="es-m-p20b" align="center" style="padding:0;Margin:0;width:164px">
                                                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="center" style="padding:0;Margin:0">
                                                                        <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><?= (isset($rows['quantity'])) ? $rows['quantity'] : $rows['qty'] ?></p>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                        <td class="es-hidden" style="padding:0;Margin:0;width:20px"></td>
                                                    </tr>
                                                </table>
                                                <!-- <table cellpadding="0" cellspacing="0" class="es-left d-none" align="left" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left">
                                                    <tr style="border-collapse:collapse">
                                                        <td class="es-m-p20b" align="center" style="padding:0;Margin:0;width:164px">
                                                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0">
                                                                        <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><?= $settings['currency'] . ' ' . strval($rows['tax_amount']) ?></p>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                        <td class="es-hidden" style="padding:0;Margin:0;width:20px"></td>
                                                    </tr>
                                                </table> -->
                                                <table cellpadding="0" cellspacing="0" class="es-right" align="right" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:right">
                                                    <tr style="border-collapse:collapse">
                                                        <td align="center" style="padding:0;Margin:0;width:151px">
                                                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0">
                                                                        <p style="Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-size:16px;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif;line-height:24px;color:#333333"><?= $settings['currency'] . ' ' . $rows['sub_total'] ?></p>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>

                                            </td>
                                        </tr>
                                    <?php
                                    }
                                    // }
                                    ?>

                                    <tr style="border-collapse:collapse">
                                        <td align="left" style="padding:0;Margin:0;padding-top:10px;padding-left:35px;padding-right:35px">
                                            <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                <tr style="border-collapse:collapse">
                                                    <td valign="top" align="center" style="padding:0;Margin:0;width:650px">
                                                        <table style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;border-top:3px solid #EEEEEE;border-bottom:3px solid #EEEEEE" width="100%" cellspacing="0" cellpadding="0" role="presentation">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="right" style="Margin:0;padding-right:10px;padding-top:15px;padding-bottom:15px;padding-left:40px">
                                                                    <table style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:500px" class="cke_show_border" cellspacing="1" cellpadding="1" border="0" align="left" role="presentation">
                                                                        <tr style="border-collapse:collapse">
                                                                            <td width="80%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">Total (+)</h4>
                                                                            </td>
                                                                            <td width="20%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">&nbsp; &nbsp; &nbsp; &nbsp;<?= $settings['currency'] . ' ' . $order_data['total_amount'] ?></h4>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr style="border-collapse:collapse">
                                                                <td align="right" style="Margin:0;padding-right:10px;padding-top:15px;padding-bottom:15px;padding-left:40px">
                                                                    <table style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:500px" class="cke_show_border" cellspacing="1" cellpadding="1" border="0" align="left" role="presentation">
                                                                        <tr style="border-collapse:collapse">
                                                                            <td width="80%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif"><b>Delivery Charge (+)</b></h4>
                                                                            </td>
                                                                            <td width="20%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<?= $settings['currency'] . ' ' . $order_data['delivery_charge'] ?></h4>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <!-- <tr style="border-collapse:collapse">
                                                                <td align="right" style="Margin:0;padding-right:10px;padding-top:15px;padding-bottom:15px;padding-left:40px">
                                                                    <table style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:500px" class="cke_show_border" cellspacing="1" cellpadding="1" border="0" align="left" role="presentation">
                                                                        <tr style="border-collapse:collapse">
                                                                            <td width="80%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif"><b>Tax Amount (+)</b></h4>
                                                                            </td>
                                                                            <td width="20%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<?= $settings['currency'] .  ' ' . $order_data['tax_amount'] ?></h4>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr> -->
                                                            <tr style="border-collapse:collapse">
                                                                <td align="left" style="Margin:0;padding-right:10px;padding-top:15px;padding-bottom:15px;padding-left:40px">
                                                                    <table style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:500px" class="cke_show_border" cellspacing="1" cellpadding="1" border="0" align="left" role="presentation">
                                                                        <tr style="border-collapse:collapse">
                                                                            <td width="80%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">Discount (-)</h4>
                                                                            </td>
                                                                            <td width="20%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<?= $settings['currency'] . ' ' . $order_data['discount'] ?></h4>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr style="border-collapse:collapse">
                                                                <td align="left" style="Margin:0;padding-right:10px;padding-top:15px;padding-bottom:15px;padding-left:40px">
                                                                    <table style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:500px" class="cke_show_border" cellspacing="1" cellpadding="1" border="0" align="left" role="presentation">
                                                                        <tr style="border-collapse:collapse">
                                                                            <td width="80%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif"><b>Wallet Amount (-)</b></h4>
                                                                            </td>
                                                                            <td width="20%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<?= $settings['currency'] . ' ' . $order_data['wallet'] ?></h4>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr style="border-collapse:collapse">
                                                                <td align="left" style="Margin:0;padding-right:10px;padding-top:15px;padding-bottom:15px;padding-left:40px">
                                                                    <table style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:500px" class="cke_show_border" cellspacing="1" cellpadding="1" border="0" align="left" role="presentation">
                                                                        <tr style="border-collapse:collapse">
                                                                            <td width="80%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif"><b>Final Total</b></h4>
                                                                            </td>
                                                                            <td width="20%" style="padding:0;Margin:0">
                                                                                <h4 style="Margin:0;line-height:120%;mso-line-height-rule:exactly;font-family:'open sans', 'helvetica neue', helvetica, arial, sans-serif">&nbsp; &nbsp; &nbsp; &nbsp;<?= $settings['currency'] . ' ' . $order_data['total_payable'] ?></h4>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr style="border-collapse:collapse">
                                        <td align="left" style="Margin:0;padding-left:35px;padding-right:35px;padding-top:40px;padding-bottom:40px">
                                            <table class="m_4436399974316938904es-left" cellspacing="0" cellpadding="0" align="left" style="border-collapse:collapse;border-spacing:0px;float:left">
                                                <tr style="border-collapse:collapse">
                                                    <td class="m_4436399974316938904es-m-p20b" align="left" style="padding:0;Margin:0;width: 220px;">
                                                        <table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="border-collapse:collapse;border-spacing:0px">
                                                            <tbody>
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0;padding-bottom:15px">
                                                                        <h4 style="Margin:0;line-height:120%;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif">From</h4>
                                                                    </td>
                                                                </tr>
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0;padding-bottom:10px">
                                                                        <p style="Margin:0;font-size:16px;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif;line-height:24px;color:#333333"><b><small>Email:</small></b></p>
                                                                        <p style="Margin:0;font-size:16px;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif;line-height:24px;color:#333333"><small><?= $system_settings['support_email'] ?></small></p>
                                                                        <p style="Margin:0;font-size:16px;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif;line-height:24px;color:#333333"><b><small>Customer Care:</small></b></p>
                                                                        <p style="Margin:0;font-size:16px;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif;line-height:24px;color:#333333"><small><?= $system_settings['support_number'] ?></small></p>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td class="m_4436399974316938904es-m-p20b" align="left" style="padding:0;Margin:0;width: 220px;">
                                                        <table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="border-collapse:collapse;border-spacing:0px">
                                                            <tbody>
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0;padding-bottom:15px">
                                                                        <h4 style="Margin:0;line-height:120%;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif">Delivery Address</h4>
                                                                    </td>
                                                                </tr>
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0;padding-bottom:10px">
                                                                        <p style="Margin:0;font-size:16px;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif;line-height:24px;color:#333333"><?= $order_data['address'] ?></p>
                                                                    </td>

                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td class="m_4436399974316938904es-m-p20b" align="left" style="padding:0;Margin:0;width: 220px;">
                                                        <table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="border-collapse:collapse;border-spacing:0px">
                                                            <tbody>
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0;padding-bottom:15px">
                                                                        <h4 style="Margin:0;line-height:120%;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif">Payment Method</h4>
                                                                    </td>
                                                                </tr>
                                                                <tr style="border-collapse:collapse">
                                                                    <td align="left" style="padding:0;Margin:0;padding-bottom:10px">
                                                                        <p style="Margin:0;font-size:16px;font-family:'open sans','helvetica neue',helvetica,arial,sans-serif;line-height:24px;color:#333333"><?= $order_data['payment_method'] ?></p>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table cellpadding="0" cellspacing="0" class="es-footer" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%;background-color:transparent;background-repeat:repeat;background-position:center top">
                        <tr style="border-collapse:collapse">
                            <td align="center" style="padding:0;Margin:0">
                                <table class="es-footer-body" cellspacing="0" cellpadding="0" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#FFFFFF;width:720px">
                                    <tr style="border-collapse:collapse">
                                        <td align="left" style="Margin:0;padding-top:35px;padding-left:35px;padding-right:35px;padding-bottom:40px">
                                            <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                <tr style="border-collapse:collapse">
                                                    <td valign="top" align="center" style="padding:0;Margin:0;width:650px">
                                                        <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="center" style="padding:0;Margin:0;display:none"></td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table class="es-content" cellspacing="0" cellpadding="0" align="center" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%">
                        <tr style="border-collapse:collapse">
                            <td align="center" style="padding:0;Margin:0">
                                <table class="es-content-body" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:720px" cellspacing="0" cellpadding="0" align="center">
                                    <tr style="border-collapse:collapse">
                                        <td align="left" style="Margin:0;padding-left:20px;padding-right:20px;padding-top:30px;padding-bottom:30px">
                                            <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                <tr style="border-collapse:collapse">
                                                    <td valign="top" align="center" style="padding:0;Margin:0;width:680px">
                                                        <table width="100%" cellspacing="0" cellpadding="0" style="mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px">
                                                            <tr style="border-collapse:collapse">
                                                                <td align="center" style="padding:0;Margin:0;display:none"></td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</body>

</html>