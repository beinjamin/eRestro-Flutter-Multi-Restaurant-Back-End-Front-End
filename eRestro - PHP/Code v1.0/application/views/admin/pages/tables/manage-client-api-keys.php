<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Client Api Keys</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Client Api Keys</li>
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
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/Client_api_keys/add_client'); ?>" method="POST" id="add_product_form" enctype="multipart/form-data">
                            <?php
                            if (isset($fetched_data[0]['id'])) {
                            ?>
                                <input type="hidden" id="edit_client_api_keys" name="edit_client_api_keys" value="<?= @$fetched_data[0]['id'] ?>">
                                <input type="hidden" id="update_id" name="update_id" value="1">
                            <?php
                            }
                            ?>
                            <div class="card-body">
                                <div class="form-group row">
                                    <label for="name" class="control-label col-md-12">Client Name <span class='text-danger text-xs'>*</span></label>
                                    <div class="col-md-6">
                                        <input type="text" class="form-control" name="name" id="name" value="<?= (isset($fetched_data[0]['name']) ? $fetched_data[0]['name'] : '') ?>">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($fetched_data[0]['id'])) ? 'Update Client Api ' : 'Add Client Api' ?></button>
                                </div>
                            </div>
                            <div class="d-flex justify-content-center">
                                <div class="form-group" id="error_box">
                                </div>
                            </div>
                        </form>
                        <div class="row">
                            <div class="form-group px-3 col-md-6">
                                <label for="name" class="control-label col-md-12">API link for Customer App <small>( Use this link as your API link in App's code )</small></label>
                                <div class="col-md-12">
                                    <input type="text" class="form-control" id="api_link" value="<?= base_url('app/v1/api/'); ?>" disabled>
                                </div>
                            </div>
                            <div class="form-group px-3 col-md-6">
                                <label for="name" class="control-label col-md-12">Bearer Token <small>( Use token for testing purpose in API )</small></label>
                                <div class="col-md-12">
                                    <textarea class="form-control" id="jwt_token" disabled=""><?= $token; ?></textarea>
                                </div>
                            </div>
                            <div class="form-group px-3 col-md-6">
                                <label for="name" class="control-label col-md-12">Rider API Link</label>
                                <div class="col-md-12">
                                    <input type="text" class="form-control" value="<?= base_url('rider/app/v1/api/'); ?>" disabled>
                                </div>
                            </div>
                            <div class="form-group px-3 col-md-6">
                                <label for="name" class="control-label col-md-12">Admin API Link</label>
                                <div class="col-md-12">
                                <input type="text" class="form-control" value="<?= base_url('admin/app/v1/api/'); ?>" disabled>
                                </div>
                            </div>
                            <div class="form-group px-3 col-md-6">
                                <label for="name" class="control-label col-md-12">Partner API Link</label>
                                <div class="col-md-12">
                                <input type="text" class="form-control" value="<?= base_url('partner/app/v1/api/'); ?>" disabled>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!--/.card-->
                </div>
                <div class="modal fade edit-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLongTitle">Edit Client Api</h5>
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
                            <h4 class="card-title">Client(s) Details</h4>
                        </div>
                        <div class="card-innr">
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' data-toggle="table" data-url="<?= base_url('admin/client_api_keys/get_client_api_keys') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">ID</th>
                                        <th data-field="name" data-sortable="false">Name</th>
                                        <th data-field="secret" data-sortable="false">Secret</th>
                                        <th data-field="status" data-sortable="false">Status</th>
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