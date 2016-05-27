require "test/unit"
require "helper"
require "pp"

class Test_milestone < Test::Unit::TestCase
    def test_milestone_create
        create_milestone create_repo
    end
end
