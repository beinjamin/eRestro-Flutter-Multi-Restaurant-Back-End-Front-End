<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Rider</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Rider</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="modal fade edit-modal-lg" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLongTitle">Edit Rider</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body p-0">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true" id='fund_transfer_rider'>
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Fund Transfer Rider</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body p-0">
                                <form class="form-horizontal form-submit-event" action="<?= base_url('admin/fund_transfer/add-fund-transfer'); ?>" method="POST" enctype="multipart/form-data">
                                    <div class="card-body row">
                                        <input type="hidden" name='rider_id' id="rider_id" >
                                        <div class="form-group col-md-6">
                                            <label for="name" class="col-sm-2 col-form-label">Name</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="name" name="name" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label for="mobile" class="col-sm-2 col-form-label">Mobile</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" id="mobile" name="mobile" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label for="balance" class="col-sm-2 col-form-label">Balance</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" id="balance" name="balance" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label for="transfer_amt" class="col-sm-6 col-form-label">Transfer Amount</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" id="transfer_amt" name="transfer_amt" min="0">
                                            </div>
                                        </div>
                                        <div class="form-group col-md-12">
                                            <label for="message" class="col-sm-2 col-form-label">Message</label>
                                            <div class="col-sm-5">
                                                <input type="text" class="form-control" id="message" name="message">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <button type="reset" class="btn btn-warning">Reset</button>
                                            <button type="submit" class="btn btn-info" id="submit_btn">Transfer Fund</button>
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-center">
                                        <div class="form-group" id="error_box">
                                        </div>
                                    </div>
                                    <!-- /.card-body -->
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12 main-content">
                    <div class="card content-area p-4">
                        <div class="card-header border-0">
                            <div class="card-tools">
                                <a href="<?= base_url() . 'admin/riders/' ?>" class="btn btn-block  btn-outline-info btn-sm">Add Rider </a>
                            </div>
                        </div>
                        <div class="card-innr">
                            <div class="row col-md-6">
                            </div>
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' id='fund_transfer' data-toggle="table" data-url="<?= base_url('admin/riders/view_riders') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="asc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">ID</th>
                                        <th data-field="name" data-sortable="false">Name</th>
                                        <th data-field="email" data-sortable="false">Email</th>
                                        <th data-field="mobile" data-sortable="true">Mobile No</th>
                                        <th data-field="rating" data-sortable="true">Rating</th>
                                        <th data-field="address" data-sortable="true">Address</th>
                                        <th data-field="balance" data-sortable="true">balance</th>
                                        <th data-field="commission_method" data-sortable="true">Commission Method</th>
                                        <th data-field="commission" data-sortable="true">Commission</th>
                                        <th data-field="date" data-sortable="true">Date</th>
                                        <th data-field="operate">Actions</th>
                                    </tr>
                                </thead>
                            </table>
                        </div><!-- .card-innr -->
                    </div><!-- .card -->
                </div>
                <div class="modal fade" id="rider-rating-modal" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog modal-xl">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">View Rider Rating</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                <div class="tab-pane " role="tabpanel" aria-labelledby="product-rating-tab">
                                    <table class='table-striped' id="rider-rating-table" data-toggle="table" data-url="<?= base_url('admin/riders/get_rating_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="ratingParams">
                                        <thead>
                                            <tr>
                                                <th data-field="id" data-sortable="true">ID</th>
                                                <th data-field="username" data-width='500' data-sortable="false" class="col-md-6">Username</th>
                                                <th data-field="rating" data-sortable="false">Rating</th>
                                                <th data-field="comment" data-sortable="false">Comment</th>
                                                <th data-field="data_added" data-sortable="false">Data added</th>
                                                <th data-field="operate" data-sortable="false">Operate</th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- /.row -->
        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>
