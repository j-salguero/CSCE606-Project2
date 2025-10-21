require "test_helper"

class CollectionItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get collection_items_index_url
    assert_response :success
  end
end
