require "typhoeus"
require "json"
require "shellwords"
require "pp"
require "securerandom"
require "mock_data"

def append_token headers
    headers.merge(:Authorization=>"token #{get_token}")
end

def get_url path
    "https://api.github.com/#{path}"
end

def request path, method, options={}
    if options[:params].nil?
        options.merge!(:params=>{})
    end
    if options[:headers].nil?
        options.merge!(:headers=>{})
    end
    if options[:body].nil?
        options.merge!(:body=>{})
    end

    Typhoeus::Request.new(get_url(path),
        method: method,
        body: JSON.dump(options[:body]),
        params: options[:params],
        headers: append_token(options[:headers])
    ).run
end

def head path, options={}
    request(path,:head,options)
end

def get path, options ={}
    request(path,:get,options)
end

def post path, options ={}
    request(path,:post,options)
end

def ghi_exec
    File.expand_path('../ghi', File.dirname(__FILE__))
end

def get_attr index, attr
    Shellwords.escape(issues[index][attr])
end

def get_token
    token=`git config --global ghi.token`
    assert_not_equal("",token,"Token not present in ~/.gitconfig")
    token.chop
end

def create_repo
    repo_name=SecureRandom.uuid
    response=post("user/repos",{body:{'name':repo_name}})
    response_body=JSON.load(response.response_body)
    assert_not_equal(nil,response_body["name"],"Could not create repo #{repo_name}")
    response_body["full_name"]
end

def get_issue index=0
    issue=issues[index]
    issue[:des].gsub!(/\n/,"<br>")
    # http://stackoverflow.com/questions/12700218/how-do-i-escape-a-single-quote-in-ruby
    issue[:des].gsub!(/'/){"\\'"}
    return issue
end

def get_comment index=0
    comments[index]
end

def get_milestone index=0
    milestones[index]
end
