<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Notification</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Send Notification</li>
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
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/Notification_settings/send_notifications'); ?>" method="POST" id="add_product_form" enctype="multipart/form-data">
                            <?php
                            if (isset($fetched_data[0]['id'])) {
                            ?>
                                <input type="hidden" id="edit_area" name="edit_notification" value="<?= @$fetched_data[0]['id'] ?>">
                                <input type="hidden" id="update_id" name="update_id" value="1">
                            <?php
                            }
                            ?>
                            <div class="card-body">
                                <div class="form-group">
                                    <label for="type" class="control-label">Type <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-md-12">
                                        <select name="type" id="type" class="form-control type_event_trigger" required="">
                                            <option value=" ">Select Type</option>
                                            <option value="default" <?= (@$fetched_data[0]['type'] == "default") ? 'selected' : ' ' ?>>Default</option>
                                            <option value="categories" <?= (@$fetched_data[0]['type'] == "categories") ? 'selected' : ' ' ?>>Category</option>
                                        </select>
                                    </div>
                                </div>
                                <div id="type_add_html">
                                    <?php $hiddenStatus = (isset($fetched_data[0]['id']) && $fetched_data[0]['type']  == 'categories') ? '' : 'd-none' ?>
                                    <div class="form-group notification-categories <?= $hiddenStatus ?> ">
                                        <label for="category_id"> Categories <span class='text-danger text-sm'>*</span></label>
                                        <select name="category_id" class="form-control">
                                            <option value="">Select category </option>
                                            <?php
                                            if (!empty($categories)) {
                                                foreach ($categories as $row) {
                                                    $selected = ($row['id'] == $fetched_data[0]['type_id'] && strtolower($fetched_data[0]['type']) == 'categories') ? 'selected' : '';
                                            ?>
                                                    <option value="<?= $row['id'] ?>" <?= $selected ?>> <?= $row['name'] ?></option>
                                            <?php
                                                }
                                            }
                                            ?>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="title" class="control-label ">Title <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-md-12">
                                        <input type="text" class="form-control" name="title" id="title" placeholder="Title" value="<?= (isset($fetched_data[0]['title']) ? $fetched_data[0]['title'] : '') ?>">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="message" class="control-label">Message <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-md-12">
                                        <textarea name='message' class="form-control" placeholder="Notification Message"></textarea>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="image_checkbox" id="image_checkbox">
                                        <span>Include Image</span>
                                    </div>
                                    <div class="col-md-12 d-none include_image">
                                        <label for="message" class="control-label">Image </label>
                                        <div class="col-sm-10">
                                            <div class='col-md-3'><a class="uploadFile img btn btn-primary text-white btn-sm" data-input='image' data-isremovable='1' data-is-multiple-uploads-allowed='0' data-toggle="modal" data-target="#media-upload-modal" value="Upload Photo"><i class='fa fa-upload'></i> Upload</a></div>
                                            <?php
                                            if (file_exists(FCPATH . @$fetched_data[0]['image']) && !empty(@$fetched_data[0]['image'])) {
                                            ?>
                                                <div class="container-fluid row image-upload-section">
                                                    <div class="col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image">
                                                        <div class='image-upload-div'><img class="img-fluid mb-2" src="<?= BASE_URL() . $fetched_data[0]['image'] ?>" alt="Image Not Found"></div>
                                                        <input type="hidden" name="image" value='<?= $fetched_data[0]['image'] ?>'>
                                                    </div>
                                                </div>
                                            <?php
                                            } else { ?>
                                                <div class="container-fluid row image-upload-section">
                                                    <div class="col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image d-none">
                                                    </div>
                                                </div>
                                            <?php } ?>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn">Send Notification</button>
                                </div>

                                <div class="d-flex justify-content-center">
                                    <div class="form-group" id="error_box">
                                    </div>
                                </div>
                        </form>
                    </div>
                    <!--/.card-->
                </div>
                <div class="col-md-12 main-content">
                    <div class="card content-area p-4">
                        <div class="card-head">
                            <h4 class="card-title">Notifation Details</h4>
                        </div>
                        <div class="card-innr">
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' data-toggle="table" data-url="<?= base_url('admin/Notification_settings/get_notification_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="asc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">ID</th>
                                        <th data-field="title" data-sortable="false">Title</th>
                                        <th data-field="type" data-sortable="false">Type</th>
                                        <th data-field="image" data-sortable="false" class="col-md-5">Image</th>
                                        <th data-field="message" data-sortable="false">Message</th>
                                        <th data-field="operate" data-sortable="true">Actions</th>
                                    </tr>
                                </thead>
                            </table>
                        </div><!-- .card-innr -->
                    </div><!-- .card -->
                </div>
            </div>
            <!-- /.row -->
        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>