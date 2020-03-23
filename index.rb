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


    # user_id=(session["u_id"]||-1)
    user_id=(cookies["u_id"][0]||-1).to_i
    new_cookie=CGI::Cookie.new("name"=>"u_id","value"=>user_id.to_s)
    print cgi.header("type"=>"text/html", "charset"=>"utf-8","cookie"=>[new_cookie])

    print <<EOF
<html>
    <head>
        <meta charset="utf-8">
        <title>Twintter</title>
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
EOF
    if user_id==-1 then 
        print <<EOF    
    <body>
        <div class="hero is-info"  aria-label="main navigation">
            <a href="index.rb"><h1 class="title is-1">Twintter</h1></a>
        </div>
        <div class="box">
            <h2 class="title">アカウント作成</h2>
            <p>アカウント情報を入力してください。<br>※パスワードは暗号化等されていないのでテキトーなものにしてください</p>
                <form method="post" action="register.rb" onsubmit="return Pre_check()">
                    <p>ユーザー名<input type="text" name="_u_name" id="check"  maxlength="10"></p>
                    <p>パスワード<input type="password" name="_password" maxlength="10"></p>
                    <p><input type="submit" value="登録"></p>
                </form>
        </div>
        <div class="box">
            <h2 class="title">ログイン</h2>
                <form method="post" action="login.rb">
                    <p>アカウント：<br>
                        <select name="account_id">
EOF
user_id=""
user_name=""
user_data=db.execute('select id , name from user;')

user_data.each{|row_user_data|
    user_id=row_user_data[0]
    user_name=row_user_data[1]
    print("<option value=\"#{user_id}\">#{user_id}:#{user_name}</option>")

}

        print <<EOF
                    </select>
                </p>
                <p>パスワード<input type="password" name="_password" maxlength="4"></p>
                <p><input type="submit" value="ログイン"></p>
            </form>
        </div>
            <script type="text/javascript" src="myfile.js"></script>
    </body>
</html>
EOF
    else 
        user_name=""
        profile=""
        db.execute('select * from user where id=?;',user_id){|row_tmp|
            user_name=row_tmp[1]
            profile=row_tmp[2]
        }
        rows_is_follower=db.execute('SELECT follower_id FROM relation WHERE user_id=?;',user_id)
        rows_is_follow=db.execute('SELECT user_id FROM relation WHERE follower_id=?;',user_id)
        print <<EOF
    <body>
        <div class="hero is-info"  aria-label="main navigation">
            <a href="index.rb"><h1 class="title is-1">Twintter</h1></a>
        </div>
        <div class="main">
            <div class="columns">
                <div class="column">
                    <div class="box">
                        <a href="account.rb?account_id=#{user_id}"><h3 class="title is-3">あなたのプロフィール</h2></a>
                        <p>
                            あなたのid : #{user_id} <br>
                            ユーザー名 : #{user_name} <br>
                            ひとこと : #{profile} <br>
                            <a href="follow_list.rb?account_id=#{user_id}">フォロー#{rows_is_follow.length}</a>    
                            <a href="follower_list.rb?account_id=#{user_id}">フォロワー#{rows_is_follower.length}</a><br>

                            <a  href="update_profile_form.rb"><button class="button is-info"> プロフィールを更新する</button></a>
                            <a  href="account.rb?account_id=#{user_id}"><button class="button is-info"> 詳しく見る</button></a>
                            </p>  
                    </div>
                </div>
                <div class="column">
                    <div class="box">
                        <h3 class="title is-3">ツイートする</h2>
                        <form method="post" action="tweet.rb" onsubmit="return Pre_check()">
                            <div class="form-group">
                                <textarea class="form-control" id="check" name="tweet" cols="14" rows="10" maxlength="140" placeholder="いまなにしてる?" required></textarea>
                            </div>
                            <button type="submit" class="button is-info">ツイート</button>
                        </form>
                    </div>
                </div>
            </div>
            <div class="box">
                <div class="tabs is-fullwidth is-toggle">
                    <ul class="tab">
                        <li class="is-active">
                            <a><h3 class="title is-3">ツイート一覧</h3></a>
                        </li>
                        <li>
                            <a><h3 class="title is-3">タイムライン</h3></a>
                        </li>
                    </ul>
                </div>
                <div class="area">
                    <ul class="show">
                        <p>すべてのユーザーのツイートが表示されます</p>

EOF
        rows_tweets=db.execute('select * from tweet LIMIT 300;')
        tweet_user=""
        rows_tweets.reverse_each{|row_tweets|
            db.execute('select name from user where id=?;',row_tweets[1]){|row2|
                tweet_user=row2[0]
            }
            puts("<li class=\"box\"><a href=\"account.rb?account_id=#{row_tweets[1]}\">user_id:#{row_tweets[1]} #{tweet_user}</a> <br>#{row_tweets[2]} <br> tweet_id:#{row_tweets[0]}  #{row_tweets[3]}</li>")
        }
                    
        print <<EOF
                    </ul>
                    <ul>
                    <p>フォローしているユーザーのツイートのみ表示されます</p>

EOF

        rows_is_follow=db.execute('SELECT user_id FROM relation WHERE follower_id=?;',user_id)
        if rows_is_follow.empty? then
            puts("フォローしているアカウントがありません")
        else
            rows_tweets.reverse_each{|row_tweets| 
                rows_is_follow.each{|row_is_follow|
                # puts("<hr>")
                # print("<p>DEBUG1 フォローしているユーザー #{row_is_follow[0]} </p>")
                # print("<p>DEBUG2 ツイートユーザー #{row_tweets[1]} </p>")
                
                if row_is_follow[0]==row_tweets[1] then
                    db.execute('select name from user where id=?;',row_tweets[1]){|row2|
                        tweet_user=row2[0]
                    }
                    puts("<li class=\"box\"><a href=\"account.rb?account_id=#{row_tweets[1]}\">user_id:#{row_tweets[1]} #{tweet_user}</a> <br>#{row_tweets[2]} <br> tweet_id:#{row_tweets[0]}  #{row_tweets[3]}</li>")
                    break
                end
                }
            }
        end
        print <<EOF
                    </ul>
                </div>
            </div> 
        </div>
    </body>
</html>
EOF

db.close()
# session.close()

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
# session.close()

end
