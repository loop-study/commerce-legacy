<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="<c:url value='/main.do'/>">Commerce</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#mainNavbar"
            aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="mainNavbar">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/main.do'/>">메인</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/dp/good/prdList.do'/>">상품목록</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/od/cart/cartInit.do'/>">장바구니</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="<c:url value='/my/order/myOrderList.do'/>">마이페이지</a>
            </li>
        </ul>
        <ul class="navbar-nav">
            <c:if test="${not empty sessionScope.memberVO}">
                <li class="nav-item">
                    <span class="nav-link"><c:out value="${sessionScope.memberVO.mbrNm}"/>님</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<c:url value='/selectLogout.do'/>">로그아웃</a>
                </li>
            </c:if>
            <c:if test="${empty sessionScope.memberVO}">
                <li class="nav-item">
                    <a class="nav-link" href="<c:url value='/login.do'/>">로그인</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<c:url value='/mb/join/joinAgree.do'/>">회원가입</a>
                </li>
            </c:if>
        </ul>
    </div>
</nav>
