//Toggle Night Vision
/datum/action/spell/night_vision
	name = "Toggle Nightvision"
	desc = "Toggle your nightvision mode."

	cooldown_time = 1 SECONDS
	spell_requirements = NONE

	/// The span the "toggle" message uses when sent to the user
	var/toggle_span = "notice"

/datum/action/spell/night_vision/New(Target)
	. = ..()
	name = "[name] \[ON\]"

/datum/action/spell/night_vision/is_valid_spell(mob/user, atom/target)
	return isliving(user)

/datum/action/spell/night_vision/on_cast(mob/living/user, atom/target)
	. = ..()
	to_chat(user, "<span class='[toggle_span]'>You toggle your night vision.</span>")

	var/next_mode_text = ""
	switch(user.lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			next_mode_text = "More"
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			next_mode_text = "Full"
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			next_mode_text = "OFF"
		else
			user.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			next_mode_text = "ON"

	user.update_sight()
	name = "[initial(name)] \[[next_mode_text]\]"
