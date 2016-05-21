require "test/unit"
require "helper"
require "json"

class Test_issue < Test::Unit::TestCase

  def test_1_open_issue
      repo_name=create_repo
      issue=get_issue
      `#{ghi_exec} open "#{issue[:title]}" -m "#{issue[:des]}" -L "#{issue[:labels].join(",")}" -- #{repo_name}`
      response=get("repos/#{repo_name}/issues/1")
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

end
