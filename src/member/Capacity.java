package member;

import java.sql.*;
import java.util.*;

public class Capacity {
	Connection conn = null;
    Statement st = null;
    ResultSet rs = null;
    
    String url = "jdbc:postgresql://127.0.0.1:5432/workshop";
    String user = "postgres";
    String password = "postgres";
    
    public String getCpt(int n) {
    	String result = "";
    	try {
            conn = DriverManager.getConnection(url, user, password);
            st = conn.createStatement();
            rs = st.executeQuery("SELECT capacity from shelter where no="+n);
            if (rs.next())
                result = rs.getString(1);
        } catch (SQLException sqlEX) {
            System.out.println(sqlEX);
        } finally {
            try {
                rs.close();
                st.close();
                conn.close();
            } catch (SQLException sqlEX) {
                System.out.println(sqlEX);
            }
        }
    	return result;
    }

}
