require "test/unit"
require "helper"
require "json"
require "pp"

class Test_issue < Test::Unit::TestCase
  @@repo_name=nil

  def test_1_open_issue
      @@repo_name=create_repo
      issue=get_issue
      `#{ghi_exec} open "#{issue[:title]}" -m "#{issue[:des]}" -L "#{issue[:labels].join(",")}" -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_equal(200,response.code,"Issue not created")
      assert_equal(issue[:title],response_issue["title"],"Title not proper")
      assert_equal(issue[:des],response_issue["body"],"Descreption not proper")
      response_labels=[]
      response_issue["labels"].each do |label|
          response_labels<<label["name"]
      end
      assert_equal(issue[:labels].uniq.sort,response_labels.uniq.sort,"Labels do not match")
  end

  def test_2_comment
      comment=get_comment
      `#{ghi_exec} comment -m "#{comment}" 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1/comments")
      response_body=JSON.load(response.body)
      assert_equal(1,response_body.length,"Comment not created")
      assert_equal(comment,response_body[-1]["body"],"Comment text not proper")
  end

  def test_3_close_issue
      comment=get_comment 1
      `#{ghi_exec} close -m "#{comment}" 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_equal("closed",response_issue["state"],"Issue not closed")
      response=get("repos/#{@@repo_name}/issues/1/comments")
      response_body=JSON.load(response.body)
      assert_equal(comment,response_body[-1]["body"],"Close comment text not proper")
  end

  def test_4_milestone_create
      milestone=get_milestone
      # TODO this is not the correct command for milestone creation, though it
      # should be for make it consistent with ghi open. In current version you
      # pass both title and description as argument of -m
      `#{ghi_exec} milestone "#{milestone[:title]}" -m "#{milestone[:des]}" --due "#{milestone[:due]}"  -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/milestones/1")
      response_issue=JSON.load(response.body)
      assert_equal(200,response.code,"Milestone not created")
      assert_equal(milestone[:title],response_issue["title"],"Title not proper")
      assert_equal(milestone[:des],response_issue["description"],"Descreption not proper")
      # TODO test due date due_on format is 2012-04-30T00:00:00Z
      # assert_equal(milestone[:due],response_issue["due_on"],"Due date not proper")
  end

end
