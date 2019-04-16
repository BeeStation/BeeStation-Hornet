/client/New()
	. = ..()
	if(!prefs.agree_rules)  // if this is their first time joining since the new movement
		alert("By playing here, you agree to follow the rules stated by the rules button.")
		prefs.agree_rules = TRUE
		prefs.save_preferences()