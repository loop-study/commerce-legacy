<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-4">
    <h4 class="mb-4">회원가입</h4>

    <!-- 가입 단계 -->
    <div class="row text-center mb-4">
        <div class="col-4"><span class="badge badge-light p-2">1. 약관동의</span></div>
        <div class="col-4"><span class="badge badge-light p-2">2. 정보입력</span></div>
        <div class="col-4"><span class="badge badge-dark p-2">3. 가입완료</span></div>
    </div>

    <div class="card">
        <div class="card-body text-center py-5">
            <h5 class="mb-3">회원가입이 완료되었습니다.</h5>
            <p class="text-muted mb-4">
                로그인 후 서비스를 이용하실 수 있습니다.
            </p>
            <a href="<c:url value='/login.do'/>" class="btn btn-dark btn-lg mr-2">로그인</a>
            <a href="<c:url value='/main.do'/>" class="btn btn-outline-secondary btn-lg">메인으로</a>
        </div>
    </div>
</div>
