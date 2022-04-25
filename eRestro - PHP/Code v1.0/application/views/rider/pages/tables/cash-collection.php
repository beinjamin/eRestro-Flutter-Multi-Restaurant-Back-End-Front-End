<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Cash Collection Transactions </h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('rider/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Cash Collection Transactions</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">

                <div class="col-md-12 main-content">
                    <div class="card content-area p-4">
                        <div class="card-innr">
                            <div class="gaps-1-5x"></div>
                            <div class="row pt-4">
                                <div class="col-xl-3 col-lg-6 col-md-6 col-12">
                                    <div class="card pull-up">
                                        <div class="card-content">
                                            <div class="card-body">
                                                <div class="media d-flex">
                                                    <div class="align-self-center text-info">
                                                        <i class="far fa-money-bill-alt fa-3x"></i>
                                                    </div>
                                                    <div class="media-body text-right">
                                                        <h5 class="text-muted text-bold-500">Cash in Hand:</h5>
                                                        <h3 class="text-bold-600"> <?= $curreny . " "?> <?= (isset($cash_in_hand) && !empty($cash_in_hand[0]['cash_received'])) ? $cash_in_hand[0]['cash_received'] : "0" ?></h3>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-xl-3 col-lg-6 col-md-6 col-12">
                                    <div class="card pull-up">
                                        <div class="card-content">
                                            <div class="card-body">
                                                <div class="media d-flex">
                                                    <div class="align-self-center text-info">
                                                        <i class="ion-ios-albums-outline display-4 display-4"></i>
                                                    </div>
                                                    <div class="media-body text-right">
                                                        <h5 class="text-muted text-bold-500">Cash Collected:</h5>
                                                        <h3 class="text-bold-600"> <?= $curreny . " " ?> <?= (isset($cash_collected) && !empty($cash_collected[0]['total_amt'])) ? $cash_collected[0]['total_amt'] : "0" ?></h3>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
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
                                            <option value="rider_cash">Rider Cash In Hand</option>
                                            <option value="rider_cash_collection">Cash Collected by Admin</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group col-md-3 d-flex align-items-center pt-4">
                                    <button type="button" class="btn btn-outline-info btn-sm" onclick="status_date_wise_search()">Filter</button>
                                </div>
                            </div>
                            <input type="hidden" value="<?= $curreny ?>" name="store_currency">
                            <table class='table table-striped' data-toggle="table" data-show-footer="true" data-url="<?= base_url('rider/fund-transfer/get_cash_collection') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-export-options='{
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