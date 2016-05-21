def issues
    [
        {
            title: "Test Issue",
            des: <<EOF,
This is a test issue. Here is some random description. Some random feature is
not working. I don't know what's wrong. The os is ubuntu 16.04.
EOF

            assign: "ghitest",
            milestone: "1",
            labels: ["help-wanted", "wontfix", "bug" ]
        }
    ]
end

def comments
    [ 
        "This is first test comment",
        "This is second test comment"
    ]
end
