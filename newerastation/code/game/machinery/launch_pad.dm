/datum/atom_hud/launchpad_hud
	hud_icons = list(DIAG_LAUNCHPAD_HUD)

/obj/machinery/launchpad/Initialize()
	. = ..()
	for(var/datum/atom_hud/launchpad_hud/hud in GLOB.huds)
		hud.add_to_hud(src)

/obj/item/launchpad_remote
	var/hud_type = ANTAG_HUD_BFLAUNCHPAD
	var/hud_on = FALSE

/obj/item/launchpad_remote/attack_self(mob/user)
	. = ..()
	if(!hud_on)
		hud_on = TRUE
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.add_hud_to(user)

/obj/item/launchpad_remote/ui_close(mob/user)
	. = ..() //just in case upstream decides to implement this in the future
	to_chat(user, "<span class='notice'>The display quickly fades.</span>")
	if(hud_on)
		hud_on = FALSE
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.remove_hud_from(user)
