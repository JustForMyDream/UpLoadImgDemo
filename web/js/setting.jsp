<%--suppress JSAnnotator --%>
<%--suppress ALL --%>
<%--suppress ALL --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1,maximum-scale=1,user-scalable=no">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <!--标准mui.css-->
    <link rel="stylesheet" href="../css/mui.min.css">
    <!--App自定义的css-->
    <style>
        .right{
            float: right;
            padding-right: 20px;
            color: #999;
        }
        .top {
            margin-top: 20px;
        }
    </style>
</head>

<body>
<header class="mui-bar mui-bar-nav">
    <a class="mui-action-back mui-icon mui-icon-left-nav mui-pull-left"></a>
    <h1 class="mui-title">设置</h1>
</header>
<div class="mui-content detail1">

    <div class="detail">
        <ul class="mui-table-view">
            <li class="mui-table-view-cell">
                <a id="init" class="mui-navigate-right" href="mod.jsp?type=2&lc=0" >
                    初始里程<span class="right" ><span>0</span>公里</span>
                </a>
            </li>
            <%--<li class="mui-table-view-cell" >--%>
                <%--<a id="pl" class="mui-navigate-right" href="modpl.jsp" >--%>
                    <%--汽车排量<span class="right" ><span>0</span>L</span>--%>
                <%--</a>--%>
            <%--</li>--%>
            <%--<li class="mui-table-view-cell" id="xcby">--%>
                <%--下次保养里程<span class="right" ><span>0</span>公里</span>--%>
            <%--</li>--%>
        </ul>
        <ul class="mui-table-view top">
            <li class="mui-table-view-cell hid">
                <span>屏蔽位置信息</span>
                <div class="mui-switch " id="wz">
                    <div class="mui-switch-handle"></div>
                </div>
            </li>
            <li class="mui-table-view-cell hid">
                <span>屏蔽驻车安全告警</span>
                <div class="mui-switch " id="zc">
                    <div class="mui-switch-handle"></div>
                </div>
            </li>
        </ul>
        <ul class="mui-table-view top">
            <li class="mui-table-view-cell hid">
                <span> 屏蔽行车小秘书</span>
                <div class="mui-switch " id="xc">
                    <div class="mui-switch-handle"></div>
                </div>
            </li>
            <li class="mui-table-view-cell hid">
                <span> 屏蔽行车安全告警</span>
                <div class="mui-switch " id="aq">
                    <div class="mui-switch-handle"></div>
                </div>
            </li>
        </ul>
        <%--<ul class="mui-table-view top">--%>
            <%--<li class="mui-table-view-cell" >--%>
                <%--<a class="mui-navigate-right" href="route.jsp?type=0" >--%>
                    <%--出行提醒--%>
                <%--</a>--%>
            <%--</li>--%>
        <%--</ul>--%>
        <%--<ul class="mui-table-view">--%>
            <%--<li class="mui-table-view-cell" >--%>
                <%--<a class="mui-navigate-right" href="userinfo.jsp" >--%>
                    <%--用户信息--%>
                <%--</a>--%>
            <%--</li>--%>
        <%--</ul>--%>

    </div>
</div>

</body>
<script src="../js/mui.min.js"></script>
<script type="text/javascript" src="../js/jquery-2.1.4.min.js"></script>
<script type="text/javascript" src="../js/server.js"></script>
<script type="text/javascript" src="../js/util.js"></script>

<%--suppress JSAnnotator --%>
<script>
    var type = "<%= request.getParameter("type")%>";
    loadtitle(type);
    mui.init({
        swipeBack: true //启用右滑关闭功能
    });
    $.ajax('../OBDServlet/obdinfo', {
        type: 'post',
        dataType: 'json',
        timeout: 10000,
        success: function (data) {
            console.log("obd");
            console.log(data);
            var href = "";
            var lc = "0";
            var xz = "0";
            var xc = "0";
            var pl = "0";
            if(data){
                if(data.ITEM_CSLC){
                    lc = data.ITEM_CSLC;
                }
                if(data.ITEM_XCBYLC){
                    xc = data.ITEM_XCBYLC;
                }
                if(data.ITEM_CAR_PL){
                    pl = data.ITEM_CAR_PL;
                }
            }
            $("#init").attr("href","mod.jsp?type=1&lc="+lc+"&ptype="+type);
            $("#pl").attr("href","modpl.jsp?pl="+pl+"&ptype="+type);

            $("#init .right span").text(lc);
            $("#xcby .right span").text(xc);
            $("#pl .right span").text(pl);

        },
        error: function (err) {
            console.log(err);
        }
    });

    $.ajax('../UserServlet/SelectUserInfo', {
        type: 'post',
        dataType: 'json',
        timeout: 10000,
        success: function (data) {
            console.log(data);
            var a = new Array();
            a.push(tf(data[0].ITEM_ISPB_POSITION));
            a.push(tf(data[0].ITEM_ISPB_ZCAQ));
            a.push(tf(data[0].ITEM_ISPB_XCMS));
            a.push(tf(data[0].ITEM_ISPB_XCAQ));
            var b = ['wz','zc','xc','aq'];
            for(var i in a){
                if(!a[i]){//如果关闭的话就移除样式
                    $("#"+b[i]+"").removeClass("mui-active");
                }else{//如果打开的话就添加样式
                    $("#"+b[i]+"").addClass("mui-active");
                }
            }
        },
        error: function (err) {
            console.log(err);
        }
    });
    function tf(t) {
        var state = false;
        if(t=="1"){
            state = true;
        }
        return state;
    }

    mui('.mui-content .mui-switch').each(function () { //循环所有toggle
        var flag;
        var id = this.id;
        this.addEventListener('toggle', function (event) {
            //event.detail.isActive 可直接获取当前状态
            var isflag = event.detail.isActive;
            if(isflag){
                flag = "1"
            }else{
                flag = "0";
            }
            console.log(flag);
           var type=  convert(id);
            req(type,flag);
        });
    });

    function convert(t) {
        var type = "";
        switch(t){
            case "wz":type="ITEM_ISPB_POSITION";break;
            case "zc":type="ITEM_ISPB_ZCAQ";break;
            case "xc":type="ITEM_ISPB_XCMS";break;
            case "aq":type="ITEM_ISPB_XCAQ";break;
        }
        return type;
    }
function req(type,ispb){
    $.ajax('../OBDServlet/pb', {
        data:{"type":type,"pb":ispb},
            type: 'post',
            dataType: 'json',
            timeout: 10000,
            success: function (data) {
                console.log(data);
                mui.toast("设置成功")


            },
            error: function (err) {
                console.log(err);
            }
        });
}


//
//    mui(".hid .mui-switch").on("tap",function (event) {
//        var state = event.detail.isActive;
////        ? 'true' : 'false';
//        console.log(state);
////        $.ajax('../OBDServlet/pb', {
////            type: 'post',
////            dataType: 'json',
////            timeout: 10000,
////            success: function (data) {
////                console.log(data);
////                var href = "";
////                var lc = "";
////                if(data){
////                    if(data.ITEM_CSLC){
////                        lc = data.ITEM_CSLC;
////                    }
////                }
////                $("#init").attr("href","mod.jsp?type=1&lc="+lc);
////                $(".right span").text(lc);
////
////            },
////            error: function (err) {
////                console.log(err);
////            }
////        });
//    })


</script>
</html>