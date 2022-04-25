<div class="content-wrapper">
  <!-- Content Header (Page header) -->
  <!-- Main content -->
  <section class="content-header">
    <div class="container-fluid">
      <div class="row mb-2">
        <div class="col-sm-6">
          <h4>About Us</h4>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
            <li class="breadcrumb-item active">About Us</li>
          </ol>
        </div>
      </div>
    </div><!-- /.container-fluid -->
  </section>
  <section class="content">
    <div class="container-fluid">
      <div class="row">
        <div class="col-md-12">
          <div class="card card-info">
            <!-- form start -->
            <form class="form-horizontal form-submit-event" action="<?= base_url('admin/About_us/update-about-us-settings'); ?>" method="POST" enctype="multipart/form-data">
              <div class="card-body pad">
                <label for="other_images"> About Us </label>
                <div class="mb-3">
                  <textarea name="about_us_input_description" class="textarea text_editor" placeholder="Place some text here">
                          <?= @$about_us ?>
                        </textarea>
                </div>
                <div class="form-group">
                  <button type="reset" class="btn btn-warning">Reset</button>
                  <button type="submit" class="btn btn-info" id="submit_btn">Update About Us</button>
                </div>
              </div>
              <div class="d-flex justify-content-center">
                <div class="form-group" id="error_box">
                </div>
              </div>
              <!-- /.card-body -->              
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