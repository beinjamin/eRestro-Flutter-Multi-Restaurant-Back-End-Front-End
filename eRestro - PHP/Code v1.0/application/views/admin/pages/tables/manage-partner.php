<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Partner</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Partner</li>
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
                        <div class="card-header border-0">
                            <div class="card-tools row ">
                                <a href="<?= base_url() . 'admin/partners/manage-partner' ?>" class="btn btn-block  btn-outline-info btn-sm">Add Partner </a>
                            </div>
                        </div>
                        <div class="card-innr">
                            <div class="row">
                                <div class="col-md-4">
                                    <label for="settle_commission" class="col col-form-label">Settle Payments for Partners</label>
                                    <div class="col-md-8">
                                        <a href="#" class="btn btn-info update-partner-commission" title="If you found partner Payment not crediting using cron job you can update Partners Payments from here!">Settle Partner Payment</a>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label for="status_filter" class="col-form-label">Filter By Partner Status</label>
                                    <select class='form-control' name='status' id="status_filter">
                                        <option value=''>Select Status</option>
                                        <option value='1'>Approved</option>
                                        <option value='2'>Not-Approved</option>
                                        <option value='0'>Deactivated</option>
                                    </select>
                                </div>
                            </div>
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' id='seller_table' data-toggle="table" data-url="<?= base_url('admin/partners/view_partners') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="sd.id" data-sort-order="DESC" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel"]' data-query-params="partner_query_params">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">ID</th>
                                        <th data-field="name" data-sortable="false">Owner Name</th>
                                        <th data-field="email" data-sortable="false" data-visible="false">Email</th>
                                        <th data-field="mobile" data-sortable="true">Mobile</th>
                                        <th data-field="address" data-sortable="true" data-visible="false">Address</th>
                                        <th data-field="balance" data-sortable="true">Balance</th>
                                        <th data-field="rating" data-sortable="true">Rating</th>
                                        <th data-field="partner_name" data-sortable="true">Name</th>
                                        <th data-field="working_days" data-sortable="true">Working Days</th>
                                        <th data-field="commission" data-sortable="true">Admin Commission(%)</th>
                                        <th data-field="type" data-sortable="true" data-visible="false">Type</th>
                                        <th data-field="gallery" data-sortable="true" data-visible="false">Gallery</th>
                                        <th data-field="description" data-sortable="true" data-visible="false">Description</th>
                                        <th data-field="account_number" data-sortable="true" data-visible="false">Account Number</th>
                                        <th data-field="account_name" data-sortable="true" data-visible="false">Account Name</th>
                                        <th data-field="bank_code" data-sortable="true" data-visible="false">Bank Code</th>
                                        <th data-field="bank_name" data-sortable="true" data-visible="false">Bank Name</th>
                                        <th data-field="latitude" data-sortable="true" data-visible="false">Latitude</th>
                                        <th data-field="longitude" data-sortable="true" data-visible="false">Longitude</th>
                                        <th data-field="tax_name" data-sortable="true" data-visible="false">Tax Name</th>
                                        <th data-field="tax_number" data-sortable="true" data-visible="false">Tax Number</th>
                                        <th data-field="pan_number" data-sortable="true" data-visible="false">Pan Number</th>
                                        <th data-field="status" data-sortable="true">Status</th>
                                        <th data-field="profile" data-sortable="true">Profile</th>
                                        <th data-field="national_identity_card" data-sortable="true" data-visible="false">National Identity Card</th>
                                        <th data-field="address_proof" data-sortable="true" data-visible="false">Address Proof</th>
                                        <th data-field="date" data-sortable="true" data-visible="false">Date</th>
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