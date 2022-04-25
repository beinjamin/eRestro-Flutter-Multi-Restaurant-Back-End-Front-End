<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Products</h4>
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
            <div class="row">
                <div class="modal fade" id="product-rating-modal" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog modal-xl">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">View Product Rating</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                <div class="tab-pane " role="tabpanel" aria-labelledby="product-rating-tab">
                                    <table class='table-striped' id="product-rating-table" data-toggle="table" data-url="<?= base_url('partner/product/get_rating_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="ratingParams">
                                        <thead>
                                            <tr>
                                                <th data-field="id" data-sortable="true">ID</th>
                                                <th data-field="username" data-width='500' data-sortable="false" class="col-md-6">Username</th>
                                                <th data-field="rating" data-sortable="false">Rating</th>
                                                <th data-field="comment" data-sortable="false">Comment</th>
                                                <th data-field="images" data-sortable="true">Images</th>
                                                <th data-field="data_added" data-sortable="false">Data added</th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-12 main-content">
                    <div class="card content-area p-4">
                        <div class="card-header border-0">
                            <div class="card-tools">
                                <a href="<?= base_url() . 'partner/product/create_product' ?>" class="btn btn-block btn-outline-info btn-sm">Add Product</a>
                            </div>
                        </div>
                        <div class="card-innr">
                            <div class="row">
                                <div class="col-md-3">
                                    <label for="zipcode" class="col-form-label">Filter By Product Category</label>
                                    <select id="category_parent" name="category_parent">
                                        <option value=""><?= (isset($categories) && empty($categories)) ? 'No Categories Exist' : 'Select Categories' ?>
                                        </option>
                                        <?php
                                        echo get_categories_option_html($categories);
                                        ?>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label for="zipcode" class="col-form-label">Filter By Product Status</label>
                                    <select class='form-control' name='status' id="status_filter">
                                        <option value=''>Select Status</option>
                                        <option value='1'>Approved</option>
                                        <option value='2'>Not-Approved</option>
                                        <option value='0'>Deactivated</option>
                                    </select>
                                </div>
                            </div>
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' id='products_table' data-toggle="table" data-url="<?= isset($_GET['flag']) ? base_url('partner/product/get_product_data?flag=') . $_GET['flag'] : base_url('partner/product/get_product_data') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel","csv"]' data-export-options='{"fileName": "products-list","ignoreColumn": ["state"] }' data-query-params="product_query_params">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true" data-visible='false'>ID</th>
                                        <th data-field="image" data-sortable="true">Image</th>
                                        <th data-field="name" data-sortable="false">Name</th>
                                        <th data-field="rating" data-sortable="true">Rating</th>
                                        <th data-field="variations" data-sortable="true" data-visible='false'>Variations</th>
                                        <th data-field="operate" data-sortable="true">Action</th>
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