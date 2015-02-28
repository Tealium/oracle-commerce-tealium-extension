package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.nucleus.naming.ParameterName;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;
import atg.userprofiling.Profile;

public class SiteCoreCustomerDetailDroplet extends SiteCoreBaseDroplet {

	private final ParameterName IP_PROFILE = ParameterName.getParameterName("profile");

	@Override
	public void service(final DynamoHttpServletRequest req, final DynamoHttpServletResponse res)
			throws ServletException, IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		Profile profile = (Profile) req.getObjectParameter(IP_PROFILE);
		final String scriptStr = getConverter().getCustomerDetailScript(profile, pageName, currency, language);
		serviceScript(scriptStr, res);
	}

}
