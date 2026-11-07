/mob/var/datum/focus //What receives our keyboard inputs. src by default

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return
	focus = new_focus
	set_mob_eye_to(focus == src ? MOB_EYE_SELF : focus) // Old comment: Maybe this should be done manually? You figure it out, reader // EvilDragon: I have no idea why they wanted this here and what they intended.
