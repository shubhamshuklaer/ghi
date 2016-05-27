require "test/unit"
require "helper"
require "pp"

class Test_open < Test::Unit::TestCase
  def test_open_issue
      open_issue create_repo
  end

end
