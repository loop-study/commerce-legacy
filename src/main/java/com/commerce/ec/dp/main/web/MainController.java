package com.commerce.ec.dp.main.web;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

import com.commerce.ec.dp.main.service.MainService;

@Controller
public class MainController {

	private static final Logger logger = LoggerFactory.getLogger(MainController.class);

	@Resource(name = "mainService")
	private MainService mainService;

	/**
	 * 메인 페이지
	 */
	@RequestMapping("/main.do")
	public String main(ModelMap model) {
		try {
			// 대카테고리 목록
			List<HashMap<String, Object>> catList = mainService.selectCategoryList();
			model.addAttribute("catList", catList);

			// 최신 상품 목록 (판매중, 최대 8건)
			List<HashMap<String, Object>> newPrdList = mainService.selectNewPrdList();
			model.addAttribute("newPrdList", newPrdList);

		} catch (Exception e) {
			logger.error("메인 페이지 조회 오류", e);
		}
		return "dp/main/main.main";
	}
}