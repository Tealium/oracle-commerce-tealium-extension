package com.tealium.config;

import atg.nucleus.GenericService;

/**
 * Holds basic SiteCore configuration options
 */
public class TealiumConfiguration extends GenericService {

	private boolean enabled;

	private String tealiumCDN;

	private String accountName;

	private String profileName;

	private String environmentName;

	private boolean utagSyncEnabled;

	private boolean allowCustomUDO;

	/**
	 * Returns whether site-core is enabled
	 * 
	 * @return whether site-core is enabled
	 */
	public boolean isEnabled() {
		return enabled;
	}

	/**
	 * Enables or completely disables the SiteCore tags generations
	 * 
	 * @param enabled
	 *            {@code true} to enable or {@code false} to disable the
	 *            SiteCore tags generation
	 */
	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	/**
	 * Returns URL on the SiteCore script
	 * 
	 * @return URL on the SiteCore script
	 */
	public String getTealiumCDN() {
		return tealiumCDN;
	}

	/**
	 * Sets location of SiteCore script
	 * 
	 * @param siteCoreScriptURL
	 *            URL on the SiteCore script
	 */
	public void setTealiumCDN(String siteCoreScriptURL) {
		this.tealiumCDN = siteCoreScriptURL;
	}

	/**
	 * Returns the SiteCore account name
	 * 
	 * @return SiteCore account name
	 */
	public String getAccountName() {
		return accountName;
	}

	/**
	 * Set the SiteCore account name
	 * 
	 * @param accountName
	 *            SiteCore account name
	 */
	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	/**
	 * Returns the SiteCore profile name
	 * 
	 * @return SiteCore profile name
	 */
	public String getProfileName() {
		return profileName;
	}

	/**
	 * Set the SiteCore profile name
	 * 
	 * @param profileName
	 *            SiteCore profile name
	 */
	public void setProfileName(String profileName) {
		this.profileName = profileName;
	}

	/**
	 * Returns the SiteCore environment name
	 * 
	 * @return SiteCore environment name
	 */
	public String getEnvironmentName() {
		return environmentName;
	}

	/**
	 * Set the SiteCore environment name
	 * 
	 * @param environmentName
	 *            SiteCore environment name
	 */
	public void setEnvironmentName(String environmentName) {
		this.environmentName = environmentName;
	}

	/**
	 * Returns whether utag.sync.js is enabled
	 * 
	 * @return whether utag.sync.js enabled
	 */
	public boolean isUtagSyncEnabled() {
		return utagSyncEnabled;
	}

	/**
	 * Enables or disables adding utag.sync.js on the site
	 * 
	 * @param utagSyncEnabled
	 *            {@code true} to enable utag.sync.js or {@code false} to
	 *            disable it
	 */
	public void setUtagSyncEnabled(boolean utagSyncEnabled) {
		this.utagSyncEnabled = utagSyncEnabled;
	}

	/**
	 * Returns whether allowed extending the data layer with additional
	 * name/value pairs
	 * 
	 * @return whether extending the data layer is allowed
	 */
	public boolean isAllowCustomUDO() {
		return allowCustomUDO;
	}

	/**
	 * Allows or disallows adding utag.sync.js on the site
	 * 
	 * @param allowed
	 *            {@code true} to allow extending the data layer {@code false}
	 *            to disallow
	 * 
	 */
	public void setAllowCustomUDO(boolean allowed) {
		this.allowCustomUDO = allowed;
	}

}
