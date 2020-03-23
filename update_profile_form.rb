#!/usr/bin/env ruby
# encoding: utf-8

begin
    require "cgi"
    # require "cgi/session"
    require 'sqlite3'

    cgi = CGI.new
    db_name="twitter.db"
    db = SQLite3::Database.new(db_name)
    # session=CGI::Session.new(cgi)

    cookies=cgi.cookies
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
    user_name=db.execute('select name from user where id=?;',user_id)[0][0]
    user_profile=(db.execute('select profile from user where id=?;',user_id)[0][0]||"")
        print <<EOF
            <html>
    
            <head>
                <meta charset="utf-8">
                <title>Twintter | プロフィールの更新</title>
            </head>
    
            <body>
                <h1>Twintter</h1>
                
                <p>
                あなたのid :@
                #{user_id}

                </p>
        <form method="post" action="update_profile.rb" onsubmit="return Pre_check()">
            <p>ユーザー名<input type="text" name="_u_name" id="check" value="#{user_name}" maxlength="10"></p>
            <p>ひとこと<textarea name="profile" cols="14" rows="10" maxlength="140" >#{user_profile}</textarea></p>
            <p><input type="submit" value="変更"></p>
        </form>
        <p><a href="index.rb">タイムラインに戻る</a></p>
        <script type="text/javascript" src="myfile.js"></script>

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
    # session.close