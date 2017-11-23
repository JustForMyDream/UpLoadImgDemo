package serlvet;

import com.google.gson.Gson;
import sun.misc.BASE64Decoder;
import util.ResponseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;


@WebServlet(name = "UpLoadImgServlet", value = ("/UpLoadImgServlet"))
public class UpLoadImgServlet extends HttpServlet {

    private static final String imgpath  = "E:/SC/bin/apache-tomcat-7.0.57/webapps";
    private static final String imgpre = "/uploadImg/2017/";
    private static final String filepath = imgpath + imgpre;
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request,response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Map<String,String> map = new HashMap<String, String>();
        try{
            System.out.println("===============《《图片开始上传》》=============");
            String imgFile = request.getParameter("imgFile");
            String imgName = request.getParameter("imgName");

            //如果request没有取得参数
            if(imgFile == null || imgName == null){
                String params = (String) request.getAttribute("params");
                if(params != null && imgFile == null && params.indexOf("imgFile=") != -1){
                    imgFile = params.substring(params.indexOf("imgFile=") + "imgFile=".length(), params.indexOf("&imgName="));
                    System.out.println();
                }else {
                    System.out.println("imgFile参数错误");
                    map.put("state","error");
                    map.put("msg","imgFile参数错误");
                    ResponseUtil.response(response,new Gson().toJson(map));
                    return;
                }
                if (params != null && imgName == null && params.indexOf("imgName=") != -1) {
                    imgName = params.substring(params.indexOf("imgName=") + "imgName=".length());
                }else {
                    System.out.println("imgName参数错误");
                    map.put("state","error");
                    map.put("msg","imgName参数错误");
                    ResponseUtil.response(response,new Gson().toJson(map));
                    return;
                }
            }
            //对参数为空进行判断
            if("".endsWith(imgFile.trim()) || "".endsWith(imgName.trim())){
                System.out.println("参数为空");
                map.put("state","error");
                map.put("msg","参数为空");
                ResponseUtil.response(response,new Gson().toJson(map));
                return;
            }

            imgName = URLDecoder.decode(imgName,"utf-8");//前面进行了两次编码，这里需要用解码器解码一次

            String path = filepath +imgName;//Windows文件保存路径
            File file = new File(filepath);
            if(!file.exists() && !file.isDirectory()){//如果文件夹不存在则创建
                System.out.println("文件目录不存在，开始创建");
                if (!file.mkdirs()) {
                    System.out.println("文件目录创建失败");
                    map.put("state","error");
                    map.put("msg","文件目录创建失败");
                    ResponseUtil.response(response,new Gson().toJson(map));
                    return;
                }
            }

            //打开输出流的路径
            FileOutputStream os = new FileOutputStream(path);

            //替换字符
            imgFile = imgFile.replaceAll("#wb#", "+");

            BASE64Decoder decoder = new BASE64Decoder();
            byte[] b = decoder.decodeBuffer(imgFile);

            for(int i = 0;i < b.length;i ++){
                if(b[i] < 0){
                    b[i] += 256;
                }
            }

            os.write(b);
            os.flush();
            os.close();
            System.out.println("上传成功,文件保存在："+path);
            map.put("state","success");
            map.put("msg","上传成功");
            ResponseUtil.response(response,new Gson().toJson(map));

        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
