<!DOCTYPE html>
<html>
<?php $this->load->view('rider/include-head.php'); ?>
<div id="loading">
    <div class="lds-ring">
        <div></div>
    </div>
</div>

<body class="hold-transition sidebar-mini layout-fixed ">
    <div class=" wrapper ">
        <?php $this->load->view('rider/include-navbar.php') ?>
        <?php $this->load->view('rider/include-sidebar.php'); ?>
        <?php $this->load->view('rider/pages/' . $main_page); ?>
        <?php $this->load->view('rider/include-footer.php'); ?>
    </div>
    <?php $this->load->view('rider/include-script.php'); ?>
</body>

</html>