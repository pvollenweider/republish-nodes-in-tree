<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="s" uri="http://www.jahia.org/tags/search" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<c:set var="startPath" value="${param.startPath}"/>
<c:set var="nodeType" value="${param.nodeType}"/>
<c:set var="testOnly" value="${param.testOnly}"/>
<c:set var="forcePublication" value="${param.forcePublication}"/>
<c:set var="posted" value="${param.posted}"/>

<main>
<c:if test="${empty posted}">

        <section class="py-3 text-center container">
            <div class="row py-lg-3">
                <div class="col-lg-6 col-md-8 mx-auto">
                    <h1 class="fw-light">Republish</h1>
                    <p class="lead text-muted">A tool to republish a content tree.</p>
                </div>
            </div>
        </section>

</c:if>


<c:if test="${empty startPath}">
    <c:set var="startPath" value="${renderContext.site.home.path}"/>
</c:if>
<c:if test="${empty nodeType}">
    <c:set var="nodeType" value="jnt:content"/>
</c:if>
<c:if test="${empty posted}">
    <c:set var="testOnly" value="On"/>
</c:if>
<div class="container pt-3">

    <form action="?">
        <input type="hidden" name="posted" value="true">

        <div class="mb-3">
            <label for="startPath" class="form-label">Start path</label>
            <input type="text" class="form-control" id="startPath" name="startPath" value="${startPath}" placeholder="${renderContext.site.home.path}">
            <div id="startPathHelp" class="form-text">Enter the starting path of the tree you want to republish.</div>
        </div>

        <div class="mb-3">
            <label for="nodeType" class="form-label">NodeType</label>
            <input type="text" class="form-control" id="nodeType" name="nodeType" value="${nodeType}" placeholder="jnt:content">
            <div id="nodeTypeHelp" class="form-text">Linit the type of node that you want to republish. </div>
        </div>

        <div class="mb-3">
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" id="testOnly" name="testOnly" ${! empty testOnly ? ' checked' : ''}>
                <label for="testOnly" class="form-check-label">Test only mode</label>
                <div id="testOnlyHelp" class="form-text">If enabled, no update or publication will be done</div>
            </div>
        </div>

        <div class="mb-3">
            <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" id="forcePublication" name="forcePublication" ${! empty forcePublication ? ' checked' : ''}>
                <label for="forcePublication" class="form-check-label">Force publication</label>
                <div id="forcePublicationHelp" class="form-text">If enabled, content with pending modification will be published</div>
            </div>
        </div>
        <div class="mb-3">

            <button class="btn btn-primary" type="submit">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-cloud-arrow-up" viewBox="0 0 16 16">
                    <path fill-rule="evenodd" d="M7.646 5.146a.5.5 0 0 1 .708 0l2 2a.5.5 0 0 1-.708.708L8.5 6.707V10.5a.5.5 0 0 1-1 0V6.707L6.354 7.854a.5.5 0 1 1-.708-.708l2-2z"/>
                    <path d="M4.406 3.342A5.53 5.53 0 0 1 8 2c2.69 0 4.923 2 5.166 4.579C14.758 6.804 16 8.137 16 9.773 16 11.569 14.502 13 12.687 13H3.781C1.708 13 0 11.366 0 9.318c0-1.763 1.266-3.223 2.942-3.593.143-.863.698-1.723 1.464-2.383zm.653.757c-.757.653-1.153 1.44-1.153 2.056v.448l-.445.049C2.064 6.805 1 7.952 1 9.318 1 10.785 2.23 12 3.781 12h8.906C13.98 12 15 10.988 15 9.773c0-1.216-1.02-2.228-2.313-2.228h-.5v-.5C12.188 4.825 10.328 3 8 3a4.53 4.53 0 0 0-2.941 1.1z"/>
                </svg>
                Republish</button>
        </div>
    </form>


    <c:if test="${! empty posted}">
        <c:choose>
            <c:when test="${!fn:contains(startPath,renderContext.site.path)}">
                <div class="alert alert-danger" role="alert">
                    <p><strong>Oops...</strong> The Start path is outside the current site</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:if test="${! empty testOnly || ! empty forcePublication}">
                    <div class="alert alert-warning" role="alert">
                        <c:if test="${! empty testOnly}">
                            <p><strong>Test only mode enabled</strong>. No updates or publication are done (only listing).</p>
                        </c:if>
                        <c:if test="${! empty forcePublication}">
                            <p><strong>Force publication mode enabled</strong>. content with pending modification will be published.</p>
                        </c:if>
                    </div>
                </c:if>
                <template:include view="execute"/>
            </c:otherwise>

        </c:choose>
    </c:if>
</div>
</main>
