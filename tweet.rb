#!/usr/bin/env ruby
# encoding: utf-8

begin
    require "cgi"
    # require "cgi/session"
    require 'sqlite3'
    cgi = CGI.new
    cookies=cgi.cookies

    # print cgi.header("type"=>"text/html", "charset"=>"charset=utf-8")
    # session=CGI::Session.new(cgi)
    db_name="twitter.db"
    db = SQLite3::Database.new(db_name)

    user_id=(cookies["u_id"][0]||-1).to_i
    new_cookie=CGI::Cookie.new("name"=>"u_id","value"=>user_id.to_s)
    print cgi.header("type"=>"text/html", "charset"=>"utf-8","cookie"=>[new_cookie])


    tweet_message=cgi['tweet']
    tweet_files=cgi['files']

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
        db.transaction(){
            db.execute("INSERT INTO tweet(user_id,messages,time) values(?,?,datetime('now','localtime'));",user_id,tweet_message)
        }
        db.close()
    print <<EOS
        <html>

        <head>
            <meta charset="utf-8">
            <title>Twintter | つぶやく</title>

        </head>

        <body>
            <h1>Twintter</h1>
            <p>
                あなたのid :@
                #{user_id}
                </p>
            <p>ツイートが投稿されました。</p>
                #{user_id}
                #{tweet_message}

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
    session.close