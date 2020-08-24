/datum/guardian_ability/major/frenzy
	name = "Frenzy"
	desc = "This guardian attacks by teleport around a target making it hard to hit, as well as speeding up its owner while manifested. REQUIRES RANGE C OR ABOVE."
	ui_icon = "fighter-jet"
	cost = 3 // low cost because this stand is pretty much LOUD AS FUCK, and using it is stealthily is pretty hard due to it's loud, unique sounds and abilities
				// also because in order for this to be any good, you need to spread your points real good
	var/next_rush = 0

/datum/guardian_ability/major/frenzy/Apply()
	. = ..()
	guardian.add_movespeed_modifier("frenzy_guardian", update=TRUE, priority=100, multiplicative_slowdown=-1)

/datum/guardian_ability/major/frenzy/Remove()
	. = ..()
	guardian.remove_movespeed_modifier("frenzy_guardian")

/datum/guardian_ability/major/frenzy/CanBuy(care_about_points = TRUE)
	return ..() && master_stats.range >= 3

/datum/guardian_ability/major/frenzy/Manifest()
	if(guardian.summoner?.current)
		guardian.summoner.current.add_movespeed_modifier("frenzy", update=TRUE, priority=100, multiplicative_slowdown=-1.5)

/datum/guardian_ability/major/frenzy/Recall()
	if(guardian.summoner?.current)
		guardian.summoner.current.remove_movespeed_modifier("frenzy")

/datum/guardian_ability/major/frenzy/Attack(atom/target)
	return world.time < next_rush	//True if on cooldown

/datum/guardian_ability/major/frenzy/AfterAttack(atom/target)
	if(isliving(target) && world.time >= next_rush && guardian.is_deployed())
		var/mob/living/L = target
		if(target == guardian.summoner?.current)
			to_chat(guardian, "<span class='danger italics'>You can't attack your summoner!</span>")
			return
		playsound(guardian, 'sound/magic/blind.ogg', 60, FALSE)
		guardian.forceMove(get_step(get_turf(L), get_dir(guardian, L)))
		if(master_stats.potential > 3)
			L.throw_at(get_edge_target_turf(L, get_dir(guardian, L)), 2, 4, guardian, TRUE)
		next_rush = world.time + ((0.2 SECONDS * (5 - master_stats.potential)) + 2)	//2 to 3 seconds

/datum/guardian_ability/major/frenzy/Stat()
	. = ..()
	if(statpanel("Status"))
		if(next_rush > world.time)
			stat(null, "Frenzy Charge Cooldown Remaining: [DisplayTimeText(next_rush - world.time)]")
