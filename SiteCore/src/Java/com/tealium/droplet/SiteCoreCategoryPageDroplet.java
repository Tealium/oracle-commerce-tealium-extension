package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.nucleus.naming.ParameterName;
import atg.repository.RepositoryItem;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

public class SiteCoreCategoryPageDroplet extends SiteCoreBaseDroplet {

	private static final ParameterName IP_CATEGORY = ParameterName.getParameterName("category");
	
	@Override
	public void service(final DynamoHttpServletRequest req, final DynamoHttpServletResponse res)
			throws ServletException, IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		final RepositoryItem category = (RepositoryItem)req.getObjectParameter(IP_CATEGORY);
		final String script = getConverter().getCategoryScript(category, pageName, currency, language);
		serviceScript(script, res);
	}
}
