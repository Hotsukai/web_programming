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
                <h2>#{account_id}のフォロワーリスト</h2>
EOF

    #ユーザー情報を出力
 
        #フォロワーのidをとってくる 0:user_id 1:follower_id
        rows_is_follower=db.execute('SELECT follower_id FROM relation WHERE user_id=?;',account_id)

        #フォロワーのユーザー名をとってくる
        rows_is_follower.each{|row_is_follower|
            follower_id=row_is_follower[0]
            rows_user_name=db.execute('select name from user where id=?;',follower_id)
            # print("#{rows_user_name[0]}")

            rows_user_name.each{|row_user_name|
                follower_name=row_user_name[0]
                puts("<div><a href=\"account.rb?account_id=#{follower_id}\">user_id:#{follower_id} #{follower_name}</a></div>")

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