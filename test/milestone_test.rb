require "test/unit"
require "helper"
require "pp"

class Test_milestone < Test::Unit::TestCase
    def setup
        @repo_name=create_repo
    end

    def test_milestone_create
        create_milestone @repo_name
    end

    def teardown
        delete_repo(@repo_name)
    end
end
