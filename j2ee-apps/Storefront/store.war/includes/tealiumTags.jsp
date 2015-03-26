<dsp:page>
	
	<dsp:getvalueof var="bodyClass" param="bodyClass" />

	<dsp:importbean bean="/atg/endeca/assembler/cartridge/StoreCartridgeTools" var="StoreCartridgeTools" />
	<dsp:importbean bean="/atg/multisite/Site" var="currentSite" />

	<%-- Serve Tealium generic page script, if not page specific requarements --%>
	<dsp:getvalueof var="productId" param="productId" />
	<dsp:getvalueof var="search" param="search"/>
	<dsp:getvalueof var="siteLocale" bean="/OriginatingRequest.requestLocale.locale"/>
	<dsp:getvalueof var="requestURI" bean="/OriginatingRequest.RequestURI" />
	
	<c:choose>

		<%-- display product detail script --%>
		<c:when test="${not empty productId}">
			<dsp:importbean bean="/tealium/droplet/ProductDetailDroplet" />
			<dsp:droplet name="/atg/commerce/catalog/ProductLookup">
				<dsp:param name="id" value="${productId}" />
				<dsp:oparam name="output">
					<dsp:droplet name="ProductDetailDroplet">
						<dsp:param name="pageName" value="Product Detail" />
						<dsp:param name="language" value="${siteLocale}" />
						<dsp:param name="product" param="element" />
					</dsp:droplet>
				</dsp:oparam>
			</dsp:droplet>
		</c:when>

		<%-- Display category tags on category page --%>
		<c:when test="${StoreCartridgeTools.userOnCategoryPage}">			
			<c:if test="${not empty StoreCartridgeTools.currentCategoryId}">
				<dsp:droplet name="/atg/commerce/catalog/CategoryLookup">
					<dsp:param name="id" value="${StoreCartridgeTools.currentCategoryId}" />
					<dsp:oparam name="output">
						<dsp:droplet name="/tealium/droplet/CategoryPageDroplet">
							<dsp:param name="category" param="element" />
							<dsp:param name="pageName" value="category" />
							<dsp:param name="language" value="${siteLocale}" />
							<dsp:param name="currency" value="USD" />
						</dsp:droplet>
					</dsp:oparam>
				</dsp:droplet>
			</c:if>
		</c:when>
		
		<%-- Skip the generic script generation for the search results --%>
		<c:when test="${not empty search}">
			<%-- Just skip, results will be rendered on search result Endeca cartridge --%> 
			
			<%-- 
			<dsp:droplet name="/tealium/droplet/SearchResultsDroplet">
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
			<dsp:importbean bean="/tealium/droplet/ShoppingCardDroplet" />
			<dsp:droplet name="ShoppingCardDroplet">
				<dsp:param name="pageName" value="Cart" />
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
			<dsp:droplet name="/tealium/droplet/OrderConfirmationDroplet">
				<dsp:param name="pageName" value="Order Confirmation" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
				<dsp:param name="order" bean="/atg/commerce/ShoppingCart.current" />
				<dsp:param name="userEmail" value="${userEmail}"/>
			</dsp:droplet>
		</c:when>
		
		<%-- Display my account page scripts --%>
		<c:when test="${fn:contains(bodyClass,'atg_store_myAccountPage')}">
			<dsp:droplet name="/tealium/droplet/CustomerDetailDroplet">
				<dsp:param name="pageName" value="myAccountPage" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
				<dsp:param name="profile" bean="/atg/userprofiling/Profile"/>
			</dsp:droplet>
		</c:when>
		
		<%-- Display home page --%>
		<c:when test="${fn:endsWith(requestURI,'home') }">
			<dsp:droplet name="/tealium/droplet/HomePageDroplet">
				<dsp:param name="pageName" value="HomePage" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
			</dsp:droplet>
		</c:when>
		

		<%-- Display generic page tag when unknown page type --%>
		<c:otherwise>
			<dsp:importbean bean="/tealium/droplet/GenericPageDroplet" />
			<dsp:droplet name="GenericPageDroplet">
				<dsp:param name="pageName" param="pageTitle" />
				<dsp:param name="language" value="${siteLocale}" />
				<dsp:param name="currency" value="USD" />
			</dsp:droplet>
		</c:otherwise>

	</c:choose>

</dsp:page>