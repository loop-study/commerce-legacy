<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container mt-4">
    <h4 class="mb-4">회원가입</h4>

    <!-- 가입 단계 -->
    <div class="row text-center mb-4">
        <div class="col-4"><span class="badge badge-dark p-2">1. 약관동의</span></div>
        <div class="col-4"><span class="badge badge-light p-2">2. 정보입력</span></div>
        <div class="col-4"><span class="badge badge-light p-2">3. 가입완료</span></div>
    </div>

    <c:if test="${not empty msg}">
        <div class="alert alert-danger"><c:out value="${msg}"/></div>
    </c:if>

    <form id="agreeForm" action="<c:url value='/mb/join/joinInput.do'/>" method="post">
        <!-- 이용약관 -->
        <div class="card mb-3">
            <div class="card-header">이용약관 <span class="text-danger">(필수)</span></div>
            <div class="card-body">
                <textarea class="form-control" rows="7" readonly>제1조(목적)
이 약관은 Commerce(이하 "회사")가 제공하는 전자상거래 서비스의 이용조건 및 절차,
회사와 회원 간의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

제2조(정의)
1. "서비스"란 회사가 운영하는 사이버몰에서 재화 등을 거래할 수 있도록 제공하는 서비스를 말합니다.
2. "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자를 말합니다.

제3조(약관의 효력 및 변경)
회사는 관련 법령을 위배하지 않는 범위에서 이 약관을 변경할 수 있으며,
변경 시 적용일자 및 사유를 명시하여 서비스 화면에 공지합니다.

※ 본 약관은 토이 프로젝트용 예시 문안입니다.</textarea>
                <div class="form-check mt-2">
                    <input type="checkbox" class="form-check-input" id="agreeYn" name="agreeYn" value="Y">
                    <label class="form-check-label" for="agreeYn">이용약관에 동의합니다.</label>
                </div>
            </div>
        </div>

        <!-- 개인정보 수집·이용 동의 -->
        <div class="card mb-3">
            <div class="card-header">개인정보 수집·이용 동의 <span class="text-danger">(필수)</span></div>
            <div class="card-body">
                <textarea class="form-control" rows="7" readonly>1. 수집 항목
- 필수 : 아이디, 비밀번호, 이름
- 선택 : 휴대폰번호, 이메일, 주소

2. 수집·이용 목적
- 회원 식별 및 서비스 제공, 주문·배송 처리, 고객 문의 응대

3. 보유 및 이용 기간
- 회원 탈퇴 시까지 (관계 법령에 따라 일정 기간 보관될 수 있음)

동의를 거부할 권리가 있으며, 거부 시 회원가입이 제한됩니다.

※ 본 문안은 토이 프로젝트용 예시입니다.</textarea>
                <div class="form-check mt-2">
                    <input type="checkbox" class="form-check-input" id="privacyYn" name="privacyYn" value="Y">
                    <label class="form-check-label" for="privacyYn">개인정보 수집·이용에 동의합니다.</label>
                </div>
            </div>
        </div>

        <!-- 전체동의 -->
        <div class="form-check mb-4">
            <input type="checkbox" class="form-check-input" id="allAgreeYn" onclick="checkAllAgree(this)">
            <label class="form-check-label font-weight-bold" for="allAgreeYn">전체 동의</label>
        </div>

        <div class="text-center mb-5">
            <a href="<c:url value='/main.do'/>" class="btn btn-outline-secondary btn-lg mr-2">취소</a>
            <button type="button" class="btn btn-dark btn-lg" onclick="goJoinInput()">다음 단계</button>
        </div>
    </form>
</div>

<script>
function checkAllAgree(el) {
    var checked = $(el).is(":checked");
    $("#agreeYn").prop("checked", checked);
    $("#privacyYn").prop("checked", checked);
}

function goJoinInput() {
    if (!$("#agreeYn").is(":checked")) {
        alert("이용약관에 동의해주세요.");
        return;
    }
    if (!$("#privacyYn").is(":checked")) {
        alert("개인정보 수집·이용에 동의해주세요.");
        return;
    }
    $("#agreeForm").submit();
}
</script>
