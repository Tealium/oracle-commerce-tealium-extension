package com.tealium.connector;

import atg.nucleus.GenericService;
import atg.nucleus.ServiceException;

import com.tealium.config.TealiumConfiguration;
import com.tealium.util.udohelpers.TealiumHelper;
import com.tealium.util.udohelpers.exceptions.UDODefinitionException;
import com.tealium.util.udohelpers.exceptions.UDOUpdateException;

public class DataConverter extends GenericService {

	private TealiumConfiguration configuration;
	private TealiumHelper tealiumHelper;

	public TealiumHelper setupTealiumHelper() throws UDODefinitionException,
			UDOUpdateException {
		final String accountString = getConfiguration().getAccountName();// Config.getParameter("tealiumIQ.account");
		final String profileString = getConfiguration().getProfileName();// Config.getParameter("tealiumIQ.profile");
		final String targetString = getConfiguration().getEnvironmentName();// Config.getParameter("tealiumIQ.target");;
		return new TealiumHelper(accountString, profileString, targetString);
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
			result = this.tealiumHelper.outputUtagSyncJsTag();
		}
		return result;
	}

	public String getGenericPageScript() throws UDODefinitionException, UDOUpdateException {
		return null;
	}

	/* Get/Set */
	public TealiumConfiguration getConfiguration() {
		return configuration;
	}

	public void setConfiguration(TealiumConfiguration configuration) {
		this.configuration = configuration;
	}

}
