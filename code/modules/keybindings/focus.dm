/mob/var/datum/focus //What receives our keyboard inputs. src by default

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return
	focus = new_focus
	set_mob_eye(focus) //Maybe this should be done manually? You figure it out, reader
