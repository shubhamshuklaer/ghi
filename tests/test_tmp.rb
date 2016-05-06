require "test/unit"
require "typhoeus"

class TestNAME < Test::Unit::TestCase

  def test_generate_token
     ghi_exec=File.expand_path('../ghi', File.dirname(__FILE__))
     `#{ghi_exec} config --auth --quiet`
     token=`git config --global ghi.token`
     assert_not_equal("",token,"Token not present in ~/.gitconfig")
     response=Typhoeus.get("https://api.github.com/users/#{ENV['GITHUB_USER']}",headers:{'Authorization'=>"token #{token}"})
     assert_equal('public_repo, repo',response.headers["X-OAuth-Scopes"])
  end

end
