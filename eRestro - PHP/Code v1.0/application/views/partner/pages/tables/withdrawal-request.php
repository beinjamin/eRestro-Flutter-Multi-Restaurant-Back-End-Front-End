<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Withdrawal Request</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a  class="text text-info" href="<?= base_url('partner/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Withdrawal Request</li>
                    </ol>
                </div>

            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="col-md-12 main-content">
            <div class="card content-area p-4">
                <div class="card-header border-0">
                    <div class="card-tools">
                        <a href="<?= base_url() . 'partner/payment-request/send-withdrawal-request' ?>" class="btn btn-block  btn-outline-info  btn-sm">Send Withdrawal Request</a>
                    </div>
                </div>
                <div class="card-innr">
                    <div class="gaps-1-5x"></div>
                    <table class='table-striped' id='payment_request_table' data-toggle="table" data-url="<?= base_url('partner/payment-request/view_withdrawal_request_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="pr.id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="queryParams">
                        <thead>
                            <tr>
                                <th data-field="id" data-sortable="true">ID</th>
                                <th data-field="user_name" data-sortable="false">Username</th>
                                <th data-field="payment_type" data-sortable="true">Type</th>
                                <th data-field="payment_address" data-sortable="false">Payment Address</th>
                                <th data-field="amount_requested" data-sortable="false">Amount Requested</th>
                                <th data-field="remarks" data-sortable="false">Remarks</th>
                                <th data-field="status" data-sortable="false">Status</th>
                                <th data-field="date_created" data-sortable="false">Date Created</th>
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