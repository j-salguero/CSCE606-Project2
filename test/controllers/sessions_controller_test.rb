require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should post create" do
    post login_url
    # usually redirects after successful login
    assert_response :redirect
  end

  test "should delete destroy" do
    delete logout_url
    # usually redirects after logout
    assert_response :redirect
  end
end
