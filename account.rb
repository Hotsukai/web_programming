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
        rows_user_info=db.execute('select * from user where id=?;',account_id)
        user_name=db.execute('select name from user where id=?;',account_id)[0][0]
        rows_user_tweets=db.execute('select * from tweet where user_id=?;',account_id)
        rows_is_I_follow=db.execute('SELECT * FROM relation WHERE user_id=? AND follower_id=?;',account_id,user_id)
        rows_is_follow_me=db.execute('SELECT * FROM relation WHERE user_id=? AND follower_id=?;',user_id,account_id)
        rows_is_follower=db.execute('SELECT follower_id FROM relation WHERE user_id=?;',account_id)
        rows_is_follow=db.execute('SELECT user_id FROM relation WHERE follower_id=?;',account_id)
       
        print <<EOF
        <html>
    
            <head>
                <meta charset="utf-8">
                <title>Twintter | #{user_name}</title>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.1.2/css/bulma.css">
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
                <script type="text/javascript" src="myfile.js"></script>
                <script type="text/javascript" src="tab.js"></script>
            </head>
            <style>
                .main {
                    background-color: #eeeeee;
                    padding:20px;
                }
                .area ul{
                    display: none;
                }
                .area ul.show {
                    display: block;
                }
            </style>
            <body>
                <div class="hero is-info"  aria-label="main navigation">
                    <a href="index.rb"><h1 class="title is-1">Twintter</h1></a>
                </div>
                <div class="main">
                    <p>
                    あなたのid : #{user_id}
                    </p>
                    <div class="card">

EOF

    #ユーザー情報を出力
    
        rows_user_info.each{|row|
            puts("<p>#{row[0]} #{row[1]} #{row[2]} #{row[3]}</p>")
            }
        #     #FFのリストをここに出力
        # puts("<p>#{rows_is_follow_me}</p>")
        # puts("<p>#{rows_is_follow_me.length}</p>")



        puts("<p><a href=\"follow_list.rb?account_id=#{account_id}\">フォロー#{rows_is_follow.length}</a>    <a href=\"follower_list.rb?account_id=#{account_id}\">フォロワー#{rows_is_follower.length}</a></p>")

        if user_id.to_i==account_id.to_i then 
            
            print("<a  href=\"update_profile_form.rb\"><button class=\"button is-info\"> プロフィールを更新する</button></a></p>")
        else
        #  ここにふぉろーを書く。relationから取得した結果に応じてフォローか解除化を決める
            if rows_is_I_follow.length==0 then 
                print("<a href=\"follow.rb?account_id=#{account_id}\"><button class=\"button is-info\">フォローする</button></a>")
            else
                print("<a href=\"follow.rb?account_id=#{account_id}\"><button class=\"button is-info\">リムーブする</button></a>")
            end

            if rows_is_follow_me.length==0 then 
                print("<p>フォローされていません</p>")
            else
                print("<p>フォローされています</p>")
            end
            
        end
        puts("</div>")
    #アカウントのツイートを出力
        rows_user_tweets.reverse_each{|row_tweets|
            puts("<li class=\"box\"><a href=\"account.rb?account_id=#{row_tweets[1]}\">user_id:#{row_tweets[1]} #{user_name}</a> <br>#{row_tweets[2]} <br> tweet_id:#{row_tweets[0]}  #{row_tweets[3]}</li>")
            }
    print <<EOS
            
            <p><a href="index.rb">タイムラインに戻る</a></p>
            </div>
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