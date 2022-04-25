<!DOCTYPE html>
<html>
<?php $this->load->view('admin/include-head.php'); ?>

<body class="hold-transition sidebar-mini layout-fixed ">
    <div class=" wrapper ">
        <?php $this->load->view('admin/pages/' . $main_page); ?>
    </div>
    <?php $this->load->view('admin/include-script.php'); ?>
</body>

</html>