<!DOCTYPE html>
<html>
<?php $this->load->view('admin/include-head.php'); ?>
<div id="loading">
    <div class="lds-ring">
        <div></div>
    </div>
</div>
<body class="hold-transition sidebar-mini layout-fixed ">
    <div class=" wrapper ">
        <?php $this->load->view('admin/include-navbar.php') ?>
        <?php $this->load->view('admin/include-sidebar.php'); ?>
        <?php $this->load->view('admin/pages/' . $main_page); ?>
        <?php $this->load->view('admin/include-footer.php'); ?>
    </div>
    <?php $this->load->view('admin/include-script.php'); ?>
</body>

</html>