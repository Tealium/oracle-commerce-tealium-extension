package com.tealium.connector.search;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

public class SearchResult {

	private final String keyWord;
	private final long totalResultsNumber;

	public SearchResult(String keyWord, long totalResultsNumber) {
		this.keyWord = keyWord;
		this.totalResultsNumber = totalResultsNumber;
	}

	public String getKeyWord() {
		return keyWord;
	}

	public long getTotalResultsNumber() {
		return totalResultsNumber;
	}

	@Override
	public String toString() {
		ToStringBuilder builder = new ToStringBuilder(this, ToStringStyle.SIMPLE_STYLE);
		builder.append("keyWord", keyWord);
		builder.append("totalResultsNumber", totalResultsNumber);
		return builder.build();
	}

}
