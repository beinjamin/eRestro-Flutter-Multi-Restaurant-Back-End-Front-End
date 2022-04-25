<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="card card-info">
                        <!-- form start -->
                        <form class="form-submit-event" action="<?= base_url('rider/login/update_user') ?>" method="POST">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <label class="h5">Commission Method: <span class="text text-info"><?= (!empty($users->commission_method)) ? str_replace("_", " ", ucwords($users->commission_method)) : "" ?> </span></label>
                                        <?php if (!empty($users->commission_method) && $users->commission_method == "fixed_commission_per_order") { ?>
                                            <label class="h5">Commission: <span class="text text-info"><?= $users->commission . "(" . $curreny . ")" ?> </span></label>
                                        <?php } ?>
                                        <?php if (!empty($users->commission_method) && $users->commission_method == "percentage_on_delivery_charges") { ?>
                                            <label class="h5">Commission: <span class="text text-info"><?= $users->commission . "(%)" ?> </span></label>
                                        <?php } ?>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col">
                                        <?php $city_name = fetch_details(['id' => $users->city], "cities", "name"); ?>
                                        <label class="h5">Servicing City: <span class="text text-info"><?= (isset($city_name) && !empty($city_name)) ? $city_name[0]['name'] : ""; ?> </span></label>
                                        <p class="text text-info">If you want to change servicing city then please contact super system.</p>
                                    </div>
                                </div>
                                <hr>
                                <div class="form-group row">
                                    <label for="username" class="col-sm-2 col-form-label">Name <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-sm-10">
                                        <input type="text" class="form-control" id="username" placeholder="Type Password here" name="username" value="<?= $users->username ?>">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <?php if ($identity_column == 'email') { ?>
                                        <label for="email" class="col-sm-2 col-form-label">Email <span class='text-danger text-sm'>*</span></label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" id="email" placeholder="Type Password here" name="email" value="<?= $users->email ?>">
                                        </div>
                                    <?php } else { ?>
                                        <label for="mobile" class="col-sm-2 col-form-label">Mobile <span class='text-danger text-sm'>*</span></label>
                                        <div class="col-sm-10">
                                            <input type="number" class="form-control" id="mobile" placeholder="Type Password here" name="mobile" value="<?= $users->mobile ?>" readonly>
                                        </div>
                                    <?php } ?>
                                </div>
                                <div class="form-group row">
                                    <label for="old" class="col-sm-2 col-form-label">Old Password</label>
                                    <div class="col-sm-10">
                                        <input type="password" class="form-control" id="old" placeholder="Type Password here" name="old">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="new" class="col-sm-2 col-form-label">New Password</label>
                                    <div class="col-sm-10">
                                        <input type="password" class="form-control" id="new" placeholder="Type Password here" name="new">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="new_confirm" class="col-sm-2 col-form-label">Confirm New Password</label>
                                    <div class="col-sm-10">
                                        <input type="password" class="form-control" id="new_confirm" placeholder="Type Confirm Password here" name="new_confirm">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="address" class="col-sm-2 col-form-label">Address <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-sm-10">
                                        <input type="text" class="form-control" id="address" placeholder="Enter Address" name="address" value="<?= $users->address ?>">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-2 col-form-label">Status <span class='text-danger text-sm'>*</span></label>
                                    <div id="active" class="btn-group col-sm-8">
                                        <label class="btn btn-default" data-toggle-class="btn-default" data-toggle-passive-class="btn-default">
                                            <input type="radio" name="active" value="0" <?= (isset($users->active) && $users->active == '0') ? 'Checked' : '' ?>> Deactive
                                        </label>
                                        <label class="btn btn-primary" data-toggle-class="btn-primary" data-toggle-passive-class="btn-default">
                                            <input type="radio" name="active" value="1" <?= (isset($users->active) && $users->active == '1') ? 'Checked' : '' ?>> Active
                                        </label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn">Update Profile</button>
                                </div>

                            </div>
                            <div class="d-flex justify-content-center">
                                <div class="form-group" id="error_box">
                                </div>
                            </div>

                            <!-- /.card-footer -->
                        </form>
                    </div>
                    <!--/.card-->
                </div>
                <!--/.col-md-12-->
            </div>
            <!-- /.row -->
        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>