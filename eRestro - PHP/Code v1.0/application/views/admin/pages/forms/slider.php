<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Slider Image For Add-on Offers and other benefits </h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Slider</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="modal fade" id='media-upload' tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLongTitle">Media</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12">
                    <div class="card card-info">
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/slider/add_slider'); ?>" method="POST" id="payment_setting_form" enctype="multipart/form-data">
                            <div class="card-body">

                                <div class="form-group">
                                    <?php if (isset($fetched_data[0]['id'])) {
                                    ?>
                                        <input type="hidden" name="edit_slider" value="<?= $fetched_data[0]['id'] ?>">
                                    <?php } ?>
                                    <label for="slider_type">Type <span class='text-danger text-sm'>*</span> </label>
                                    <select name="slider_type" id="slider_type" class="form-control type_event_trigger" required="">
                                        <option value=" ">Select Type</option>
                                        <option value="default" <?= (@$fetched_data[0]['type'] == "default") ? 'selected' : ' ' ?>>Default</option>
                                        <option value="categories" <?= (@$fetched_data[0]['type'] == "categories") ? 'selected' : ' ' ?>>Category</option>
                                        <option value="products" <?= (@$fetched_data[0]['type'] == "products") ? 'selected' : ' ' ?>>Product</option>
                                    </select>
                                </div>
                                <div id="type_add_html">
                                    <?php $hiddenStatus = (isset($fetched_data[0]['id']) && $fetched_data[0]['type']  == 'categories') ? '' : 'd-none' ?>
                                    <div class="form-group slider-categories <?= $hiddenStatus ?> ">

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
                                    <?php $hiddenStatus = (isset($fetched_data[0]['id']) && $fetched_data[0]['type']  == 'products') ? '' : 'd-none' ?>
                                    <div class="form-group row slider-products <?= $hiddenStatus ?>">
                                        <label for="product_id" class="control-label">Products <span class='text-danger text-sm'>*</span></label>
                                        <div class="col-md-12">
                                            <select name="product_id" class="search_product w-100" data-placeholder=" Type to search and select products" onload="multiselect()">
                                                <?php
                                                if (isset($fetched_data[0]['id']) && $fetched_data[0]['type']  == 'products') {
                                                    $product_details = fetch_details(['id' => $row['type_id']], 'products', 'id,name');
                                                    if (!empty($product_details)) {
                                                ?>
                                                        <option value="<?= $product_details[0]['id'] ?>" selected> <?= $product_details[0]['name'] ?></option>
                                                <?php
                                                    }
                                                }
                                                ?>
                                            </select>
                                        </div>
                                    </div>

                                </div>
                                <div class="form-group">
                                    <div><label for="image">Slider Image <span class='text-danger text-sm'>*</span> </label></div>
                                    <div class="col-sm-10">
                                        <div class='col-md-3'><a class="uploadFile img btn btn-info text-white btn-sm" data-input='image' data-isremovable='0' data-is-multiple-uploads-allowed='0' data-toggle="modal" data-target="#media-upload-modal" value="Upload Photo"><i class='fa fa-upload'></i> Upload</a></div>
                                        <?php
                                        if (file_exists(FCPATH  . @$fetched_data[0]['image']) && !empty(@$fetched_data[0]['image'])) {  ?>
                                            <input type="hidden" name="image" value='<?= $fetched_data[0]['image'] ?>'>
                                            <?php  $fetched_data[0]['image'] = get_image_url($fetched_data[0]['image'], 'thumb', 'sm');
                                        ?>
                                            <label class="text-danger mt-3">*Only Choose When Update is necessary</label>
                                            <div class="container-fluid row image-upload-section">
                                                <div class="col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image">
                                                    <div class='image-upload-div'><img class="img-fluid mb-2" src="<?= $fetched_data[0]['image'] ?>" alt="Image Not Found"></div>
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
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($fetched_data[0]['id'])) ? 'Update Slider' : 'Add Slider' ?></button>
                                </div>
                                <div class="d-flex justify-content-center">
                                    <div class="form-group" id="error_box">

                                    </div>
                                </div>
                            </div>
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