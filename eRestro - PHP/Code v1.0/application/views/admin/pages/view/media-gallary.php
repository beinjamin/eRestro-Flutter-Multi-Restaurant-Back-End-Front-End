<div class="content-wrapper">
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12 mt-3 mb-3">
                    <!-- Change /upload-target to your upload address -->
                    <div id="dropzone" class="dropzone"></div>
                    <br>
                    <a href="" id="upload-files-btn" class="btn btn-info float-right">Upload</a>
                </div>
                <div class="col-12 border-bottom">
                    <div class="col-lg-9 col-md-8">
                        <div class="section-title">
                            <h4 class="title mb-2">Media Gallary</h4>
                        </div>
                    </div>
                    <div class="row">

                        <div class="form-group col-md-4">
                            <label>Date and time range:</label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text"><i class="far fa-clock"></i></span>
                                </div>
                                <input type="text" class="form-control float-right" autocomplete="off" id="datepicker">
                                <input type="hidden" id="start_date" class="form-control float-right">
                                <input type="hidden" id="end_date" class="form-control float-right">
                            </div>
                            <!-- /.input group -->
                        </div>
                        <div class="form-group col-md-4">
                            <label>Media Type</label>
                            <div class="input-group">
                                <select class="form-control" id="media-type">
                                    <option value="">All Media Items</option>
                                    <option value="image">Images</option>
                                    <option value="audio">Audio</option>
                                    <option value="video">Video</option>
                                    <option value="archive">Archive</option>
                                    <option value="spreadsheet">Spreadsheet</option>
                                    <option value="documents">Documents</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group col-md-4">
                            <div class="row mt-2">
                                <div class="col-md-4 d-flex align-items-center pt-4">
                                    <button type="button" class="btn btn-outline-info btn-sm mr-2" onclick="status_date_wise_search()">Search</button>
                                    <button type="button" class="btn btn-outline-danger btn-sm" onclick="resetfilters()">Reset</button>
                                </div>

                            </div>
                        </div>
                        <div class="col-md-12 main-content">
                            <div class="card content-area p-4">
                                <div class="card-head">
                                    <h4 class="card-title">Media Details</h4>
                                </div>
                                <div class="card-innr">
                                    <div class="gaps-1-5x"></div>
                                    <table class='table-striped' id='media-table' data-page-size="5" data-toggle="table" data-url="<?= base_url('admin/media/fetch') ?>" data-click-to-select="true" data-single-select='true' data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-query-params="mediaUploadParams">
                                        <thead>
                                            <tr>
                                                <th data-field="state" data-checkbox="true"></th>
                                                <th data-field="id" data-sortable="true" data-visible='false'>ID</th>
                                                <th data-field="partner_id" data-sortable="true" data-visible='false'>Partner ID</th>
                                                <th data-field="name" data-sortable="false">Name</th>
                                                <th data-field="image" data-sortable="false">Image</th>
                                                <th data-field="extension" data-sortable="false">Extension</th>
                                                <th data-field="sub_directory" data-sortable="false">Sub directory</th>
                                                <th data-field="size" data-sortable="false">Size</th>
                                                <th data-field="operate" data-sortable="false">Actions</th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div><!-- .card-innr -->
                            </div><!-- .card -->
                        </div>
                        <!--end col-->
                    </div>
                    <!--end row-->
                </div>
                <!--end col-->
            </div>
        </div>
    </section>
</div>