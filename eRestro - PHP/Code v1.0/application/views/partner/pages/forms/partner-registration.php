<div class="">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4 class="text text-info">Partner Registration <span class='text-danger text-sm'>DO NOT REFRESH OR RELOAD THIS PAGE</span></h4>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>

    <section class="content">
        <div class="container-fluid">
            <form class="form-horizontal" action="<?= base_url('partner/auth/create_partner'); ?>" method="POST" id='sign_up_restro_form'>
                <?php if (isset($user_data) && !empty($user_data)) { ?>
                    <input type="hidden" name="user_id" value="<?= $user_data['to_be_partner_id'] ?>">
                    <input type='hidden' name='user_name' value='<?= $user_data['to_be_partner_name'] ?>'>
                    <input type='hidden' name='user_mobile' value='<?= $user_data['to_be_partner_mobile'] ?>'>
                <?php
                } ?>
                <input type="hidden" name="working_time" id="working_time" value="">
                <div class="row">
                    <div class="col-md-12">
                        <div class="card card-info">
                            <div class="card-body">
                                <h4>Partner Details</h4>
                                <hr>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group ">
                                            <label for="name" class="col-sm-3 col-form-label">Name <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="partner_name" placeholder="Partner Name" name="partner_name" >
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="profile" class="col-sm-4 col-form-label">Partner Profile<span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                    <span class="text-danger">*Leave blank if there is no change</span>

                                                <input type="file" class="form-control" name="profile" id="profile" accept="image/*" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="description" class="col-sm-3 col-form-label">Description </label>
                                            <div class="col-sm-10">
                                                <textarea type="text" class="form-control" id="description" rows="5" placeholder="Short Description of Restro" name="description"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="cities" class="col-sm-2 col-form-label">City <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <select name="city" class="search_city w-100" id="deliverable_zipcodes">
                                                    <option value="">Select City</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="cooking_time" class="col-sm-8 col-form-label">Cooking Time <span class='text-danger text-sm'>*</span> <small>(Enter in Minutes)</small> </label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="cooking_time" id="cooking_time" placeholder="Food Preparation Time in Minutes" min="0">
                                            </div>
                                        </div>
                                        <!-- removed city -->
                                        <div class="row">
                                            <label class="text-danger mt-3">*Only Search Location, When Update is necessary</label>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-4 map-div">
                                                <label for="city_name">Search Reataurant Location</label>
                                                <input id="city-input" type="text" class="form-control" placeholder="Enter Partner Name" />
                                                </br>
                                                <span class="text text-primary">Search your partner name and you will get the location points(Latitude & Longitude) below.</span>
                                            </div>
                                            <div class="col-md-8">
                                                <div id="map"></div>
                                                <div id="infowindow-content">
                                                    <span id="place-name" class="title"></span><br />
                                                    <span id="place-address"></span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="latitude">Latitude <span class='text-danger text-sm'>*</span></label>
                                                    <input type="text" class="form-control" name="latitude" id="city_lat" autocomplete="off">
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="longitude">Longitude <span class='text-danger text-sm'>*</span></label>
                                                    <input type="text" class="form-control" name="longitude" id="city_long" autocomplete="off">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group ">
                                            <label for="type" class="col-sm-3 col-form-label">Type <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <select class='form-control' name='type'>
                                                    <option value='' >None</option>
                                                    <option value='1'>Veg</option>
                                                    <option value='2' >Non-Veg</option>
                                                    <option value='3' >Both</option>
                                                </select>
                                            </div>
                                        </div>

                                        <?php
                                        $timing = get_working_hour_html();
                                        ?>
                                        <div class="form-group">
                                            <label for="address" class="col-sm-4 col-form-label">Working Days <span class='text-danger text-sm'>*</span></label>
                                            <div id="hourForm" class="ml-3">
                                                <?= $timing ?>
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="address" class="col-sm-3 col-form-label">Address <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <textarea type="text" class="form-control" id="address" placeholder="Enter Address" name="address"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="address_proof" class="col-sm-3 col-form-label">Address Proof <span class='text-danger text-sm'>*</span> </label>
                                            <div class="col-sm-10">
                                                    <span class="text-danger">*Leave blank if there is no change</span>
                                                <input type="file" class="form-control" name="address_proof" id="address_proof" accept="image/*" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="card card-info">
                            <div class="card-body">
                                <h4>Owner Details</h4>
                                <hr>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group ">
                                            <label for="name" class="col-sm-3 col-form-label">Name <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="name" placeholder="Restro Owner Name" name="name" <?= (isset($user_data) && !empty($user_data) && !empty($user_data['to_be_partner_id'])) ? 'disabled' : ''; ?> value="<?= @$user_data['to_be_partner_name'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="mobile" class="col-sm-3 col-form-label">Mobile <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" id="mobile" placeholder="Enter Mobile" name="mobile" <?= (isset($user_data) && !empty($user_data) && !empty($user_data['to_be_partner_id'])) ? 'disabled' : ''; ?> value="<?= @$user_data['to_be_partner_mobile'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="email" class="col-sm-3 col-form-label">Email <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="email" class="form-control" id="email" placeholder="Enter Email" name="email" >
                                            </div>
                                        </div>
                                        <?php
                                        if ( empty($user_data)) {
                                        ?>
                                            <div class="form-group">
                                                <label for="password" class="col-sm-4 col-form-label">Password <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-10">
                                                    <input type="password" class="form-control" id="password" placeholder="Enter Passsword" name="password">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label for="confirm_password" class="col-sm-4 col-form-label">Confirm Password <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-10">
                                                    <input type="password" class="form-control" id="confirm_password" placeholder="Enter Confirm Password" name="confirm_password">
                                                </div>
                                            </div>
                                        <?php } ?>
                                        <div class="form-group ">
                                            <label for="national_identity_card" class="col-sm-6 col-form-label">National Identity Card <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                    <span class="text-danger">*Leave blank if there is no change</span>
                                                <input type="file" class="form-control" name="national_identity_card" id="national_identity_card" accept="image/*" />
                                            </div>
                                        </div>
                                        <!-- need to show commission percentage for admin so restro can get idea about commission -->
                                        <hr>
                                        <div class="form-group">
                                            <button type="reset" class="btn btn-warning">Reset</button>
                                            <button type="submit" class="btn btn-info" id="submit_btn">Register</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card card-info">
                            <div class="card-body">
                                <h4>Bank Details</h4>
                                <hr>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group ">
                                            <label for="tax_name" class="col-sm-4 col-form-label">Tax Name <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="tax_name" placeholder="Tax Name" name="tax_name" value="<?= @$fetched_data[0]['tax_name'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="tax_number" class="col-sm-4 col-form-label">Tax Number <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="tax_number" placeholder="Tax Number" name="tax_number" value="<?= @$fetched_data[0]['tax_number'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="account_number" class="col-sm-4 col-form-label">Account Number </label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="account_number" placeholder="Account Number" name="account_number" value="<?= @$fetched_data[0]['account_number'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="account_name" class="col-sm-6 col-form-label">Account Name </label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="account_name" placeholder="Account Name" name="account_name" value="<?= @$fetched_data[0]['account_name'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="bank_code" class="col-sm-4 col-form-label">Bank Code</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="bank_code" placeholder="Bank Code" name="bank_code" value="<?= @$fetched_data[0]['bank_code'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="bank_name" class="col-sm-4 col-form-label">Bank Name </label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="bank_name" placeholder="Bank Name" name="bank_name" value="<?= @$fetched_data[0]['bank_name'] ?>">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>