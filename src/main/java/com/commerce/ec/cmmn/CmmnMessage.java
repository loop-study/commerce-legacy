package com.commerce.ec.cmmn;

import java.util.Locale;

import javax.annotation.Resource;

import org.springframework.context.MessageSource;
import org.springframework.stereotype.Component;

@Component
public class CmmnMessage {

	@Resource(name = "messageSource")
	private MessageSource messageSource;

	public String getMessage(String code) {
		return messageSource.getMessage(code, null, Locale.getDefault());
	}

	public String getMessage(String code, Object[] args) {
		return messageSource.getMessage(code, args, Locale.getDefault());
	}

	public String getMessage(String code, Object[] args, Locale locale) {
		return messageSource.getMessage(code, args, locale);
	}
}
