<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>System Health</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">System Health</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">

        <!-- Default box -->
        <div class="card card-solid">
            <div class="card-header">System Analytics</div>
            <div class="card-body">
                <label class="row">Current PHP Version: <span class="text text-danger ml-2"> <?= PHP_VERSION ?></span></label>
                <label class="row">Required Minimum PHP Version: <span class="text text-danger ml-2"> <?= MIN_PHP_VERSION ?></span></label>
                <label class="row">Required Maximum PHP Version: <span class="text text-danger ml-2"> <?= MAX_PHP_VERSION ?></span></label>
                <?php
                $actions = [
                    'number',
                    'status',
                    'title',
                    'description'
                ];
                ?>
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <?php foreach ($actions as $row) { ?>
                                    <th><?= ucfirst($row) ?></th>
                                <?php }
                                ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $i = 1;
                            foreach ($system_status as $key => $value) {
                            ?>
                                <tr>
                                    <th scope="row"><?= $i ?></th>
                                    <?php for ($j = 0; $j < count($value); $j++) {
                                        if ($j == 0) { ?>
                                            <td>
                                                <?php
                                                if (isset($value[$j]) && $value[$j] == 1) {
                                                    $status = '<i class="fas fa-check-circle text-success fa-2x"></i>';
                                                } else if (isset($value[$j]) && $value[$j] == 2) {
                                                    $status = '<i class="fas fa-exclamation-triangle text-warning fa-2x"></i>';
                                                } else {
                                                    $status = '<i class="fas fa-times-circle text-danger fa-2x"></i>';
                                                }
                                                ?>
                                                <?= $status; ?>
                                            </td>
                                        <?php } else { ?>
                                            <td><?= $value[$j] ?></td>
                                    <?php }
                                    }
                                    ?>
                                </tr>
                            <?php
                                $i++;
                            } ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- /.card-body -->
        </div>
        <!-- /.card -->

    </section>
</div>
<!-- /.content -->