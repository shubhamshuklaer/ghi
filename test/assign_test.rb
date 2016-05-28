require "test/unit"
require "helper"
require "pp"

class Test_assign < Test::Unit::TestCase
    def un_assign repo_name, issue_no=1
        `#{ghi_exec} assign -d #{issue_no} -- #{repo_name}`

        response_issue = get_body("repos/#{repo_name}/issues/#{issue_no}","Issue does not exist")

        assert_equal(nil,response_issue["assignee"],"User not unassigned")
    end

    def test_un_assign
        repo_name=create_repo
        open_issue repo_name

        un_assign repo_name
    end

    def test_assign
        repo_name=create_repo
        open_issue repo_name

        un_assign repo_name

        `#{ghi_exec} assign -u "#{ENV['GITHUB_USER']}"  1 -- #{repo_name}`

        response_issue=get_body("repos/#{repo_name}/issues/1","Issue does not exist")

        assert_not_equal(nil,response_issue["assignee"],"No user assigned")
        assert_equal(ENV['GITHUB_USER'],response_issue["assignee"]["login"],"Not assigned to proper user")
    end
end
