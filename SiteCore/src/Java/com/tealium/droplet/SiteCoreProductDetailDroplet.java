package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.nucleus.naming.ParameterName;
import atg.repository.RepositoryItem;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

public class SiteCoreProductDetailDroplet extends SiteCoreBaseDroplet {
	
	private final ParameterName IP_PRODUCT = ParameterName.getParameterName("product");
	
	@Override
	public void service(DynamoHttpServletRequest req, DynamoHttpServletResponse res) throws ServletException,
			IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		final RepositoryItem product = (RepositoryItem) req.getObjectParameter(IP_PRODUCT);
		serviceScript(getConverter().getProductPageScript(product, pageName, currency, language), res);
	}
}