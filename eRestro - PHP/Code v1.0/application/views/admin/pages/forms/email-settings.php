<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Email SMTP Settings</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Email settings</li>
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
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/email_settings/set_email_settings   '); ?>" method="POST" id="add_product_form" enctype="multipart/form-data">
                            <!-- card -->
                            <div class="card-body">
                                <p class="text-muted text-bold">Email SMTP settings, notifications and others related to email.</p>


                                <div class="form-group row align-items-center">
                                    <label for="email-set" class="control-label">Email <span class="text-danger text-sm">*</span></label>
                                    <div class="col-sm-12 col-md-12">
                                        <input type="text" name="email" class="form-control" id="email-set" value="<?= (isset($email_settings)) ? $email_settings['email'] : '' ?>" required="" dir="ltr">
                                        <div class="form-text text-muted">This is the email address that the contact and report emails will be sent to, aswell as being the from address in signup and notification emails.</div>
                                    </div>

                                </div>

                                <div class="form-group row align-items-center">
                                    <label for="password" class="col-form-label">Password <span class="text-danger text-sm">*</span></label>
                                    <div class="col-sm-6 col-md-12">
                                        <input type="text" name="password" class="form-control" id="password" value="<?= (isset($email_settings)) ? $email_settings['password'] : '' ?>" required="">
                                        <div class="form-text text-muted">Password of above given email.</div>
                                    </div>
                                </div>


                                <div class="form-group row align-items-center">
                                    <label for="smtp_host" class="col-form-label ">SMTP Host <span class="text-danger text-sm">*</span></label>
                                    <div class="col-sm-6 col-md-12">
                                        <input type="text" name="smtp_host" class="form-control" id="smtp_host" value="<?= (isset($email_settings)) ? $email_settings['smtp_host'] : '' ?>" required="">
                                        <div class="form-text text-muted">This is the host address for your smtp server, this is only needed if you are using SMTP as the Email Send Type.</div>
                                    </div>
                                </div>


                                <div class="form-group row align-items-center">
                                    <label for="smtp_port" class="col-form-label ">SMTP Port <span class="text-danger text-sm">*</span></label>
                                    <div class="col-sm-6 col-md-12">
                                        <input type="text" name="smtp_port" class="form-control" id="smtp_port" value="<?= (isset($email_settings)) ? $email_settings['smtp_port'] : '' ?>" required="">
                                        <div class="form-text text-muted">SMTP port this will provide your service provider.</div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-form-label">Email Content Type <span class="text-danger text-sm">*</span></label>
                                    <div class="col-sm-6 col-md-12">

                                        <select class="form-control" name="mail_content_type" id="mail_content_type">
                                            <option value="text" <?= (isset($email_settings) && $email_settings['mail_content_type'] == 'text') ? 'selected' : '' ?>>Text</option>
                                            <option value="html" <?= (isset($email_settings) && $email_settings['mail_content_type'] == 'html') ? 'selected' : '' ?>>HTML</option>
                                        </select>
                                        <div class="form-text text-muted">Text-plain or HTML content chooser.</div>
                                    </div>
                                </div>


                                <div class="form-group row">
                                    <label class="col-form-label">SMTP Encryption <span class="text-danger text-sm">*</span></label>
                                    <div class="col-sm-6 col-md-12">

                                        <select class="form-control" name="smtp_encryption" id="smtp_encryption">
                                            <option value="off" <?= (isset($email_settings) && $email_settings['smtp_encryption'] == 'off') ? 'selected' : '' ?>>off</option>
                                            <option value="ssl" <?= (isset($email_settings) && $email_settings['smtp_encryption'] == 'ssl') ? 'selected' : '' ?>>SSL</option>
                                            <option value="tls" <?= (isset($email_settings) && $email_settings['smtp_encryption'] == 'tls') ? 'selected' : '' ?>>TLS</option>
                                        </select>
                                        <div class="form-text text-muted">If your e-mail service provider supported secure connections, you can choose security method on list.</div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($email_settings)) ? 'Update Email Settings' : 'Add Email Settings' ?></button>
                                </div>

                                <!-- /.card-body -->
                                <div class="d-flex justify-content-center">
                                    <div id="error_box">
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <!--/.card-->
                </div>
                <!--/.col-md-12-->
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>