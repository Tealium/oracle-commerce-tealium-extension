<%--
  This page returns the one product of the random targeter.

  This page introduces the following page-scoped variables:
    products
      Map of products returned by random targeter (0-indexed).  For example, the third product returned
      can be accessed using:
        <c:set var="thirdProduct" value="${requestScope.products['2']}"/>

  Required Parameters:
    targeter
      The targeter to use

  Optional parameters:
    howMany
      The number of products to return (defaults to 1)
--%>
<dsp:page>
  <dsp:importbean bean="/atg/store/droplet/ItemSiteGroupFilterDroplet"/>
  <dsp:importbean bean="/atg/targeting/TargetingRandom"/>

  <c:set var="product" scope="request" value="${null}"/>

  <%--
    "ItemSiteGroupFilterDroplet" droplet filters out items that don't belong to the same cart sharing site group
    as the current site.

    Input parameters:
      collection
        Collection of products to filter based on the site group

    Output parameters:
      filteredCollection
        Filtered collection
  --%>
  <dsp:getvalueof var="howMany" param="howMany"/>
  
  <%-- If optional parameter 'howMany' is not set, default to 1 --%>
  <c:if test="${howMany == ''}">
    <c:set var="howMany" value="1"/>
  </c:if>
  
  <dsp:droplet name="ItemSiteGroupFilterDroplet">
    <dsp:param name="collection" param="product.relatedProducts" />
    <dsp:oparam name="output">
      <dsp:getvalueof var="filteredItems" param="filteredCollection" />
    </dsp:oparam>
  </dsp:droplet>

  <jsp:useBean id="products" class="java.util.HashMap" scope="request"/>
  
  
  <dsp:droplet name="TargetingRandom">
    <dsp:param name="howMany" value="${howMany}"/>
    <dsp:param name="targeter" param="targeter"/>
    <dsp:param name="fireViewItemEvent" value="false"/>
    <dsp:param name="elementName" value="product"/>
    <dsp:param name="filter" param="filteredItems"/>
    <dsp:oparam name="output">
      <dsp:getvalueof var="product" param="product"/>
      <dsp:getvalueof var="count" param="count"/>
      <c:set var="product" value="${product}"/>
      <c:set target="${products}" property="${count}" value="${product}"/>
    </dsp:oparam>
  </dsp:droplet>
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/mobile/cart/gadgets/getTargeterProduct.jsp#1 $$Change: 848678 $ --%>
