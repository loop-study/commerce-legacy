<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - 서버 오류</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
</head>
<body>
    <div class="container text-center mt-5">
        <h1 class="display-1">500</h1>
        <h2>서버 오류가 발생했습니다</h2>
        <p class="lead">일시적인 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.</p>
        <a href="<c:url value='/main.do'/>" class="btn btn-primary mt-3">메인으로 이동</a>
    </div>
</body>
</html>
