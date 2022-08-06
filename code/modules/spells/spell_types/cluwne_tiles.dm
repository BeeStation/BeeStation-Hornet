/obj/effect/proc_holder/spell/aoe_turf/cluwne_tiles
	name = "Cluwnificate tiles"
	desc = "Lubricate big amount of tiles around you with super duper lube for 7 seconds while you become slip free for the duration."

	school = "conjuration" // not transmutation, because it's summoning lubes on tiles
	clothes_req = TRUE
	invocation = "KLUDA ARV'N GRIODANE"
	invocation_type = "shout"
	charge_max = 60 SECONDS
	cooldown_min = 30 SECONDS
	range = 22 // radius of tiles from the caster to lubricate
	var/lubricant_duration = 7 SECONDS

	sound = "sound/effects/meteorimpact.ogg"
	action_icon = 'icons/mob/mask.dmi'
	action_icon_state = "clown"

/obj/effect/proc_holder/spell/aoe_turf/cluwne_tiles/cast(list/targets, mob/user=usr)
	var/area/A = get_area(user)
	if(istype(A, /area/wizard_station))
		// This is a bug-proof to prevent wizards to get perma-slip-free trait by casting then refunding the spell.
		to_chat(user, "<span class='warning'>Wizard Federation doesn't want their property to be lubricated by the annoying spell. Best wait until you leave to use [src].</span>")
		return
	ADD_TRAIT(user, TRAIT_NOSLIPALL, MAGIC_TRAIT)
	addtimer(CALLBACK(src, /obj/effect/proc_holder/spell/aoe_turf/cluwne_tiles.proc/remove_trait, user), lubricant_duration*2) // This should be called more than `1.5*duration SECONDS` because that time is exactly when the lube tiles gone. that's why it's *2.
	for(var/turf/open/O in targets)
		O.MakeSlippery(TURF_WET_SUPERLUBE, lubricant_duration)

/obj/effect/proc_holder/spell/aoe_turf/cluwne_tiles/proc/remove_trait(mob/user)
	REMOVE_TRAIT(user, TRAIT_NOSLIPALL, MAGIC_TRAIT)
