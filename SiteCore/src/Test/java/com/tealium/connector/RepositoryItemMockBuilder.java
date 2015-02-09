package com.tealium.connector;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.Arrays;

import org.apache.commons.lang3.Validate;

import atg.repository.MutableRepositoryItem;
import atg.repository.RepositoryException;
import atg.repository.RepositoryItemDescriptor;

import com.google.common.collect.Sets;


@SuppressWarnings("unchecked")
public class RepositoryItemMockBuilder {
	private MutableRepositoryItem mock;

	public RepositoryItemMockBuilder(final String itemDescriptorName) {
		Validate.notBlank(itemDescriptorName, "itemDescriptorName should be provided");
		this.mock = mock(MutableRepositoryItem.class);
		final RepositoryItemDescriptor descriptorMock = mock(RepositoryItemDescriptor.class);
		when(descriptorMock.getItemDescriptorName()).thenReturn(itemDescriptorName);
		try {
			when(this.mock.getItemDescriptor()).thenReturn(descriptorMock);
		} catch (RepositoryException exc) {
			// Can be skip, never happens on test
			throw new IllegalStateException(exc);
		}
	}

	public RepositoryItemMockBuilder setId(final String id) {
		when(this.mock.getRepositoryId()).thenReturn(id);
		return this;
	}

	public <T> RepositoryItemMockBuilder setProperty(final String name, final T value) {
		when(this.mock.getPropertyValue(name)).thenReturn(value);
		return this;
	}

	public <I> RepositoryItemMockBuilder setSetProperty(final String name, final I... item) {
		return this.setProperty(name, Sets.newHashSet(item));
	}

	public <I> RepositoryItemMockBuilder setListProperty(final String name, final I... item) {
		return this.setProperty(name, Arrays.asList(item));
	}

	public <I> RepositoryItemMockBuilder setArrayProperty(final String name, final I... item) {
		return this.setProperty(name, item);
	}

	public MutableRepositoryItem build() {
		return this.mock;
	}
}
