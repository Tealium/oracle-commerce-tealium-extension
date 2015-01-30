package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.repository.RepositoryItem;
import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;
import atg.servlet.DynamoServlet;

public class SiteCoreProductDetail extends DynamoServlet {
	
	private static final I

	@Override
	public void service(DynamoHttpServletRequest req,
			DynamoHttpServletResponse res) throws ServletException, IOException {
		RepositoryItem product = req.getObjectParameter(pName);
	}

}
