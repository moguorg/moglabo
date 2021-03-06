package webcise;

import java.io.IOException;
import java.io.PrintWriter;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "CspReport", urlPatterns = {"/CspReport"})
public class CspReport extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 違反報告JSONはそれほど大きいオブジェクトにならないはずなので
        // JsonObjectを使っている。もし大きくなりそうな時はJsonParserを
        // 使うべきかもしれない。
        try (JsonReader reader = Json.createReader(request.getInputStream())) {
            JsonObject jsonObject = reader.readObject();
            String allResult = jsonObject.toString();
            System.out.println(allResult);
            
            // リクエストボディの違反報告JSONをレスポンスとして返すことで
            // ブラウザのデバッガでも内容を確認できるようにする。しかしブラウザには
            // レスポンスが返ってこない。
            PrintWriter out = response.getWriter();
            out.print(allResult);
        }
    }
    
}
