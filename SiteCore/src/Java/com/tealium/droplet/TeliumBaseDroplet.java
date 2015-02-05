package com.tealium.droplet;

import com.tealium.connector.DataConverter;

import atg.servlet.DynamoServlet;

public abstract class TeliumBaseDroplet extends DynamoServlet {
	private DataConverter converter;

	/*Get/Set*/
	public DataConverter getConverter() {
		return converter;
	}

	public void setConverter(DataConverter converter) {
		this.converter = converter;
	}
	
	
}
