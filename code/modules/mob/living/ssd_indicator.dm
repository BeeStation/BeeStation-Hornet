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

//This proc should stop mobs from having the overlay when someone keeps jumping control of mobs, unfortunately it causes Aghosts to have their character without the SSD overlay, I wasn't able to find a better proc unfortunately
/mob/living/transfer_ckey(mob/new_mob, send_signal = TRUE)
	..()
	set_ssd_indicator(FALSE)
