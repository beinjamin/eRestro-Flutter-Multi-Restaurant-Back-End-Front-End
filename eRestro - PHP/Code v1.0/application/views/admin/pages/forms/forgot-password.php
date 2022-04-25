<body class="hold-transition login-page">
  <div class="login-box">

    <!-- /.login-logo -->
    <div class="card">
      <div class="card-body login-card-body">
        <div class="login-logo">
          <a href="<?= base_url('admin') ?>"><img src="<?= base_url() . $logo ?>"></a>
        </div>
        <p class="login-box-msg">You forgot your password?<br>Here you can easily retrieve a new password.</p>

        <form action="<?= base_url('auth/forgot_password') ?>" id="forgot_password_page" method="POST">
          <div class="input-group mb-3">
            <input type="email" class="form-control" name="identity" placeholder="Email">
            <div class="input-group-append">
              <div class="input-group-text">
                <span class="fas fa-envelope"></span>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col-12">
              <button type="submit" class="btn btn-primary btn-block" id="submit_btn">Request new password</button>
            </div>
            <!-- /.col -->
          </div>
          <div class="col-md-12 col-6 text-danger text-center m-1" id="result"></div>
        </form>

        <p class="mt-3 mb-1">
          <a href="<?= base_url('admin/home/') ?>">Login</a>
        </p>
      </div>
      <!-- /.login-card-body -->
    </div>
  </div>