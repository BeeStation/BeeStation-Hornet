/mob/living/silicon/auto_deadmin_on_login()
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_silicons) || client.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_silicon))
		return client.holder.auto_deadmin()
	return ..()
