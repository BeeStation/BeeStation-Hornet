/datum/guardian_ability/major/frenzy
	name = "Frenzy"
	desc = "The guardian is capable of high-speed fighting, and speeding up it's owner while manifested, too. REQUIRES RANGE C OR ABOVE."
	ui_icon = "fighter-jet"
	cost = 3 // low cost because this stand is pretty much LOUD AS FUCK, and using it is stealthily is pretty hard due to it's loud, unique sounds and abilities
				// also because in order for this to be any good, you need to spread your points real good
	spell_type = /obj/effect/proc_holder/spell/targeted/guardian/frenzy
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

/datum/guardian_ability/major/frenzy/RangedAttack(atom/target)
	if(isliving(target) && world.time >= next_rush && guardian.is_deployed())
		var/mob/living/L = target
		if(guardian.summoner?.current && get_dist_euclidian(guardian.summoner.current, L) > master_stats.range)
			to_chat(guardian, "<span class='danger italics'>[L] is out of your range!</span>")
			return
		playsound(guardian, 'sound/effects/vector_rush.ogg', 100, FALSE)
		guardian.forceMove(get_step(get_turf(L), get_dir(L, guardian)))
		guardian.target = L
		guardian.AttackingTarget()
		L.throw_at(get_edge_target_turf(L, get_dir(guardian, L)), 20, 4, guardian, TRUE)
		next_rush = world.time + 3 SECONDS

/datum/guardian_ability/major/frenzy/Stat()
	. = ..()
	if(statpanel("Status"))
		if(next_rush > world.time)
			stat(null, "Frenzy Charge Cooldown Remaining: [DisplayTimeText(next_rush - world.time)]")

/obj/effect/proc_holder/spell/targeted/guardian/frenzy
	name = "Teleport Behind"
	desc = "<i>teleports behind you.<i> NANI?"

/obj/effect/proc_holder/spell/targeted/guardian/frenzy/InterceptClickOn(mob/living/caller, params, atom/movable/A)
	if(!isguardian(caller))
		revert_cast()
		return
	var/mob/living/simple_animal/hostile/guardian/G = caller
	if(!G.is_deployed())
		to_chat(G, "<span class='danger italics'>You are not manifested!</span>")
		revert_cast()
		return
	if(!isliving(A))
		to_chat(G, "<span class='danger italics'>[A] is not a living thing.</span>")
		revert_cast()
		return
	if(!G.stats)
		revert_cast()
		return
	if(get_dist_euclidian(G.summoner, A) > G.range)
		to_chat(G, "<span class='danger italics'>[A] is out of your range!</span>")
		revert_cast()
		return
	remove_ranged_ability()
	G.forceMove(get_step(get_turf(A), turn(A.dir, 180)))
	playsound(G, 'sound/effects/vector_appear.ogg', 100, FALSE)
	G.target = A
	G.AttackingTarget()
