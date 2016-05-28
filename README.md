# ghi

[![Build Status](https://travis-ci.org/shubhamshuklaer/ghi.svg?branch=travis-ci)](https://travis-ci.org/shubhamshuklaer/ghi)

GitHub Issues on the command line. Use your `$EDITOR`, not your browser.

`ghi` was originally created by [Stephen Celis](https://github.com/stephencelis), and is now maintained by [Alex Chesters](https://github.com/alexchesters).

## Install

Via brew ([latest stable release](https://github.com/stephencelis/ghi/releases/latest)):
``` sh
brew install ghi
```

Via gem ([latest stable release](https://github.com/stephencelis/ghi/releases/latest)):
``` sh
gem install ghi
```

Via curl (latest bleeding-edge versions, may not be stable):
``` sh
curl -sL https://raw.githubusercontent.com/stephencelis/ghi/master/ghi > ghi && \
chmod 755 ghi && \
mv ghi /usr/local/bin
```

## Usage

```
usage: ghi [--version] [-p|--paginate|--no-pager] [--help] <command> [<args>]
           [ -- [<user>/]<repo>]

The most commonly used ghi commands are:
   list        List your issues (or a repository's)
   show        Show an issue's details
   open        Open (or reopen) an issue
   close       Close an issue
   edit        Modify an existing issue
   comment     Leave a comment on an issue
   label       Create, list, modify, or delete labels
   assign      Assign an issue to yourself (or someone else)
   milestone   Manage project milestones
   status      Determine whether or not issues are enabled for this repo
   enable      Enable issues for the current repo
   disable     Disable issues for the current repo

See 'ghi help <command>' for more information on a specific command.
```

## Source Tree
You may get a strange error if you use SourceTree, similar to [#275](https://github.com/stephencelis/ghi/issues/275) and [#189](https://github.com/stephencelis/ghi/issues/189). You can follow the steps [here](https://github.com/stephencelis/ghi/issues/275#issuecomment-182895962) to resolve this. 

## Contributing

If you're looking for a place to start, there are [issues we need help with](https://github.com/stephencelis/ghi/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22)!

Once you have an idea of what you want to do, there is a section in the [wiki](https://github.com/stephencelis/ghi/wiki/Contributing) to provide more detailed information but the basic steps are as follows.

1. Fork this repo
2. Do your work:
  1. Add tests if you are adding new feature or solving some problem which do
     not have a test. If you add a new test file then keep the file name of the
     format `somthing_test.rb`.The test file should be kept in the test folder.
     And the test function should be of the format `test_something`.
  2. Make your changes
  3. Run `rake build`
  4. Before running tests `GITHUB_USER` and `GITHUB_PASSWORD` environment variables
     must be exported. It will be best to use a fake account as the tests will
     litter your original repo. Also remove the token for your original repo
     from `~/.gitconfig` or `GHI_TOKEN` environment variable.
  5. Run `rake test:one_by_one` to run all the tests
  6. Checkout [Single Test](https://github.com/grosser/single_test) for better
     control over which test to run. Eg. `rake test:assign:un_assign` will run
     a test function matching `/un_assign/` in file `assign_test.rb`. One more
     eg. `rake test:edit test:assign` will runt tests `edit_test.rb` and
     `assign_test.rb`. Or you can use use `ruby -I"lib:test" test/file_name.rb
     -n method_name`
  7. If you don't wanna run the tests locally use travis-ci. See section below.
  3. Make sure your changes work
3. Open a pull request!

## FAQ

FAQs can be found in the [wiki](https://github.com/stephencelis/ghi/wiki/FAQ)

## Screenshot

![Example](images/example.png)

## Enable Travis CI in fork

* Open a Travis CI account and activate travis-ci for the fork
* Create a fake github account for testing. The username, password and token
will be available to the tests and if by mistake(or otherwise) the test prints
it, it will be available in public log. So its best to create a fake account
and use a password you are not using for anything else. Also apart from
security reasons, bugs in tests or software can mess up you original user
account, to to be on safe side use a fake account.
* In Travis-CI on settings page for the repo add environment variables
`GITHUB_USER` and `GITHUB_PASSWORD`. Ensure that the "Display value in build log"
is set to false. It is possible to add these in ".travis.yml", but don't as all
forks as well as original repo will be using different accounts for testing, so
it will cause problems during merge.
