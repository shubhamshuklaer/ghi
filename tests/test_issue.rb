require "test/unit"
require "helper"
require "json"
require "pp"

class Test_issue < Test::Unit::TestCase
  @@repo_name=nil

  def test_00_open_issue
      @@repo_name=create_repo
      issue=get_issue
      `#{ghi_exec} open "#{issue[:title]}" -m "#{issue[:des]}" -L "#{issue[:labels].join(",")}" -u "#{ENV['GITHUB_USER']}" -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_equal(200,response.code,"Issue not created")
      assert_equal(issue[:title],response_issue["title"],"Title not proper")
      assert_equal(issue[:des],response_issue["body"],"Descreption not proper")
      assert_not_equal(nil,response_issue["assignee"],"No user assigned")
      assert_equal(ENV['GITHUB_USER'],response_issue["assignee"]["login"],"Not assigned to proper user")
      response_labels=[]
      response_issue["labels"].each do |label|
          response_labels<<label["name"]
      end
      assert_equal(issue[:labels].uniq.sort,response_labels.uniq.sort,"Labels do not match")
  end

  def test_01_un_assign
      `#{ghi_exec} assign -d 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_equal(nil,response_issue["assignee"],"User not unassigned")
  end


  def test_02_comment
      comment=get_comment
      `#{ghi_exec} comment -m "#{comment}" 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1/comments")
      response_body=JSON.load(response.body)
      assert_equal(1,response_body.length,"Comment not created")
      assert_equal(comment,response_body[-1]["body"],"Comment text not proper")
  end

  def test_03_comment_ammend
      comment=get_comment 1
      `#{ghi_exec} comment --amend "#{comment}" 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1/comments")
      response_body=JSON.load(response.body)
      assert_equal(comment,response_body[-1]["body"],"Comment text not proper")
  end

  def test_04_comment_delete
      `#{ghi_exec} comment -D 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1/comments")
      response_body=JSON.load(response.body)
      assert_equal(0,response_body.length,"Comment not deleted")
  end

  def test_05_close_issue
      comment=get_comment 2
      `#{ghi_exec} close -m "#{comment}" 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_equal("closed",response_issue["state"],"Issue not closed")
      response=get("repos/#{@@repo_name}/issues/1/comments")
      response_body=JSON.load(response.body)
      assert_equal(comment,response_body[-1]["body"],"Close comment text not proper")
  end

  def test_06_milestone_create
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

  def test_07_milestone_add
      `#{ghi_exec} edit 1 -M 1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_equal(1,response_issue["milestone"]["number"],"Milestone not added to issue")
  end

  def test_08_edit_issue
      issue=get_issue 1
      milestone=get_milestone 1
      `#{ghi_exec} milestone "#{milestone[:title]}" -m "#{milestone[:des]}" --due "#{milestone[:due]}"  -- #{@@repo_name}`
      #TODO test this milestone creation too
      `#{ghi_exec} edit 1 "#{issue[:title]}" -m "#{issue[:des]}" -L "#{issue[:labels].join(",")}" -M 2 -s open -u "#{ENV['GITHUB_USER']}" -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_equal(issue[:title],response_issue["title"],"Title not proper")
      assert_equal(issue[:des],response_issue["body"],"Descreption not proper")
      response_labels=[]
      response_issue["labels"].each do |label|
          response_labels<<label["name"]
      end
      assert_equal(issue[:labels].uniq.sort,response_labels.uniq.sort,"Labels do not match")
      assert_equal("open",response_issue["state"],"Issue state not changed")
      assert_equal(2,response_issue["milestone"]["number"],"Milestone not proper")
      assert_not_equal(nil,response_issue["assignee"],"No user assigned")
      assert_equal(ENV['GITHUB_USER'],response_issue["assignee"]["login"],"Not assigned to proper user")
  end

  def test_09_assign
      `#{ghi_exec} assign -d 1 -- #{@@repo_name}`
      `#{ghi_exec} assign -u "#{ENV['GITHUB_USER']}"  1 -- #{@@repo_name}`
      response=get("repos/#{@@repo_name}/issues/1")
      response_issue=JSON.load(response.body)
      assert_not_equal(nil,response_issue["assignee"],"No user assigned")
      assert_equal(ENV['GITHUB_USER'],response_issue["assignee"]["login"],"Not assigned to proper user")
  end
end
