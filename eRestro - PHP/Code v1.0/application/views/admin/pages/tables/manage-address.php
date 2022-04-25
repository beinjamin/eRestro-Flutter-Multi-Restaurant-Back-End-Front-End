<div class="content-wrapper">
    <section class="content-header">
        <div class="container-fluid">           
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Customer Address</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Customer Address</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content address-section">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12 main-content">
                    <div class="card content-area p-4">
                        <div class="card-innr">
                            <div class="gaps-1-5x"></div>
                            <input type='hidden' id='address_user_id' value='<?=(isset($view_id) && !empty($view_id)) ? $view_id : '' ?>'>
                            <table class='table-striped' id='customer-address-table' data-toggle="table" data-url="<?= base_url('admin/customer/get_address') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="address_query_params">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">Id</th>
                                        <th data-field="name" data-sortable="false">User Name</th>
                                        <th data-field="type" data-sortable="false">Type</th>
                                        <th data-field="mobile" data-sortable="false">mobile</th>
                                        <th data-field="alternate_mobile" data-sortable="false">Alternate mobile</th>
                                        <th data-field="address" data-sortable="false" data-visible="false">Address</th>
                                        <th data-field="landmark" data-sortable="false">Landmark</th>
                                        <th data-field="area" data-sortable="false">Area</th>
                                        <th data-field="city" data-sortable="false">City</th>
                                        <th data-field="state" data-sortable="false">State</th>
                                        <th data-field="pincode" data-sortable="false">Pincode</th>
                                        <th data-field="country" data-sortable="false">Country</th>
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
