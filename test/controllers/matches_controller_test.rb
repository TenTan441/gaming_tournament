require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get report" do
    get matches_report_url
    assert_response :success
  end

end
