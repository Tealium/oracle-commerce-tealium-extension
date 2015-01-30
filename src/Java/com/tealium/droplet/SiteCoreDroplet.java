package com.tealium.droplet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletException;

import com.tealium.config.TealiumConfiguration;

import atg.servlet.DynamoHttpServletRequest;
import atg.servlet.DynamoHttpServletResponse;
import atg.servlet.DynamoServlet;

/**
 * Outputs the base TealiumSC tag, should be used after the body HTML tag
 */
public class SiteCoreDroplet extends DynamoServlet {

	private static final Pattern SCRIPT_LOCATION_PATTERN = Pattern
			.compile("\\$\\{site.core.script\\}");

	private TealiumConfiguration configuration;

	private String template;

	@Override
	public void service(final DynamoHttpServletRequest req,
			final DynamoHttpServletResponse res) throws ServletException,
			IOException {
		if (getConfiguration().isEnabled()) {
			final PrintWriter out = res.getWriter();
			final Matcher matcher = SCRIPT_LOCATION_PATTERN.matcher(getTemplate());
			out.print(matcher.replaceFirst(getConfiguration()
					.getSiteCoreScriptURL()));
		}
	}

	// Get/Set
	public TealiumConfiguration getConfiguration() {
		return configuration;
	}

	public void setConfiguration(TealiumConfiguration configuration) {
		this.configuration = configuration;
	}

	public String getTemplate() {
		return template;
	}

	public void setTemplate(String template) {
		this.template = template;
	}

}
