<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4><?= isset($product_details[0]['id']) ? 'Update' : 'Add' ?> Product</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('partner/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Products</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <form class="form-horizontal" action="<?= base_url('partner/product/add_product'); ?>" method="POST" enctype="multipart/form-data" id="save-product">
                <?php if (isset($product_details[0]['id'])) {
                ?>
                    <input type="hidden" name="edit_product_id" value="<?= (isset($product_details[0]['id'])) ? $product_details[0]['id'] : "" ?>">
                <?php } ?>
                <input type="hidden" name="product_add_ons" id="product_add_ons" value="">

                <div class="row">
                    <div class="col-md-6">
                        <div class="card card-info">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group ">
                                            <label for="name" class="col-sm-3 col-form-label">Name <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-12">
                                                <input type="text" class="form-control" id="pro_input_text" placeholder="Product Name" name="pro_input_name" value="<?= @$product_details[0]['name'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="partners" class="col-sm-4 col-form-label">Select Category <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-12">
                                                <select class="search_category select_multiple" name="product_category_id" data-placeholder=" Type to search and select Category">
                                                    <option value=""></option>
                                                    <?php if (isset($categories) && !empty($categories)) {
                                                        foreach ($categories as $category) { ?>
                                                            <option value='<?= $category['id'] ?>' <?= ($category['id'] == @$product_details[0]['category_id']) ? 'selected' : ''; ?>><?= $category['name'] ?></option>
                                                    <?php }
                                                    } ?>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="pro_short_description" class="col-sm-4 col-form-label">Short Description <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-12">
                                                <textarea type="text" class="form-control" id="short_description" placeholder="Product Short Description" name="short_description"><?= isset($product_details[0]['short_description']) ? output_escaping(str_replace('\r\n', '&#13;&#10;', $product_details[0]['short_description'])) : ""; ?></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="pro_input_tax" class="col-sm-3 col-form-label">Tax </label>
                                            <div class="col-sm-12">
                                                <select class='form-control' name='pro_input_tax' id="pro_input_tax">
                                                    <?php if (empty($taxes)) { ?>
                                                        <option value="0" selected> No Taxes Were Added </option>
                                                    <?php } ?>
                                                    <?php foreach ($taxes as $row) { ?>
                                                        <option value="<?= $row['id'] ?>" <?= (isset($product_details[0]['tax']) && $product_details[0]['tax'] == $row['id']) ? 'selected' : "" ?>><?= $row['title'] ?></option>
                                                    <?php } ?>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="col-md-12 row">
                                            <div class="form-group ">
                                                <label for="is_prices_inclusive_tax" class="col-12 col-form-label">Tax included in prices?</label>
                                                <div class="col-12">
                                                    <input type="checkbox" name="is_prices_inclusive_tax" <?= (isset($product_details[0]['is_prices_inclusive_tax']) && $product_details[0]['is_prices_inclusive_tax'] == '1') ? 'checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success" data-on-text="Yes" data-off-text="No">
                                                </div>
                                            </div>
                                            <div class="form-group ">
                                                <label for="is_cod_allowed" class="col-12 col-form-label">Is COD allowed?</label>
                                                <div class="col-12">
                                                    <input type="checkbox" name="cod_allowed" <?= (isset($product_details[0]['cod_allowed']) && $product_details[0]['cod_allowed'] == '1') ? 'Checked' : '' ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                                </div>
                                            </div>
                                            <div class="form-group ">
                                                <label for="is_cancelable" class="col-12 col-form-label">Is Cancelable ?</label>
                                                <div class="col-12">
                                                    <input type="checkbox" name="is_cancelable" id="is_cancelable" class="switch" <?= (isset($product_details[0]['is_cancelable']) && $product_details[0]['is_cancelable'] == '1') ? 'Checked' : ''; ?> data-bootstrap-switch data-off-color="danger" data-on-color="success">
                                                </div>
                                            </div>
                                            <div class="form-group <?= (isset($product_details[0]['is_cancelable']) && $product_details[0]['is_cancelable'] == 1) ? '' : 'collapse' ?>" id='cancelable_till'>
                                                <label for="cancelable_till" class=" col-12 col-form-label">Till which status ? <span class='text-danger text-sm'>*</span></label>
                                                <select class='form-control' name="cancelable_till">
                                                    <option value='pending' <?= (isset($product_details[0]['cancelable_till']) && $product_details[0]['cancelable_till'] == 'pending') ? 'selected' : '' ?>>Pending</option>
                                                    <option value='confirmed' <?= (isset($product_details[0]['cancelable_till']) && $product_details[0]['cancelable_till'] == 'confirmed') ? 'selected' : '' ?>>Confirmed</option>
                                                    <option value='preparing' <?= (isset($product_details[0]['cancelable_till']) && $product_details[0]['cancelable_till'] == 'preparing') ? 'selected' : '' ?>>Preparing</option>
                                                    <option value='out_for_delivery' <?= (isset($product_details[0]['cancelable_till']) && $product_details[0]['cancelable_till'] == 'out_for_delivery') ? 'selected' : '' ?>>Out For Delivery</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="image" class="col-sm-3 col-form-label">Main Image <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-12">
                                                <div class='col-md-3'><a class="uploadFile img btn btn-info text-white btn-sm" data-input='pro_input_image' data-isremovable='0' data-is-multiple-uploads-allowed='0' data-toggle="modal" data-target="#media-upload-modal" value="Upload Photo"><i class='fa fa-upload'></i> Upload</a></div>
                                                <?php if (isset($product_details[0]['id']) && !empty($product_details[0]['id'])) { ?>
                                                    <label class="text-danger mt-3">*Only Choose When Update is necessary</label>
                                                    <div class="container-fluid row image-upload-section ">
                                                        <div class="col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image">
                                                            <div class='image-upload-div'><img class="img-fluid mb-2" src="<?= BASE_URL() . $product_details[0]['image'] ?>" alt="Image Not Found"></div>
                                                            <input type="hidden" name="pro_input_image" value='<?= $product_details[0]['image'] ?>'>
                                                        </div>
                                                    </div>
                                                <?php } else { ?>
                                                    <div class="container-fluid row image-upload-section">
                                                        <div class="col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image d-none">
                                                        </div>
                                                    </div>
                                                <?php } ?>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card card-info">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group ">
                                            <label for="cities" class="col-sm-2 col-form-label">Select Tags <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-12">
                                                <select name="tags[]" class="search_tags w-100" multiple onload="multiselect()">
                                                    <option value="">Select Tags for Product</option>
                                                    <?php foreach ($tags as $row) { ?>
                                                        <option value=<?= $row['tag_id'] ?> selected> <?= output_escaping($row['title']) ?></option>
                                                    <?php } ?>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="indicator" class="col-sm-3 col-form-label">Indicator </label>
                                            <div class="col-sm-12">
                                                <select class='form-control' name='indicator'>
                                                    <option value='0' <?= (isset($product_details[0]['indicator']) &&  $product_details[0]['indicator'] == '0') ? 'selected' : ''; ?>>None</option>
                                                    <option value='1' <?= (isset($product_details[0]['indicator']) &&  $product_details[0]['indicator'] == '1') ? 'selected' : ''; ?>>Veg</option>
                                                    <option value='2' <?= (isset($product_details[0]['indicator']) &&  $product_details[0]['indicator'] == '2') ? 'selected' : ''; ?>>Non-Veg</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-md-12">
                                                <label for="highlights">Highlights <small>( These highlights will show near product title )</small></label>
                                                <input name='highlights' class='' id='highlights' placeholder="Type in some highlights for example Spicy,Sweet,Must Try etc" value="<?= (isset($product_details[0]['highlights']) && !empty($product_details[0]['highlights'])) ? $product_details[0]['highlights'] : "" ?>" />
                                            </div>
                                        </div>
                                        <div class="form-group ">
                                            <label for="calories" class="col-sm-6 col-form-label">Calories <small>(1 kilocalorie (kcal) = 1000 calories (cal))</small></label>
                                            <div class="col-sm-12">
                                                <input type="text" class="form-control" id="calories" placeholder="Enter calories in cal unit" name="calories" value="<?= @$product_details[0]['calories'] ?>">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="total_allowed_quantity" class="col-sm-4 col-form-label">Total Allowed Quantity</label>
                                            <div class="col-sm-12">
                                                <input type="number" class="form-control" name="total_allowed_quantity" value="<?= (isset($product_details[0]['total_allowed_quantity'])) ? $product_details[0]['total_allowed_quantity'] : ''; ?>" placeholder='Total Allowed Quantity' min="0">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="minimum_order_quantity" class="col-sm-4 col-form-label">Minimum Order Quantity</label>
                                            <div class="col-sm-12">
                                                <input type="number" class="form-control" name="minimum_order_quantity" min="1" value="<?= (isset($product_details[0]['minimum_order_quantity'])) ? $product_details[0]['minimum_order_quantity'] : 1; ?>" placeholder='Minimum Order Quantity' min="0">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="quantity_step_size" class="col-sm-4 col-form-label">Quantity Step Size</label>
                                            <div class="col-sm-12">
                                                <input type="number" class=" form-control" name="quantity_step_size" min="1" value="<?= (isset($product_details[0]['quantity_step_size'])) ? $product_details[0]['quantity_step_size'] : 1; ?>" placeholder='Quantity Step Size' min="0">
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12">
                        <div class="card card-info">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="card-header  border-0 h5">Product Add Ons</div>
                                        <input type="hidden" class="form-control" id="add_on_id" name="add_on_id" value="">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label for="add_on_snaps" class="col-sm-4 col-form-label">Choose Add Ons </label>
                                                <div class="col-sm-12">
                                                    <select class=" select_multiple" name="add_on_snaps" id="add_on_snaps" data-placeholder=" Type to search and select Category">
                                                        <option value=""></option>
                                                        <?php if (isset($add_on_snaps) && !empty($add_on_snaps)) {
                                                            foreach ($add_on_snaps as $add_on_snap) { ?>
                                                                <option value='<?= $add_on_snap['title'] ?>' data-price="<?= $add_on_snap['price'] ?>" data-description="<?= $add_on_snap['description'] ?>" data-calories="<?= $add_on_snap['calories'] ?>"><?= $add_on_snap['title'] ?></option>
                                                        <?php }
                                                        } ?>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group ">
                                                <label for="title" class="col-sm-3 col-form-label">Title <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-12">
                                                    <input type="text" class="form-control" id="add_on_title" placeholder="Add ON Title" name="title">
                                                </div>
                                            </div>
                                            <div class="form-group ">
                                                <label for="description" class="col-sm-4 col-form-label">Short Description </label>
                                                <div class="col-sm-12">
                                                    <textarea type="text" class="form-control" id="add_on_description" placeholder="Add Ons Short Description" name="description"></textarea>
                                                </div>
                                            </div>
                                            <div class="form-group ">
                                                <label for="price" class="col-sm-3 col-form-label">Price <span class='text-danger text-sm'>*</span></label>
                                                <div class="col-sm-12">
                                                    <input type="number" class="form-control" id="add_on_price" placeholder="Add ON Price" name="price" min="0">
                                                </div>
                                            </div>
                                            <div class="form-group ">
                                                <label for="add_on_calories" class="col-sm-3 col-form-label">Calories </label>
                                                <div class="col-sm-12">
                                                    <input type="number" class="form-control" id="add_on_calories" placeholder="Add On Calories" name="add_on_calories" min="0">
                                                </div>
                                            </div>
                                            <div class="form-group ">
                                                <div class="col-sm-12">
                                                    <?php if (isset($product_details[0]['id']) && !empty($product_details[0]['id'])) { ?>
                                                        <a href="javascript:void(0);" class="btn btn-warning" id="update_add_ons" data-product_id=<?= $product_details[0]['id'] ?>>Update Add Ons</a>
                                                        <a href="javascript:void(0);" class="btn btn-info" id="add_new_add_ons" data-product_id=<?= $product_details[0]['id'] ?>>Insert Add Ons</a>
                                                    <?php } else { ?>
                                                        <a href="javascript:void(0);" class="btn btn-info btn-sm" id="save_add_ons">Save Add Ons</a>
                                                        <small class="text text-danger">Click on <strong> Add Product</strong> to save the Add Ons for this product after filling remaining details. </small>
                                                    <?php } ?>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <?php if (isset($product_details[0]['id']) && !empty($product_details[0]['id'])) { ?>
                                        <div class="col-md-6">
                                            <div class="card-header bg-white border-0 h5">Select Add On for Update</div>
                                            <table class='table-striped' id='add_ons_table' data-toggle="table" data-url="<?= base_url('admin/product/get_product_add_ons?product_id=' . $product_details[0]['id']) ?>" data-side-pagination="server" data-click-to-select="true" data-pagination="true" data-id-field="id" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="asc" data-mobile-responsive="true" data-toolbar="#toolbar" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-query-params="queryParams">
                                                <thead>
                                                    <tr>
                                                        <th data-field="state" data-radio='true'></th>
                                                        <th data-field="id" data-sortable="true" data-visible="false">ID</th>
                                                        <th data-field="product_id" data-visible="false" data-sortable="false">Product Id</th>
                                                        <th data-field="title" data-sortable="true">Title</th>
                                                        <th data-field="description" data-sortable="true">Description</th>
                                                        <th data-field="price" data-sortable="true">Price</th>
                                                        <th data-field="calories" data-sortable="true">Calories</th>
                                                        <th data-field="status" data-sortable="true">Status</th>
                                                        <th data-field="actions" data-sortable="true">Action</th>
                                                    </tr>
                                                </thead>
                                            </table>
                                        </div>
                                    <?php } else { ?>
                                        <div class="col-md-6">
                                            <div class=" bg-white border-0 h5">Saved Add Ons <small class="text text-danger">You have to Add product to save this Add Ons data on your server. This is <strong> temporary.</strong></small></div>
                                            <a href='javascript:void(0)' class='remove-add-ons btn btn-danger btn-xs mr-1 mb-1' title='Remove'><i class='fa fa-trash'></i> Remove</a>
                                            <table class='table-striped' id='saved_add_ons_table' data-toggle="table" data-url="" data-click-to-select="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-show-columns="true" data-mobile-responsive="true" data-toolbar="#toolbar" data-maintain-selected="true" data-query-params="queryParams">
                                                <thead>
                                                    <tr>
                                                        <th data-field="state" data-checkbox="true"></th>
                                                        <th data-field="id" data-sortable="true" data-visible="false">ID</th>
                                                        <th data-field="title" data-sortable="true">Title</th>
                                                        <th data-field="description" data-sortable="true">Description</th>
                                                        <th data-field="price" data-sortable="true">Price</th>
                                                        <th data-field="calories" data-sortable="true">Calories</th>
                                                    </tr>
                                                </thead>
                                            </table>
                                        </div>
                                    <?php } ?>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="attributes_values_json_data" class="d-none">
                        <select class="select_single" data-placeholder=" Type to search and select attributes">
                            <option value=""></option>
                            <?php foreach ($attributes_refind as $key => $value) { ?>
                                <option name='<?= $key  ?>' value='<?= $key ?>' data-values='<?= json_encode($value, 1) ?>'><?= $key ?></option>
                            <?php } ?>
                        </select>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="card card-info">
                                <!-- form start -->
                                <div class="card-body">
                                    <div class="col-12 mb-3">
                                        <h3 class="card-title">Additional Info</h3>

                                        <?php
                                        if (isset($product_details)) {
                                            $HideStatus = (isset($product_details[0]['id']) && $product_details[0]['stock_type'] == NULL) ? 'collapse' : '';
                                        ?>
                                            <div class="col-12 row additional-info existing-additional-settings">
                                                <div class="row mt-4 col-md-12 ">
                                                    <nav class="w-100">
                                                        <div class="nav nav-tabs" id="product-tab" role="tablist">
                                                            <a class="nav-item nav-link active" id="tab-for-general-price" data-toggle="tab" href="#general-settings" role="tab" aria-controls="general-price" aria-selected="true">General</a>
                                                            <a class="nav-item nav-link edit-product-attributes" id="tab-for-attributes" data-toggle="tab" href="#product-attributes" role="tab" aria-controls="product-attributes" aria-selected="false">Attributes</a>
                                                            <a class="nav-item nav-link <?= ($product_details[0]['type'] == 'simple_product') ? 'disabled d-none' : 'edit-variants'; ?>""  id=" tab-for-variations" data-toggle="tab" href="#product-variants" role="tab" aria-controls="product-variants" aria-selected="false">Variations</a>
                                                        </div>
                                                    </nav>
                                                </div>

                                                <div class="tab-content p-3 col-md-12" id="nav-tabContent">
                                                    <div class="tab-pane fade active show" id="general-settings" role="tabpanel" aria-labelledby="general-settings-tab">
                                                        <div class="form-group">
                                                            <label for="type" class="col-md-12">Type Of Product :</label>
                                                            <div class="col-md-12">
                                                                <?php @$variant_stock_level = !empty($product_details[0]['stock_type']) && $product_details[0]['stock_type'] == '1' ? 'product_level' : 'variant_level' ?>
                                                                <input type="hidden" name="product_type" value="<?= isset($product_details[0]['type']) ? $product_details[0]['type'] : '' ?>">
                                                                <input type="hidden" name="simple_product_stock_status" <?= isset($product_details[0]['stock_type']) && !empty($product_details[0]['stock_type']) && $product_details[0]['type'] == 'simple_product' ? 'value="' . $product_details[0]['stock_type'] . '"'  : '' ?>>
                                                                <input type="hidden" name="variant_stock_level_type" <?= isset($product_details[0]['stock_type']) && !empty($product_details[0]['stock_type']) && $product_details[0]['type'] == 'variable_product' ? 'value="' . $variant_stock_level . '"'  : '' ?>>
                                                                <input type="hidden" name="variant_stock_status" <?= isset($product_details[0]['stock_type']) && !empty($product_details[0]['stock_type']) && $product_details[0]['type'] == 'variable_product' ? 'value="0"'  : '' ?>>
                                                                <select name="type" id="product-type" class="form-control" data-placeholder=" Type to search and select type" <?= isset($product_details[0]['id']) ? 'disabled' : '' ?>>
                                                                    <option value=" ">Select Type</option>
                                                                    <option value="simple_product" <?= ($product_details[0]['type'] == "simple_product") ? 'selected' : '' ?>>Simple Product</option>
                                                                    <option value="variable_product" <?= ($product_details[0]['type'] == "variable_product") ? 'selected' : '' ?>>Variable Product</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div id='product-general-settings'>
                                                            <?php
                                                            if ($product_details[0]['type'] == "simple_product") {
                                                            ?>
                                                                <div id="general_price_section">
                                                                    <div class="form-group">
                                                                        <label for="type" class="col-md-2">Price:</label>
                                                                        <div class="col-md-12">
                                                                            <input type="number" name="simple_price" class="form-control stock-simple-mustfill-field price" value="<?= $product_variants[0]['price'] ?>" min='0' step="0.01">
                                                                        </div>
                                                                    </div>
                                                                    <div class="form-group">
                                                                        <label for="type" class="col-md-2">Special Price:</label>
                                                                        <div class="col-md-12">
                                                                            <input type="number" name="simple_special_price" class="form-control  discounted_price" value="<?= $product_variants[0]['special_price'] ?>" min='0' step="0.01">
                                                                        </div>
                                                                    </div>
                                                                    <div class="form-group">
                                                                        <div class="col">
                                                                            <input type="checkbox" name="simple_stock_management_status" class="align-middle simple_stock_management_status" <?= (isset($product_details[0]['id']) && $product_details[0]['stock_type'] != NULL) ? 'checked' : '' ?>> <span class="align-middle">Enable Stock Management</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group simple-product-level-stock-management <?= $HideStatus ?>">
                                                                    <div class="col col-xs-12">
                                                                        <label class="control-label">Total Stock :</label>
                                                                        <input type="text" name="product_total_stock" class="col form-control stock-simple-mustfill-field" <?= (isset($product_details[0]['id']) && $product_details[0]['stock_type'] != NULL) ? ' value="' . $product_details[0]['stock'] . '" ' : '' ?>>
                                                                    </div>
                                                                    <div class="col col-xs-12">
                                                                        <label class="control-label">Stock Status :</label>
                                                                        <select type="text" class="col form-control stock-simple-mustfill-field" id="simple_product_stock_status">
                                                                            <option value="1" <?= (isset($product_details[0]['stock_type']) &&
                                                                                                    $product_details[0]['stock_type'] != NULL && $product_details[0]['availability'] == "1") ? 'selected' : '' ?>>In Stock</option>
                                                                            <option value="0" <?= (isset($product_details[0]['stock_type']) &&
                                                                                                    $product_details[0]['stock_type'] != NULL && $product_details[0]['availability'] == "0") ? 'selected' : '' ?>>Out Of Stock</option>
                                                                        </select>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group simple-product-save">
                                                                    <div class="col">
                                                                        <a href="javascript:void(0);" class="btn btn-info save-settings">Save Settings</a>
                                                                        <a href="javascript:void(0);" class="btn btn-warning reset-settings">Reset Settings</a>
                                                                    </div>
                                                                </div>
                                                            <?php } else { ?>
                                                                <div id="variant_stock_level">
                                                                    <div class="form-group">
                                                                        <div class="col">
                                                                            <input type="checkbox" name="variant_stock_management_status" class="align-middle variant_stock_status" <?= (isset($product_details[0]['id']) && $product_details[0]['stock_type'] != NULL) ? 'checked' : '' ?>> <span class="align-middle"> Enable Stock Management</span>
                                                                        </div>
                                                                    </div>
                                                                    <div class="form-group <?= (intval($product_details[0]['stock_type']) > 0) ? '' : 'collapse' ?>" id='stock_level'>
                                                                        <label for="type" class="col-md-2">Choose Stock Management Type:</label>
                                                                        <div class="col-md-12">
                                                                            <select id="stock_level_type" class="form-control variant-stock-level-type" data-placeholder=" Type to search and select type">
                                                                                <option value=" ">Select Stock Type</option>
                                                                                <option value="product_level" <?= (isset($product_details[0]['id']) && $product_details[0]['stock_type'] == '1') ? 'Selected' : '' ?>> Product Level ( Stock Will Be Managed Generally )</option>
                                                                            </select>
                                                                            <div class="form-group variant-product-level-stock-management <?= (intval($product_details[0]['stock_type']) == 1) ? '' : 'collapse' ?>">
                                                                                <div class="col col-xs-12">
                                                                                    <label class="control-label">Total Stock :</label>
                                                                                    <input type="text" name="total_stock_variant_type" class="col form-control variant-stock-mustfill-field" value="<?= (intval($product_details[0]['stock_type']) == 1 && isset($product_variants[0]['id']) && !empty($product_variants[0]['stock'])) ? $product_variants[0]['stock'] : '' ?>">
                                                                                </div>
                                                                                <div class="col col-xs-12">
                                                                                    <label class="control-label">Stock Status :</label>
                                                                                    <select type="text" id="stock_status_variant_type" name="variant_status" class="col form-control variant-stock-mustfill-field">
                                                                                        <option value="1" <?= (intval($product_details[0]['stock_type']) == 1 && isset($product_variants[0]['id']) && $product_variants[0]['availability'] == '1') ? 'Selected' : '' ?>>In Stock</option>
                                                                                        <option value="0" <?= (intval($product_details[0]['stock_type']) == 1 && isset($product_variants[0]['id']) && $product_variants[0]['availability'] == '0') ? 'Selected' : '' ?>>Out Of Stock</option>
                                                                                    </select>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="form-group">
                                                                        <div class="col">
                                                                            <a href="javascript:void(0);" class="btn btn-info save-variant-general-settings">Save Settings</a>
                                                                            <a href="javascript:void(0);" class="btn btn-warning reset-settings">Reset Settings</a>
                                                                        </div>
                                                                    </div>
                                                                </div>

                                                            <?php } ?>
                                                        </div>
                                                    </div>
                                                    <div class="tab-pane fade" id="product-attributes" role="tabpanel" aria-labelledby="product-attributes-tab">
                                                        <div class="info col-12 p-3 d-none" id="note">
                                                            <div class=" col-12 d-flex align-center">
                                                                <strong class="text text-dark" >Note : </strong>
                                                                <input type="checkbox" checked="" class="ml-3 my-auto custom-checkbox" disabled>
                                                                <span class="ml-3 text text-dark">check if the attribute is to be used for variation </span>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-12">
                                                            <a href="javascript:void(0);" id="add_attributes" class="btn btn-block btn-outline-primary col-md-2 float-right m-2 btn-sm">Add Attributes</a>
                                                            <a href="javascript:void(0);" id="save_attributes" class="btn btn-block btn-outline-primary col-md-2 float-right m-2 btn-sm d-none">Save Attributes</a>
                                                        </div>
                                                        <div class="clearfix"></div>

                                                        <div id="attributes_process">
                                                            <div class="form-group text-center row my-auto p-2 border rounded bg-gray-light col-md-12 no-attributes-added">
                                                                <div class="col-md-12 text-center">No Product Attribures Are Added ! </div>
                                                            </div>
                                                        </div>

                                                    </div>
                                                    <div class="tab-pane fade" id="product-variants" role="tabpanel" aria-labelledby="product-variants-tab">
                                                        <div class="col-md-12">
                                                            <a href="javascript:void(0);" id="reset_variants" class="btn btn-block btn-outline-primary col-md-2 float-right m-2 btn-sm collapse">Reset Variants</a>
                                                        </div>
                                                        <div class="clearfix"></div>
                                                        <div class="form-group text-center row my-auto p-2 border rounded bg-gray-light col-md-12 no-variants-added">
                                                            <div class="col-md-12 text-center"> No Product Variations Are Added ! </div>
                                                        </div>
                                                        <div id="variants_process" class="ui-sortable">

                                                            <div class="form-group move row my-auto p-2 border rounded bg-gray-light product-variant-selectbox">
                                                                <div class="col-1 text-center my-auto">
                                                                    <i class="fas fa-sort"></i>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                <?php
                                            } else { ?>
                                                    <div class="col-12 row additional-info existing-additional-settings">
                                                        <div class="row mt-4 col-md-12 ">
                                                            <nav class="w-100">
                                                                <div class="nav nav-tabs" id="product-tab" role="tablist">
                                                                    <a class="nav-item nav-link active" id="tab-for-general-price" data-toggle="tab" href="#general-settings" role="tab" aria-controls="general-price" aria-selected="true">General</a>
                                                                    <a class="nav-item nav-link disabled product-attributes" id="tab-for-attributes" data-toggle="tab" href="#product-attributes" role="tab" aria-controls="product-attributes" aria-selected="false">Attributes</a>
                                                                    <a class="nav-item nav-link disabled product-variants d-none" id="tab-for-variations" data-toggle="tab" href="#product-variants" role="tab" aria-controls="product-variants" aria-selected="false">Variations</a>
                                                                </div>
                                                            </nav>
                                                            <div class="tab-content p-3 col-md-12" id="nav-tabContent">
                                                                <div class="tab-pane fade active show" id="general-settings" role="tabpanel" aria-labelledby="general-settings-tab">
                                                                    <div class="form-group">
                                                                        <label for="type" class="col-md-12">Type Of Product :</label>
                                                                        <div class="col-md-12">
                                                                            <input type="hidden" name="product_type">
                                                                            <input type="hidden" name="simple_product_stock_status">
                                                                            <input type="hidden" name="variant_stock_level_type">
                                                                            <input type="hidden" name="variant_stock_status">
                                                                            <select name="type" id="product-type" class="form-control product-type" data-placeholder=" Type to search and select type">
                                                                                <option value=" ">Select Type</option>
                                                                                <option value="simple_product">Simple Product</option>
                                                                                <option value="variable_product">Variable Product</option>
                                                                            </select>
                                                                        </div>
                                                                    </div>
                                                                    <div id="product-general-settings">
                                                                        <div id="general_price_section" class="collapse">
                                                                            <div class="form-group">
                                                                                <label for="type" class="col-md-2">Price:</label>
                                                                                <div class="col-md-12">
                                                                                    <input type="number" name="simple_price" class="form-control stock-simple-mustfill-field price" min='0' step="0.01">
                                                                                </div>
                                                                            </div>
                                                                            <div class="form-group">
                                                                                <label for="type" class="col-md-2">Special Price:</label>
                                                                                <div class="col-md-12">
                                                                                    <input type="number" name="simple_special_price" class="form-control discounted_price" min='0' step="0.01">
                                                                                </div>
                                                                            </div>
                                                                            <div class="form-group">
                                                                                <div class="col">
                                                                                    <input type="checkbox" name="simple_stock_management_status" class="align-middle simple_stock_management_status"> <span class="align-middle">Enable Stock Management</span>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <div class="form-group simple-product-level-stock-management collapse">
                                                                            <div class="col col-xs-12">
                                                                                <label class="control-label">Total Stock :</label>
                                                                                <input type="text" name="product_total_stock" class="col form-control stock-simple-mustfill-field">
                                                                            </div>
                                                                            <div class="col col-xs-12">
                                                                                <label class="control-label">Stock Status :</label>
                                                                                <select type="text" class="col form-control stock-simple-mustfill-field" id="simple_product_stock_status">
                                                                                    <option value="1">In Stock</option>
                                                                                    <option value="0">Out Of Stock</option>
                                                                                </select>
                                                                            </div>
                                                                        </div>
                                                                        <div class="form-group collapse simple-product-save">
                                                                            <div class="col"> <a href="javascript:void(0);" class="btn btn-info save-settings">Save Settings</a>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div id="variant_stock_level" class="collapse">
                                                                        <div class="form-group">
                                                                            <div class="col">
                                                                                <input type="checkbox" name="variant_stock_management_status" class="align-middle variant_stock_status"> <span class="align-middle"> Enable Stock Management</span>
                                                                            </div>
                                                                        </div>
                                                                        <div class="form-group collapse" id="stock_level">
                                                                            <label for="type" class="col-md-2">Choose Stock Management Type:</label>
                                                                            <div class="col-md-12">
                                                                                <select id="stock_level_type" class="form-control variant-stock-level-type" data-placeholder=" Type to search and select type">
                                                                                    <option value=" ">Select Stock Type</option>
                                                                                    <option value="product_level">Product Level ( Stock Will Be Managed Generally )</option>
                                                                                </select>
                                                                                <div class="form-group row variant-product-level-stock-management collapse">
                                                                                    <div class="col col-xs-12">
                                                                                        <label class="control-label">Total Stock :</label>
                                                                                        <input type="text" name="total_stock_variant_type" class="col form-control variant-stock-mustfill-field">
                                                                                    </div>
                                                                                    <div class="col col-xs-12">
                                                                                        <label class="control-label">Stock Status :</label>
                                                                                        <select type="text" id="stock_status_variant_type" name="variant_status" class="col form-control variant-stock-mustfill-field">
                                                                                            <option value="1">In Stock</option>
                                                                                            <option value="0">Out Of Stock</option>
                                                                                        </select>
                                                                                    </div>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                        <div class="form-group">
                                                                            <div class="col"> <a href="javascript:void(0);" class="btn btn-info save-variant-general-settings">Save Settings</a>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="tab-pane fade" id="product-attributes" role="tabpanel" aria-labelledby="product-attributes-tab">
                                                                    <div class="info col-12 p-3 d-none" id="note">
                                                                        <div class=" col-12 d-flex align-center"> <strong class="text text-dark">Note : </strong>
                                                                            <input type="checkbox" checked="checked" class="ml-3 my-auto custom-checkbox" disabled> <span class="ml-3 text text-dark">check if the attribute is to be used for variation </span>
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-md-12"> <a href="javascript:void(0);" id="add_attributes" class="btn btn-block btn-outline-primary col-md-2 float-right m-2 btn-sm">Add Attributes</a> <a href="javascript:void(0);" id="save_attributes" class="btn btn-block btn-outline-primary col-md-2 float-right m-2 btn-sm d-none">Save Attributes</a>
                                                                    </div>
                                                                    <div class="clearfix"></div>
                                                                    <div id="attributes_process">
                                                                        <div class="form-group text-center row my-auto p-2 border rounded bg-gray-light col-md-12 no-attributes-added">
                                                                            <div class="col-md-12 text-center">No Product Attribures Were Added !</div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="tab-pane fade" id="product-variants" role="tabpanel" aria-labelledby="product-variants-tab">
                                                                    <div class="clearfix"></div>
                                                                    <div class="form-group text-center row my-auto p-2 border rounded bg-gray-light col-md-12 no-variants-added">
                                                                        <div class="col-md-12 text-center">No Product Variations Were Added !</div>
                                                                    </div>
                                                                    <div id="variants_process" class="ui-sortable"></div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                <?php } ?>
                                                </div>
                                            </div>
                                    </div>
                                    <div class="card-body pad">
                                        <div class="d-flex justify-content-center">
                                            <div class="form-group" id="error_box">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <button type="reset" class="btn btn-warning">Reset</button>
                                            <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($product_details[0]['id'])) ? 'Update Product' : 'Add Product' ?></button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>
                        <!--/.card-->
                    </div>
                    <!--/.col-md-12-->

            </form>

        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>