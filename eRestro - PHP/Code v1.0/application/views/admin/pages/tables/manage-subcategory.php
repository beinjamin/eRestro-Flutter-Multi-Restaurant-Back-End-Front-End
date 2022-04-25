<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1>Manage Subcategory</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="<?=base_url('admin/home')?>">Home</a></li>
              <li class="breadcrumb-item active">Subcategory</li>
            </ol>
          </div>
        </div>
      </div><!-- /.container-fluid -->
    </section>
    <section class="content">
      <div class="container-fluid">
        <div class="row">
           <div class="modal fade edit-modal-lg" tabindex="-1" role="dialog"  aria-hidden="true">
             <div class="modal-dialog modal-lg">
                <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" >Edit SubCategory</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">&times;</span>
                    </button>
                  </div>
                  <div class="modal-body">
                  </div>
                </div>
            </div>
          </div>
            <div class="col-md-12 main-content">
                <div class="card content-area p-4">
                  <div class="card-header border-0">
                    <div class="card-tools">                       
                      <a href="<?=base_url().'admin/category/create-subcategory'?>" class="btn btn-block btn-outline-info btn-lg">Add Subcategory</a>
                    </div>                              
                  </div>
                  <div class="card-innr">
                    <div class="card-head">
                        <h4 class="card-title"></h4>                                                 
                    </div>
                    <div class="gaps-1-5x"></div>
                      <table class='table-striped' id='sub_category_table'
                        data-toggle="table"
                        data-url="<?=base_url('admin/category/subcategory_list')?>"
                        data-click-to-select="true"
                        data-side-pagination="server"
                        data-pagination="true"
                        data-page-list="[5, 10, 20, 50, 100, 200]"
                        data-search="true" data-show-columns="true"
                        data-show-refresh="true" data-trim-on-search="false"
                        data-sort-name="id" data-sort-order="asc"
                        data-mobile-responsive="true"
                        data-toolbar="" data-show-export="true"
                        data-maintain-selected="true"
                        data-export-types='["txt","excel","csv"]'
                        data-export-options='{
                        "fileName": "subcategory-list",
                        "ignoreColumn": ["state"] 
                        }'
                        data-query-params="queryParams">
                        <thead>
                          <tr>
                              <th data-field="id" data-sortable="true">ID</th>
                              <th data-field="name" data-sortable="false">Name</th>
                              <th data-field="main_category" data-sortable="true">Main Category</th>
                              <th data-field="subtitle"data-sortable="true">Subtitle</th>
                              <th data-field="image"data-sortable="true">Image</th>
                              <th data-field="operate" data-sortable="true" >Action</th>
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
