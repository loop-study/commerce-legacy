package com.commerce.ec.cmmn.utils;

import java.util.Random;

public class NumberUtil {

	public static String randNumGenerate(int length) {
		Random random = new Random();
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < length; i++) {
			sb.append(random.nextInt(10));
		}
		return sb.toString();
	}
}
