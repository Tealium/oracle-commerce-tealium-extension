<%--
  It's a welcome page for the CRS application.
  The user will see this page when he first comes to the store, or after he's clicked the store icon on the page.

  Required parameters:
    None.

  Optional parameters:
    None.
--%>
<dsp:page>
  <dsp:importbean bean="/atg/endeca/assembler/droplet/InvokeAssembler"/>

  <%--
    The InvokeAssembler droplet is used to retrieve content from Experience 
    Manager. In this instance we request the ContentItem representing the home
    page.
  
    Input Parameters:
      contentCollection is the full path to the content in Experience Manager.
  
    Open Parameters:
      output The open parameter in which our output parameter is rendered in.
  
    Output Parameters:
      contentItem The ContentItem representing the content requested from Experience
      Manager.
  --%>
  <dsp:droplet name="InvokeAssembler">
    <dsp:param name="contentCollection" value="/content/Web/Home Pages"/>
    <dsp:oparam name="output">
      <dsp:getvalueof var="homePageContent" vartype="com.endeca.infront.assembler.ContentItem" param="contentItem" />
    </dsp:oparam>
  </dsp:droplet>
      
  <c:if test="${not empty homePageContent}">
    <dsp:renderContentItem contentItem="${homePageContent}" />
  </c:if>

</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/index.jsp#1 $$Change: 848678 $ --%>