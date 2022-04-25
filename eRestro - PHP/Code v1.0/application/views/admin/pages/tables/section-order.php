<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Manage Section Order</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Section Order</li>
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
                        </div>
                        <div class="card-innr">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6 col-12 offset-md-3">
                                        <label for="subcategory_id" class="col-form-label">Section List</label>
                                        <div class="row font-weight-bold">
                                            <div class="col-md-1">No.</div>
                                            <div class="col-md-3">Row Order Id</div>
                                            <div class="col-md-4">Title</div>
                                        </div>
                                        <ul class="list-group bg-grey move order-container" id="sortable">
                                            <?php
                                            $i = 0;
                                            foreach ($section_result as $row) {
                                            ?>
                                                <li class="list-group-item d-flex bg-gray-light align-items-center h-25" id="section_id-<?= $row['id'] ?>">
                                                    <div class="col-md-1"><span> <?= $i ?> </span></div>
                                                    <div class="col-md-3"><span> <?= $row['row_order'] ?> </span></div>
                                                    <div class="col-md-4"><span><?= $row['title'] ?></span></div>
                                                </li>
                                            <?php
                                                $i++;
                                            }
                                            ?>
                                        </ul>
                                        <button type="button" class="btn btn-block btn-info btn-lg mt-3" id="save_section_order">Save</button>
                                    </div>
                                </div>
                            </div><!-- .card-innr -->
                        </div><!-- .card -->
                    </div>

                </div>
                <!-- /.row -->
            </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>