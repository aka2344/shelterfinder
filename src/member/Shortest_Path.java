package member;

import java.sql.*;
import java.util.*;

public class Shortest_Path {
	Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    String url = "jdbc:postgresql://127.0.0.1:5432/workshop";
    String user = "postgres";
    String password = "postgres";
    
    public Shortest_Path() {
    }
    
    public String getNearestNode(double lng, double lat) {
    	String result = "";
    	try {
            conn = DriverManager.getConnection(url, user, password);
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id, ST_AsText(the_geom) AS wkt\r\n" + 
            		"FROM ways_vertices_pgr\r\n" + 
            		"WHERE id IN (SELECT find_nearest_node_within_distance(ST_AsText(ST_GeomFromText('POINT("+ lng + " " + lat + ")', 4326)), 100, 'ways'))");
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
    
    public List<String> getNearestNodes(double lng, double lat, double range) {
    	List<String> result = new ArrayList<String>();
    	try {
            conn = DriverManager.getConnection(url, user, password);
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id from ways_vertices_pgr where ST_dwithin((ST_GeomFromText('POINT("
            +lng+" "+lat+")', 4326)::geography), the_geom::geography, "+range+")");
            while (rs.next())
                result.add(rs.getString(1));
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
    
    public String[] ConnectLine(double lng, double lat, String id) {
    	String[] result = new String[2];
    	try {
            conn = DriverManager.getConnection(url, user, password);
            st = conn.createStatement();
            rs = st.executeQuery("SELECT (ST_MakeLine(the_geom, ST_GeomFromText('POINT("+lng+" "+lat+")', 4326))) as result, ST_length((ST_MakeLine(the_geom, ST_GeomFromText('POINT("+lng+" "+lat+")', 4326))), false) as length from ways_vertices_pgr where id="+id+";");
            while (rs.next()) {  
            	result[0] = rs.getString("result");
            	result[1] = rs.getString("length");
            }
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
    	System.out.println("length : " +result[1]);
    	return result;
    }
    
    public String getShortestPath(double marker_lng, double marker_lat, double shel_lng, double shel_lat){
    	String path = "";
    	String node_start = "";
    	String node_end = "";
    	double length = 0;
    	List<String> node_starts = getNearestNodes(marker_lng, marker_lat, 100);
    	System.out.println(node_starts.toString());
    	List<String> node_ends = getNearestNodes(shel_lng, shel_lat, 100);
    	try {
            conn = DriverManager.getConnection(url, user, password);
            st = conn.createStatement();
            String query = "SELECT sum(length_m) as length, (ST_Collect(the_Geom)) as result, start_vid, end_vid FROM pgr_dijkstra(\r\n" + 
            		"    'SELECT gid as id, source, target, cost, reverse_cost FROM ways',\r\n" + 
            		"     ARRAY"+node_starts.toString()+", ARRAY"+node_ends.toString()+"\r\n" + 
            		") as shortest, ways where gid=edge group by start_vid, end_vid order by sum(ways.cost) limit 1;";
            rs = st.executeQuery(query);
            System.out.println(query);
            while (rs.next()) {
            	path = rs.getString("result");
            	length = Double.parseDouble(rs.getString("length"));
            	node_start = rs.getString("start_vid");
            	node_end = rs.getString("end_vid");
            	}              
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
    	//Connect Start, End Point to each node
    	String[] startL = ConnectLine(marker_lng, marker_lat, node_start);
    	String[] endL = ConnectLine(shel_lng, shel_lat, node_end);
    	String Line_start = startL[0];
    	String Line_end = endL[0];
    	length += Double.parseDouble(startL[1]) + Double.parseDouble(endL[1]);
    	try {
            conn = DriverManager.getConnection(url, user, password);
            st = conn.createStatement();
            rs = st.executeQuery("SELECT (trim( trailing '}' from ST_AsGeoJSON(ST_Collect(ST_Collect('"+Line_start+"', '"+Line_end+"'), '"+path+"')))) || ', \"distance\":"+length+"}' as result;");
            while (rs.next()) {
            	path = rs.getString("result");
            	}              
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
    	return path;
    }
    
    
    
	
}
