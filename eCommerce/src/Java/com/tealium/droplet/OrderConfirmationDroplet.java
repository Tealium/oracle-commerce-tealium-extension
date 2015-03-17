package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.commerce.order.Order;
import atg.nucleus.naming.ParameterName;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

public class OrderConfirmationDroplet extends BaseDroplet {

	private static final ParameterName IP_ORDER = ParameterName.getParameterName("order");
	private static final ParameterName IP_USER_EMAIL = ParameterName.getParameterName("userEmail");

	@Override
	public void service(DynamoHttpServletRequest req, DynamoHttpServletResponse res) throws ServletException,
			IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		final Order order = (Order) req.getObjectParameter(IP_ORDER);
		final String userEmail = req.getParameter(IP_USER_EMAIL);
		serviceScript(getConverter().getOrderConfirmationScript(order, userEmail, pageName, currency, language), res);
	}

}
