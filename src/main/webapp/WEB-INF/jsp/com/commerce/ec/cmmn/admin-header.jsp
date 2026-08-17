<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <a class="navbar-brand" href="<c:url value='/admin/gd/prdMng.do'/>">Commerce Admin</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#adminNavbar"
            aria-controls="adminNavbar" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="adminNavbar">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/admin/gd/prdMng.do'/>">상품관리</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/admin/gd/catMng.do'/>">카테고리관리</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/admin/od/ordList.do'/>">주문관리</a>
            </li>
        </ul>
        <ul class="navbar-nav">
            <c:if test="${not empty sessionScope.adminVO}">
                <li class="nav-item">
                    <span class="nav-link text-warning"><c:out value="${sessionScope.adminVO.adminNm}"/>님</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<c:url value='/admin/selectLogout.do'/>">로그아웃</a>
                </li>
            </c:if>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/main.do'/>">FO로 이동</a>
            </li>
        </ul>
    </div>
</nav>
