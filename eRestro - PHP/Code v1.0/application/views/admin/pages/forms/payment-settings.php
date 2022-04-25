<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Payment Methods Settings</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a>
                        </li>
                        <li class="breadcrumb-item active">Payment Methods Settings</li>
                    </ol>
                </div>
            </div>
        </div>
        <!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="card card-info">
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/Payment_settings/update_payment_settings'); ?>" method="POST" id="payment_setting_form">
                            <div class="card-body">
                                <div class="row">
                                    <div class="form-group col-md-4">
                                        <label for="paypal_payment_method">Paypal Payments <small>[ Enable / Disable ] </small>
                                        </label>
                                        <div class="card-body">
                                            <input type="checkbox" name="paypal_payment_method" <?= (@$settings['paypal_payment_method']) == '1' ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                        </div>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="">Payment Mode <small>[ sandbox / live ]</small>
                                        </label>
                                        <select name="paypal_mode" class="form-control" required>
                                            <option value="">Select Mode</option>
                                            <option value="sandbox" <?= (isset($settings['paypal_mode']) && $settings['paypal_mode'] == 'sandbox') ? 'selected' : '' ?>>Sandbox ( Testing )</option>
                                            <option value="production" <?= (isset($settings['paypal_mode']) && $settings['paypal_mode'] == 'production') ? 'selected' : '' ?>>Production ( Live )</option>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="paypal_business_email">Paypal Business Email</label>
                                        <input type="text" class="form-control" name="paypal_business_email" value="<?= (isset($settings['paypal_mode'])) ? $settings['paypal_business_email'] : '' ?>" placeholder="Paypal Business Email" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="currency_code">Currency code</label>
                                        <select class="form-control" name="currency_code" value="<?= @$settings['currency_code'] ?>">
                                            <option value="AUD" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "AUD") ? "selected" : '' ?>>AUD</option>
                                            <option value="BRL" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "BRL") ? "selected" : '' ?>>BRL</option>
                                            <option value="CAD" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "CAD") ? "selected" : '' ?>>CAD</option>
                                            <option value="CNY" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "CNY") ? "selected" : '' ?>>CNY</option>
                                            <option value="CZK" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "CZK") ? "selected" : '' ?>>CZK</option>
                                            <option value="DKK" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "DKK") ? "selected" : '' ?>>DKK</option>
                                            <option value="EUR" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "EUR") ? "selected" : '' ?>>EUR</option>
                                            <option value="HKD" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "HKD") ? "selected" : '' ?>>HKD</option>
                                            <option value="HUF" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "HUF") ? "selected" : '' ?>>HUF</option>
                                            <option value="INR" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "INR") ? "selected" : '' ?>>INR</option>
                                            <option value="ILS" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "ILS") ? "selected" : '' ?>>ILS</option>
                                            <option value="JPY" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "JPY") ? "selected" : '' ?>>JPY</option>
                                            <option value="MYR" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "MYR") ? "selected" : '' ?>>MYR</option>
                                            <option value="MXN" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "MXN") ? "selected" : '' ?>>MXN</option>
                                            <option value="TWD" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "TWD") ? "selected" : '' ?>>TWD</option>
                                            <option value="NZD" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "NZD") ? "selected" : '' ?>>NZD</option>
                                            <option value="NOK" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "NOK") ? "selected" : '' ?>>NOK</option>
                                            <option value="PHP" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "PHP") ? "selected" : '' ?>>PHP</option>
                                            <option value="PLN" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "PLN") ? "selected" : '' ?>>PLN</option>
                                            <option value="GBP" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "GBP") ? "selected" : '' ?>>GBP</option>
                                            <option value="RUB" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "RUB") ? "selected" : '' ?>>RUB</option>
                                            <option value="SGD" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "SGD") ? "selected" : '' ?>>SGD</option>
                                            <option value="SEK" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "SEK") ? "selected" : '' ?>>SEK</option>
                                            <option value="CHF" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "CHF") ? "selected" : '' ?>>CHF</option>
                                            <option value="THB" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "THB") ? "selected" : '' ?>>THB</option>
                                            <option value="USD" <?= (isset($settings["currency_code"]) && $settings["currency_code"] == "USD") ? "selected" : '' ?>>USD</option>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label>Notification URL <small>(Set this as IPN notification URL in you PayPal account)</small></label>
                                        <input type="text" class="form-control" readonly value="<?= base_url('app/v1/api/ipn') ?>" />
                                    </div>
                                </div>
                                <h5>Razorpay Payments </h5>
                                <hr>
                                <div class="row">
                                    <div class="form-group col-md-4">
                                        <label for="razorpay_payment_method">Razorpay Payments <small>[ Enable / Disable ] </small>
                                        </label>
                                        <br>
                                        <div class="card-body">
                                            <input type="checkbox" name="razorpay_payment_method" <?= (@$settings['razorpay_payment_method']) == '1' ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                        </div>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="razorpay_key_id">Razorpay key ID</label>
                                        <input type="text" class="form-control" name="razorpay_key_id" value="<?= @$settings['razorpay_key_id'] ?>" placeholder="Razor Key ID" />
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="razorpay_secret_key">Secret Key</label>
                                        <input type="text" class="form-control" name="razorpay_secret_key" value="<?= @$settings['razorpay_secret_key'] ?>" placeholder="Razorpay Secret Key " />
                                    </div>
                                </div>

                                <h5>Paystack Payments </h5>
                                <hr>
                                <div class="row">
                                    <div class="form-group col-md-4">
                                        <label for="paystack_payment_method">Paystack Payments <small>[ Enable / Disable ] </small>
                                        </label>
                                        <br>
                                        <div class="card-body">
                                            <input type="checkbox" name="paystack_payment_method" <?= (@$settings['paystack_payment_method']) == '1' ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                        </div>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="paystack_key_id">Paystack key ID</label>
                                        <input type="text" class="form-control" name="paystack_key_id" value="<?= @$settings['paystack_key_id'] ?>" placeholder="Paystack Public Key" />
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="paystack_secret_key">Secret Key</label>
                                        <input type="text" class="form-control" name="paystack_secret_key" value="<?= @$settings['paystack_secret_key'] ?>" placeholder="Paystack Secret Key " />
                                    </div>
                                </div>
                                <h5>Stripe Payments </h5>
                                <hr>
                                <div class="row">
                                    <div class="form-group col-md-4">
                                        <label for="stripe_payment_method">Stripe Payments <small>[ Enable / Disable ] </small></label>
                                        <div class="card-body">
                                            <input type="checkbox" name="stripe_payment_method" <?= (@$settings['stripe_payment_method']) == '1' ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                        </div>
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label for="">Payment Mode <small>[ sandbox / live ]</small>
                                        </label>
                                        <select name="stripe_payment_mode" class="form-control" required>
                                            <option value="">Select Mode</option>
                                            <option value="test" <?= (isset($settings['stripe_payment_mode']) && $settings['stripe_payment_mode'] == 'test') ? 'selected' : '' ?>>Test</option>
                                            <option value="live" <?= (isset($settings['stripe_payment_mode']) && $settings['stripe_payment_mode'] == 'live') ? 'selected' : '' ?>>Live</option>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-5">
                                        <label for="stripe_webhook_url">Payment Endpoint URL <small>(Set this as Endpoint URL in your Stripe account)</small></label>
                                        <input type="text" class="form-control" name="stripe_webhook_url" value="<?= base_url("app/v1/api/stripe-webhook"); ?>" disabled />
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label for="stripe_publishable_key">Stripe Publishable Key</label>
                                        <input type="text" class="form-control" name="stripe_publishable_key" value="<?= @$settings['stripe_publishable_key'] ?>" placeholder="Stripe Publishable Key" />
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label for="stripe_secret_key">Stripe Secret Key</label>
                                        <input type="text" class="form-control" name="stripe_secret_key" value="<?= @$settings['stripe_secret_key'] ?>" placeholder="Stripe Secret Key" />
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label for="stripe_webhook_secret_key">Stripe Webhook Secret Key</label>
                                        <input type="text" class="form-control" name="stripe_webhook_secret_key" value="<?= @$settings['stripe_webhook_secret_key'] ?>" placeholder="Stripe Webhook Secret Key" />
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label for="">Currency Code <small>[ Stripe supported ]</small> <a href="https://stripe.com/docs/currencies" target="_BLANK"><i class="fa fa-link"></i></a></label>
                                        <select name="stripe_currency_code" class="form-control">
                                            <option value="">Select Currency Code </option>
                                            <option value="INR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'INR') ? "selected" : "" ?>>Indian rupee </option>
                                            <option value="USD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'USD') ? "selected" : "" ?>>United States dollar </option>
                                            <option value="AED" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'AED') ? "selected" : "" ?>>United Arab Emirates Dirham </option>
                                            <option value="AFN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'AFN') ? "selected" : "" ?>>Afghan Afghani </option>
                                            <option value="ALL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ALL') ? "selected" : "" ?>>Albanian Lek </option>
                                            <option value="AMD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'AMD') ? "selected" : "" ?>>Armenian Dram </option>
                                            <option value="ANG" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ANG') ? "selected" : "" ?>>Netherlands Antillean Guilder </option>
                                            <option value="AOA" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'AOA') ? "selected" : "" ?>>Angolan Kwanza </option>
                                            <option value="ARS" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ARS') ? "selected" : "" ?>>Argentine Peso</option>
                                            <option value="AUD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'AUD') ? "selected" : "" ?>> Australian Dollar</option>
                                            <option value="AWG" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'AWG') ? "selected" : "" ?>> Aruban Florin</option>
                                            <option value="AZN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'AZN') ? "selected" : "" ?>> Azerbaijani Manat </option>
                                            <option value="BAM" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BAM') ? "selected" : "" ?>> Bosnia-Herzegovina Convertible Mark </option>
                                            <option value="BBD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BBD') ? "selected" : "" ?>> Bajan dollar </option>
                                            <option value="BDT" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BDT') ? "selected" : "" ?>> Bangladeshi Taka</option>
                                            <option value="BGN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BGN') ? "selected" : "" ?>> Bulgarian Lev </option>
                                            <option value="BIF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BIF') ? "selected" : "" ?>>Burundian Franc</option>
                                            <option value="BMD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BMD') ? "selected" : "" ?>> Bermudan Dollar</option>
                                            <option value="BND" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BND') ? "selected" : "" ?>> Brunei Dollar </option>
                                            <option value="BOB" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BOB') ? "selected" : "" ?>> Bolivian Boliviano </option>
                                            <option value="BRL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BRL') ? "selected" : "" ?>> Brazilian Real </option>
                                            <option value="BSD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BSD') ? "selected" : "" ?>> Bahamian Dollar </option>
                                            <option value="BWP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BWP') ? "selected" : "" ?>> Botswanan Pula </option>
                                            <option value="BZD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'BZD') ? "selected" : "" ?>> Belize Dollar </option>
                                            <option value="CAD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CAD') ? "selected" : "" ?>> Canadian Dollar </option>
                                            <option value="CDF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CDF') ? "selected" : "" ?>> Congolese Franc </option>
                                            <option value="CHF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CHF') ? "selected" : "" ?>> Swiss Franc </option>
                                            <option value="CLP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CLP') ? "selected" : "" ?>> Chilean Peso </option>
                                            <option value="CNY" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CNY') ? "selected" : "" ?>> Chinese Yuan </option>
                                            <option value="COP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'COP') ? "selected" : "" ?>> Colombian Peso </option>
                                            <option value="CRC" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CRC') ? "selected" : "" ?>> Costa Rican Colón </option>
                                            <option value="CVE" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CVE') ? "selected" : "" ?>> Cape Verdean Escudo </option>
                                            <option value="CZK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'CZK') ? "selected" : "" ?>> Czech Koruna </option>
                                            <option value="DJF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'DJF') ? "selected" : "" ?>> Djiboutian Franc </option>
                                            <option value="DKK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'DKK') ? "selected" : "" ?>> Danish Krone </option>
                                            <option value="DOP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'DOP') ? "selected" : "" ?>> Dominican Peso </option>
                                            <option value="DZD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'DZD') ? "selected" : "" ?>> Algerian Dinar </option>
                                            <option value="EGP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'EGP') ? "selected" : "" ?>> Egyptian Pound </option>
                                            <option value="ETB" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ETB') ? "selected" : "" ?>> Ethiopian Birr </option>
                                            <option value="EUR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'EUR') ? "selected" : "" ?>> Euro </option>
                                            <option value="FJD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'FJD') ? "selected" : "" ?>> Fijian Dollar </option>
                                            <option value="FKP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'FKP') ? "selected" : "" ?>> Falkland Island Pound </option>
                                            <option value="GBP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'GBP') ? "selected" : "" ?>> Pound sterling </option>
                                            <option value="GEL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'GEL') ? "selected" : "" ?>> Georgian Lari </option>
                                            <option value="GIP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'GIP') ? "selected" : "" ?>> Gibraltar Pound </option>
                                            <option value="GMD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'GMD') ? "selected" : "" ?>> Gambian dalasi </option>
                                            <option value="GNF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'GNF') ? "selected" : "" ?>> Guinean Franc </option>
                                            <option value="GTQ" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'GTQ') ? "selected" : "" ?>> Guatemalan Quetzal </option>
                                            <option value="GYD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'GYD') ? "selected" : "" ?>> Guyanaese Dollar </option>
                                            <option value="HKD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'HKD') ? "selected" : "" ?>> Hong Kong Dollar </option>
                                            <option value="HNL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'HNL') ? "selected" : "" ?>> Honduran Lempira </option>
                                            <option value="HRK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'HRK') ? "selected" : "" ?>> Croatian Kuna </option>
                                            <option value="HTG" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'HTG') ? "selected" : "" ?>> Haitian Gourde </option>
                                            <option value="HUF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'HUF') ? "selected" : "" ?>> Hungarian Forint </option>
                                            <option value="IDR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'IDR') ? "selected" : "" ?>> Indonesian Rupiah </option>
                                            <option value="ILS" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ILS') ? "selected" : "" ?>> Israeli New Shekel </option>
                                            <option value="ISK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ISK') ? "selected" : "" ?>> Icelandic Króna </option>
                                            <option value="JMD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'JMD') ? "selected" : "" ?>> Jamaican Dollar </option>
                                            <option value="JPY" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'JPY') ? "selected" : "" ?>> Japanese Yen </option>
                                            <option value="KES" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'KES') ? "selected" : "" ?>> Kenyan Shilling </option>
                                            <option value="KGS" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'KGS') ? "selected" : "" ?>> Kyrgystani Som </option>
                                            <option value="KHR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'KHR') ? "selected" : "" ?>> Cambodian riel </option>
                                            <option value="KMF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'KMF') ? "selected" : "" ?>> Comorian franc </option>
                                            <option value="KRW" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'KRW') ? "selected" : "" ?>> South Korean won </option>
                                            <option value="KYD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'KYD') ? "selected" : "" ?>> Cayman Islands Dollar </option>
                                            <option value="KZT" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'KZT') ? "selected" : "" ?>> Kazakhstani Tenge </option>
                                            <option value="LAK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'LAK') ? "selected" : "" ?>> Laotian Kip </option>
                                            <option value="LBP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'LBP') ? "selected" : "" ?>> Lebanese pound </option>
                                            <option value="LKR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'LKR') ? "selected" : "" ?>> Sri Lankan Rupee </option>
                                            <option value="LRD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'LRD') ? "selected" : "" ?>> Liberian Dollar </option>
                                            <option value="LSL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'LSL') ? "selected" : "" ?>>Lesotho loti </option>
                                            <option value="MAD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MAD') ? "selected" : "" ?>> Moroccan Dirham </option>
                                            <option value="MDL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MDL') ? "selected" : "" ?>> Moldovan Leu </option>
                                            <option value="MGA" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MGA') ? "selected" : "" ?>> Malagasy Ariary </option>
                                            <option value="MKD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MKD') ? "selected" : "" ?>> Macedonian Denar </option>
                                            <option value="MMK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MMK') ? "selected" : "" ?>> Myanmar Kyat </option>
                                            <option value="MNT" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MNT') ? "selected" : "" ?>> Mongolian Tugrik </option>
                                            <option value="MOP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MOP') ? "selected" : "" ?>> Macanese Pataca </option>
                                            <option value="MRO" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MRO') ? "selected" : "" ?>> Mauritanian Ouguiya </option>
                                            <option value="MUR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MUR') ? "selected" : "" ?>> Mauritian Rupee</option>
                                            <option value="MVR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MVR') ? "selected" : "" ?>> Maldivian Rufiyaa </option>
                                            <option value="MWK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MWK') ? "selected" : "" ?>> Malawian Kwacha </option>
                                            <option value="MXN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MXN') ? "selected" : "" ?>> Mexican Peso </option>
                                            <option value="MYR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MYR') ? "selected" : "" ?>> Malaysian Ringgit </option>
                                            <option value="MZN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'MZN') ? "selected" : "" ?>> Mozambican metical </option>
                                            <option value="NAD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'NAD') ? "selected" : "" ?>> Namibian dollar </option>
                                            <option value="NGN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'NGN') ? "selected" : "" ?>> Nigerian Naira </option>
                                            <option value="NIO" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'NIO') ? "selected" : "" ?>>Nicaraguan Córdoba </option>
                                            <option value="NOK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'NOK') ? "selected" : "" ?>> Norwegian Krone </option>
                                            <option value="NPR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'NPR') ? "selected" : "" ?>> Nepalese Rupee </option>
                                            <option value="NZD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'NZD') ? "selected" : "" ?>> New Zealand Dollar </option>
                                            <option value="PAB" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'PAB') ? "selected" : "" ?>> Panamanian Balboa </option>
                                            <option value="PEN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'PEN') ? "selected" : "" ?>> Sol </option>
                                            <option value="PGK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'PGK') ? "selected" : "" ?>> Papua New Guinean Kina </option>
                                            <option value="PHP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'PHP') ? "selected" : "" ?>>Philippine peso </option>
                                            <option value="PKR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'PKR') ? "selected" : "" ?>> Pakistani Rupee </option>
                                            <option value="PLN" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'PLN') ? "selected" : "" ?>> Poland złoty </option>
                                            <option value="PYG" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'PYG') ? "selected" : "" ?>> Paraguayan Guarani </option>
                                            <option value="QAR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'QAR') ? "selected" : "" ?>> Qatari Rial </option>
                                            <option value="RON" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'RON') ? "selected" : "" ?>>Romanian Leu </option>
                                            <option value="RSD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'RSD') ? "selected" : "" ?>> Serbian Dinar </option>
                                            <option value="RUB" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'RUB') ? "selected" : "" ?>> Russian Ruble </option>
                                            <option value="RWF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'RWF') ? "selected" : "" ?>> Rwandan franc </option>
                                            <option value="SAR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SAR') ? "selected" : "" ?>> Saudi Riyal </option>
                                            <option value="SBD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SBD') ? "selected" : "" ?>> Solomon Islands Dollar </option>
                                            <option value="SCR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SCR') ? "selected" : "" ?>>Seychellois Rupee </option>
                                            <option value="SEK" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SEK') ? "selected" : "" ?>> Swedish Krona </option>
                                            <option value="SGD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SGD') ? "selected" : "" ?>> Singapore Dollar </option>
                                            <option value="SHP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SHP') ? "selected" : "" ?>> Saint Helenian Pound </option>
                                            <option value="SLL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SLL') ? "selected" : "" ?>> Sierra Leonean Leone </option>
                                            <option value="SOS" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SOS') ? "selected" : "" ?>>Somali Shilling </option>
                                            <option value="SRD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SRD') ? "selected" : "" ?>> Surinamese Dollar </option>
                                            <option value="STD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'STD') ? "selected" : "" ?>> Sao Tome Dobra </option>
                                            <option value="SZL" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'SZL') ? "selected" : "" ?>> Swazi Lilangeni </option>
                                            <option value="THB" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'THB') ? "selected" : "" ?>> Thai Baht </option>
                                            <option value="TJS" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'TJS') ? "selected" : "" ?>> Tajikistani Somoni </option>
                                            <option value="TOP" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'TOP') ? "selected" : "" ?>> Tongan Paʻanga </option>
                                            <option value="TRY" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'TRY') ? "selected" : "" ?>> Turkish lira </option>
                                            <option value="TTD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'TTD') ? "selected" : "" ?>> Trinidad & Tobago Dollar </option>
                                            <option value="TWD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'TWD') ? "selected" : "" ?>> New Taiwan dollar </option>
                                            <option value="TZS" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'TZS') ? "selected" : "" ?>> Tanzanian Shilling </option>
                                            <option value="UAH" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'UAH') ? "selected" : "" ?>> Ukrainian hryvnia </option>
                                            <option value="UGX" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'UGX') ? "selected" : "" ?>> Ugandan Shilling </option>
                                            <option value="UYU" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'UYU') ? "selected" : "" ?>> Uruguayan Peso </option>
                                            <option value="UZS" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'UZS') ? "selected" : "" ?>> Uzbekistani Som </option>
                                            <option value="VND" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'VND') ? "selected" : "" ?>> Vietnamese dong </option>
                                            <option value="VUV" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'VUV') ? "selected" : "" ?>> Vanuatu Vatu </option>
                                            <option value="WST" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'WST') ? "selected" : "" ?>> Samoa Tala</option>
                                            <option value="XAF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'XAF') ? "selected" : "" ?>> Central African CFA franc </option>
                                            <option value="XCD" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'XCD') ? "selected" : "" ?>> East Caribbean Dollar </option>
                                            <option value="XOF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'XOF') ? "selected" : "" ?>> West African CFA franc </option>
                                            <option value="XPF" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'XPF') ? "selected" : "" ?>> CFP Franc </option>
                                            <option value="YER" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'YER') ? "selected" : "" ?>> Yemeni Rial </option>
                                            <option value="ZAR" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ZAR') ? "selected" : "" ?>> South African Rand </option>
                                            <option value="ZMW" <?= (isset($settings['stripe_currency_code']) && $settings['stripe_currency_code'] == 'ZMW') ? "selected" : "" ?>> Zambian Kwacha </option>
                                        </select>
                                    </div>
                                </div>

                                <h5>Flutterwave Payments </h5>
                                <hr>
                                <div class="row">
                                    <div class="form-group col-md-4">
                                        <label for="flutterwave_payment_method">Flutterwave Payments <small>[ Enable / Disable ] </small>
                                        </label>
                                        <br>
                                        <div class="card-body">
                                            <input type="checkbox" name="flutterwave_payment_method" <?= (@$settings['flutterwave_payment_method']) == '1' ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                        </div>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="flutterwave_public_key">Flutterwave Public Key</label>
                                        <input type="text" class="form-control" name="flutterwave_public_key" value="<?= @$settings['flutterwave_public_key'] ?>" placeholder="Flutterwave Public Key" />
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="flutterwave_secret_key">Secret Key</label>
                                        <input type="text" class="form-control" name="flutterwave_secret_key" value="<?= @$settings['flutterwave_secret_key'] ?>" placeholder="Flutterwave Secret Key " />
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="flutterwave_encryption_key">Flutterwave Encryption key</label>
                                        <input type="text" class="form-control" name="flutterwave_encryption_key" value="<?= @$settings['flutterwave_encryption_key'] ?>" placeholder="Flutterwave Encryption Key " />
                                    </div>
                                    <div class="form-group">
                                        <label for="flutterwave_currency_code">Currency Code <small>[ Flutterwave supported ]</small> </label>
                                        <select name="flutterwave_currency_code" class="form-control">
                                            <option value="">Select Currency Code </option>
                                            <option value="NGN" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'NGN') ? "selected" : "" ?>>Nigerian Naira</option>
                                            <option value="USD" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'USD') ? "selected" : "" ?>>United States dollar</option>
                                            <option value="TZS" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'TZS') ? "selected" : "" ?>>Tanzanian Shilling</option>
                                            <option value="SLL" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'SLL') ? "selected" : "" ?>>Sierra Leonean Leone</option>
                                            <option value="MUR" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'MUR') ? "selected" : "" ?>>Mauritian Rupee</option>
                                            <option value="MWK" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'MWK') ? "selected" : "" ?>>Malawian Kwacha </option>
                                            <option value="GBP" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'GBP') ? "selected" : "" ?>>UK Bank Accounts</option>
                                            <option value="GHS" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'GHS') ? "selected" : "" ?>>Ghanaian Cedi</option>
                                            <option value="RWF" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'RWF') ? "selected" : "" ?>>Rwandan franc</option>
                                            <option value="UGX" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'UGX') ? "selected" : "" ?>>Ugandan Shilling</option>
                                            <option value="ZMW" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'ZMW') ? "selected" : "" ?>>Zambian Kwacha</option>
                                            <option value="KES" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'KES') ? "selected" : "" ?>>Mpesa</option>
                                            <option value="ZAR" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'ZAR') ? "selected" : "" ?>>South African Rand</option>
                                            <option value="XAF" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'XAF') ? "selected" : "" ?>>Central African CFA franc</option>
                                            <option value="XOF" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'XOF') ? "selected" : "" ?>>West African CFA franc</option>
                                            <option value="AUD" <?= (isset($settings['flutterwave_currency_code']) && $settings['flutterwave_currency_code'] == 'AUD') ? "selected" : "" ?>>Australian Dollar</option>
                                        </select>
                                    </div>
                                </div>

                                <h5>Paytm Payments </h5>
                                <hr>
                                <div class="row">
                                    <div class="form-group col-md-4">
                                        <label for="paytm_payment_method">Paytm Payments <small>[ Enable / Disable ] </small>
                                        </label>
                                        <br>
                                        <div class="card-body">
                                            <input type="checkbox" name="paytm_payment_method" <?= (@$settings['paytm_payment_method']) == '1' ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                        </div>
                                    </div>
                                    <div class="form-group col-md-3">
                                        <label for="">Paytm Mode <small>[ sandbox / live ]</small>
                                        </label>
                                        <select name="paytm_payment_mode" class="form-control" required>
                                            <option value="">Select Mode</option>
                                            <option value="sandbox" <?= (isset($settings['paytm_payment_mode']) && $settings['paytm_payment_mode'] == 'sandbox') ? 'selected' : '' ?>>Sandbox</option>
                                            <option value="production" <?= (isset($settings['paytm_payment_mode']) && $settings['paytm_payment_mode'] == 'production') ? 'selected' : '' ?>>Production</option>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="paytm_merchant_key">Paytm Merchant Key </label>
                                        <input type="text" class="form-control" name="paytm_merchant_key" value="<?= @$settings['paytm_merchant_key'] ?>" placeholder="Paytm Merchant Key" />
                                    </div>
                                    <div class="form-group col-md-4">
                                        <label for="paytm_merchant_id">Paytm Merchant ID </label>
                                        <input type="text" class="form-control" name="paytm_merchant_id" value="<?= @$settings['paytm_merchant_id'] ?>" placeholder="Paytm Merchant ID" />
                                    </div>
                                    <?php
                                    if ($settings['paytm_payment_mode'] == 'production') {
                                    ?>
                                        <div class="form-group col-md-4">
                                            <label for="paytm_website">Paytm Website <small>[<a href="https://dashboard.paytm.com/next/apikeys?src=dev" target="_blank">click here</a> to know]</small></label>
                                            <input type="text" class="form-control" name="paytm_website" value="<?= @$settings['paytm_website'] ?>" placeholder="Paytm Website" />
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label for="paytm_industry_type_id">Industry Type ID <small>[<a href="https://dashboard.paytm.com/next/apikeys?src=dev" target="_blank">click here</a> to know]</small></label>
                                            <input type="text" class="form-control" name="paytm_industry_type_id" value="<?= @$settings['paytm_industry_type_id'] ?>" placeholder="Industry Type ID" />
                                        </div>
                                    <?php } else { ?>
                                        <div class="form-group col-md-4">
                                            <label for="paytm_website">Paytm Website <small>[<a href="https://dashboard.paytm.com/next/apikeys?src=dev" target="_blank">click here</a> to know]</small></label>
                                            <input type="text" class="form-control" name="paytm_website" placeholder="Paytm Website" />
                                        </div>
                                        <div class="form-group col-md-4">
                                            <label for="paytm_industry_type_id">Industry Type ID <small>[<a href="https://dashboard.paytm.com/next/apikeys?src=dev" target="_blank">click here</a> to know]</small></label>
                                            <input type="text" class="form-control" name="paytm_industry_type_id" placeholder="Industry Type ID" />
                                        </div>
                                    <?php } ?>
                                </div>
                                <h5>Cash On Delivery </h5>
                                <hr>
                                <div class="row">
                                    <div class="form-group col-md-4">
                                        <label for="cod_method">COD <small>[ Enable / Disable ] </small>
                                        </label>
                                        <br>
                                        <div class="card-body">
                                            <input type="checkbox" name="cod_method" <?= (@$settings['cod_method']) == '1' ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn">Update Payment Settings</button>
                                </div>
                            </div>
                            <div class="d-flex justify-content-center">
                                <div class="form-group" id="error_box">
                                </div>
                            </div>
                        </form>
                    </div>
                    <!--/.card-->
                </div>
                <!--/.col-md-12-->
            </div>
            <!-- /.row -->
        </div>
        <!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>