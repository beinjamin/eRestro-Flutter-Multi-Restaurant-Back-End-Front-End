<div class="login-box">

  <!-- /.login-logo -->
  <div class="card">
    <div class="card-body login-card-body">
      <div class="login-logo">
        <a href="<?= base_url('admin/login/forgot_password') ?>"><img src="<?= base_url() . $logo ?>"></a>
      </div>
      <p class="login-box-msg">You are only one step a way from your new password, recover your password now.</p>

      <form action="<?= base_url('auth/reset_password/') . $code ?>" method="post">
        <input type="hidden" name="user_id" value="<?= $user->id ?>">
        <div class="input-group mb-3">
          <input type="password" class="form-control" placeholder="Password">
          <div class="input-group-append">
            <div class="input-group-text">
              <span class="fas fa-lock"></span>
            </div>
          </div>
        </div>
        <div class="input-group mb-3">
          <input type="password" class="form-control" placeholder="Confirm Password">
          <div class="input-group-append">
            <div class="input-group-text">
              <span class="fas fa-lock"></span>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col-12">
            <button type="submit" class="btn btn-primary btn-block">Change password</button>
          </div>
          <!-- /.col -->
        </div>
      </form>

      <p class="mt-3 mb-1">
        <a href="https://adminlte.io/themes/v3/pages/examples/login.html">Login</a>
      </p>
    </div>
    <!-- /.login-card-body -->
  </div>
</div>