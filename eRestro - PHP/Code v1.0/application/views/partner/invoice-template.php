<!DOCTYPE html>
<html>
<?php $this->load->view('partner/include-head.php'); ?>

<body class="hold-transition sidebar-mini layout-fixed ">
    <div class=" wrapper ">
        <?php $this->load->view('partner/pages/' . $main_page); ?>
    </div>
    <?php $this->load->view('partner/include-script.php'); ?>
</body>

</html>