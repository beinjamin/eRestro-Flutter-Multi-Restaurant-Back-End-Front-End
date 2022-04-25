<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row">
                <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true" id="transaction_modal" data-backdrop="static" data-keyboard="false">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="user_name"></h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="card card-info">
                                            <!-- form start -->
                                            <form class="form-horizontal " id="edit_transaction_form" action="<?= base_url('admin/transaction/edit-transactions/'); ?>" method="POST" enctype="multipart/form-data">
                                            <input type="hidden" name="id" id="id">

                                                <div class="card-body pad">
                                                    <div class="form-group ">
                                                        <label for="transaction"> Update Transaction </label>
                                                        <select class="form-control" name="status" id="t_status">
                                                            <option value="awaiting"> Awaiting </option>
                                                            <option value="Success"> Success </option>
                                                            <option value="Failed"> Failed </option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group ">
                                                        <label for="txn_id">Txn_id</label>
                                                        <input type="text" class="form-control" name="txn_id" id="txn_id" placeholder="txn_id" />
                                                    </div>
                                                    <div class="form-group ">
                                                        <label for="message">Message</label>
                                                        <input type="text" class="form-control" name="message" id="message" placeholder="Message" />
                                                    </div>
                                                    <div class="form-group">
                                                        <button type="reset" class="btn btn-warning">Reset</button>
                                                        <button type="submit" class="btn btn-success" id="submit_btn">Update Transaction</button>
                                                    </div>
                                                </div>
                                                <div class="d-flex justify-content-center">
                                                    <div class="form-group" id="error_box">
                                                    </div>
                                                </div>
                                                <!-- /.card-body -->
                                            </form>
                                        </div>
                                        <!--/.card-->
                                    </div>
                                    <!--/.col-md-12-->
                                </div>
                                <!-- /.row -->

                            </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4> View Transaction </h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Transaction</li>
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
                            <input type='hidden' id='transaction_user_id' value='<?= (isset($_GET['user_id']) && !empty($_GET['user_id'])) ? $_GET['user_id'] : '' ?>'>
                            <table class='table table-striped' data-toggle="table" data-url="<?= base_url('admin/transaction/view_transactions') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="transaction_query_params">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">Id</th>
                                        <th data-field="name" data-sortable="false">User Name</th>
                                        <th data-field="order_id" data-sortable="false">Order Id</th>
                                        <th data-field="txn_id" data-sortable="false">Transaction Id</th>
                                        <th data-field="payu_txn_id" data-sortable="false" data-visible="false">Pay Transaction Id</th>
                                        <th data-field="amount" data-sortable="false">Amount</th>
                                        <th data-field="status" data-sortable="false">Status</th>
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

<script>

</script>