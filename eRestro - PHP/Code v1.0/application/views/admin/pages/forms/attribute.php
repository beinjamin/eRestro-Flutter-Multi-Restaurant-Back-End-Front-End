<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Attributes</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Manage Attributes</li>
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
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/attribute/add_attributes'); ?>" method="POST" enctype="multipart/form-data">
                            <div class="card-body">
                                <?php if (isset($fetched_data[0]['id'])) { ?>
                                    <input type="hidden" name="edit_attribute" value="<?= @$fetched_data[0]['id'] ?>">
                                <?php  } ?>
                                <div class="form-group row">
                                    <label for="name" class="col-sm-2 col-form-label">Attribute Name <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-sm-10">
                                        <input type="text" class="form-control" placeholder="Name"  name="name" value="<?= @$fetched_data[0]['name'] ?>">
                                    </div>
                                </div>

                                <?php if (isset($fetched_data) && !empty($fetched_data)) { ?>
                                    <div class="form-group row">
                                        <label for="attribute_value" class="col-sm-2 col-form-label">Attribute Values <span class='text-danger text-sm'>*</span></label>
                                        <div class="col-sm-10">
                                            <input name='attribute_value' class='' id='attribute_value' placeholder="Type in attribute values for example 2GB,4GB,8GB etc" value="<?= @$fetched_data[0]['attribute_values'] ?>" />
                                        </div>
                                    </div>
                                <?php } else { ?>
                                    <div class="form-group row">
                                        <label for="attribute_values" class="col-sm-2 col-form-label">Attribute Values <span class='text-danger text-sm'>*</span></label>
                                        <div class="col-sm-10">
                                            <input name='attribute_values' class='' id='attribute_values' placeholder="Type in attribute values for example 2GB,4GB,8GB etc" value="<?= @$fetched_data[0]['attribute_values'] ?>" />
                                        </div>
                                    </div>
                                <?php } ?>
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($fetched_data[0]['id'])) ? 'Update Attribute' : 'Add Attribute' ?></button>
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
                <div class="modal fade " tabindex="-1" role="dialog" aria-hidden="true" id='attribute-modal'>
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Edit Attributes & Values</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body p-0">
                                <form class="form-horizontal" id="edit-attributes-form" action="<?= base_url('admin/attribute/add_attributes'); ?>" method="POST" enctype="multipart/form-data">
                                    <div class="card-body">
                                        <input type="hidden" name="edit_attribute_id" value="">
                                        <input type="hidden" name="attribute_value_ids" value="">
                                        <div class="form-group row">
                                            <label for="name" class="col-sm-2 col-form-label">Attribute Name <span class='text-danger text-sm'>*</span></label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" placeholder="Name" id="name" name="name" value="">
                                            </div>
                                        </div>
                                        <h6 class="modal-title">Attributes Values</h6>
                                        <hr>
                                        <div id="attribute_values_html"></div>
                                        <div class="form-group col-md-12  text-center">
                                            <button type="button" id="add_attribute_val" class="btn btn-secondary btn-xs"> <i class="fa fa-plus"></i> Add Attribute Value </button>
                                        </div>
                                        <div class="form-group">
                                            <button type="reset" class="btn btn-warning">Reset</button>
                                            <button type="submit" class="btn btn-info" id="edit_attribute_val">Update Attribute</button>
                                        </div>
                                    </div>

                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                <!--/.col-md-12-->
                <div class="col-md-12 ">
                    <div class="card content-area p-4">
                        <div class="card-innr">
                            <div class="card-head">
                                <h4 class="card-title">Attributes </h4>
                            </div>
                            <div class="gaps-1-5x"></div>
                            <table class='table-striped' id='attribute_val_table' data-toggle="table" data-url="<?= base_url('admin/attribute/attribute_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="asc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-export-types='["txt","excel","csv"]' data-export-options='{
                        "fileName": "attributes-list", 
                        "ignoreColumn": ["state"] 
                        }' data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th data-field="id" data-sortable="true">ID</th>
                                        <th data-field="name" data-sortable="false">Attribute Name</th>
                                        <th data-field="attribute_values" data-sortable="false">Attribute Values</th>
                                        <th data-field="attribute_value_ids" data-sortable="false" data-visible="false">Attribute Value IDs</th>
                                        <th data-field="status" data-sortable="false">Status</th>
                                        <th data-field="operate" data-sortable="true">Action</th>
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