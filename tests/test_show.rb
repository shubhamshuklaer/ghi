require "test/unit"
require "helper"
require "pp"

class Test_show < Test::Unit::TestCase
    def test_show
        repo_name=create_repo
        issue=get_issue
        milestone=get_milestone
        comment=get_comment

        comment_issue repo_name

        show_output = `#{ghi_exec} show 1 -- #{repo_name}`

        assert_match(/\A#1: #{issue[:title]}\n/,show_output,"Title not proper")
        assert_match(/^@#{ENV["GITHUB_USER"]} opened this issue/,show_output,"Opening user not proper")
        assert_match(/^@#{ENV["GITHUB_USER"]} is assigned/,show_output,"Assigned user not proper")
        issue[:labels].each do |label|
            assert_match(/[#{label}]/,show_output,"#{label} label not present")
        end
        assert_match(/Milestone #1: #{milestone[:title]}/,show_output,"Milestone not proper")
        assert_match(/@#{ENV["GITHUB_USER"]} commented/,show_output,"Comment creator not proper")
        assert_match(/#{comment}/,show_output,"Comment not proper")
    end
end
