/**
 * Ensure VV edits to holoparasites go through the proper setter procs where applicable.
 */
/mob/living/simple_animal/hostile/holoparasite/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, name), NAMEOF(src, real_name))
			if(!istext(var_value) || !length(var_value) || length(var_value) > MAX_NAME_LEN)
				return FALSE
			set_new_name(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, theme))
			var/datum/holoparasite_theme/new_theme = get_holoparasite_theme(var_value)
			if(!istype(new_theme))
				return FALSE
			set_theme(new_theme)
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, accent_color))
			if(!istext(var_value) || !length(var_value))
				return FALSE
			set_accent_color(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, summoner))
			if(!istype(var_value, /datum/mind))
				return FALSE
			set_summoner(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, battlecry))
			if(!isnull(var_value) && (!istext(var_value) || !length(var_value)))
				return FALSE
			set_battlecry(var_value, silent = TRUE)
			datum_flags |= DF_VAR_EDITED
			return TRUE
	return ..()
