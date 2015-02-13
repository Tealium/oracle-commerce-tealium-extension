package com.tealium.connector;

import static org.apache.commons.lang3.ObjectUtils.defaultIfNull;

import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.EnumSet;
import java.util.List;

import org.apache.commons.lang3.ObjectUtils;

import atg.commerce.catalog.CatalogTools;
import atg.commerce.order.CommerceItem;
import atg.commerce.order.Order;
import atg.commerce.order.PaymentGroup;
import atg.commerce.pricing.ItemPriceInfo;
import atg.commerce.pricing.OrderPriceInfo;
import atg.commerce.pricing.PricingTools;
import atg.core.util.StringUtils;
import atg.nucleus.GenericService;
import atg.nucleus.ServiceException;
import atg.repository.RepositoryItem;
import atg.userprofiling.Profile;
import atg.userprofiling.ProfileTools;
import atg.userprofiling.PropertyManager;

import com.google.common.base.Function;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.tealium.config.TealiumConfiguration;
import com.tealium.connector.search.SearchResult;
import com.tealium.util.udohelpers.TealiumHelper;
import com.tealium.util.udohelpers.TealiumHelper.PrebuiltUDOPageTypes;
import com.tealium.util.udohelpers.TealiumHelper.UDOOptions;
import com.tealium.util.udohelpers.UDO;
import com.tealium.util.udohelpers.exceptions.UDODefinitionException;
import com.tealium.util.udohelpers.exceptions.UDOUpdateException;

/**
 * Converts ATG service layer data to the corresponding SiteCore JavaScript tags
 * content
 * 
 * @author TealiumIQ
 * 
 */
public class DataConverter extends GenericService {

	private static final String ERROR_STRING = "<!--  Tealium ERROR \nThere may be an error in your installation, please check you logging.\n"
			+ "Log refernce ID:  %s\n\t\t  END Tealium ERROR -->";

	private TealiumConfiguration configuration;
	private TealiumHelper tealiumHelper;
	private PricingTools pricingTools;
	private CatalogTools catalogTools;

	/**
	 * Creates and do the basic configuration of UDO
	 * 
	 * @param pageType
	 *            the UDO page type
	 * @param pageName
	 *            the page name, i.e. {@code shoping Card} or {@code PDP}
	 * @param currency
	 *            the current site currency, can be obtained from ATG site
	 *            starting from ATG 10
	 * @param language
	 *            the current site language, can be obtained from ATG site
	 *            locale form ATG 11
	 * @return the new UDO
	 * @throws UDODefinitionException
	 *             in case of UDO creation error
	 * @throws UDOUpdateException
	 *             in case of UDO basic configuration error
	 */
	protected UDO setupUDO(PrebuiltUDOPageTypes pageType, final String pageName, final String currency,
			final String language) throws UDODefinitionException, UDOUpdateException {
		this.tealiumHelper.assumePageTypeUDO("global").mayHaveStringFields(
				EnumSet.of(UDOOptions.WRITE_IF_EMPTY_OR_NULL, UDOOptions.REQUIRED), "page_name", "site_currency",
				"site_region");
		UDO udo = tealiumHelper.createDefaultUDO(pageType);
		udo.getPageType().includesFieldsFromPageType("global");
		if (StringUtils.isNotBlank(currency)) {
			udo.setValue("site_currency", currency);
		}
		if (StringUtils.isNotBlank(language)) {
			udo.setValue("site_region", language);
		}
		if (StringUtils.isNotBlank(pageName)) {
			udo.setValue("page_name", pageName);
		}
		return udo;
	}

	private TealiumHelper setupTealiumHelper() throws UDODefinitionException, UDOUpdateException {
		final String accountString = getConfiguration().getAccountName();
		final String profileString = getConfiguration().getProfileName();
		final String targetString = getConfiguration().getEnvironmentName();// Config.getParameter("tealiumIQ.target");;
		return new TealiumHelper(accountString, profileString, targetString);
	}

	private String getExceptionString(Exception exc) {
		final Date date = new Date();
		final String referenceIDString = String.valueOf(date.hashCode());
		vlogError(exc, "Tealium error ID: {0}", referenceIDString);
		return String.format(ERROR_STRING, referenceIDString);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void doStartService() throws ServiceException {
		super.doStartService();
		try {
			this.tealiumHelper = setupTealiumHelper();
		} catch (UDODefinitionException exc) {
			throw new ServiceException(exc);
		} catch (UDOUpdateException exc) {
			throw new ServiceException(exc);
		}
	}

	/**
	 * Creates UTAG synk script tag text
	 * 
	 * @return UTAG synk script tag text
	 */
	public String getSyncTag() {
		String result = "";
		if (getConfiguration().isEnabled() && getConfiguration().isUtagSyncEnabled()) {
			try {
				result = this.tealiumHelper.outputUtagSyncJsTag();
			} catch (Exception exc) {
				vlogError(exc, "Can't bild tealium UTAG synck tag");
				return getExceptionString(exc);
			}
		}
		return result;
	}

	/**
	 * Creates generic page script tag, which can be used at any site page which
	 * not requires any special parameters
	 * 
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return generic page script tag
	 */
	public String getGenericPageScript(final String pageName, final String currency, final String language) {
		if (getConfiguration().isEnabled()) {
			try {
				UDO udo = setupUDO(PrebuiltUDOPageTypes.HOME, pageName, currency, language);
				udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "generic");
				return tealiumHelper.outputFullHtml(udo);
			} catch (Exception exc) {
				vlogError(exc, "Can't bild tealium generic script:  pageName {1}, currency {2}, language {3}",
						pageName, currency, language);
				return getExceptionString(exc);
			}
		} else {
			return "";
		}
	}

	/**
	 * Creates home page tag script
	 * 
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return home page script tag
	 */
	public String getHomeScript(final String pageName, final String currency, final String language) {
		String scriptString = "";
		if (getConfiguration().isEnabled()) {
			try {
				UDO udo = setupUDO(PrebuiltUDOPageTypes.HOME, pageName, currency, language);
				udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "home");
				scriptString = tealiumHelper.outputFullHtml(udo);
			} catch (Exception exc) {
				vlogError(exc, "Can't bild tealium home script:  pageName {1}, currency {2}, language {3}", pageName,
						currency, language);
				scriptString = getExceptionString(exc);
			}
		}
		return scriptString;
	}

	/**
	 * Creates product detail page (PDP) script tag
	 * 
	 * @param product
	 *            the ATG catalog product
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return PDP page script tag
	 */
	@SuppressWarnings("unchecked")
	public String getProductPageScript(final RepositoryItem product, final String pageName, final String currency,
			final String language) {
		String result = "";
		if (getConfiguration().isEnabled()) {
			try {
				UDO udo = setupUDO(PrebuiltUDOPageTypes.PRODUCT, pageName, currency, language);

				Collection<RepositoryItem> parentCategories = (Collection<RepositoryItem>) product
						.getPropertyValue("parentCategories");
				List<String> productCategories = Collections.emptyList();
				if (null != parentCategories) {
					productCategories = Lists.transform(Lists.<RepositoryItem> newArrayList(parentCategories),
							new Function<RepositoryItem, String>() {
								@Override
								public String apply(RepositoryItem item) {
									return (String) item.getPropertyValue("name");
								}

							});
				}
				String productBrand = (String) product.getPropertyValue("brand");
				String productPrice = String.valueOf((Double) product.getPropertyValue("listPrice"));
				String productName = (String) product.getPropertyValue("name");

				Collection<RepositoryItem> childSkus = (Collection<RepositoryItem>) product
						.getPropertyValue(getPricingTools().getChildSKUsPropertyName());
				List<String> skus = Collections.emptyList();
				List<String> skusPrices = Collections.emptyList();
				if (null != childSkus) {
					List<RepositoryItem> prodSkus = Lists.newArrayList(childSkus);
					skus = Lists.transform(prodSkus, new Function<RepositoryItem, String>() {
						@Override
						public String apply(RepositoryItem sku) {
							return sku.getRepositoryId();
						}
					});
					skusPrices = Lists.transform(prodSkus, new Function<RepositoryItem, String>() {
						@Override
						public String apply(RepositoryItem sku) {
							return String.valueOf((Double) sku.getPropertyValue("listPrice"));
						}
					});
				}

				// TODO: Check about multiple SKU's and categories
				udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "product");
				udo.addArrayValues(TealiumHelper.ProductPageUDO.PredefinedUDOFields.PRODUCT_BRAND,
						Lists.newArrayList(productBrand));
				udo.addArrayValues(TealiumHelper.ProductPageUDO.PredefinedUDOFields.PRODUCT_CATEGORY,
						Lists.newArrayList(Iterables.getFirst(productCategories, "")));
				udo.addArrayValues(TealiumHelper.ProductPageUDO.PredefinedUDOFields.PRODUCT_ID,
						Lists.newArrayList(product.getRepositoryId()));
				udo.addArrayValues(TealiumHelper.ProductPageUDO.PredefinedUDOFields.PRODUCT_LIST_PRICE,
						Lists.newArrayList(productPrice));
				udo.addArrayValues(TealiumHelper.ProductPageUDO.PredefinedUDOFields.PRODUCT_NAME,
						Lists.newArrayList(productName));
				udo.addArrayValues(TealiumHelper.ProductPageUDO.PredefinedUDOFields.PRODUCT_SKU,
						Lists.newArrayList(Iterables.getFirst(skus, "")));
				udo.addArrayValues(TealiumHelper.ProductPageUDO.PredefinedUDOFields.PRODUCT_UNIT_PRICE,
						Lists.newArrayList(Iterables.getFirst(skusPrices, "")));

				result = tealiumHelper.outputFullHtml(udo);
			} catch (Exception exc) {
				vlogError(exc, "Can not build PDP script. For product: {0}, pageName {1}, currency {2}, language {3}",
						product, pageName, currency, language);
				result = getExceptionString(exc);
			}
		}
		return result;
	}

	/**
	 * Creates category details page (CDP) script tag
	 * 
	 * @param category
	 *            ATG catalog category
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return CDP page script tag
	 */
	public String getCategoryScript(final RepositoryItem category, final String pageName, final String currency,
			final String language) {
		String result = "";
		if (getConfiguration().isEnabled()) {
			try {
				UDO udo = setupUDO(PrebuiltUDOPageTypes.CATEGORY, pageName, currency, language);
				udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "product");
				final String categoryName = (String) category.getPropertyValue("name");
				if (StringUtils.isNotBlank(categoryName)) {
					udo.setValue(TealiumHelper.CategoryPageUDO.PredefinedUDOFields.PAGE_CATEGORY_NAME, categoryName);
				}
				result = tealiumHelper.outputFullHtml(udo);
			} catch (Exception exc) {
				vlogError(exc,
						"Can not build category script. For category: {0}, pageName {1}, currency {2}, language {3}",
						category, pageName, currency, language);
				result = getExceptionString(exc);
			}
		}
		return result;
	}

	/**
	 * Creates search result page script tag
	 * 
	 * @param searchResults
	 *            the search results holder, can be obtained from Endeca
	 *            starting from ATG 10.1.2 or from ATG search engine
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return search result page page script tag
	 */
	public String getSearchPageScript(final SearchResult searchResults, final String pageName, final String currency,
			final String language) {
		String result = "";
		if (getConfiguration().isEnabled()) {
			try {
				UDO udo = setupUDO(PrebuiltUDOPageTypes.SEARCH, pageName, currency, language);
				udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "search");
				udo.setValue(TealiumHelper.SearchPageUDO.PredefinedUDOFields.SEARCH_KEYWORD, searchResults.getKeyWord());
				udo.setValue(TealiumHelper.SearchPageUDO.PredefinedUDOFields.SEARCH_RESULTS,
						String.valueOf(searchResults.getTotalResultsNumber()));
				result = tealiumHelper.outputFullHtml(udo);
			} catch (Exception exc) {
				vlogError(
						exc,
						"Can not build search results script. For searchResults: {0}, pageName {1}, currency {2}, language {3}",
						searchResults, pageName, currency, language);
				result = getExceptionString(exc);
			}
		}
		return result;
	}

	/**
	 * Creates my account page script tag
	 * 
	 * @param profile
	 *            ATG customer profile
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return my account page page script tag
	 */
	public String getCustomerDetailScript(final Profile profile, final String pageName, final String currency,
			final String language) {
		String result = "";
		if (getConfiguration().isEnabled()) {
			try {
				final UDO udo = setupUDO(PrebuiltUDOPageTypes.CUSTOMER, pageName, currency, language);
				udo.setValue(TealiumHelper.CustomerPageUDO.PredefinedUDOFields.CUSTOMER_ID, profile.getRepositoryId());
				final ProfileTools profileTools = profile.getProfileTools();
				final PropertyManager propertyManager = profileTools.getPropertyManager();
				if (profileTools.getSecurityStatus(profile) > propertyManager.getSecurityStatusAnonymous()) {
					final String userEmail = (String) profile.getPropertyValue(propertyManager
							.getEmailAddressPropertyName());
					final String firstName = (String) profile.getPropertyValue(propertyManager
							.getFirstNamePropertyName());
					final String lastName = (String) profile
							.getPropertyValue(propertyManager.getLastNamePropertyName());
					final String gender = defaultIfNull((String) profile.getPropertyValue("gender"), "unknown");
					final String userNameString = StringUtils.joinStrings(new String[] { defaultIfNull(firstName, ""),
							defaultIfNull(lastName, "") }, ' ');

					if (StringUtils.isNotBlank(userEmail)) {
						udo.setValue(TealiumHelper.CustomerPageUDO.PredefinedUDOFields.CUSTOMER_EMAIL, userEmail);
					}
					udo.setValue("customer_name", userNameString);
					udo.setValue("gender", gender);
				}
				result = tealiumHelper.outputFullHtml(udo);
			} catch (Exception exc) {
				vlogError(exc,
						"Can not build account script. For profile: {0}, pageName {1}, currency {2}, language {3}",
						profile, pageName, currency, language);
				result = getExceptionString(exc);
			}
		}
		return result;
	}

	/**
	 * Creates basket page script
	 * 
	 * @param currentOrder
	 *            current shopping card order, can be obtained from
	 *            ShoppingCard.current ATG component
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return basket page page script tag
	 */
	@SuppressWarnings("unchecked")
	public String getCartScript(Order currentOrder, final String pageName, final String currency, final String language) {
		String result = "";
		if (getConfiguration().isEnabled()) {
			try {
				UDO udo = setupUDO(PrebuiltUDOPageTypes.CART, pageName, currency, language);
				List<String> productBrandList = Lists.newLinkedList();
				List<String> productCategoryList = Lists.newLinkedList();
				List<String> productIdList = Lists.newLinkedList();
				List<String> productListPriceList = Lists.newLinkedList();
				List<String> productNameList = Lists.newLinkedList();
				List<String> productQuantityList = Lists.newLinkedList();
				List<String> productSkuList = Lists.newLinkedList();
				List<String> productUnitPriceList = Lists.newLinkedList();

				// Set total price
				OrderPriceInfo orderPrice = currentOrder.getPriceInfo();
				udo.setValue("cart_total", String.valueOf(orderPrice.getTotal()));

				final Collection<CommerceItem> commerceItems = currentOrder.getCommerceItems();
				for (CommerceItem commerceItem : commerceItems) {
					final RepositoryItem skuItem = getCatalogTools().getCatalog().getItem(commerceItem.getCatalogId(),
							"sku");
					final RepositoryItem product = (RepositoryItem) skuItem.getPropertyValue("parentProduct");
					String sku = skuItem.getRepositoryId();
					String name = (String) skuItem.getPropertyValue("name");
					String quantity = String.valueOf(commerceItem.getQuantity());
					ItemPriceInfo itemPriceInfo = commerceItem.getPriceInfo();
					String basePrice = String.valueOf(itemPriceInfo.getAmount());
					final Collection<RepositoryItem> parentCategories = (Collection<RepositoryItem>) product
							.getPropertyValue("parentCategories");
					String category = (String) Iterables.getFirst(parentCategories, null).getPropertyValue("name");
					String brand = (String) product.getPropertyValue("brand");
					productBrandList.add(brand);
					productCategoryList.add(category);
					productIdList.add(product.getRepositoryId());
					productListPriceList.add(basePrice);
					productNameList.add(name);
					productQuantityList.add(quantity);
					productSkuList.add(sku);
					productUnitPriceList.add(String.valueOf(itemPriceInfo.getSalePrice()));
				}

				udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "checkout")
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_BRAND, productBrandList)
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_CATEGORY,
								productCategoryList)
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_ID, productIdList)
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_LIST_PRICE,
								productListPriceList)
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_NAME, productNameList)
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_QUANTITY,
								productQuantityList)
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_SKU, productSkuList)
						.addArrayValues(TealiumHelper.CartPageUDO.PredefinedUDOFields.PRODUCT_UNIT_PRICE,
								productUnitPriceList);

				result = tealiumHelper.outputFullHtml(udo);

			} catch (Exception exc) {
				vlogError(exc,
						"Can not build shopping card script. For order: {0}, pageName {1}, currency {2}, language {3}",
						currentOrder, pageName, currency, language);
				result = getExceptionString(exc);
			}
		}
		return result;
	}

	/**
	 * Creates order confirmation page (thank you page) script tag
	 * 
	 * @param lastOrder
	 *            an submitted order, can be obtained from ShoppingCard.last ATG
	 *            component
	 * @param userEmail
	 *            the customer email, usually stored in the first order
	 *            HardgoodShppingGroup.userAddress up to your customization
	 * @param pageName
	 *            the page name
	 * @param currency
	 *            the current site currency
	 * @param language
	 *            the current site language
	 * @return order confirmation page script tag
	 */
	@SuppressWarnings("unchecked")
	public String getOrderConfirmationScript(Order lastOrder, String userEmail, final String pageName,
			final String currency, final String language) {
		String result = "";
		if (getConfiguration().isEnabled()) {
			try {
				UDO udo = setupUDO(PrebuiltUDOPageTypes.CONFIRMATION, pageName, currency, language);
				String siteCurrency = ObjectUtils.defaultIfNull(lastOrder.getPriceInfo().getCurrencyCode(), currency);
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_CURRENCY, siteCurrency);
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_ID, lastOrder.getId());
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.CUSTOMER_ID,
						lastOrder.getProfileId());
				if (StringUtils.isNotBlank(userEmail)) {
					udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.CUSTOMER_EMAIL, userEmail);
				}

				OrderPriceInfo priceInfo = lastOrder.getPriceInfo();
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_TOTAL,
						String.valueOf(priceInfo.getTotal()));
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_SHIPPING,
						String.valueOf(priceInfo.getShipping()));
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_TAX,
						String.valueOf(priceInfo.getTax()));
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_DISCOUNT,
						String.valueOf(priceInfo.getManualAdjustmentTotal()));
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_SUBTOTAL,
						String.valueOf(priceInfo.getRawSubtotal()));

				final PaymentGroup paymentGroup = Iterables.getFirst((List<PaymentGroup>) lastOrder.getPaymentGroups(),
						null);
				// null is not possible for submitted order
				udo.setValue(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.ORDER_PAYMENT_TYPE,
						paymentGroup.getPaymentGroupClassType());

				List<String> productBrandList = Lists.newLinkedList();
				List<String> productCategoryList = Lists.newLinkedList();
				List<String> productIdList = Lists.newLinkedList();
				List<String> productListPriceList = Lists.newLinkedList();
				List<String> productNameList = Lists.newLinkedList();
				List<String> productQuantityList = Lists.newLinkedList();
				List<String> productSkuList = Lists.newLinkedList();
				List<String> productUnitPriceList = Lists.newLinkedList();
				List<String> productDiscountList = Lists.newLinkedList();

				final Collection<CommerceItem> commerceItems = lastOrder.getCommerceItems();
				for (CommerceItem commerceItem : commerceItems) {
					final RepositoryItem skuItem = getCatalogTools().getCatalog().getItem(commerceItem.getCatalogId(),
							"sku");
					final RepositoryItem product = (RepositoryItem) skuItem.getPropertyValue("parentProduct");
					String sku = skuItem.getRepositoryId();
					String name = (String) skuItem.getPropertyValue("name");
					String quantity = String.valueOf(commerceItem.getQuantity());
					ItemPriceInfo itemPriceInfo = commerceItem.getPriceInfo();
					String basePrice = String.valueOf(itemPriceInfo.getAmount());
					final Collection<RepositoryItem> parentCategories = (Collection<RepositoryItem>) product
							.getPropertyValue("parentCategories");
					String category = (String) Iterables.getFirst(parentCategories, null).getPropertyValue("name");
					String brand = (String) product.getPropertyValue("brand");

					// TODO: Check filds with Patric
					productBrandList.add(brand);
					productCategoryList.add(category);
					productIdList.add(product.getRepositoryId());
					productListPriceList.add(basePrice);
					productNameList.add(name);
					productQuantityList.add(quantity);
					productSkuList.add(sku);
					productUnitPriceList.add(String.valueOf(itemPriceInfo.getSalePrice()));
					productDiscountList.add(String.valueOf(itemPriceInfo.getOrderDiscountShare()));
				}

				udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "checkout")
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_BRAND,
								productBrandList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_CATEGORY,
								productCategoryList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_ID, productIdList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_LIST_PRICE,
								productListPriceList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_NAME,
								productNameList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_QUANTITY,
								productQuantityList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_SKU,
								productSkuList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_UNIT_PRICE,
								productUnitPriceList)
						.addArrayValues(TealiumHelper.ConfirmationPageUDO.PredefinedUDOFields.PRODUCT_DISCOUNT,
								productDiscountList);

				result = tealiumHelper.outputFullHtml(udo);
			} catch (Exception exc) {
				vlogError(
						exc,
						"Can not build order confirmations script. For order: {0}, pageName {1}, currency {2}, language {3}",
						lastOrder, pageName, currency, language);
				result = getExceptionString(exc);
			}
		}
		return result;
	}

	/* Get/Set */
	public TealiumConfiguration getConfiguration() {
		return configuration;
	}

	public void setConfiguration(TealiumConfiguration configuration) {
		this.configuration = configuration;
	}

	public PricingTools getPricingTools() {
		return pricingTools;
	}

	public void setPricingTools(PricingTools pricingTools) {
		this.pricingTools = pricingTools;
	}

	public CatalogTools getCatalogTools() {
		return catalogTools;
	}

	public void setCatalogTools(CatalogTools catalogTools) {
		this.catalogTools = catalogTools;
	}

}
