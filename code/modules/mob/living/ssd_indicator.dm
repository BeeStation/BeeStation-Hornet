/mob/living/var/lastclienttime = 0
/mob/living/var/obj/effect/decal/ssd_indicator

/mob/living/proc/set_ssd_indicator(var/state)
	if(!ssd_indicator)
		ssd_indicator = new
		ssd_indicator.icon = 'icons/mob/hud.dmi'
		ssd_indicator.icon_state = "ssd"
		ssd_indicator.layer = FLY_LAYER

	ssd_indicator.invisibility = invisibility
	if(state && stat != DEAD)
		overlays += ssd_indicator
	else
		overlays -= ssd_indicator
	return state
