<?php $current_version = get_current_version(); 
$current_status = $this->ion_auth->user()->row()->active; ?>
<nav class="main-header navbar navbar-expand navbar-dark navbar-info">
    <!-- Left navbar links -->
    <ul class="navbar-nav">
        <li class="nav-item">
            <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
        </li>
        <li class="nav-item my-auto">
            <span class="badge badge-dark">v <?= (isset($current_version) && !empty($current_version)) ? $current_version : '1.0' ?></span>
        </li>
        <li class="nav-item my-auto m-2">
            <span class="badge badge-<?= ($current_status == TRUE) ? "light" : "secondary" ?>"> <?= ($current_status == TRUE) ? "Active" : "Deactivated" ?></span>
        </li>
    </ul>

    <!-- Right navbar links -->
    <ul class="navbar-nav ml-auto">
        <li class="nav-item">
            <a class="nav-link" id="panel_dark_mode" data-slide="true" href="#" role="button">
                <i id="dark-mode-icon" class="fas fa-moon"></i>
            </a>
        </li>
        <?php if (ALLOW_MODIFICATION == 0) { ?>
            <li class="nav-item">
                <a class="nav-link" data-widget="control-sidebar" data-slide="true" href="#" role="button">
                    <i class="fas fa-th-large"></i>
                </a>
            </li>
        <?php } ?>
        <li class="nav-item dropdown">
            <a class="nav-link" data-toggle="dropdown" href="#">
                <i class="fa fa-user"></i>
            </a>
            <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right">
                <div class="dropdown-divider"></div>
                <div class="dropdown-divider">

                </div>
                <div class="dropdown-divider"></div>

                <?php if ($this->ion_auth->is_admin()) { ?>
                    <a href="#" class="dropdown-item">Welcome <b><?= ucfirst($this->ion_auth->user()->row()->username) ?> </b> ! </a>
                    <a href="<?= base_url('admin/home/profile') ?>" class="dropdown-item">
                        <i class="fas fa-user mr-2"></i> Profile
                    </a>
                    <a href="<?= base_url('admin/home/logout') ?>" class="dropdown-item">
                        <i class="fa fa-sign-out-alt mr-2"></i> Log Out
                    </a>
                <?php } else { ?>
                    <a href="#" class="dropdown-item">Welcome <b><?= ucfirst($this->ion_auth->user()->row()->username) ?> </b>! </a>
                    <a href="<?= base_url('rider/home/profile') ?>" class="dropdown-item"><i class="fas fa-user mr-2"></i> Profile </a>
                    <a href="<?= base_url('rider/home/logout') ?>" class="dropdown-item "><i class="fa fa-sign-out-alt mr-2"></i> Log Out </a>
                <?php } ?>
            </div>
        </li>
    </ul>
</nav>