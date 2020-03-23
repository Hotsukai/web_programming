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
    new_profile=(cgi["profile"]||-1)
    new_user_name=(cgi["_u_name"]||-1)
    new_file=(cgi["files"]||-1)

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
        str="UPDATE user SET"
        if new_profile != -1 then
            str=str+" profile=" +"\""+ new_profile+"\","
        end
        if new_user_name != -1 then
            str=str+" name=" + +"\""+new_user_name+"\","
        end
        # if new_file != -1 then
        #     str=str+ " icon=" +  new_e 
        # end
        str=str.chop
        str=str + " WHERE id="+user_id.to_s+";"
        # print(str)
        db.execute(str)

        print <<EOF
        <html>

        <head>
            <meta charset="utf-8">
            <title>Twintter </title>
        </head>

        <body>
            <h1>Twintter</h1>
            
            <p>
            あなたのid :@
            #{user_id}
            </p>
EOF
        rows=db.execute('select * from user where id=?;',user_id)

        rows.each{|row|
            puts("<p>#{row[0]} #{row[1]} #{row[2]} #{row[3]}</p>")
            }
        print <<EOS
        <p>プロフィールを更新しました</p>
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
db.close()
session.close()

end
