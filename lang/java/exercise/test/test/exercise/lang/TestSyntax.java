package test.exercise.lang;

import static org.hamcrest.CoreMatchers.is;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

public class TestSyntax {
	
	public TestSyntax() {
	}
	
	@BeforeClass
	public static void setUpClass() {
	}
	
	@AfterClass
	public static void tearDownClass() {
	}
	
	@Before
	public void setUp() {
	}
	
	@After
	public void tearDown() {
	}

	@Test
	public void 三項演算子の優先度を調べる(){
		boolean expected = false;
		boolean actual = true ? false : true == true ? false: true;
		
		assertThat(actual, is(expected));
	}
	
}
