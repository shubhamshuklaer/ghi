module GHI
  module Commands
    class Pull::Create < Pull
      def options
        OptionParser.new do |opts|
          opts.banner = "create - creates a new pull request from your editor"
        end
      end

      def execute
        editor.start(template)
        editor.require_content_for(:title, :base, :head, :body)
        editor.check_uniqueness(:base, :head)
        editor.unlink

        begin
          #res = throb { api.post pull_uri.chop, editor.content }.body
          puts fg('2cc200') { "Pull request ##{res['number']} successfully created!" }
        rescue
          # TODO
          puts "Something went wrong"
        end
      end

      private

      def editor
        @editor ||= Editor.new('GHI_PULL_REQUEST')
      end

      def create_uri
        "/repos/#{repo}/pulls"
      end

      def head
        @head ||= "#{origin[:user]}:#{current_branch}"
      end

      def base
        @base ||= "#{(upstream || origin)[:user]}:master"
      end

      def title
        current_branch.capitalize.split('_').join(' ')
      end

      def body
        ''
      end

      def template
        <<EOF
@ghi-title@ #{title}
@ghi-head@  #{head}
@ghi-base@  #{base}

#{body}
#{template_explanation}
EOF
      end

      def template_explanation
<<EOF
# Please explain the pull request. You can edit title, head and base but
# don't touch the keywords itself. Use the empty section as the message's
# body. Trailing lines starting with '#' (like these) will be ignored,
# and empty messages will not be submitted. Issues are formatted with
# GitHub Flavored Markdown (GFM):
#
#   http://github.github.com/github-flavored-markdown
EOF
      end
    end
  end
end
