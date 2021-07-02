<%@ page language="java" contentType="text/html;charset=UTF-8" %><!doctype html>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<html lang="${fn:substring(renderContext.request.locale,0,2)}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:description" inherited="true" var="description"/>
    <jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:createdBy" inherited="true" var="author"/>
    <c:set var="keywords" value="${jcr:getKeywords(renderContext.mainResource.node, true)}"/>
    <c:if test="${!empty description}"><meta name="description" content="${description.string}" /></c:if>
    <c:if test="${!empty author}"><meta name="author" content="${author.string}" /></c:if>
    <c:if test="${!empty keywords}"><meta name="keywords" content="${keywords}" /></c:if>
    <title>${fn:escapeXml(renderContext.mainResource.node.displayableName)}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

</head>

<body class="bg-light">

<div class="container">
    <template:area path="pagecontent"/>
</div>
<template:addResources type="javascript" resources="jquery.min.js"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
</body>
</html>
