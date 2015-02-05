package com.tealium.droplet;

import java.io.IOException;

import javax.servlet.ServletException;

import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;

public class UtagSyncDroplet extends TeliumBaseDroplet {

	@Override
	public void service(final DynamoHttpServletRequest req,
			final DynamoHttpServletResponse res) throws ServletException, IOException {
		final String syncTag = getConverter().getSyncTag();
		vlogDebug("Generated utag sync tag: {0}", syncTag);
		res.getOutputStream().print(syncTag);
	}

}
