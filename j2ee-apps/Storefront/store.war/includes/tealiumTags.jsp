<dsp:page>
	
	<dsp:getvalueof var="bodyClass" param="bodyClass" />

	<dsp:importbean bean="/atg/endeca/assembler/cartridge/StoreCartridgeTools" var="StoreCartridgeTools" />
	<dsp:importbean bean="/atg/multisite/Site" var="currentSite" />

	<%-- Serve Tealium generic page script, if not page specific requarements --%>
	<dsp:getvalueof var="productId" param="productId" />
	<dsp:getvalueof var="search" param="search"/>
	<dsp:getvalueof var="siteLocale" value="${currentSite.defaultLanguage}_${currentSite.defaultCountry}" />
	<dsp:getvalueof var="requestURI" bean="/OriginatingRequest.RequestURI" />
	
	<c:choose>

		<%-- display product detail script --%>
		<c:when test="${not empty productId}">
			<dsp:importbean bean="/tealium/droplet/SiteCoreProductDetailDroplet" />
			<dsp:droplet name="/atg/commerce/catalog/ProductLookup">
				<dsp:param name="id" value="${productId}" />
				<dsp:oparam name="output">
					<dsp:droplet name="SiteCoreProductDetailDroplet">
						<dsp:param name="pageName" value="atg_store_pageProductDetail" />
						<dsp:param name="language" value="${siteLocale}" />
						<dsp:param name="product" param="element" />
					</dsp:droplet>
				</dsp:oparam>
			</dsp:droplet>
		</c:when>

		<%-- Display category tags on category page --%>
		<c:when test="${StoreCartridgeTools.userOnCategoryPage}">			
			<c:if test="${not empty currentCategoryId}">
				<dsp:importbean bean="/tealium/droplet/SiteCoreCategoryPageDroplet" />
				<dsp:droplet name="CategoryLookup">
					<dsp:param name="id" value="${currentCategoryId}" />
					<dsp:oparam name="output">
						<dsp:droplet name="SiteCoreCategoryPageDroplet">
							<dsp:param name="category" param="element" />
							<dsp:param name="pageName" value="${bodyClass}" />
							<dsp:param name="language" value="${siteLocale}" />
							<dsp:param name="currency" value="USD" />
						</dsp:droplet>
					</dsp:oparam>
				</dsp:droplet>
			</c:if>
		</c:when>
		
		<%-- display search results tags --%>
		<c:when test="${not empty search}">
			<dsp:importbean bean="/atg/endeca/assembler/SearchFormHandler"/> 
			<%--
			<dsp:droplet name="/tealium/droplet/SiteCoreSearchResultsDroplet">
				<dsp:param name="pageName" value="${bodyClass}" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
				<dsp:param name="searchKeyWord" param="Ntt"/>
				<dsp:param name="totalResultsNumber" value="2"/>
			</dsp:droplet>
			--%>
		</c:when>
			
		<%-- Display shopping card script --%>
		<c:when test="${fn:contains(bodyClass, 'atg_store_pageCart')}">
			<dsp:importbean bean="/tealium/droplet/SiteCoreShoppingCardDroplet" />
			<dsp:droplet name="SiteCoreShoppingCardDroplet">
				<dsp:param name="pageName" value="${bodyClass}" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
				<dsp:param name="shopingCard" bean="/atg/commerce/ShoppingCart" />
			</dsp:droplet>
		</c:when>
		
		<%-- Display order confirmation page script --%>
		<c:when test="${fn:contains(bodyClass,'atg_store_orderConfirmation')}">	
			<dsp:getvalueof var="currentProfile" bean="/atg/userprofiling/Profile"/>
			<%-- Handle the guest checkout without email --%>
			<dsp:getvalueof var="userEmail" value="unknown"/>			
			<c:if test="${not currentProfile.transient}">	
				<dsp:getvalueof var="userEmail" value="${currentProfile.email}" />
			</c:if>
			<dsp:droplet name="/tealium/droplet/SiteCoreOrderConfirmationDroplet">
				<dsp:param name="pageName" value="${bodyClass}" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
				<dsp:param name="order" bean="/atg/commerce/ShoppingCart.current" />
				<dsp:param name="userEmail" value="${userEmail}"/>
			</dsp:droplet>
		</c:when>
		
		<%-- Display my account page scripts --%>
		<c:when test="${fn:contains(bodyClass,'atg_store_myAccountPage')}">
			<dsp:droplet name="/tealium/droplet/SiteCoreCustomerDetailDroplet">
				<dsp:param name="pageName" value="${bodyClass}" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
				<dsp:param name="profile" bean="/atg/userprofiling/Profile"/>
			</dsp:droplet>
		</c:when>
		
		<%-- Display home page --%>
		<c:when test="${requestURI eq '/crs/home'}">
			<dsp:droplet name="/tealium/droplet/SiteCoreHomePageDroplet">
				<dsp:param name="pageName" value="atg_store_pageHomePage" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
			</dsp:droplet>
		</c:when>
		

		<%-- Display generic page tag when unknown page type --%>
		<c:otherwise>
			<dsp:importbean bean="/tealium/droplet/SiteCoreGenericPageDroplet" />
			<dsp:droplet name="SiteCoreGenericPageDroplet">
				<dsp:param name="pageName" value="${bodyClass}" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
			</dsp:droplet>
		</c:otherwise>

	</c:choose>

</dsp:page>