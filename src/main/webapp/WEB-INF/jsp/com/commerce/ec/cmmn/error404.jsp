<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - 페이지를 찾을 수 없습니다</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
</head>
<body>
    <div class="container text-center mt-5">
        <h1 class="display-1">404</h1>
        <h2>페이지를 찾을 수 없습니다</h2>
        <p class="lead">요청하신 페이지가 존재하지 않습니다.</p>
        <a href="<c:url value='/main.do'/>" class="btn btn-primary mt-3">메인으로 이동</a>
    </div>
</body>
</html>
