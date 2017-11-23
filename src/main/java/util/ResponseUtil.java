package util;

import javax.servlet.http.HttpServletResponse;

public class ResponseUtil {
    public static void response(HttpServletResponse response,String content){
        response.setContentType("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        try{
            response.getWriter().print(content);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
