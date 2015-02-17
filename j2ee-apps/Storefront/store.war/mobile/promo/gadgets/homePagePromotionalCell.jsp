<%--
  Renders promotional item cell html (top slot).
                                                       Required Parameters:
    promotionalContent
      Promotional item

  Optional Parameters:
    None
--%>
<dsp:page>
  <%-- Request parameters - to variables --%>
  <dsp:getvalueof var="promotionalContent" param="promotionalContent"/>

  <div class="cell">
    <div class="homePromotionalWrap">
      <c:choose>
        <c:when test="${not empty promotionalContent.linkUrl}">
          <%-- Display "Link destination" --%>
          <c:choose>
            <%-- handle Endeca links --%>
            <c:when test="${fn:startsWith(promotionalContent.linkUrl, '/browse')}">
              <a href="${siteBaseURL}${promotionalContent.linkUrl}">
                <img src="${promotionalContent.derivedDeviceImage}" alt="${promotionalContent.displayName}"
                class="homePromotionalImage" style="background-image:url(${promotionalContent.deviceDescription})"/>
              </a>
            </c:when>
            <%-- otherwise popup the link in a new window --%>
            <c:otherwise>
              <a href="${promotionalContent.linkUrl}" target="_blank">
                <img src="${promotionalContent.derivedDeviceImage}" alt="${promotionalContent.displayName}"
                class="homePromotionalImage" style="background-image:url(${promotionalContent.deviceDescription})"/>
              </a>
            </c:otherwise>
          </c:choose>
        </c:when>
        <c:otherwise>
          <%-- Display static image --%>
          <img src="${promotionalContent.derivedDeviceImage}" alt="${promotionalContent.displayName}"
               class="homePromotionalImage" style="background-image:url(${promotionalContent.deviceDescription})"/>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/mobile/promo/gadgets/homePagePromotionalCell.jsp#1 $$Change: 848678 $--%>
