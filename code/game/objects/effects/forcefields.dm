/obj/effect/forcefield
	desc = "A space wizard's magic wall."
	name = "FORCEWALL"
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	CanAtmosPass = ATMOS_PASS_DENSITY
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	var/timeleft = 300 //Set to 0 for permanent forcefields (ugh)

/obj/effect/forcefield/Initialize(mapload, ntimeleft)
	. = ..()
	if(isnum_safe(ntimeleft))
		timeleft = ntimeleft
	if(timeleft)
		QDEL_IN(src, timeleft)

/obj/effect/forcefield/singularity_pull()
	return

/obj/effect/forcefield/cult
	desc = "An unholy shield that blocks all attacks."
	name = "glowing wall"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultshield"
	CanAtmosPass = ATMOS_PASS_NO
	timeleft = 200

//Event forcefields

/obj/effect/forcefield/event
	name = "glowing barrier"
	desc = "An unholy barrier obstructs your path."
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultshield"
	CanAtmosPass = ATMOS_PASS_NO
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF // Seriously doubt forcefields can be effected like this, but just in case, right?
	timeleft = 0
	layer = 3.5
	opacity = TRUE

/obj/effect/forcefield/event/door
	icon_state = "door-shield"

/obj/effect/forcefield/event/space //For use outside the station to prevent players from bypassing major chunks of the station
	name = "spacial barrier"
	desc = "A rapidly expanding barrier capable of interfering with all but the most advanced forms of intragalactic spaceflight and communications technology."
	icon = 'icons/effects/gorewall.dmi'
	icon_state = "gorewall-15"

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "nothing"
	name = "invisible wall"
	desc = "You have a bad feeling about this."

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You're gonna be here awhile."
	timeleft = 600
