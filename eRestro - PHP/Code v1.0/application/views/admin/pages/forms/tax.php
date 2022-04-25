<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Add Tax </h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Add Tax</li>
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
                        <form class="form-horizontal form-submit-event" action="<?= base_url('admin/taxes/add_tax'); ?>" method="POST" enctype="multipart/form-data">
                            <div class="card-body">
                                <?php if (isset($fetched_data[0]['id'])) { ?>
                                    <input type="hidden" name="edit_tax_id" value="<?= @$fetched_data[0]['id'] ?>">
                                <?php } ?>
                                <div class="form-group row">
                                    <label for="title" class="col-sm-2 col-form-label">Title <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-sm-10">
                                        <input type="text" class="form-control" id="title" placeholder="Title" name="title" value="<?= @$fetched_data[0]['title'] ?>">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label for="percentage" class="col-sm-2 col-form-label">Percentage <span class='text-danger text-sm'>*</span></label>
                                    <div class="col-sm-10">
                                        <input type="text" class="form-control" id="percentage" placeholder="Percentage" name="percentage" value="<?= @$fetched_data[0]['percentage'] ?>">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <button type="reset" class="btn btn-warning">Reset</button>
                                    <button type="submit" class="btn btn-info" id="submit_btn"><?= (isset($fetched_data[0]['id'])) ? 'Update Tax' : 'Add Tax' ?></button>
                                </div>
                                <div class="d-flex justify-content-center">
                                    <div class="form-group" id="error_box">

                                    </div>
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