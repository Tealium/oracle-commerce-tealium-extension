package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.commerce.order.Order;
import atg.commerce.order.OrderHolder;
import atg.nucleus.naming.ParameterName;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

public class ShoppingCardDroplet extends BaseDroplet {
	
	private final ParameterName SHOPING_CARD = ParameterName.getParameterName("shopingCard");

	@Override
	public void service(DynamoHttpServletRequest req, DynamoHttpServletResponse res) throws ServletException,
			IOException {
		final String pageName = getPageName(req);
		final String currency = getCurrency(req);
		final String language = getLanguage(req);
		final OrderHolder shopingCard = (OrderHolder) req.getObjectParameter(SHOPING_CARD);
		final Order currentOrder = shopingCard.getCurrent();
		serviceScript(getConverter().getCartScript(currentOrder, pageName, currency, language), res);
	}

	
}
