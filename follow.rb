#!/usr/bin/env ruby
# encoding: utf-8

begin
    require "cgi"
    # require "cgi/session"
    require 'sqlite3'
    cgi = CGI.new
    cookies=cgi.cookies
    # session=CGI::Session.new(cgi)
    db_name="twitter.db"
    db = SQLite3::Database.new(db_name)
    account_id=cgi["account_id"]
    # user_id=(session["u_id"]||-1)
    user_id=(cookies["u_id"][0]||-1).to_i
    new_cookie=CGI::Cookie.new("name"=>"u_id","value"=>user_id.to_s)
    print cgi.header("type"=>"text/html", "charset"=>"utf-8","cookie"=>[new_cookie])

    if user_id==-1 then 
        print <<EOF
            <html>
    
            <head>
                <meta charset="utf-8">
                <title>Twintter</title>
    
            </head>
    
            <body>
                <h1>Twintter</h1>
                <p>アカウント登録がお済み出ないようです</p>
                <p><a href="index.rb">登録する</a></p>
                </body>
            </html>
EOF
    else 
        user_name=db.execute('select name from user where id=?;',account_id)[0][0]
        rows=db.execute('SELECT * FROM relation WHERE user_id=? AND follower_id=?;',account_id,user_id)
        print <<EOF
            <html>
    
            <head>
                <meta charset="utf-8">
                <title>Twintter | #{user_name}</title>
            </head>
    
            <body>
                <h1>Twintter</h1>
                
                <p>
                あなたのid : #{user_id}
                </p>
                
EOF
    if rows.empty? then 
        print("<p>#{account_id} #{user_name}をフォローしました</p>")
        db.transaction(){
            db.execute("INSERT INTO relation(user_id,follower_id) values(?,?);",account_id,user_id)
        }
    else
    #  ここにふぉろーを書く。relationから取得した結果に応じてフォローか解除化を決める
    print("<p>#{rows[0][1]} #{user_name}をリムーブしました</p>")
        db.transaction(){
            db.execute("DELETE FROM relation WHERE user_id =? AND follower_id=?;",account_id,user_id)
        }

    end

    print <<EOS
            <p><a href="account.rb?account_id=#{account_id}">アカウントページに戻る</a></p>
            <p><a href="index.rb">タイムラインに戻る</a></p>
            </body>
            </html>
EOS
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
    # session.close