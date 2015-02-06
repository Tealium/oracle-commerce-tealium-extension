package com.tealium.droplet;

import com.tealium.connector.DataConverter;

import atg.nucleus.naming.ParameterName;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoServlet;

public abstract class TealiumBaseDroplet extends DynamoServlet {
	
	private static ParameterName IP_PAGE_NAME = ParameterName.getParameterName("pageName");
	private static ParameterName IP_CURRENCY = ParameterName.getParameterName("currency");
	private static ParameterName IP_LANGUAGE = ParameterName.getParameterName("language");
	
	protected String getPageName(final DynamoHttpServletRequest req)  {
		return req.getParameter(IP_PAGE_NAME);
	}
	
	protected String getCurrency(final DynamoHttpServletRequest req) {
		return req.getParameter(IP_CURRENCY);
	}
	
	protected String getLanguage(final DynamoHttpServletRequest req) {
		return req.getParameter(IP_LANGUAGE);
	}
	
	private DataConverter converter;

	/* Get/Set */
	public DataConverter getConverter() {
		return converter;
	}

	public void setConverter(DataConverter converter) {
		this.converter = converter;
	}

}
