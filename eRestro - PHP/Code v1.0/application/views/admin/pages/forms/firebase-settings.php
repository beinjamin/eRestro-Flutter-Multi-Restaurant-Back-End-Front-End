<div class="content-wrapper">
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Firebase Settings</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a  class="text text-info" href="<?= base_url('admin/home') ?>">Home</a>
                        </li>
                        <li class="breadcrumb-item active">Firebase Settings</li>
                    </ol>
                </div>
            </div>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="card card-info">
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/web-setting/store_firebase') ?>" method="POST" id="system_setting_form" enctype="multipart/form-data">
                            <div class="card-body">
                                <div class="row">
                                    <div class="form-group col-md-6">
                                        <label for="apiKey">apiKey <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="apiKey" value="<?= (isset($firebase_settings['apiKey'])) ? $firebase_settings['apiKey'] : '' ?>" placeholder="apiKey" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="authDomain">authDomain <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="authDomain" value="<?= (isset($firebase_settings['authDomain'])) ? $firebase_settings['authDomain'] : '' ?>" placeholder="authDomain" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="databaseURL">databaseURL <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="databaseURL" value="<?= (isset($firebase_settings['databaseURL'])) ? $firebase_settings['databaseURL'] : '' ?>" placeholder="databaseURL" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="projectId">projectId <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="projectId" value="<?= (isset($firebase_settings['projectId'])) ? $firebase_settings['projectId'] : '' ?>" placeholder="projectId" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="storageBucket">storageBucket <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="storageBucket" value="<?= (isset($firebase_settings['storageBucket'])) ? $firebase_settings['storageBucket'] : '' ?>" placeholder="storageBucket" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="messagingSenderId">messagingSenderId <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="messagingSenderId" value="<?= (isset($firebase_settings['messagingSenderId'])) ? $firebase_settings['messagingSenderId'] : '' ?>" placeholder="messagingSenderId" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="appId">appId <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="appId" value="<?= (isset($firebase_settings['appId'])) ? $firebase_settings['appId'] : '' ?>" placeholder="appId" />
                                    </div>
                                    <div class="form-group col-md-6">
                                        <label for="measurementId">measurementId <span class='text-danger text-xs'>*</span></label>
                                        <input type="text" class="form-control" name="measurementId" value="<?= (isset($firebase_settings['measurementId'])) ? $firebase_settings['measurementId'] : '' ?>" placeholder="measurementId" />
                                    </div>
                                    <div class="form-group">
                                        <button type="reset" class="btn btn-warning">Reset</button>
                                        <button type="submit" class="btn btn-success" id="submit_btn">Update Settings</button>
                                    </div>
                                </div>
                                <hr>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
    </section>
    <!-- /.content -->
</div>