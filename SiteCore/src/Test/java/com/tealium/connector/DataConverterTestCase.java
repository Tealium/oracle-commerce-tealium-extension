package com.tealium.connector;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.CharBuffer;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

import atg.beans.PropertyNotFoundException;
import atg.commerce.pricing.PricingTools;
import atg.core.util.StringUtils;
import atg.repository.MutableRepositoryItem;
import atg.repository.RepositoryItem;
import atg.userprofiling.Profile;
import atg.userprofiling.ProfileTools;
import atg.userprofiling.PropertyManager;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.tealium.config.TealiumConfiguration;

@RunWith(MockitoJUnitRunner.class)
public class DataConverterTestCase {

	private static final URL GENERIC_TAG_WITH_UTAG = DataConverter.class.getResource("GENERIC_TAG_WITH_UTAG.txt");
	private static final URL HOME_TAG = DataConverterTestCase.class.getResource("HOME_TAG.txt");
	private static final URL PDP_TAG = DataConverterTestCase.class.getResource("PDP_TAG.txt");
	private static final URL CDP_TAG = DataConverterTestCase.class.getResource("CDP_TAG.txt");
	private static final URL ADP_TAG = DataConverterTestCase.class.getResource("ADP_TAG.txt");

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

	private TealiumConfiguration config;
	private DataConverter testInstance;
	@Mock
	private PricingTools mPricingTools;

	@Before
	public void setUp() throws Exception {
		this.config = new TealiumConfiguration();
		this.config.setEnabled(true);
		this.config.setAccountName("testAccount");
		this.config.setProfileName("testProfile");
		this.config.setEnvironmentName("testEnv");

		when(mPricingTools.getChildSKUsPropertyName()).thenReturn("childSkus");
		this.testInstance = new DataConverter();
		this.testInstance.setConfiguration(this.config);
		this.testInstance.setPricingTools(mPricingTools);
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

	@Test
	public void shoulProduceHomeScript() throws Exception {
		assertEquals(readResource(HOME_TAG), this.testInstance.getHomeScript("testPage", "USD", "en"));
	}

	@Test
	public void shouldProducePDPScript() throws Exception {
		final RepositoryItem product = createProductMock();
		assertEquals(readResource(PDP_TAG), this.testInstance.getProductPageScript(product, "testPDP", "USD", "en"));
	}

	@Test
	public void shouldProduceCategoryScript() throws Exception {
		final RepositoryItem category = new RepositoryItemMockBuilder("category").setId("TC0")
				.setProperty("name", "TestCat0").build();
		assertEquals(readResource(CDP_TAG), this.testInstance.getCategoryScript(category, "testCDP", "USD", "en"));
	}

	@Test
	public void shouldProduceCustmerScript() throws Exception {
		final Profile profile = mockProfile();
		assertEquals(readResource(ADP_TAG), this.testInstance.getCustomerDetailScript(profile, "tstADP", "USD", "en"));
	}

	private Profile mockProfile() throws PropertyNotFoundException {
		Profile profile = new Profile();

		ProfileTools mProfileTools = mock(ProfileTools.class);
		PropertyManager mPropertyManager = mock(PropertyManager.class);
		when(mProfileTools.getPropertyManager()).thenReturn(mPropertyManager);
		when(mProfileTools.getSecurityStatus(profile)).thenReturn(5); // login
																		// wiht
																		// https
		when(mPropertyManager.getSecurityStatusAnonymous()).thenReturn(0);
		when(mPropertyManager.getEmailAddressPropertyName()).thenReturn("email");
		when(mPropertyManager.getFirstNamePropertyName()).thenReturn("firstName");
		when(mPropertyManager.getLastNamePropertyName()).thenReturn("lastName");
		profile.setProfileTools(mProfileTools);

		MutableRepositoryItem user = new RepositoryItemMockBuilder("user").setId("tstUsr")
				.setProperty("firstName", "Test").setProperty("lastName", "Testing").setProperty("gender", "male")
				.setProperty("email", "test@example.com").build();

		profile.setDataSource(user);
		return profile;
	}

	private RepositoryItem createProductMock() {
		final RepositoryItem firstCat = new RepositoryItemMockBuilder("category").setId("TC0")
				.setProperty("name", "Test0").build();
		// final RepositoryItem secondCat = new
		// RepositoryItemMockBuilder("category").setId("TC1")
		// .setProperty("name", "Test1").build();
		final RepositoryItem firstSku = new RepositoryItemMockBuilder("sku").setId("TSKU0")
				.setProperty("listPrice", 10d).build();
		// final RepositoryItem secondSku = new
		// RepositoryItemMockBuilder("sku").setId("TSKU1")
		// .setProperty("listPrice", 20d).build();
		return new RepositoryItemMockBuilder("product").setId("TP0").setProperty("name", "TestsProduct")
				.setProperty("listPrice", 10d).setProperty("brand", "TestBrand")
				.setProperty("parentCategories", Sets.<RepositoryItem> newHashSet(firstCat))
				.setProperty("childSkus", Lists.<RepositoryItem> newArrayList(firstSku)).build();
	}

}
