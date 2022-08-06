/obj/effect/proc_holder/spell/cluwne_tiles
	name = "Cluwnificate tiles"
	desc = "Lubricate big amount of tiles around you with super duper lube for 3 seconds while you become slip free for a short duration."

	school = "conjuration" // not transmutation, because it's summoning lubes on tiles
	clothes_req = TRUE
	invocation = "KLUDA ARV'N GRIODANE"
	invocation_type = "shout"
	charge_max = 60 SECONDS
	cooldown_min = 6 SECONDS
	range = 40 // radius of tiles from center to lubricate
	var/lubricant_duration = 3 SECONDS

	sound = "sound/effects/meteorimpact.ogg"
	action_icon = 'icons/mob/mask.dmi'
	action_icon_state = "clown"

/obj/effect/proc_holder/spell/cluwne_tiles/cast(list/targets, mob/user=usr)
	world.log << "cast successed"
	ADD_TRAIT(user, TRAIT_NOSLIPALL, MAGIC_TRAIT)
	addtimer(CALLBACK(src, /obj/effect/proc_holder/spell/cluwne_tiles.proc/remove_trait, user), lubricant_duration+1 SECONDS)
	for(var/turf/open/O in RANGE_TURFS(range, user))
		O.MakeSlippery(TURF_WET_SUPERLUBE, lubricant_duration)
		world.log << "done [O]"

/obj/effect/proc_holder/spell/cluwne_tiles/proc/remove_trait(mob/user)
	REMOVE_TRAIT(user, TRAIT_NOSLIPALL, MAGIC_TRAIT)
