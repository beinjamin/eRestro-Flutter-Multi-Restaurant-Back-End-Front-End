<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Customer Wallet</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Customers</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-6">
                    <div class="card card-info">
                        <!-- form start -->
                        <form class="form-horizontal form-submit-event"  method="POST" action="<?=base_url('admin/customer/update_customer_wallet')?>" enctype="multipart/form-data">
                            <div class="card-body">
                                <input type="hidden" id='user_id' name='user_id'>
                                <div class="form-group row">
                                    <label for="customer" class="col-sm-4 col-form-label">Customer</label>
                                    <div class="col-sm-8">
                                        <input type="text" class="form-control" id="customer_dtls"  readonly>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="type" class="col-sm-4 col-form-label">Select Type</label>
                                    <div class="col-sm-8">
                                        <select name="type" class='form-control'>
                                            <option value="credit" >Credit </option>
                                            <option value="debit">Debit</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="amount" class="col-sm-4 col-form-label">Amount</label>
                                    <div class="col-sm-8">
                                        <input type="number" class="form-control" id="amount" placeholder="Enter Amount" name="amount" min="0">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="message" class="col-sm-4 col-form-label">Message</label>
                                    <div class="col-sm-8">
                                        <textarea class="form-control" id="message" placeholder="Enter Message Here" name="message" ></textarea>
                                    </div>
                                </div>    
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-success" id="submit_btn">Submit</button>
                                </div>
                            </div>
                            <div class="d-flex justify-content-center">
                                <div class="form-group" id="error_box">
                                </div>
                            </div>
                        </form>
                    </div>
                    <!-- /.card-footer -->

                </div>
                <div class="col-md-6 main-content">
                    <div class="card content-area p-4">
                        <div class="card-innr">
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' id='customers' data-toggle="table" data-url="<?= base_url('admin/customer/view_customer') ?>" data-side-pagination="server" data-click-to-select="true" data-pagination="true" data-id-field="id" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="asc" data-mobile-responsive="true" data-toolbar="#toolbar" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th data-field="state" data-radio='true'></th>
                                        <th data-field="id" data-sortable="true" >ID</th>
                                        <th data-field="name" data-sortable="false">Name</th>
                                        <th data-field="email" data-sortable="true">Email</th>
                                        <th data-field="balance" data-sortable="true">Balance</th>
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
