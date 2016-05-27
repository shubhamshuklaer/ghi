require "test/unit"
require "helper"
require "pp"

class Test_close < Test::Unit::TestCase
    def test_close_issue
        repo_name=create_repo
        open_issue repo_name
        comment=get_comment

        `#{ghi_exec} close -m "#{comment}" 1 -- #{repo_name}`

        response_issue=get_body("repos/#{repo_name}/issues/1","Issue does not exist")

        assert_equal("closed",response_issue["state"],"Issue not closed")

        response_body=get_body("repos/#{repo_name}/issues/1/comments","Issue does not exist")

        assert_equal(comment,response_body[-1]["body"],"Close comment text not proper")
    end
end
