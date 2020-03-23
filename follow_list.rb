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
        print <<EOF
            <html>
    
            <head>
                <meta charset="utf-8">
                <title>Twintter </title>
            </head>
    
            <body>
                <h1>Twintter</h1>
                
                <p>
                あなたのid : #{user_id}
                </p>
                <h2>#{account_id}のフォローリスト</h2>
EOF

    #ユーザー情報を出力
 
        #フォローのidをとってくる 0:user_id 1:follower_id
        rows_is_follow=db.execute('SELECT user_id FROM relation WHERE follower_id=?;',account_id)

        #フォロワーのユーザー名をとってくる
        rows_is_follow.each{|row_is_follow|
            follow_id=row_is_follow[0]
            rows_user_name=db.execute('select name from user where id=?;',follow_id)
            # print("#{rows_user_name[0]}")

            rows_user_name.each{|row_user_name|
                follow_name=row_user_name[0]
                puts("<div><a href=\"account.rb?account_id=#{follow_id}\">user_id:#{follow_id} #{follow_name}</a></div>")

            }
        }
       
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