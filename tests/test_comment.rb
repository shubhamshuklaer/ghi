require "test/unit"
require "helper"
require "pp"

class Test_comment < Test::Unit::TestCase
    def test_comment
        comment_issue create_repo
    end

    def test_comment_amend
        repo_name=create_repo
        comment_issue repo_name

        comment=get_comment 1

        `#{ghi_exec} comment --amend "#{comment}" 1 -- #{repo_name}`

        response_body=get_body("repos/#{repo_name}/issues/1/comments","Issue does not exist")

        assert_equal(1,response_body.length,"Comment does not exist")
        assert_equal(comment,response_body[-1]["body"],"Comment text not proper")
    end

    def test_comment_delete
        repo_name=create_repo
        comment_issue repo_name

        `#{ghi_exec} comment -D 1 -- #{repo_name}`

        response_body=get_body("repos/#{repo_name}/issues/1/comments","Issue does not exist")

        assert_equal(0,response_body.length,"Comment not deleted")
    end
end
