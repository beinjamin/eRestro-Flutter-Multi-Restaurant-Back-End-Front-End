<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4><?= isset($fetched_data[0]['id']) ? 'Update' : 'Add' ?> Partner</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Partner</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>

    <section class="content">
        <div class="container-fluid">
            <form class="form-horizontal form-submit-event" action="<?= base_url('admin/partners/add_partner'); ?>" method="POST" id="add_restro_form">
                <?php if (isset($fetched_data[0]['id'])) { ?>
                    <input type="hidden" name="edit_restro" value="<?= $fetched_data[0]['user_id'] ?>">
                    <input type="hidden" name="edit_restro_data_id" value="<?= $fetched_data[0]['id'] ?>">
                    <input type="hidden" name="old_address_proof" value="<?= $fetched_data[0]['address_proof'] ?>">
                    <input type="hidden" name="old_profile" value="<?= $fetched_data[0]['profile'] ?>">
                    <input type="hidden" name="old_national_identity_card" value="<?= $fetched_data[0]['national_identity_card'] ?>">
                <?php } ?>
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
                                                <input type="text" class="form-control" id="partner_name" placeholder="Restro Name" name="partner_name" value="<?= (isset($fetched_data[0]['partner_name']) && !empty($fetched_data[0]['partner_name'])) ? output_escaping($fetched_data[0]['partner_name']) : "" ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="profile" class="col-sm-4 col-form-label">Partner Profile<span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <?php if (isset($fetched_data[0]['profile']) && !empty($fetched_data[0]['profile'])) { ?>
                                                    <span class="text-danger">*Leave blank if there is no change</span>
                                                <?php } ?>
                                                <input type="file" class="form-control" name="profile" id="profile" accept="image/*" />
                                            </div>
                                        </div>
                                        <?php if (isset($fetched_data[0]['profile']) && !empty($fetched_data[0]['profile'])) { ?>
                                            <div class="form-group ">
                                                <div class="mx-auto product-image"><a href="<?= base_url($fetched_data[0]['profile']); ?>" data-toggle="lightbox" data-gallery="gallery_restro"><img src="<?= base_url($fetched_data[0]['profile']); ?>" class="img-fluid rounded"></a></div>
                                            </div>
                                        <?php } ?>
                                        <div class="form-group">
                                            <label for="description" class="col-sm-3 col-form-label">Description </label>
                                            <div class="col-sm-10">
                                                <textarea type="text" class="form-control" id="description" placeholder="Short Description of Restro" name="description"><?= isset($fetched_data[0]['description']) ? @$fetched_data[0]['description'] : ""; ?></textarea>
                                            </div>
                                        </div>
                                        <?php
                                        $city = (isset($fetched_data[0]['city']) &&  $fetched_data[0]['city'] != NULL) ?  $fetched_data[0]['city'] : "";
                                        ?>
                                        <div class="form-group">
                                            <label for="cities" class="col-sm-2 col-form-label">City <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <select name="city" class="search_city w-100" id="deliverable_zipcodes">
                                                    <option value="">Select City</option>
                                                    <?php
                                                    $city_name =  fetch_details("", 'cities', 'name,id', "", "", "", "", "id", $city);
                                                    foreach ($city_name as $row) {
                                                    ?>
                                                        <option value=<?= $row['id'] ?> <?= ($row['id'] == $city) ? 'selected' : ''; ?>> <?= $row['name'] ?></option>
                                                    <?php }
                                                    ?>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="cooking_time" class="col-sm-8 col-form-label">Cooking Time <span class='text-danger text-sm'>*</span> <small>(Enter in Minutes)</small> </label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="cooking_time" id="cooking_time" value="<?= @$fetched_data[0]['cooking_time'] ?>" placeholder="Food Preparation Time in Minutes" min="0">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="address" class="col-sm-3 col-form-label">Address <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <textarea type="text" class="form-control" id="address" placeholder="Enter Address" name="address"><?= @$fetched_data[0]['address'] ?></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="address_proof" class="col-sm-3 col-form-label">Address Proof <span class='text-danger text-sm'>*</span> </label>
                                            <div class="col-sm-10">
                                                <?php if (isset($fetched_data[0]['address_proof']) && !empty($fetched_data[0]['address_proof'])) { ?>
                                                    <span class="text-danger">*Leave blank if there is no change</span>
                                                <?php } ?>
                                                <input type="file" class="form-control" name="address_proof" id="address_proof" accept="image/*" />
                                            </div>
                                        </div>
                                        <?php if (isset($fetched_data[0]['address_proof']) && !empty($fetched_data[0]['address_proof'])) { ?>
                                            <div class="form-group">
                                                <div class="mx-auto product-image"><a href="<?= base_url($fetched_data[0]['address_proof']); ?>" data-toggle="lightbox" data-gallery="gallery_seller"><img src="<?= base_url($fetched_data[0]['address_proof']); ?>" class="img-fluid rounded"></a></div>
                                            </div>
                                        <?php } ?>
                                        <!-- removed city -->
                                        <div class="row">
                                            <label class="text-danger mt-3">*Only Search Location, When Update is necessary</label>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-4 map-div">
                                                <label for="city_name">Search Reataurant Location</label>
                                                <input id="city-input" type="text" class="form-control" placeholder="Enter Partner Name"  autocomplete="off"/>
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
                                                    <input type="text" class="form-control" name="latitude" id="city_lat" value="<?= @$fetched_data[0]['latitude'] ?>" autocomplete="off">
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="form-group">
                                                    <label for="longitude">Longitude <span class='text-danger text-sm'>*</span></label>
                                                    <input type="text" class="form-control" name="longitude" id="city_long" value="<?= @$fetched_data[0]['longitude'] ?>" autocomplete="off">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group ">
                                            <label for="type" class="col-sm-3 col-form-label">Type <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <select class='form-control' name='type'>
                                                    <option value='' <?= (isset($fetched_data[0]['type']) &&  $fetched_data[0]['type'] == '0') ? 'selected' : ''; ?>>None</option>
                                                    <option value='1' <?= (isset($fetched_data[0]['type']) &&  $fetched_data[0]['type'] == '1') ? 'selected' : ''; ?>>Veg</option>
                                                    <option value='2' <?= (isset($fetched_data[0]['type']) &&  $fetched_data[0]['type'] == '2') ? 'selected' : ''; ?>>Non-Veg</option>
                                                    <option value='3' <?= (isset($fetched_data[0]['type']) &&  $fetched_data[0]['type'] == '3') ? 'selected' : ''; ?>>Both</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="cities" class="col-sm-3 col-form-label">Select Tags</label>
                                            <div class="col-sm-10">
                                                <select name="restro_tags[]" class="search_tags w-100" multiple onload="multiselect()">
                                                    <?php if (isset($tags) && !empty($tags)) {
                                                        foreach ($tags as $row) { ?>
                                                            <option value=<?= $row['tag_id'] ?> selected> <?= $row['title'] ?></option>
                                                    <?php }
                                                    } ?>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label class="col-sm-3 col-form-label">Status <span class='text-danger text-sm'>*</span></label>
                                            <div id="status" class="btn-group col-sm-8">
                                                <label class="btn btn-default" data-toggle-class="btn-default" data-toggle-passive-class="btn-default">
                                                    <input type="radio" name="status" value="0" <?= (isset($fetched_data[0]['status']) && $fetched_data[0]['status'] == '0') ? 'Checked' : '' ?>> Deactive
                                                </label>
                                                <label class="btn btn-primary" data-toggle-class="btn-primary" data-toggle-passive-class="btn-default">
                                                    <input type="radio" name="status" value="1" <?= (isset($fetched_data[0]['status']) && $fetched_data[0]['status'] == '1') ? 'Checked' : '' ?>> Approved
                                                </label>
                                                <label class="btn btn-danger" data-toggle-class="btn-danger" data-toggle-passive-class="btn-default">
                                                    <input type="radio" name="status" value="2" <?= (isset($fetched_data[0]['status']) && $fetched_data[0]['status'] == '2') ? 'Checked' : '' ?>> Not-Approved
                                                </label>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <!-- what if we have many images? so give limit on listing images of gallery -->
                                            <label for="" class="col-sm-2 col-form-label"> Gallery </label>
                                            <div class="col-sm-12">
                                                <div class='col-md-3'><a class="uploadFile img btn btn-info text-white btn-sm" data-input='gallery[]' data-isremovable='1' data-is-multiple-uploads-allowed='1' data-toggle="modal" data-target="#media-upload-modal" value="Upload Photo"><i class='fa fa-upload'></i> Upload</a></div>
                                                <?php
                                                if (isset($fetched_data[0]['id']) && !empty($fetched_data[0]['id'])) {
                                                ?>
                                                    <div class="container-fluid row image-upload-section">
                                                        <?php
                                                        $gallery = json_decode($fetched_data[0]['gallery']);
                                                        if (!empty($gallery)) {
                                                            foreach ($gallery as $row) {
                                                        ?>
                                                                <div class="col-md-3 col-sm-12 shadow bg-white rounded m-3 p-3 text-center grow">
                                                                    <div class='image-upload-div'><img src="<?= BASE_URL()  . $row ?>" alt="Image Not Found"></div>
                                                                    <a href="javascript:void(0)" class="delete-img m-3" data-id="<?= $fetched_data[0]['id'] ?>" data-field="gallery" data-img="<?= $row ?>" data-table="partner_data" data-path="<?= $row ?>" data-isjson="true">
                                                                        <span class="btn btn-block bg-gradient-danger btn-xs"><i class="far fa-trash-alt "></i> Delete</span></a>
                                                                    <input type="hidden" name="gallery[]" value='<?= $row ?>'>
                                                                </div>
                                                        <?php
                                                            }
                                                        }
                                                        ?>
                                                    </div>
                                                <?php
                                                } else { ?>
                                                    <div class="container-fluid row image-upload-section">
                                                    </div>
                                                <?php } ?>
                                            </div>
                                        </div>
                                        <?php
                                        $restro_id = (isset($fetched_data[0]['user_id']) && !empty($fetched_data[0]['user_id'])) ? $fetched_data[0]['user_id'] : "";
                                        $timing = get_working_hour_html($restro_id);
                                        ?>
                                        <div class="form-group">
                                            <label for="address" class="col-sm-4 col-form-label">Working Days <span class='text-danger text-sm'>*</span></label>
                                            <div id="hourForm" class="ml-3">
                                                <?= $timing ?>
                                            </div>
                                        </div>
                                        <?php if (isset($fetched_data[0]['permissions']) && !empty($fetched_data[0]['permissions'])) {
                                            $permit = json_decode($fetched_data[0]['permissions'], true);
                                        } ?>
                                        <hr>
                                        <h4>Permissions </h4>
                                        <hr>
                                        <div class="form-group">
                                            <div class="row pt-2 mb-2">
                                                <label for="customer_privacy" class="col-sm-8 form-label">View Customer's Details? <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-1">
                                                    <input type="checkbox" name="customer_privacy" <?= (isset($permit['customer_privacy']) && $permit['customer_privacy'] == '1') ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                                </div>
                                            </div>
                                            <div class="row pt-2 mb-2">
                                                <label for="view_order_otp" class="col-sm-8 form-label">View Order's OTP? <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-1">
                                                    <input type="checkbox" name="view_order_otp" <?= (isset($permit['view_order_otp']) && $permit['view_order_otp'] == '1') ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                                </div>
                                            </div>
                                            <div class="row pt-2 mb-2">
                                                <label for="assign_rider" class="col-sm-8 form-label">Can assign Rider? & Can chnage deliver status? <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-1">
                                                    <input type="checkbox" name="assign_rider" <?= (isset($permit['assign_rider']) && $permit['assign_rider'] == '1') ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                                </div>
                                            </div>
                                            <div class="row pt-2 mb-2">
                                                <label for="is_email_setting_on" class="col-sm-8 form-label">Email Notification? <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-1">
                                                    <input type="checkbox" name="is_email_setting_on" <?= (isset($permit['is_email_setting_on']) && $permit['is_email_setting_on'] == '1') ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                                </div>
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
                                                <input type="text" class="form-control" id="name" placeholder="Restro Owner Name" name="name" value="<?= @$fetched_data[0]['username'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="mobile" class="col-sm-3 col-form-label">Mobile <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" id="mobile" placeholder="Enter Mobile" name="mobile" value="<?= @$fetched_data[0]['mobile'] ?>" min="0">
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="email" class="col-sm-3 col-form-label">Email <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="email" class="form-control" id="email" placeholder="Enter Email" name="email" value="<?= @$fetched_data[0]['email'] ?>">
                                            </div>
                                        </div>
                                        <?php
                                        if (!isset($fetched_data[0]['id'])) {
                                        ?>
                                            <div class="form-group">
                                                <label for="password" class="col-sm-4 col-form-label">Password <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-10">
                                                    <input type="password" class="form-control" id="password" placeholder="Enter Passsword" name="password" value="<?= @$fetched_data[0]['password'] ?>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label for="confirm_password" class="col-sm-4 col-form-label">Confirm Password <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-10">
                                                    <input type="password" class="form-control" id="confirm_password" placeholder="Enter Confirm Password" name="confirm_password">
                                                </div>
                                            </div>
                                        <?php
                                        }
                                        ?>

                                        <div class="form-group ">
                                            <label for="national_identity_card" class="col-sm-6 col-form-label">National Identity Card <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <?php if (isset($fetched_data[0]['national_identity_card']) && !empty($fetched_data[0]['national_identity_card'])) { ?>
                                                    <span class="text-danger">*Leave blank if there is no change</span>
                                                <?php } ?>
                                                <input type="file" class="form-control" name="national_identity_card" id="national_identity_card" accept="image/*" />
                                            </div>
                                        </div>
                                        <?php if (isset($fetched_data[0]['national_identity_card']) && !empty($fetched_data[0]['national_identity_card'])) { ?>
                                            <div class="form-group ">
                                                <div class="mx-auto product-image"><a href="<?= base_url($fetched_data[0]['national_identity_card']); ?>" data-toggle="lightbox" data-gallery="gallery_seller"><img src="<?= base_url($fetched_data[0]['national_identity_card']); ?>" class="img-fluid rounded"></a></div>
                                            </div>
                                        <?php } ?>
                                        <div class="form-group ">
                                            <label for="commission" class="col-sm-12 col-form-label">Admin Commission(%) <span class='text-danger text-sm'>*</span> <small>( Commission(%) to be given to the Super Admin on order.)</small> </label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" id="global_commission" placeholder="Enter Commission(%) to be given to the Super Admin on order." name="global_commission" value="<?= @$fetched_data[0]['commission'] ?>" step="any" min="0">
                                            </div>
                                        </div>
                                        <hr>
                                        <div class="form-group">
                                            <button type="reset" class="btn btn-warning">Reset</button>
                                            <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($fetched_data[0]['id'])) ? 'Update Partner' : 'Add Partner' ?></button>
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
                                        <div class="form-group ">
                                            <label for="pan_number" class="col-sm-4 col-form-label">Pan Number </label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="pan_number" placeholder="Pan Number" name="pan_number" value="<?= @$fetched_data[0]['pan_number'] ?>">
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