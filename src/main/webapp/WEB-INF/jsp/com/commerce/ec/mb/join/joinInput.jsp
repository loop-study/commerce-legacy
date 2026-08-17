<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-4">
    <h4 class="mb-4">회원가입</h4>

    <!-- 가입 단계 -->
    <div class="row text-center mb-4">
        <div class="col-4"><span class="badge badge-light p-2">1. 약관동의</span></div>
        <div class="col-4"><span class="badge badge-dark p-2">2. 정보입력</span></div>
        <div class="col-4"><span class="badge badge-light p-2">3. 가입완료</span></div>
    </div>

    <form id="joinForm" onsubmit="return false;">
        <input type="hidden" name="agreeYn" value="<c:out value='${agreeYn}'/>">
        <input type="hidden" name="privacyYn" value="<c:out value='${privacyYn}'/>">

        <div class="card mb-4">
            <div class="card-header">기본 정보</div>
            <div class="card-body">
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">아이디 <span class="text-danger">*</span></label>
                    <div class="col-sm-4">
                        <div class="input-group">
                            <input type="text" name="loginId" id="loginId" class="form-control"
                                   placeholder="영문/숫자 4~20자" maxlength="20" onkeyup="clearDupChk()">
                            <div class="input-group-append">
                                <button type="button" class="btn btn-outline-secondary" onclick="dupIdCheck()">중복확인</button>
                            </div>
                        </div>
                        <small id="dupIdMsg" class="form-text"></small>
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">비밀번호 <span class="text-danger">*</span></label>
                    <div class="col-sm-4">
                        <input type="password" name="pwd" id="pwd" class="form-control"
                               placeholder="비밀번호를 입력하세요" maxlength="30">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">비밀번호 확인 <span class="text-danger">*</span></label>
                    <div class="col-sm-4">
                        <input type="password" name="pwdConfirm" id="pwdConfirm" class="form-control"
                               placeholder="비밀번호를 다시 입력하세요" maxlength="30">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">이름 <span class="text-danger">*</span></label>
                    <div class="col-sm-4">
                        <input type="text" name="mbrNm" id="mbrNm" class="form-control" maxlength="50">
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header">연락처 / 주소</div>
            <div class="card-body">
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">휴대폰번호</label>
                    <div class="col-sm-4">
                        <input type="text" name="hpNo" id="hpNo" class="form-control"
                               placeholder="010-0000-0000" maxlength="20">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">이메일</label>
                    <div class="col-sm-4">
                        <input type="text" name="email" id="email" class="form-control"
                               placeholder="example@commerce.co.kr" maxlength="100">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">우편번호</label>
                    <div class="col-sm-3">
                        <input type="text" name="zipcode" id="zipcode" class="form-control"
                               placeholder="우편번호" maxlength="10">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">주소</label>
                    <div class="col-sm-6">
                        <input type="text" name="baseAddr" id="baseAddr" class="form-control mb-2"
                               placeholder="기본주소" maxlength="200">
                        <input type="text" name="dtlAddr" id="dtlAddr" class="form-control"
                               placeholder="상세주소" maxlength="200">
                    </div>
                </div>
            </div>
        </div>

        <div class="text-center mb-5">
            <a href="<c:url value='/mb/join/joinAgree.do'/>" class="btn btn-outline-secondary btn-lg mr-2">이전</a>
            <button type="button" class="btn btn-dark btn-lg" onclick="doJoin()">가입하기</button>
        </div>
    </form>
</div>

<script>
/* 아이디 중복확인 여부 */
var dupChkYn = "N";

function clearDupChk() {
    dupChkYn = "N";
    $("#dupIdMsg").text("").removeClass("text-danger text-success");
}

function dupIdCheck() {
    var loginId = $.trim($("#loginId").val());
    if (!loginId) {
        alert("아이디를 입력해주세요.");
        $("#loginId").focus();
        return;
    }

    $.ajax({
        url: "<c:url value='/mb/join/dupIdCheck.do'/>",
        type: "POST",
        data: { loginId: loginId },
        dataType: "json",
        success: function(res) {
            if (res.rtnCode === "OK") {
                dupChkYn = "Y";
                $("#dupIdMsg").text(res.rtnMsg).removeClass("text-danger").addClass("text-success");
            } else {
                dupChkYn = "N";
                $("#dupIdMsg").text(res.rtnMsg).removeClass("text-success").addClass("text-danger");
            }
        },
        error: function() {
            alert("시스템 오류가 발생했습니다.");
        }
    });
}

function doJoin() {
    var loginId = $.trim($("#loginId").val());
    var pwd = $.trim($("#pwd").val());
    var pwdConfirm = $.trim($("#pwdConfirm").val());
    var mbrNm = $.trim($("#mbrNm").val());

    if (!loginId) {
        alert("아이디를 입력해주세요.");
        $("#loginId").focus();
        return;
    }
    if (dupChkYn !== "Y") {
        alert("아이디 중복확인을 해주세요.");
        return;
    }
    if (!pwd) {
        alert("비밀번호를 입력해주세요.");
        $("#pwd").focus();
        return;
    }
    if (pwd !== pwdConfirm) {
        alert("비밀번호가 일치하지 않습니다.");
        $("#pwdConfirm").focus();
        return;
    }
    if (!mbrNm) {
        alert("이름을 입력해주세요.");
        $("#mbrNm").focus();
        return;
    }

    $.ajax({
        url: "<c:url value='/mb/join/saveJoinMbr.do'/>",
        type: "POST",
        data: $("#joinForm").serialize(),
        dataType: "json",
        success: function(res) {
            if (res.rtnCode === "SUCCESS") {
                location.href = "<c:url value='/mb/join/joinComplete.do'/>";
            } else {
                alert(res.rtnMsg);
                if (res.rtnCode === "DUP") {
                    dupChkYn = "N";
                    $("#loginId").focus();
                }
            }
        },
        error: function() {
            alert("시스템 오류가 발생했습니다.");
        }
    });
}
</script>
