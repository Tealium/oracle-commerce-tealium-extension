package com.tealium.connector;

import java.util.Date;
import java.util.EnumSet;

import atg.core.util.StringUtils;
import atg.nucleus.GenericService;
import atg.nucleus.ServiceException;

import com.tealium.config.TealiumConfiguration;
import com.tealium.util.udohelpers.TealiumHelper;
import com.tealium.util.udohelpers.TealiumHelper.PrebuiltUDOPageTypes;
import com.tealium.util.udohelpers.TealiumHelper.UDOOptions;
import com.tealium.util.udohelpers.UDO;
import com.tealium.util.udohelpers.exceptions.UDODefinitionException;
import com.tealium.util.udohelpers.exceptions.UDOUpdateException;

public class DataConverter extends GenericService {

	private TealiumConfiguration configuration;
	private TealiumHelper tealiumHelper;

	public TealiumHelper setupTealiumHelper() throws UDODefinitionException, UDOUpdateException {
		final String accountString = getConfiguration().getAccountName();
		final String profileString = getConfiguration().getProfileName();
		final String targetString = getConfiguration().getEnvironmentName();// Config.getParameter("tealiumIQ.target");;
		return new TealiumHelper(accountString, profileString, targetString);
	}

	private UDO setupUDO(PrebuiltUDOPageTypes pageType, final String pageName, final String currency,
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

	private String getExceptionString(Exception exc) {
		final Date date = new Date();
		final String referenceIDString = date.hashCode() + "";
		vlogError(exc, "Tealium error ID: {0}", referenceIDString);
		final StringBuilder scriptBuilder = new StringBuilder();
		scriptBuilder.append("<!--  Tealium ERROR \n");
		scriptBuilder.append("There may be an error in your installation, please check you logging.");
		scriptBuilder.append("\n");
		scriptBuilder.append("Log refernce ID: ");
		scriptBuilder.append(referenceIDString);
		scriptBuilder.append("\n\t\t  END Tealium ERROR -->");
		return scriptBuilder.toString();
	}

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

	public String getSyncTag() {
		String result = null;
		if (getConfiguration().isUtagSyncEnabled()) {
			try {
				result = this.tealiumHelper.outputUtagSyncJsTag();
			} catch(Exception exc) {
				return getExceptionString(exc);
			}
		}
		return result;
	}

	public String getGenericPageScript(final String pageName, final String currency, final String language) {
		try {
			UDO udo = setupUDO(PrebuiltUDOPageTypes.HOME, pageName, currency, language);
			udo.setValue(TealiumHelper.HomePageUDO.PredefinedUDOFields.PAGE_TYPE, "generic");
			return tealiumHelper.outputFullHtml(udo);
		} catch (Exception exc) {
			return getExceptionString(exc);
		}
	}

	/* Get/Set */
	public TealiumConfiguration getConfiguration() {
		return configuration;
	}

	public void setConfiguration(TealiumConfiguration configuration) {
		this.configuration = configuration;
	}

}
