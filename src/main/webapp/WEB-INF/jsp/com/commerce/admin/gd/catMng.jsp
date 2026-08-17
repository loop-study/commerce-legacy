<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="mt-4">
    <h4>카테고리 관리</h4>
    <p class="text-muted small">대분류를 선택하면 중분류가, 중분류를 선택하면 소분류가 표시됩니다.</p>

    <div class="row">
        <!-- 대분류 -->
        <div class="col-md-4">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center py-2">
                    <strong>대분류</strong>
                    <button type="button" class="btn btn-sm btn-success" onclick="openCatReg(1, '')">추가</button>
                </div>
                <ul class="list-group list-group-flush">
                    <c:forEach var="cat" items="${lCatList}">
                        <li class="list-group-item d-flex justify-content-between align-items-center py-2
                                   <c:if test="${cat.catCd == lCatCd}">bg-light</c:if>">
                            <a href="<c:url value='/admin/gd/catMng.do?lCatCd=${cat.catCd}'/>" class="text-dark">
                                <c:out value="${cat.catNm}"/>
                                <small class="text-muted">(<c:out value="${cat.catCd}"/>)</small>
                                <c:if test="${cat.useYn == 'N'}"><span class="badge badge-secondary">미사용</span></c:if>
                            </a>
                            <span class="text-nowrap">
                                <button type="button" class="btn btn-sm btn-outline-primary"
                                        onclick="openCatEdit('<c:out value="${cat.catCd}"/>')">수정</button>
                                <button type="button" class="btn btn-sm btn-outline-danger"
                                        onclick="deleteCat('<c:out value="${cat.catCd}"/>')">삭제</button>
                            </span>
                        </li>
                    </c:forEach>
                    <c:if test="${empty lCatList}">
                        <li class="list-group-item text-center text-muted py-3">등록된 대분류가 없습니다.</li>
                    </c:if>
                </ul>
            </div>
        </div>

        <!-- 중분류 -->
        <div class="col-md-4">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center py-2">
                    <strong>중분류</strong>
                    <c:if test="${not empty lCatCd}">
                        <button type="button" class="btn btn-sm btn-success" onclick="openCatReg(2, '<c:out value="${lCatCd}"/>')">추가</button>
                    </c:if>
                </div>
                <ul class="list-group list-group-flush">
                    <c:choose>
                        <c:when test="${empty lCatCd}">
                            <li class="list-group-item text-center text-muted py-3">대분류를 선택해주세요.</li>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="cat" items="${mCatList}">
                                <li class="list-group-item d-flex justify-content-between align-items-center py-2
                                           <c:if test="${cat.catCd == mCatCd}">bg-light</c:if>">
                                    <a href="<c:url value='/admin/gd/catMng.do?lCatCd=${lCatCd}&mCatCd=${cat.catCd}'/>" class="text-dark">
                                        <c:out value="${cat.catNm}"/>
                                        <small class="text-muted">(<c:out value="${cat.catCd}"/>)</small>
                                        <c:if test="${cat.useYn == 'N'}"><span class="badge badge-secondary">미사용</span></c:if>
                                    </a>
                                    <span class="text-nowrap">
                                        <button type="button" class="btn btn-sm btn-outline-primary"
                                                onclick="openCatEdit('<c:out value="${cat.catCd}"/>')">수정</button>
                                        <button type="button" class="btn btn-sm btn-outline-danger"
                                                onclick="deleteCat('<c:out value="${cat.catCd}"/>')">삭제</button>
                                    </span>
                                </li>
                            </c:forEach>
                            <c:if test="${empty mCatList}">
                                <li class="list-group-item text-center text-muted py-3">등록된 중분류가 없습니다.</li>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>

        <!-- 소분류 -->
        <div class="col-md-4">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center py-2">
                    <strong>소분류</strong>
                    <c:if test="${not empty mCatCd}">
                        <button type="button" class="btn btn-sm btn-success" onclick="openCatReg(3, '<c:out value="${mCatCd}"/>')">추가</button>
                    </c:if>
                </div>
                <ul class="list-group list-group-flush">
                    <c:choose>
                        <c:when test="${empty mCatCd}">
                            <li class="list-group-item text-center text-muted py-3">중분류를 선택해주세요.</li>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="cat" items="${sCatList}">
                                <li class="list-group-item d-flex justify-content-between align-items-center py-2">
                                    <span>
                                        <c:out value="${cat.catNm}"/>
                                        <small class="text-muted">(<c:out value="${cat.catCd}"/>)</small>
                                        <c:if test="${cat.useYn == 'N'}"><span class="badge badge-secondary">미사용</span></c:if>
                                    </span>
                                    <span class="text-nowrap">
                                        <button type="button" class="btn btn-sm btn-outline-primary"
                                                onclick="openCatEdit('<c:out value="${cat.catCd}"/>')">수정</button>
                                        <button type="button" class="btn btn-sm btn-outline-danger"
                                                onclick="deleteCat('<c:out value="${cat.catCd}"/>')">삭제</button>
                                    </span>
                                </li>
                            </c:forEach>
                            <c:if test="${empty sCatList}">
                                <li class="list-group-item text-center text-muted py-3">등록된 소분류가 없습니다.</li>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>
    </div>
</div>

<!-- 카테고리 등록/수정 모달 -->
<div class="modal fade" id="catModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="catModalTitle">카테고리 등록</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="catMode" value="reg">
                <input type="hidden" id="catCd" value="">
                <input type="hidden" id="catLvl" value="">
                <input type="hidden" id="upCatCd" value="">

                <div class="form-group row">
                    <label class="col-4 col-form-label">분류</label>
                    <div class="col-8"><span id="catLvlNm" class="form-control-plaintext"></span></div>
                </div>
                <div class="form-group row">
                    <label class="col-4 col-form-label">카테고리명 <span class="text-danger">*</span></label>
                    <div class="col-8">
                        <input type="text" id="catNm" class="form-control" maxlength="100">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-4 col-form-label">정렬순서</label>
                    <div class="col-8">
                        <input type="number" id="sortSeq" class="form-control" value="0">
                    </div>
                </div>
                <div class="form-group row mb-0">
                    <label class="col-4 col-form-label">사용여부</label>
                    <div class="col-8">
                        <select id="useYn" class="form-control">
                            <option value="Y">사용</option>
                            <option value="N">미사용</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="btnSaveCat" onclick="saveCat()">저장</button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<script>
/* 등록 모달 */
function openCatReg(catLvl, upCatCd) {
    $('#catMode').val('reg');
    $('#catCd').val('');
    $('#catLvl').val(catLvl);
    $('#upCatCd').val(upCatCd);
    $('#catLvlNm').text(getCatLvlNm(catLvl));
    $('#catNm').val('');
    $('#sortSeq').val('0');
    $('#useYn').val('Y');
    $('#catModalTitle').text('카테고리 등록');
    setCatSaving(false);
    $('#catModal').modal('show');
}

/* 수정 모달 */
function openCatEdit(catCd) {
    $.ajax({
        url: '<c:url value="/admin/gd/selectCatDtl.do"/>',
        type: 'GET',
        data: { catCd: catCd },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode !== 'SUCCESS' || !data.catInfo) {
                alert('카테고리 정보를 불러올 수 없습니다.');
                return;
            }
            var c = data.catInfo;
            $('#catMode').val('edit');
            $('#catCd').val(c.catCd);
            $('#catLvl').val(c.catLvl);
            $('#upCatCd').val(c.upCatCd || '');
            $('#catLvlNm').text(getCatLvlNm(c.catLvl));
            $('#catNm').val(c.catNm);
            $('#sortSeq').val(c.sortSeq);
            $('#useYn').val(c.useYn);
            $('#catModalTitle').text('카테고리 수정');
            setCatSaving(false);
            $('#catModal').modal('show');
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
        }
    });
}

function getCatLvlNm(catLvl) {
    if (catLvl == 1) return '대분류';
    if (catLvl == 2) return '중분류';
    return '소분류';
}

/* 저장 진행중 여부 - 중복 클릭 시 카테고리가 두 건 등록되는 것을 막는다 */
var catSaving = false;

function setCatSaving(on) {
    catSaving = on;
    $('#btnSaveCat').prop('disabled', on).text(on ? '저장중...' : '저장');
}

function saveCat() {
    if (catSaving) return;

    var catNm = $.trim($('#catNm').val());
    if (!catNm) {
        alert('카테고리명을 입력해주세요.');
        $('#catNm').focus();
        return;
    }

    setCatSaving(true);

    $.ajax({
        url: '<c:url value="/admin/gd/saveCat.do"/>',
        type: 'POST',
        data: {
            mode: $('#catMode').val(),
            catCd: $('#catCd').val(),
            catLvl: $('#catLvl').val(),
            upCatCd: $('#upCatCd').val(),
            catNm: catNm,
            sortSeq: $('#sortSeq').val(),
            useYn: $('#useYn').val()
        },
        dataType: 'json',
        success: function(data) {
            alert(data.rtnMsg);
            if (data.rtnCode === 'SUCCESS') {
                location.reload();
            } else {
                setCatSaving(false);
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
            setCatSaving(false);
        }
    });
}

function deleteCat(catCd) {
    if (!confirm('해당 카테고리를 삭제하시겠습니까?')) return;

    $.ajax({
        url: '<c:url value="/admin/gd/deleteCat.do"/>',
        type: 'POST',
        data: { catCd: catCd },
        dataType: 'json',
        success: function(data) {
            alert(data.rtnMsg);
            if (data.rtnCode === 'SUCCESS') {
                location.href = '<c:url value="/admin/gd/catMng.do"/>';
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
        }
    });
}
</script>
