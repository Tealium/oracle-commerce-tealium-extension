package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

public class UtagSyncDroplet extends BaseDroplet {

	@Override
	public void service(final DynamoHttpServletRequest req, final DynamoHttpServletResponse res)
			throws ServletException, IOException {
		serviceScript(getConverter().getSyncTag(), res);
	}

}
