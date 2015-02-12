package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.nucleus.naming.ParameterName;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

import com.tealium.connector.search.SearchResult;

public class SiteCoreSearchResultsDroplet extends SiteCoreBaseDroplet {

	private static final ParameterName IP_KEYWORD = ParameterName.getParameterName("searchKeyWord");
	private static final ParameterName IP_TOTAL_RESULTS_NO = ParameterName.getParameterName("totalResultsNumber");

	@Override
	public void service(DynamoHttpServletRequest req, DynamoHttpServletResponse res) throws ServletException,
			IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		final String keyWord = req.getParameter(IP_KEYWORD);
		final Long totalResultsNumber = (Long) req.getObjectParameter(IP_TOTAL_RESULTS_NO);
		final String generatedScript = getConverter().getSearchPageScript(
				new SearchResult(keyWord, totalResultsNumber), pageName, currency, language);
		serviceScript(generatedScript, res);
	}

}
