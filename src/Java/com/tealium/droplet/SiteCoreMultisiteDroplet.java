package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import com.tealium.droplet.model.MultisiteModel;

import atg.multisite.Site;
import atg.nucleus.naming.ParameterName;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;
import atg.servlet.DynamoServlet;

public class SiteCoreMultisiteDroplet extends DynamoServlet {

	private static final ParameterName SITE_IP = ParameterName
			.getParameterName("site");
	private static final ParameterName PAGE_NAME_IP = ParameterName
			.getParameterName("pageName");
	private static final ParameterName PAGE_TYPE_IP = ParameterName
			.getParameterName("pageType");

	private static final String SITE_MODEL_OP = "siteModel";
	private static final String OUTPUT_LOP = "output";

	@Override
	public void service(DynamoHttpServletRequest req,
			DynamoHttpServletResponse res) throws ServletException, IOException {
		final Site site = (Site) req.getObjectParameter(SITE_IP);
		final String pageName = req.getParameter(PAGE_NAME_IP);
		final String pageType = req.getParameter(PAGE_TYPE_IP);
		String locale = (String) site.getPropertyValue("locale");
		String currency = (String) site.getPropertyValue("currecy");
		// TODO: implement logic
		MultisiteModel model = new MultisiteModel();
		req.setParameter(SITE_MODEL_OP, model);
		req.serviceLocalParameter(OUTPUT_LOP, req, res);
	}

}
