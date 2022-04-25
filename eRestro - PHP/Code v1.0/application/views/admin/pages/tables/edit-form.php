    <button type="button" class="btn btn-primary" data-toggle="modal" data-target=".bd-example-modal-lg">Large modal</button>
    <div class="modal fade bd-example-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <form class="form-horizontal form-submit-event" action="<?= base_url('admin/category/add_category'); ?>" method="POST" id="add_product_form" enctype="multipart/form-data">
            <div class="card-body">
              <div class="form-group row">
                <label for="category_input_name" class="col-sm-2 col-form-label">Name</label>
                <div class="col-sm-10">
                  <input type="text" class="form-control" id="category_input_name" placeholder="Category Name" name="category_input_name">
                </div>
              </div>
              <div class="form-group row">
                <label for="category_input_subtitle" class="col-sm-2 col-form-label">Subtitle</label>
                <div class="col-sm-10">
                  <input type="text" class="form-control" id="category_input_subtitle" placeholder="Category Subtitle" name="category_input_subtitle">
                </div>
              </div>
              <div class="form-group">
                <label for="image">Main Image :&nbsp;&nbsp;&nbsp;*Please choose square image of larger than 350px*350px &amp; smaller than 550px*550px.</label>
                <div class="col-sm-10">
                  <input type="file" name="category_input_image" id="image">
                </div>
              </div>
            </div>
            <div class='form-group col-md-4'>
              <label for='category_input_status' class='col-sm-4 col-form-label'>Status</label>
              <div class='col-sm-6'>
                <select name='category_input_status' class='form-control' required='' aria-invalid='false'>
                  <option value='1'>Available</option>
                  <option value='0'>Sold Out</option>
                </select>
              </div>
            </div>
            <div class="d-flex justify-content-center form-group" id="error_box">
              <div class="card text-white d-none mb-3">
                <div class="card-header"></div>
                <div class="card-body"></div>
              </div>
            </div>
            <div class="card-footer d-flex justify-content-center">
              <button type="submit" class="btn btn-info col-md-4" id="submit_btn">Add Category</button>
            </div>
            <!-- /.card-footer -->
          </form>
        </div>
      </div>
    </div>