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

end
