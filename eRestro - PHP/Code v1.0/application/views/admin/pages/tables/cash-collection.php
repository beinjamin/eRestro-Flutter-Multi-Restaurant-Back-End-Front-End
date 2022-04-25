<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Cash Collection </h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Cash Collection</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12 main-content">
                    <div class="row ">
                        <div class="col-md-6 ">
                            <div class="card card-info">
                                <!-- form start -->
                                <form class="form-horizontal form-submit-event" action="<?= base_url('admin/riders/manage-cash-collection'); ?>" method="POST" enctype="multipart/form-data">
                                    <div class="card-body">
                                        <input type='hidden' name="rider_id" id="rider_id" value='' />
                                        <div class="form-group row">
                                            <label for="name" class="col-sm-2 col-form-label">Details <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <textarea class="form-control" rows="3" id="details" disabled></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="name" class="col-sm-2 col-form-label">Amount to be Collect <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="text" name="amount" id="amount" class="form-control" onkeyup="validate_amount(this.value);">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="name" class="col-sm-2 col-form-label">Date <small>(DD-MM-YYYY)</small><span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="datetime-local" name="date" id="date" class="form-control" value="<?php echo date('Y-m-d'); ?>">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="name" class="col-sm-2 col-form-label">Message </label>
                                            <div class="col-sm-10">
                                                <textarea class="form-control" rows="3" name="message" id="message"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <button type="reset" class="btn btn-warning">Reset</button>
                                            <button type="submit" class="btn btn-info" id="submit_btn"> Collect </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                        <div class="col-md-6 ">
                            <div class="card content-area p-4">
                                <div class="card-header bg-white border-0 h5">Select Rider</div>
                                <div class="card-innr">
                                    <div class="gaps-1-5x"></div>
                                    <table class='table table-striped' id="riders_details" data-toggle="table" data-url="<?= base_url('admin/riders/view_riders') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="transaction_query_params">
                                        <thead>
                                            <tr>
                                                <th data-field="state" data-radio="true"></th>
                                                <th data-field="id" data-sortable="true">Id</th>
                                                <th data-field="name" data-sortable="false">User Name</th>
                                                <th data-field="cash_received" data-sortable="false">Cash To Collect(<?= $curreny ?>)</th>

                                            </tr>
                                        </thead>
                                    </table>
                                </div><!-- .card-innr -->
                            </div><!-- .card -->
                        </div>
                    </div>
                </div>
                <div class="col-md-12 main-content">
                    <div class="card content-area p-4">
                        <div class="card-header bg-white border-0 h5">Cash Transactions</div>
                        <div class="card-innr">
                            <div class="gaps-1-5x"></div>
                            <div class="row col-md-12">
                                <div class="form-group col-md-3">
                                    <label>Date and time range:</label>
                                    <div class="input-group col-md-12">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="far fa-clock"></i></span>
                                        </div>
                                        <input type="text" class="form-control float-right" id="datepicker">
                                        <input type="hidden" id="start_date" class="form-control float-right">
                                        <input type="hidden" id="end_date" class="form-control float-right">
                                    </div>

                                </div>
                                <div class="form-group col-md-3">
                                    <div>
                                        <label>Filter By status</label>
                                        <select id="filter_status" name="filter_status" placeholder="Select Status" class="form-control">
                                            <option value="">Select Status</option>
                                            <option value="rider_cash">Rider Cash Received</option>
                                            <option value="rider_cash_collection">Cash Collected by Admin</option>
                                        </select>
                                    </div>
                                </div>
                                <?php if (isset($riders) && !empty($riders)) { ?>
                                    <div class="form-group col-md-3">
                                        <div>
                                            <label>Filter By Rider</label>
                                            <select id="filter_rider" name="filter_rider" class="form-control">
                                                <option value="">Select Rider</option>
                                                <?php foreach ($riders as $row) { ?>
                                                    <option value="<?= $row['user_id'] ?>"><?= $row['username'] ?></option>
                                                <?php } ?>
                                            </select>
                                        </div>
                                    </div>
                                <?php } ?>
                                <div class="form-group col-md-3 d-flex align-items-center pt-4">
                                    <button type="button" class="btn btn-outline-primary btn-sm" onclick="status_date_wise_search()">Filter</button>
                                </div>
                            </div>
                            <input type="hidden" value="<?= $curreny ?>" name="store_currency">

                            <table class='table table-striped' data-toggle="table" data-show-footer="true" data-url="<?= base_url('admin/riders/get_cash_collection') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-export-options='{
                        "fileName": "delivery-boy-cash-collection-list",
                        "ignoreColumn": ["operate"] 
                        }' data-query-params="cash_collection_query_params">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">Id</th>
                                        <th data-field="name" data-sortable="false">User Name</th>
                                        <th data-field="mobile" data-sortable="false">Mobile</th>
                                        <th data-field="order_id" data-sortable="false" data-footer-formatter="idFormatter">Order Id</th>
                                        <th data-field="amount" data-sortable="false" data-footer-formatter="priceFormatter">Amount(<?= $curreny ?>)</th>
                                        <th data-field="type" data-sortable="false">Status</th>
                                        <th data-field="message" data-sortable="false" data-visible="false">Message</th>
                                        <th data-field="txn_date" data-sortable="false">Date</th>
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