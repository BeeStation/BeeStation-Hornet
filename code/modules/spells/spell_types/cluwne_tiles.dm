/obj/effect/proc_holder/spell/cluwne_tiles
	name = "Cluwnificate tiles"
	desc = "Lubricate big amount of tiles around you with magical lubes for some seconds. Wizards are immune to magical lubes, but still vulnerable to normal lubes."

	school = "conjuration" // not transmutation, because it's summoning lubes on tiles
	clothes_req = TRUE
	invocation = "KLUDA ARV'N GRIODANE"
	invocation_type = "shout"
	charge_max = 60 SECONDS
	cooldown_min = 30 SECONDS
	range = 40 // radius of tiles from the caster to lubricate
	var/lubricant_duration = 7 SECONDS

	sound = "sound/effects/meteorimpact.ogg"
	action_icon = 'icons/mob/mask.dmi'
	action_icon_state = "clown"

/obj/effect/proc_holder/spell/cluwne_tiles/choose_targets(mob/user = usr)
	// for optimization, targets will be given in the for loop in cast proc ("spiral_range_turfs()")
	perform(user=user)

/obj/effect/proc_holder/spell/cluwne_tiles/cast(mob/user=usr)
 	// magical no slip is given at antag_spawner.dm as `ADD_TRAIT(H, TRAIT_NOSLIPMAGIC, MAGIC_TRAIT)`
	// This is because your apprentices or fellow wizard(possibly) are supposed to be disabled by your cluwne tile spell
	ADD_TRAIT(user, TRAIT_NOSLIPMAGIC, MAGIC_TRAIT) // If you got this spell somehow, not through being a real wizard, you need to get this trait

	var/count = 1
	for(var/turf/open/O in spiral_range_turfs(dist=range, tick_checked=FALSE))
		O.MakeSlippery(TURF_WET_MAGICAL, lubricant_duration)
		count++
		if(count%200 == 0) // lag proof sleep
			count = 0
			sleep(1)
