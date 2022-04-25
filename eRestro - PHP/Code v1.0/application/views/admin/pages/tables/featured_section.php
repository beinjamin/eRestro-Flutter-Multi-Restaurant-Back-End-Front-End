<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Featured Section (Show Foods Exclusively)</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Featured Section </li>
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
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/Featured_sections/add_featured_section'); ?>" method="POST" enctype="multipart/form-data">
                            <?php if (isset($fetched_data[0]['id'])) { ?>
                                <input type="hidden" id="edit_featured_section" name="edit_featured_section" value="<?= @$fetched_data[0]['id'] ?>">
                                <input type="hidden" id="update_id" name="update_id" value="1">
                            <?php } ?>
                            <div class="card-body">
                                <div class="form-group row">
                                    <label for="title" class="control-label">Title for section <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-md-12">
                                        <input type="text" class="form-control" name="title" value="<?= (isset($fetched_data[0]['title']) ? $fetched_data[0]['title'] : '') ?>" placeholder="Title">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="short_description" class="control-label">Short description <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-md-12">
                                        <input type="text" class="form-control" name="short_description" id="short_description" value="<?= (isset($fetched_data[0]['short_description']) ? $fetched_data[0]['short_description'] : '') ?>" placeholder="Short description">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="categories" class="control-label">Categories</label>
                                    <div class="col-md-12">
                                        <select name="categories[]" class=" select_multiple w-100" multiple data-placeholder=" Type to search and select categories">
                                            <option value=""><?= (isset($categories) && empty($categories)) ? 'No Categories Exist' : 'Select Categories' ?>
                                            </option>
                                            <?php
                                            $selected_val = (isset($fetched_data[0]['id']) &&  !empty($fetched_data[0]['id'])) ? $fetched_data[0]['categories'] : '';
                                            $selected_vals = explode(',', $selected_val);
                                            echo get_categories_option_html($categories, $selected_vals);

                                            ?>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <?php
                                    $product_type = ['new_added_foods', 'food_on_offer', 'top_rated_foods', 'most_ordered_foods', 'custom_foods'];
                                    ?>
                                    <label for="product_type" class="control-label">Product Types <span class='text-danger text-sm'> * </span></label>
                                    <div class="col-md-12">
                                        <select name="product_type" class="form-control product_type">
                                            <option value=" ">Select Types</option>
                                            <?php foreach ($product_type as $row) { ?>
                                                <option value="<?= $row ?>" <?= (isset($fetched_data[0]['id']) &&  $fetched_data[0]['product_type'] == $row) ? "Selected" : "" ?>><?= ucwords(str_replace('_', ' ', $row)) ?></option>
                                            <?php
                                            } ?>
                                        </select>
                                        <?php ?>
                                    </div>
                                </div>

                                <div class="form-group row custom_foods <?= (isset($fetched_data[0]['id'])  && $fetched_data[0]['product_type'] == 'custom_foods') ? '' : 'd-none' ?>">
                                    <label for="product_ids" class="control-label">Foods <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-md-12">
                                        <select name="product_ids[]" class="search_product w-100" multiple data-placeholder=" Type to search and select products" onload="multiselect()">
                                            <?php
                                            if (isset($fetched_data[0]['id'])) {
                                                $product_id = explode(",", $fetched_data[0]['product_ids']);

                                                foreach ($product_details as $row) {
                                            ?>
                                                    <option value="<?= $row['id'] ?>" selected><?= $row['name'] ?></option>
                                            <?php
                                                }
                                            }

                                            ?>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($fetched_data[0]['id'])) ? 'Update Fetured Section' : 'Add Fetured Section' ?></button>
                                </div>
                            </div>
                            <div class="d-flex justify-content-center form-group">
                                <div id="error_box">
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                <!--/.card-->
            </div>
            <div class="modal fade edit-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLongTitle">Edit Fetured Section Details</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-12 main-content">
                <div class="card content-area p-4">
                    <div class="card-head">
                        <h4 class="card-title">Featured Section</h4>
                    </div>
                    <div class="card-innr">
                        <div class="gaps-1-5x"></div>
                        <table class='table-striped' data-toggle="table" data-url="<?= base_url('admin/Featured_sections/get_section_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="asc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-query-params="queryParams">
                            <thead>
                                <tr>
                                    <th data-field="id" data-sortable="true">ID</th>
                                    <th data-field="title" data-sortable="true">Title</th>
                                    <th data-field="short_description" data-sortable="false">Short description</th>
                                    <th data-field="categories" data-sortable="true">Categories</th>
                                    <th data-field="product_ids" data-sortable="true">Product ids</th>
                                    <th data-field="product_type" data-sortable="true">Product Type</th>
                                    <th data-field="date" data-sortable="true">Date</th>
                                    <th data-field="operate">Actions</th>
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