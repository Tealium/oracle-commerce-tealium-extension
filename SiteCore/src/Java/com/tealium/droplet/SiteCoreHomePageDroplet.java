package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

public class SiteCoreHomePageDroplet extends SiteCoreBaseDroplet {

	@Override
	public void service(DynamoHttpServletRequest req, DynamoHttpServletResponse res) throws ServletException,
			IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		final String scriptStr = getConverter().getHomeScript(pageName, currency, language);
		serviceScript(scriptStr, res);
	}

}
