require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :game
    assert_response :success
  end

end
