require "typhoeus"
require "json"
require "shellwords"
require "pp"
require "securerandom"
require "mock_data"
require "test/unit"

$token_gen_done=false

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

def gen_token
    if not $token_gen_done
        `#{ghi_exec} config --auth --quiet`

        # This needs to be before the head request as that call uses get_token
        # which will again trigger `#{ghi_exec} config --auth --quiet` since
        # token_gen_done will still be false. And hence go into an infinite
        # loop.
        $token_gen_done=true

        response=head("users/#{ENV['GITHUB_USER']}")

        assert_equal('public_repo, repo',response.headers["X-OAuth-Scopes"])
    end
end

def get_token
    token=`git config --global ghi.token`.chop
    if token == ""
        gen_token
    end
    token=`git config --global ghi.token`.chop
    assert_not_equal("",token,"Token not present in ~/.gitconfig")
    token
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

def extract_labels response_issue
    tmp_labels=[]
    response_issue["labels"].each do |label|
        tmp_labels<<label["name"]
    end
    tmp_labels.uniq.sort
end

def get_body path, err_msg=""
    response=get(path)
    assert_equal(200,response.code,err_msg)
    JSON.load(response.body)
end

def comment_issue repo_name, issue_no=1, index=0
    open_issue repo_name
    comment=get_comment index

    `#{ghi_exec} comment -m "#{comment}" #{issue_no} -- #{repo_name}`

    response_body=get_body("repos/#{repo_name}/issues/#{issue_no}/comments","Issue does not exist")

    assert_operator(1,:<=,response_body.length,"No comments exist")
    assert_equal(comment,response_body[-1]["body"],"Comment text not proper")
end

def create_milestone repo_name, index=0
    milestone=get_milestone index

    `#{ghi_exec} milestone "#{milestone[:title]}" -m "#{milestone[:des]}" --due "#{milestone[:due]}"  -- #{repo_name}`

    response_milestones=get_body("repos/#{repo_name}/milestones","Repo #{repo_name} does not exist")

    assert_operator(1,:<=,response_milestones.length,"No milestone exist")
    response_milestone=response_milestones[-1]

    assert_equal(milestone[:title],response_milestone["title"],"Title not proper")
    assert_equal(milestone[:des],response_milestone["description"],"Descreption not proper")
    # TODO test due date due_on format is 2012-04-30T00:00:00Z
    # assert_equal(milestone[:due],response_issue["due_on"],"Due date not proper")
end

def open_issue repo_name, index=0
    issue=get_issue index
    milestone_index = issue[:milestone]-1
    milestone_title = get_milestone(milestone_index)[:title]

    create_milestone repo_name, milestone_index

    `#{ghi_exec} open "#{issue[:title]}" -m "#{issue[:des]}" -L "#{issue[:labels].join(",")}" -u "#{ENV['GITHUB_USER']}" -M "#{issue[:milestone]}" -- #{repo_name}`

    response_issues = get_body("repos/#{repo_name}/issues","Repo #{repo_name} does not exist")

    assert_operator(1,:<=,response_issues.length,"No issues exist")
    response_issue = response_issues[-1]

    assert_equal(issue[:title],response_issue["title"],"Title not proper")
    assert_equal(issue[:des],response_issue["body"],"Descreption not proper")
    assert_not_equal(nil,response_issue["assignee"],"No user assigned")
    assert_equal(ENV['GITHUB_USER'],response_issue["assignee"]["login"],"Not assigned to proper user")
    assert_equal(issue[:labels].uniq.sort,extract_labels(response_issue),"Labels do not match")
    assert_not_equal(nil,response_issue["milestone"],"Milestone not added to issue")
    # Milestone title is unique
    assert_equal(milestone_title,response_issue["milestone"]["title"],"Milestone not proper")
end
