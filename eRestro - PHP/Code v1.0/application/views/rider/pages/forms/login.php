<?php if (ALLOW_MODIFICATION == 0) { ?>
    <div class="alert alert-warning">
        Note: If you cannot login here, please close the codecanyon frame by clicking on x Remove Frame button from top right corner on the page or <a href="<?= base_url('/admin') ?>" target="_blank" class="text-danger">>> Click here <<< /a>
    </div>
<?php } ?>
<div class="login-box">

    <!-- /.login-logo -->
    <div class="card container-fluid ">
        <div class="card-body login-card-body">
            <div class="login-logo">
                <a href="<?= base_url() . 'rider/login' ?>"><img src="<?= base_url() . $logo ?>"></a>
            </div>
            <p class="login-box-msg">Sign in to start your session</p>
            <form action="<?= base_url('rider/login/auth') ?>" class='form-submit-event' method="post">
                <div class="input-group mb-3">
                    <input type='hidden' name='<?= $this->security->get_csrf_token_name() ?>' value='<?= $this->security->get_csrf_hash() ?>'>
                    <input type="<?= $identity_column ?>" class="form-control" name="identity" placeholder="<?= ucfirst($identity_column)  ?>" <?= (ALLOW_MODIFICATION == 0) ? 'value="1234567890"' : 'value="1234567890"'; ?>>
                    <div class="input-group-append">
                        <div class="input-group-text">
                            <span class="fas <?= ($identity_column == 'email') ? 'fa-envelope' : 'fa-mobile' ?> "></span>
                        </div>
                    </div>
                </div>
                <div class="input-group mb-3">
                    <input type="password" class="form-control" name="password" placeholder="Password" <?= (ALLOW_MODIFICATION == 0) ? 'value="12345678"' : 'value="12345678"'; ?>>
                    <div class="input-group-append">
                        <div class="input-group-text">
                            <span class="fas fa-lock"></span>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-8">
                        <div class="icheck-info">
                            <input type="checkbox" name="remember" id="remember">
                            <label for="remember">
                                Remember Me
                            </label>
                        </div>
                    </div>
                    <!-- /.col -->
                    <div class="col-12">
                        <button type="submit" id="submit_btn" class="btn btn-info btn-block">Sign In</button>
                    </div>
                    <div class="justify-content-center mt-2 col-md-12">
                        <div class="form-group" id="error_box">
                        </div>
                    </div>
                </div>
            </form>
        </div>
        <!-- /.login-card-body -->
    </div>
</div>
<!-- /.login-box -->