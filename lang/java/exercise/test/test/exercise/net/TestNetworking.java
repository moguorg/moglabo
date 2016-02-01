package test.exercise.net;

import java.net.MalformedURLException;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.net.InetAddress;
import java.util.Collections;
import java.util.Enumeration;
import static java.util.stream.Collectors.*;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

import exercise.net.Networks;

public class TestNetworking {

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

	private URL getSampleURL() throws MalformedURLException {
		String protocol = "http";
		int port = 80;
		String host = "localhost";
		String userInfo = "testuser:testpassword";

		return new URL(protocol, userInfo + "@" + host,
			port, "/webcise/studyinghtml5/websocket/index.html?id=12345#ResultArea");
	}

	@Test
	public void URLから情報を取得する() throws MalformedURLException {
		URL url = getSampleURL();

		System.out.println("getProtocol=" + url.getProtocol());
		System.out.println("getHost=" + url.getHost());
		System.out.println("getPort=" + url.getPort());
		System.out.println("getDefaultPort=" + url.getDefaultPort());
		System.out.println("getQuery=" + url.getQuery());
		System.out.println("getPath=" + url.getPath());
		System.out.println("getRef=" + url.getRef());
		/**
		 * getUserInfoが常にnullになってしまう。
		 */
		System.out.println("getUserInfo=" + url.getUserInfo());
		System.out.println("getAuthority=" + url.getAuthority());
		System.out.println("getFile=" + url.getFile());

		System.out.println(url);
	}

	private static class NifInfo{
		private final String name;
		private final List<InetAddress> address;

		public NifInfo(String name, Enumeration<InetAddress> address) {
			this.name = name;
			this.address = Collections.list(address);
		}

		@Override
		public String toString() {
			List<String> result;
			
			if(!address.isEmpty()){
				result = address.stream()
					.map(addr -> name + ":" + addr)
					.collect(toList());
			}else{
				result = new ArrayList<>();
				result.add(name + ":no ip address");
			}
			
			return result.toString();
		}
	}
	
	@Test
	public void ネットワークインターフェースの一覧を取得する() throws SocketException {
		List<NetworkInterface> nifs = Networks.getNetworkInterfaces(ArrayList::new);
		
		assertTrue(!nifs.isEmpty());
		
		nifs.stream()
			.map(nif -> new NifInfo(nif.getName(), nif.getInetAddresses()))
			.forEach(info -> System.out.println(info));
	}

}
