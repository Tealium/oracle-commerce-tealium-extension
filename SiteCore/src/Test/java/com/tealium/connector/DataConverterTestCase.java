package com.tealium.connector;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.CharBuffer;

import org.junit.Before;
import org.junit.Test;

import atg.core.util.StringUtils;

import com.tealium.config.TealiumConfiguration;

public class DataConverterTestCase {

	private static final URL GENERIC_TAG_WITH_UTAG = DataConverter.class.getResource("GENERIC_TAG_WITH_UTAG.txt");

	private TealiumConfiguration config;
	private DataConverter testInstance;

	private static String readResource(URL resource) throws IOException {
		Reader inp = null;
		try {
			inp = new BufferedReader(new InputStreamReader(resource.openStream()));
			StringBuilder result = new StringBuilder();
			CharBuffer charBuff = CharBuffer.allocate(128);
			while (-1 != inp.read(charBuff)) {
				charBuff.flip();
				result.append(charBuff.toString());
				charBuff.clear();
			}
			return result.toString();
		} finally {
			if (null != inp) {
				inp.close();
			}
		}
	}

	@Before
	public void setUp() throws Exception {
		this.config = new TealiumConfiguration();
		this.config.setEnabled(true);
		this.config.setAccountName("testAccount");
		this.config.setProfileName("testProfile");
		this.config.setEnvironmentName("testEnv");
		this.testInstance = new DataConverter();
		this.testInstance.setConfiguration(this.config);
		this.testInstance.doStartService();
	}

	@Test
	public void shouldProduceUtagSynckScript() throws Exception {
		this.config.setUtagSyncEnabled(true);
		assertTrue(
				"Wrong utag synck script generated",
				this.testInstance.getSyncTag().contains(
						"src=\"//tags.tiqcdn.com/utag/testAccount/testProfile/testEnv/utag.sync.js\""));
	}

	@Test
	public void shouldProduceEmptyStrWhenUtagSynckDisabled() throws Exception {
		this.config.setUtagSyncEnabled(false);
		assertTrue("UtagSynk Tag produced, when it is disabled", StringUtils.isBlank(this.testInstance.getSyncTag()));
	}

	@Test
	public void shouldProduceGenericTagWithUTAG() throws Exception {
		assertEquals("Wrong tag produced", readResource(GENERIC_TAG_WITH_UTAG),
				this.testInstance.getGenericPageScript("testPage", "USD", "en"));
	}

	@Test
	public void shouldProduceEmptyGenericScriptWhenAllDisabled() throws Exception {
		this.config.setEnabled(false);
		assertTrue("Should be en empty string",
				StringUtils.isBlank(this.testInstance.getGenericPageScript("testPage", "USD", "en")));
	}

}
