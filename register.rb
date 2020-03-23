#!/usr/bin/env ruby
# encoding: utf-8
require "cgi"
# require "cgi/session"
require 'sqlite3'
db_name="twitter.db"

begin
    cgi = CGI.new
    cookies=cgi.cookies
    # session=CGI::Session.new(cgi)
    db = SQLite3::Database.new(db_name)

    user_name=cgi["_u_name"]
    password=cgi["_password"]

    db.transaction(){
        db.execute("INSERT INTO user(name,password) values(?,?);",user_name,password)
    }
    user_id=-1
    db.transaction(){
        db.execute('select id from user where name=?;',user_name){|row|
            user_id=row[0]
        }
    }
    db.close

    # session["u_id"]=user_id
    new_cookie=CGI::Cookie.new("name"=>"u_id","value"=>user_id.to_s)
    print cgi.header("type"=>"text/html", "charset"=>"utf-8","cookie"=>[new_cookie])

    print <<EOF
    <html>

        <head>
            <meta charset="utf-8">
            <title>Twintter | register</title>
        </head>

        <body>
            <h1>Twintter</h1>
            <p>あなたのid:#{user_id}</p>

            <p>#{user_name}を登録しました。</p>
            <p><a href="index.rb">タイムラインに戻る</a></p>
        </body>
    </html>
EOF


rescue =>ex #例外処理
    print <<EOF
    <html><body>
    <p>エラーが発生しました</p>
    <pre>
    #{ex.message}
    #{CGI.escapeHTML(ex.backtrace.join("\n"))}
    </pre>
    </body></html>
EOF
end
# session.close()
