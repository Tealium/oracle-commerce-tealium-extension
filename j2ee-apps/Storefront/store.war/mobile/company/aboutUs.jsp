<%--
  General information about the company ("About Us" page).

  Page includes:
    None

  Required Parameters:
    None

  Optional Parameters:
    None
--%>
<dsp:page>
  <fmt:message var="pageTitle" key="mobile.moreInfo.aboutUs"/>
  <crs:mobilePageContainer titleString="${pageTitle}">
    <jsp:body>
      <div class="infoHeader">
        <fmt:message key="mobile.company.aboutUs.ourHistory.header"/>
      </div>
      <div class="infoContent">
        <p>
          <fmt:message key="mobile.company.aboutUs.text"/>
        </p>
      </div>
    </jsp:body>
  </crs:mobilePageContainer>
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/mobile/company/aboutUs.jsp#1 $$Change: 848678 $ --%>
