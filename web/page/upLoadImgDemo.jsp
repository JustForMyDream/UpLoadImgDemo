<%--
  Created by IntelliJ IDEA.
  User: 王玉粮
  Date: 2017/11/21
  Time: 10:34
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>上传图片测试</title>
    <meta name="viewport" content="width=device-width, initial-scale=1,maximum-scale=1,user-scalable=no">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <!--标准mui.css-->
    <link rel="stylesheet" href="../css/mui.min.css">
    <style>
        .my_app {
            margin-top: 44px;
        }

        input {
            border: none;
        }
        #wbpz {
            width: 65%;
            float: right;
        }


    </style>
</head>
<body>
<div class="my_app">
    <ul class="mui-table-view">
        <li class="mui-table-view-cell">
            <div class="mui-input-row">
                <label>维保凭证:</label>
                <img id="wbpz" src="../img/xzwbjl.png">
            </div>
        </li>
        <li class="mui-table-view-cell">
            <div class="mui-input-row">
                <button id="save" type="button" class="mui-btn mui-btn-primary">新增</button>
            </div>
        </li>
    </ul>
</div>
<input type="file" name="file" style="display:none;" onchange="previewImg(this);" id="upload" accept="image/*" >

<script src="../js/jquery-3.1.1.min.js"></script>
<script>

    var g_imageFile;  //全局变量上传图片文件
    var g_imageName;  //全局变量上传图片名称
    var g_maxLen = 720;     //全局变量缩放最大宽度

    window.onload = function () {
        $("#wbpz").on("click", function () {
            uploadBtn();
        })

        $("#save").on("click", function () {
            console.log("g_imageFile:" + g_imageFile);
            uploadImg(g_imageFile);
        })
    }

    function uploadBtn() {
        $("#upload").click();
    }


    //图片预览
    function previewImg(imgFile) {
        console.log(imgFile);//这里打印出是整个input标签
        var extension = imgFile.value.substring(imgFile.value.lastIndexOf("."), imgFile.value.length);//扩展名
        extension = extension.toLowerCase();//把文件扩展名转换为小写
        if ((extension != '.jpg') && (extension != '.gif') && (extension != '.jpeg') && (extension != '.png') && (extension != '.bmp')) {
            console.log("对不起，系统仅支持标准格式的照片，请您调整格式后重新上传，谢谢 !");
            $(".btn-uploading").focus();//将焦点定位在文件上传的按钮上，可以直接按确定键再次触发
        } else {
            var path;//预览地址
            if (document.all) {//IE
                imgFile.select();
                path = document.selection.createRange().text;
            } else {//火狐，谷歌
                path = window.URL.createObjectURL(imgFile.files[0]);
            }
            $("#wbpz").attr("src", path);//设置预览地址
            g_imageFile = imgFile;
            g_imageName = uuid() + ".jpg";
        }
    }

    //开始上传
    function uploadImg(imgFile) {
        //获取图片文件
        if (imgFile == null) {
            console.log("请选择图片！");
        } else {
            var file = imgFile.files[0];//文件对象
            var name = g_imageName;//图片名
            //var size = file.size;//图片大小
            //var type = file.type;//文件类型

            //检测浏览器对FileReader的支持
            if (window.FileReader) {
                var reader = new FileReader();
                reader.onload = function () {//异步方法,文件读取成功完成时触发
                    ImgToBase64(file, g_maxLen, function (base64) {
                        syncUpload(name, base64);
                    });
                };
                reader.readAsDataURL(file);//将文件读取为 DataURL
            } else {
                layer.msg("浏览器不支持H5的FileReader!");
            }
        }
    }

    function syncUpload(name, dataImg) {
        console.log("-----------------开始上传图片------------");
        var imgFile = dataImg.replace(/\+/g, "#wb#");//将所有“+”号替换为“#wb#”
        imgFile = imgFile.substring(imgFile.indexOf(",") + 1);//截取只保留图片的base64部分,去掉了data:image/jpeg;base64,这段内容
        name = encodeURIComponent(encodeURIComponent(name));//这里对中文参数进行了两次URI编码，后台容器自动解码了一次，获取到参数后还需要解码一次才能得到正确的参数内容
        console.log("imgFile:" + dataImg.length)
        var mydata = "imgFile=" + imgFile + "&imgName=" + name;
        $.ajax({
            url: "../UpLoadImgServlet",
            data: mydata,
            type: "post",
            dataType: "json",
            success: function (data) {
                console.log("---上传图片返回的数据----" + data);
                if (data.state == 'ok') {
                    document.getElementById("upload").value = "";//重置文件域
                    console.log(data.msg);
                } else if (data.state == 'error') {
                    console.log(data.msg);
                }
            }
        });
    }

    //生成UUID
    function uuid() {
        var s = [];
        var hexDigits = "0123456789abcdef";
        for (var i = 0; i < 36; i++) {
            s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
        }
        s[14] = "4";  // bits 12-15 of the time_hi_and_version field to 0010
        s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01
        s[8] = s[13] = s[18] = s[23] = "-";

        var uuid = s.join("");
        return uuid;
    }

    /**
     * 压缩Base64
     * @param file 文件名
     * @param maxLen 最大长度
     * @param callBack 回调函数
     * @constructor
     */
    function ImgToBase64(file, maxLen, callBack) {
        var img = new Image();

        var reader = new FileReader();//读取客户端上的文件
        reader.onload = function () {
            var url = reader.result;//读取到的文件内容.这个属性只在读取操作完成之后才有效,并且数据的格式取决于读取操作是由哪个方法发起的.所以必须使用reader.onload，
            img.src = url;//reader读取的文件内容是base64,利用这个url就能实现上传前预览图片
        };
        img.onload = function () {
            //生成比例
            var width = img.width, height = img.height;
            //计算缩放比例
            var rate = 1;
            if (width >= height) {
                if (width > maxLen) {
                    rate = maxLen / width;
                }
            } else {
                if (height > maxLen) {
                    rate = maxLen / height;
                }
            };
            img.width = width * rate;
            img.height = height * rate;
            //生成canvas
            var canvas = document.createElement("canvas");
            var ctx = canvas.getContext("2d");
            canvas.width = img.width;
            canvas.height = img.height;
            ctx.drawImage(img, 0, 0, img.width, img.height);
            var base64 = canvas.toDataURL('image/jpeg', 0.9);
            callBack(base64);
        };
        reader.readAsDataURL(file);
    }

</script>
</body>
</html>

