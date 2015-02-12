package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

/**
 * Outputs the base TealiumSC tag, should be used after the body HTML tag
 */
public class SiteCoreGenericPageDroplet extends SiteCoreBaseDroplet {

	@Override
	public void service(final DynamoHttpServletRequest req, final DynamoHttpServletResponse res)
			throws ServletException, IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		final String scriptStr = getConverter().getGenericPageScript(pageName, currency, language);
		serviceScript(scriptStr, res);
	}

}
