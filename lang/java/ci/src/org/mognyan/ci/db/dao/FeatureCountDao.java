package org.mognyan.ci.db.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class FeatureCountDao extends AbstractDao{

	private static final String TABLE = "featurecount";
	private static final String SQL_INSERT = "INSERT INTO " + TABLE + " VALUES (?,?,?);";
	
	private static final String SQL_SELECT = "SELECT * FROM " + TABLE;
	private static final String SQL_UPDATE = "UPDATE" + TABLE +" SET count=?";
	private static final String SQL_DELETE = "DELETE FROM " + TABLE;
	
	/* The feature and category is primary key. */
	private static final String SQL_WHERE = " WHERE feature=? AND category=?;";

	public FeatureCountDao(Connection connection){
		super(connection);
	}

	public boolean insert(String feature, String category){
		boolean result = false;
		Connection con = getConnection();

		try(PreparedStatement ps = con.prepareStatement(SQL_INSERT)){
			ps.setString(1, feature);
			ps.setString(2, category);
			ps.setInt(3, 1);
			result = ps.execute();
		}catch(SQLException sqle){
			sqle.printStackTrace();
		}

		return result;
	}

	public int select(String feature, String category){
		int count = 0;
		Connection con = getConnection();

		try(PreparedStatement ps = con.prepareStatement(SQL_SELECT + SQL_WHERE)){
			ps.setString(1, feature);
			ps.setString(2, category);
			ResultSet rs = ps.executeQuery();
			rs.last();
			int row = rs.getRow();
			
			if (row > 0) {
				rs.first();
				count = rs.getInt(1);
			}
		}catch(SQLException sqle){
			sqle.printStackTrace();
		}

		return count;
	}

	public int update(int nowCount, String feature, String category){
		int effectCount = 0;
		Connection con = getConnection();
		
		try(PreparedStatement ps = con.prepareStatement(SQL_UPDATE + SQL_WHERE)){
			ps.setInt(1, nowCount + 1);
			ps.setString(2, feature);
			ps.setString(3, category);
			effectCount = ps.executeUpdate();
		}catch(SQLException sqle){
			sqle.printStackTrace();
		}
		
		return effectCount;
	}
}