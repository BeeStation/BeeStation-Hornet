/mob/living/silicon/Login()
	if(mind && SSticker.mode)
		SSticker.mode.remove_cultist(mind, 0, 0)
	..()

/mob/living/silicon/auto_deadmin_on_login()
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_silicons) || (client.prefs?.toggles & PREFTOGGLE_DEADMIN_POSITION_SILICON))
		return client.holder.auto_deadmin()
	return ..()
