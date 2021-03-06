package com.tealium.connector;

import static com.tealium.connector.RepositoryItemMockBuilder.newBuilder;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Matchers.any;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.CharBuffer;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.runners.MockitoJUnitRunner;

import atg.commerce.catalog.CatalogTools;
import atg.commerce.order.CommerceItem;
import atg.commerce.order.CreditCard;
import atg.commerce.order.Order;
import atg.commerce.pricing.ItemPriceInfo;
import atg.commerce.pricing.OrderPriceInfo;
import atg.commerce.pricing.PricingTools;
import atg.core.util.StringUtils;
import atg.repository.MutableRepositoryItem;
import atg.repository.Repository;
import atg.repository.RepositoryException;
import atg.repository.RepositoryItem;
import atg.userprofiling.Profile;
import atg.userprofiling.ProfileTools;
import atg.userprofiling.PropertyManager;

import com.google.common.collect.Lists;
import com.tealium.config.TealiumConfiguration;
import com.tealium.connector.search.SearchResult;
import com.tealium.util.udohelpers.TealiumHelper.PrebuiltUDOPageTypes;
import com.tealium.util.udohelpers.exceptions.UDODefinitionException;

@RunWith(MockitoJUnitRunner.class)
public class DataConverterTestCase {

	private static final URL GENERIC_TAG_WITH_UTAG = DataConverter.class.getResource("GENERIC_TAG_WITH_UTAG.txt");
	private static final URL HOME_TAG = DataConverterTestCase.class.getResource("HOME_TAG.txt");
	private static final URL PDP_TAG = DataConverterTestCase.class.getResource("PDP_TAG.txt");
	private static final URL CDP_TAG = DataConverterTestCase.class.getResource("CDP_TAG.txt");
	private static final URL ADP_TAG = DataConverterTestCase.class.getResource("ADP_TAG.txt");
	private static final URL SRP_TAG = DataConverterTestCase.class.getResource("SRP_TAG.txt");
	private static final URL ORDR_TAG = DataConverterTestCase.class.getResource("ORDR_TAG.txt");
	private static final URL ORDR_CONFIRM_TAG = DataConverterTestCase.class.getResource("ORDR_CONFIRM_TAG.txt");

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
	@Mock
	private CatalogTools mCatalogTools;
	@Mock
	private Repository mCatalog;

	@Before
	public void setUp() throws Exception {
		this.config = new TealiumConfiguration();
		this.config.setEnabled(true);
		this.config.setAccountName("testAccount");
		this.config.setProfileName("testProfile");
		this.config.setEnvironmentName("testEnv");

		when(mPricingTools.getChildSKUsPropertyName()).thenReturn("childSkus");
		when(mCatalogTools.getCatalog()).thenReturn(mCatalog);

		this.testInstance = new DataConverter();
		this.testInstance.setConfiguration(this.config);
		this.testInstance.setPricingTools(mPricingTools);
		this.testInstance.setCatalogTools(mCatalogTools);
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
	public void shouldReturnErrorScriptWhenException() throws Exception {
		this.config.setUtagSyncEnabled(true);
		this.config.setEnvironmentName(null);
		DataConverter spy = Mockito.spy(this.testInstance);
		doThrow(UDODefinitionException.class).when(spy).setupUDO(any(PrebuiltUDOPageTypes.class), anyString(),
				anyString(), anyString());
		final Pattern refIDrx = Pattern.compile("(?s)^(<!-{2}.+){1}?(ID:\\s+-{0,1}\\d{9,10})?(.+-{2}>)$");
		String errorComment = spy.getGenericPageScript("testPage", "USD", "en");
		Matcher matcher = refIDrx.matcher(errorComment);
		assertTrue("Error string not matches the expression", matcher.matches());
	}

	@Test
	public void shoulProduceHomeScript() throws Exception {
		assertEquals(readResource(HOME_TAG), this.testInstance.getHomeScript("testPage", "USD", "en"));
	}

	@Test
	public void shouldProducePDPScript() throws Exception {
		final RepositoryItem product = createPDPPageProductMock();
		assertEquals(readResource(PDP_TAG), this.testInstance.getProductPageScript(product, "testPDP", "USD", "en"));
	}

	@Test
	public void shouldProduceCategoryScript() throws Exception {
		final RepositoryItem category = newBuilder("category").setId("TC0")
				.setProperty("displayName", "TestCat0").build();
		assertEquals(readResource(CDP_TAG), this.testInstance.getCategoryScript(category, "testCDP", "USD", "en"));
	}

	@Test
	public void shouldProduceCustmerScript() throws Exception {
		final Profile profile = mockProfile();
		assertEquals(readResource(ADP_TAG), this.testInstance.getCustomerDetailScript(profile, "tstADP", "USD", "en"));
	}

	@Test
	public void shouldProduceSearchResultScript() throws Exception {
		assertEquals(readResource(SRP_TAG),
				this.testInstance.getSearchPageScript(new SearchResult("test", 100L), "testSRP", "USD", "en"));
	}

	@Test
	public void shouldProduceCardScript() throws Exception {
		assertEquals(readResource(ORDR_TAG),this.testInstance.getCartScript(createOrderMock("TSTORD0"), "ShopingCard", "USD", "en"));
	}

	@Test
	public void shouldProduceOrderConfirmationScript() throws Exception {
		assertEquals(readResource(ORDR_CONFIRM_TAG), this.testInstance.getOrderConfirmationScript(
				createOrderMock("TSTORD1"), "test@example.com", "ThankYouPage", "USD", "en"));
	}

	/* Mock helpers */

	private Profile mockProfile() throws Exception {
		Profile profile = new Profile();

		ProfileTools mProfileTools = mock(ProfileTools.class);
		PropertyManager mPropertyManager = mock(PropertyManager.class);
		when(mProfileTools.getPropertyManager()).thenReturn(mPropertyManager);
		// login with https
		when(mProfileTools.getSecurityStatus(profile)).thenReturn(5);  
		when(mPropertyManager.getSecurityStatusAnonymous()).thenReturn(0);
		when(mPropertyManager.getEmailAddressPropertyName()).thenReturn("email");
		when(mPropertyManager.getFirstNamePropertyName()).thenReturn("firstName");
		when(mPropertyManager.getLastNamePropertyName()).thenReturn("lastName");
		profile.setProfileTools(mProfileTools);

		MutableRepositoryItem user = newBuilder("user").setId("tstUsr")
				.setProperty("firstName", "Test").setProperty("lastName", "Testing").setProperty("gender", "male")
				.setProperty("email", "test@example.com").build();

		profile.setDataSource(user);
		return profile;
	}

	private Order createOrderMock(String id) throws Exception {

		final Order result = mock(Order.class);
		when(result.getId()).thenReturn(id);
		when(result.getProfileId()).thenReturn("testuser");

		List<CommerceItem> commereceItems = Lists.newArrayList();
		when(result.getCommerceItems()).thenReturn(commereceItems);

		OrderPriceInfo orderPriceInfo = mock(OrderPriceInfo.class);
		when(orderPriceInfo.getTotal()).thenReturn(560D);
		when(orderPriceInfo.getShipping()).thenReturn(10D);
		when(orderPriceInfo.getTax()).thenReturn(100D);
		when(orderPriceInfo.getManualAdjustmentTotal()).thenReturn(100D);
		when(orderPriceInfo.getRawSubtotal()).thenReturn(610D);
		when(result.getPriceInfo()).thenReturn(orderPriceInfo);

		CreditCard paymentGroup = mock(CreditCard.class);
		when(paymentGroup.getPaymentGroupClassType()).thenReturn("Debit card");
		when(result.getPaymentGroups()).thenReturn(Lists.newArrayList(paymentGroup));

		RepositoryItem category = mockCategory("TCT0", "TestCat");
		RepositoryItem product = mockProduct(category);
		RepositoryItem sku0 = mockSKU(product, "TSKU0", "TestSKU0", 100D);
		RepositoryItem sku1 = mockSKU(product, "TSKU1", "TestSKU1", 200D);
		when(product.getPropertyValue("childSkus")).thenReturn(Lists.newArrayList(sku0,sku1));

		commereceItems.add(mockCommerceItem("CI0", "TSKU0", sku0, 1L, 100D, 100D, 0D));
		commereceItems.add(mockCommerceItem("CI1", "TSKU1", sku1, 2L, 400D, 200D, 50D));

		return result;
	}

	private RepositoryItem mockSKU(RepositoryItem product, String id, String name, double price) throws Exception {
		final RepositoryItem result = newBuilder("sku").setId(id).setProperty("displayName", name).setListProperty("parentProducts", product).build();
		final ItemPriceInfo priceInfo = new ItemPriceInfo();
		priceInfo.setRawTotalPrice(price);
		priceInfo.setSalePrice(price);
		when(mPricingTools.calculatePrice(product, result, 1L)).thenReturn(priceInfo);
		when(mCatalog.getItem(id, "sku")).thenReturn(result);
		return result;
	}

	private RepositoryItem mockProduct(RepositoryItem category) {
		RepositoryItem result = newBuilder("product").setId("TP0")
				.setProperty("displayName", "TestProduct").setProperty("brand", "TestBrand")
				.setSetProperty("parentCategories", category).build();
		return result;
	}

	private RepositoryItem mockCategory(String id, String name) {
		return newBuilder("category").setId(id).setProperty("displayName", name).build();
	}

	private CommerceItem mockCommerceItem(String id, String skuId, RepositoryItem sku, long qty, double priceAmount,
			double listPrice, double discount) throws RepositoryException {
		CommerceItem result = mock(CommerceItem.class);
		when(result.getId()).thenReturn(id);
		when(result.getCatalogRefId()).thenReturn(skuId);
		when(result.getQuantity()).thenReturn(qty);
		ItemPriceInfo priceInfo = mock(ItemPriceInfo.class);
		when(priceInfo.getAmount()).thenReturn(priceAmount);
		when(priceInfo.getListPrice()).thenReturn(listPrice);
		when(priceInfo.getSalePrice()).thenReturn(listPrice);
		when(result.getPriceInfo()).thenReturn(priceInfo);
		if (discount > 0D) {
			when(priceInfo.isDiscounted()).thenReturn(true);
			when(priceInfo.getOrderDiscountShare()).thenReturn(discount);
		}
		return result;
	}

	private RepositoryItem createPDPPageProductMock() throws Exception {
		final RepositoryItem firstCat = newBuilder("category").setId("TC0").setProperty("displayName", "Test0").build();
		final RepositoryItem secondCat = mockCategory("TC1", "Test1");
		RepositoryItem result = newBuilder("product").setId("TP0").setProperty("displayName", "TestsProduct").setProperty("brand", "TestBrand")
				.setListProperty("parentCategories", firstCat, secondCat).build();		
		RepositoryItem firstSku = mockSKU(result, "TSKU0", "TestSku1", 10D);		
		final RepositoryItem secondSku = mockSKU(result,"TSKU1","TestSku2", 20D);
		when(result.getPropertyValue("childSkus")).thenReturn(Lists.newArrayList(firstSku,secondSku));		
		return result;
	}

}
