function Pre_check() {
    var name = document.getElementById("check").value;//名前を取得
    // console.log(id);
    // console.log(name);
    str = "<.*>"//正規表現を指定
    reg_obj = new RegExp(str, "g")//正規表現を指定
    result_name = name.match(reg_obj)//正規表現を利用

    if (name.length == 0) {
        bool = false; alert("名前を入力してください。");
    } else if (result_name != null) {
        bool = false; 
        alert("HTMLタグは使えません。");
        // alert(result_name);

    } else {
        bool = true;
    }
    return bool;

}
