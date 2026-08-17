<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="row justify-content-center mt-5">
    <div class="col-md-5">
        <div class="card">
            <div class="card-body p-4">
                <h4 class="card-title text-center mb-4">로그인</h4>
                <form id="loginForm" onsubmit="return false;">
                    <input type="hidden" id="returnUrl" value="${returnUrl}"/>
                    <div class="form-group">
                        <label for="loginId">아이디</label>
                        <input type="text" class="form-control" id="loginId" name="loginId"
                               placeholder="아이디를 입력하세요" maxlength="20" autofocus>
                    </div>
                    <div class="form-group">
                        <label for="pwd">비밀번호</label>
                        <input type="password" class="form-control" id="pwd" name="pwd"
                               placeholder="비밀번호를 입력하세요" maxlength="30">
                    </div>
                    <div id="loginMsg" class="text-danger small mb-3" style="display:none;"></div>
                    <button type="button" class="btn btn-dark btn-block" id="btnLogin" onclick="doLogin()">로그인</button>
                </form>
                <div class="text-center mt-3">
                    <a href="<c:url value='/mb/join/joinAgree.do'/>" class="text-muted small">회원가입</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
    $("#btnLogin").on("click", function() {
        doLogin();
    });

    $("#loginId, #pwd").on("keypress", function(e) {
        if (e.which === 13) {
            doLogin();
        }
    });
});

function doLogin() {
    var loginId = $.trim($("#loginId").val());
    var pwd = $.trim($("#pwd").val());

    if (!loginId) {
        showMsg("아이디를 입력하세요.");
        $("#loginId").focus();
        return;
    }
    if (!pwd) {
        showMsg("비밀번호를 입력하세요.");
        $("#pwd").focus();
        return;
    }

    $.ajax({
        url: "<c:url value='/selectLoginProc.do'/>",
        type: "POST",
        data: { loginId: loginId, pwd: pwd },
        dataType: "json",
        success: function(res) {
            if (res.rtnCode === "SUCCESS") {
                var returnUrl = $.trim($("#returnUrl").val());
                if (returnUrl) {
                    location.href = returnUrl;
                } else {
                    location.href = "<c:url value='/main.do'/>";
                }
            } else {
                showMsg(res.rtnMsg);
            }
        },
        error: function() {
            showMsg("시스템 오류가 발생했습니다.");
        }
    });
}

function showMsg(msg) {
    $("#loginMsg").text(msg).show();
}
</script>