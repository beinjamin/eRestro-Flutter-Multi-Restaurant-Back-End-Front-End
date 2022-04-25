<!DOCTYPE html>
<html>
<?php $this->load->view('partner/include-head.php'); ?>
<div id="loading">
    <div class="lds-ring">
        <div></div>
    </div>
</div>

<body class="hold-transition sidebar-mini layout-fixed ">
    <div class=" wrapper ">
        <?php $this->load->view('partner/include-navbar.php') ?>
        <?php $this->load->view('partner/include-sidebar.php'); ?>
        <?php $this->load->view('partner/pages/' . $main_page); ?>
        <?php $this->load->view('partner/include-footer.php'); ?>
    </div>
    <?php $this->load->view('partner/include-script.php'); ?>
</body>

</html>