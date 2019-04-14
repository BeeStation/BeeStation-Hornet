/client/New()
	. = ..()
	if(!prefs.rules_agree)  // if this is their first time joining since the new movement
		warning("By playing here, you agree to follow the rules stated by the rules button.")
		prefs.rules_agree = TRUE
		prefs.save_preferences()