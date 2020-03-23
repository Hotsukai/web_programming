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

    user_id=cgi["account_id"]
    input_password=cgi["_password"]

    db_password=""
    
    db.transaction(){
        db.execute('select password from user where id=?;',user_id){|row|
            db_password=row[0]
        }
    }
    db.close
    if db_password==input_password then 
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

            <p>ログインに成功しました。</p>
            <p><a href="index.rb">タイムラインに戻る</a></p>
        </body>
    </html>
EOF
    else
        print cgi.header("type"=>"text/html", "charset"=>"utf-8")
        print <<EOF
    <html>

        <head>
            <meta charset="utf-8">
            <title>Twintter | register</title>
        </head>

        <body>
            <h1>Twintter</h1>
            <p>ログインに失敗しました。</p>
            <p><a href="index.rb">登録に戻る</a></p>
        </body>
    </html>
EOF
    end


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
