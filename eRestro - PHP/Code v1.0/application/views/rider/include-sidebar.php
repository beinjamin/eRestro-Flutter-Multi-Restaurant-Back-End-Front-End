<?php $settings = get_settings('system_settings', true); ?>
<aside class="main-sidebar elevation-2 sidebar-light-info" id="admin-sidebar">
    <!-- Brand Logo -->
    <a href="<?= base_url('admin/home') ?>" class="brand-link">
        <img src="<?= base_url() . get_settings('favicon') ?>" alt="<?= $settings['app_name']; ?>" title="<?= $settings['app_name']; ?>" class="brand-image">
        <span class="brand-text font-weight-light small"><?= $settings['app_name']; ?></span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
        <!-- Sidebar Menu -->
        <nav class="mt-2">
            <ul class="nav nav-pills nav-sidebar flex-column nav-child-indent nav-flat" data-widget="treeview" role="menu" data-accordion="false">
                <!-- Add icons to the links using the .nav-icon class
               with font-awesome or any other icon font library -->
                <li class="nav-item has-treeview">
                    <a href="<?= base_url('rider/home') ?>" class="nav-link">
                        <i class="nav-icon fas fa-home text-danger"></i>
                        <p>
                            Home
                        </p>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<?= base_url('rider/orders/') ?>" class="nav-link">
                        <i class="nav-icon fas fa-shopping-cart text-warning"></i>
                        <p>
                            Orders
                        </p>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<?= base_url('rider/fund-transfer/') ?>" class="nav-link">
                        <i class="fa fa-rupee-sign nav-icon text-primary"></i>
                        <p>
                            Fund Transfers
                        </p>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<?= base_url('rider/fund-transfer/manage-cash') ?>" class="nav-link text-sm">
                        <i class="fas fa-money-bill-alt nav-icon text-success"></i>
                        <p> Cash Collection </p>
                    </a>
                </li>
            </ul>
        </nav>
        <!-- /.sidebar-menu -->
    </div>
    <!-- /.sidebar -->
</aside>