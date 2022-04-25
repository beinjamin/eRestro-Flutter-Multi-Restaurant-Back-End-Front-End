<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>Ticket System</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Ticket System</li>
                    </ol>
                </div>

            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true" id="ticket_modal" data-backdrop="static" data-keyboard="false">
                    <div class="modal-dialog modal-xl">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="user_name"></h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <?php

                            ?>
                            <div class="modal-body">
                                <div class="card direct-chat direct-chat-primary">
                                    <div class="card-header ui-sortable-handle" style="cursor: move;">
                                        <h4 class="" id="ticket_type">
                                            </h2>
                                            <h3 class="card-title" id="subject"></h3>
                                            <span id="status"><label class="badge badge-secondary ml-2"></label></span><br>
                                            <div class="row">
                                                <div class="col-md-2">
                                                    <p id="date_created"></p>
                                                </div>
                                                <div class="col-md-4">
                                                    <select class="form-control-sm w-100 change_ticket_status">
                                                        <option value="">Change Ticket Status</option>
                                                        <option value=<?= OPENED ?>>OPEN</option>
                                                        <option value=<?= RESOLVED ?>>RESOLVE</option>
                                                        <option value=<?= CLOSED ?>>CLOSE</option>
                                                        <option value=<?= REOPEN ?>>REOPEN</option>
                                                    </select>
                                                </div>
                                            </div>
                                    </div>
                                    <?php
                                    $offset = 0;
                                    $limit = 15;
                                    ?>
                                    <div class="card-body">
                                        <div class="direct-chat-messages" id="element">
                                            <div class="ticket_msg" data-limit="<?= $limit ?>" data-offset="<?= $offset ?>" data-max-loaded="false">
                                            </div>
                                            <div class="scroll_div"></div>
                                        </div>
                                    </div>
                                    <!-- /.card-body -->
                                    <div class="card-footer">
                                        <form class="form-horizontal " id="ticket_send_msg_form" action="<?= base_url('admin/tickets/send-message'); ?>" method="POST" enctype="multipart/form-data">
                                            <div class="input-group">
                                                <input type="hidden" name="user_id" id="user_id">
                                                <input type="hidden" name="user_type" id="user_type">
                                                <input type="hidden" name="ticket_id" id="ticket_id">
                                                <input type="text" name="message" id="message_input" placeholder="Type Message ..." class="form-control">
                                                <span class="input-group-append">
                                                    <div class="form-group">
                                                        <a class="uploadFile img btn btn-primary text-white " data-input='attachments[]' data-isremovable='1' data-is-multiple-uploads-allowed='1' data-toggle="modal" data-target="#media-upload-modal" value="Upload Photo"> <i class="fa fa-paperclip"></i></a>
                                                        <?php

                                                        if (file_exists(FCPATH  . @$fetched_data[0]['attachments']) && !empty(@$fetched_data[0]['attachments'])) {
                                                            $fetched_data[0]['attachments'] = get_image_url($fetched_data[0]['attachments']);
                                                        ?>
                                                            <div class="container-fluid row image-upload-section" >
                                                                <div class="col-md-3 col-sm-12 shadow bg-white rounded m-3 p-3 text-center grow">
                                                                    <div class='image-upload-div'><img class="img-fluid mb-2" src="<?= $fetched_data[0]['attachments'] ?>" alt="Image Not Found"></div>
                                                                    <input type="hidden" name="attachments[]" value='<?= $fetched_data[0]['attachments'] ?>'>
                                                                </div>
                                                            </div>
                                                        <?php
                                                        } else { ?>
                                                            <div class="container-fluid row image-upload-section">
                                                            </div>
                                                        <?php } ?>
                                                    </div>
                                                    <div class="form-group"><button type="submit" class="btn btn-primary" id="submit_btn">Send</button></div>
                                                </span>
                                            </div>
                                        </form>
                                    </div>
                                    <!-- /.card-footer-->
                                </div>
                            </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-12 main-content">
            <div class="card content-area p-4">
                <div class="card-innr">
                    <div class="gaps-1-5x"></div>
                    <table class='table-striped' id="ticket_table" data-toggle="table" data-url="<?= base_url('admin/tickets/view_ticket_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="t.id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="ticket_queryParams">
                        <thead>
                            <tr>
                                <th data-field="id" data-sortable="true">ID</th>
                                <th data-field="ticket_type_id" data-sortable="false" data-visible="false">Ticket Type Id</th>
                                <th data-field="ticket_type" data-sortable="false">Ticket Type</th>
                                <th data-field="user_id" data-sortable="true" data-visible="false">User Id</th>
                                <th data-field="username" data-sortable="true">User Name</th>
                                <th data-field="subject" data-sortable="false">subject</th>
                                <th data-field="email" data-sortable="false">email</th>
                                <th data-field="description" data-sortable="false">description</th>
                                <th data-field="status" data-sortable="false">Status</th>
                                <th data-field="last_updated" data-sortable="false" data-visible="false">last_updated</th>
                                <th data-field="date_created" data-sortable="false">Date Created</th>
                                <th data-field="operate" data-sortable="false">Actions</th>
                            </tr>
                        </thead>
                    </table>
                </div><!-- .card-innr -->
            </div><!-- .card -->
        </div>
</div>
<!-- /.row -->
</div><!-- /.container-fluid -->
</section>
<!-- /.content -->
</div>