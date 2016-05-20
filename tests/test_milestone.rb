require "test/unit"
require "helper"

class Test_milestone < Test::Unit::TestCase

  def test_milestone_create
      repo_name=create_repo
      milestone_title="Test Milestone"
      milestone_des="Test Milestone description"
      milestone_due="2012-04-30"
      # TODO this is not the correct command for milestone creation, though it
      # should be for make it consistent with ghi open. In current version you
      # pass both title and description as argument of -m
      `#{ghi_exec} milestone "#{milestone_title}" -m "#{milestone_des}" --due "#{milestone_due}"  -- #{repo_name}`
      response=get("repos/#{repo_name}/milestones/1")
      response_issue=JSON.load(response.body)
      assert_equal(200,response.code,"Milestone not created")
      assert_equal(milestone_title,response_issue["title"],"Title not proper")
      assert_equal(milestone_des,response_issue["description"],"Descreption not proper")
      # TODO test due date due_on format is 2012-04-30T00:00:00Z
      # assert_equal(milestone_due,response_issue["due_on"],"Due date not proper")
  end

end
