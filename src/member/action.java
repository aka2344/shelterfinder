package member;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.*;

/**
 * Servlet implementation class action
 */
@WebServlet("/action")
public class action extends HttpServlet {
	private static final long serialVersionUID = 1L;
	Shortest_Path sp = new Shortest_Path();
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public action() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see Servlet#init(ServletConfig)
	 */
	public void init(ServletConfig config) throws ServletException {
		// TODO Auto-generated method stub
	}

	/**
	 * @see Servlet#destroy()
	 */
	public void destroy() {
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		request.setCharacterEncoding("UTF-8");
		double m1 = Double.parseDouble(request.getParameter("m1"));
		double m2 = Double.parseDouble(request.getParameter("m2"));
		double t1 = Double.parseDouble(request.getParameter("t1"));
		double t2 = Double.parseDouble(request.getParameter("t2"));
		String rst = sp.getShortestPath(m1, m2, t1, t2);
		System.out.println("계산결과:"+rst);
		PrintWriter writer = response.getWriter();
		writer.print(rst);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
