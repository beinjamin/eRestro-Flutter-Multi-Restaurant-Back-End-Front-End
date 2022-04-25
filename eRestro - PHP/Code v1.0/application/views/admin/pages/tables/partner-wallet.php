<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Partner Wallet Transactions </h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Partner Wallet</li>
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
                            <div class="row">
                                <div class="col-md-3">
                                    <label for="zipcode" class="col-form-label">Filter By Partner</label>
                                    <select class='form-control' name='partner_id' id="restro_filter">
                                        <option value="">Select Partner </option>
                                        <?php foreach ($partners as $partner) { ?>
                                            <option value="<?= $partner['partner_id'] ?>" <?= (isset($product_details[0]['partner_id']) && $product_details[0]['partner_id'] == $partner['partner_id']) ? 'selected' : "" ?>><?= $partner['partner_name'] ?></option>
                                        <?php } ?>
                                    </select>
                                </div>
                            </div>
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' id="restro_wallet_table" data-toggle="table" data-url="<?= base_url('admin/transaction/view_transactions') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="partner_wallet_query_params">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">ID</th>
                                        <th data-field="user_id" data-sortable="false" data-visible="false">User Id</th>
                                        <th data-field="name" data-sortable="false">Owner</th>
                                        <th data-field="partner_name" data-sortable="false">Partner</th>
                                        <th data-field="type" data-sortable="false">Type</th>
                                        <th data-field="amount" data-sortable="false">Amount</th>
                                        <th data-field="status" data-sortable="false">Status</th>
                                        <th data-field="message" data-sortable="false">Message</th>
                                        <th data-field="date" data-sortable="false">Date</th>
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