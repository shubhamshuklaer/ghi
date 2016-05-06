require "test/unit"
require "helper"
require "pp"

class Token_gen < Test::Unit::TestCase

  def test_generate_token
     `#{ghi_exec} config --auth --quiet`
     response=head("users/#{ENV['GITHUB_USER']}")
     assert_equal('public_repo, repo',response.headers["X-OAuth-Scopes"])
  end

end
