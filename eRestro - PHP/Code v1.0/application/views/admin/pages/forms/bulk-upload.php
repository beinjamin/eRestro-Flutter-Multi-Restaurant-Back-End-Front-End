<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Bulk upload</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Products</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="alert alert-info">
                        <ul>
                            <li>Read and follow instructions carefully while preparing data</li>
                            <li>Download and save the sample file to reduce errors</li>
                            <li>For adding bulk products file should be .csv format</li>
                            <li>You can copy image path from media section</li>
                            <li><b>Make sure you entered valid data as per instructions before proceed</b></li>
                        </ul>
                    </div>
                    <div class="card card-info">

                        <!-- form start -->
                        <form class="form-horizontal" action="<?= base_url('admin/product/process_bulk_upload'); ?>" method="POST" id="bulk_upload_form">
                            <div class="card-body">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="type" class="col-form-label">Type <small>[upload/update]</small> <span class='text-danger text-sm'>*</span></label></label>
                                        <select class='form-control' name='type' id='type'>
                                            <option value=''>Select</option>
                                            <option value='upload'>Upload</option>
                                            <option value='update'>Update</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="file">File <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-md-4">
                                        <input type="file" name="upload_file" class="form-control" accept=".csv" />
                                    </div>

                                </div>
                                <div class="form-group row">
                                    <div class="card-body pad">
                                        <div class="form-group">
                                            <button type="reset" class="btn btn-warning">Reset</button>
                                            <button type="submit" class="btn btn-success" id="submit_btn">Submit</button>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="card-body pad">
                                        <div class="form-group">
                                            <a href="<?= base_url('uploads/product-bulk-upload-sample.csv') ?>" class="btn btn-info" download="product-bulk-upload-sample.csv">Bulk upload sample file <i class="fas fa-download"></i></a>
                                            <a href="<?= base_url('uploads/bulk-upload-instructions.txt') ?>" class="btn btn-primary" download="bulk-upload-instructions.txt">Bulk upload instructions <i class="fas fa-download"></i></a>
                                            <a href="<?= base_url('uploads/product-bulk-update-sample.csv') ?>" class="btn btn-info" download="product-bulk-update-sample.csv">Bulk update sample file <i class="fas fa-download"></i></a>
                                            <a href="<?= base_url('uploads/bulk-update-instructions.txt') ?>" class="btn btn-primary" download="bulk-update-instructions.txt">Bulk update instructions <i class="fas fa-download"></i></a>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-center form-group">
                                    <div id="upload_result" class="p-3"></div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <!--/.card-->
                </div>
                <!--/.col-md-12-->
            </div>
            <!-- /.row -->
        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>