/mob/living/simple_animal/hostile/cat_butcherer
	name = "Cat Surgeon"
	desc = "A man with the quest of chasing endless feline tail."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "cat_butcher"
	icon_living = "cat_butcher"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	projectiletype = /obj/projectile/bullet/dart/tranq
	projectilesound = 'sound/items/syringeproj.ogg'
	retreat_distance = 3
	ranged = TRUE
	ranged_message = "fires the syringe gun at"
	ranged_cooldown_time = 30
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 100
	health = 100
	melee_damage = 15
	attack_verb_continuous = "slashes at"
	attack_verb_simple = "slash at"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	combat_mode = TRUE
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	loot = list(/obj/effect/mob_spawn/human/corpse/cat_butcher, /obj/item/circular_saw, /obj/item/gun/syringe)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(FACTION_HOSTILE)
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	hardattacks = TRUE
	dodging = TRUE
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	lose_patience_timeout = 200
	rapid_melee = 2
	var/list/victims = list()

//heal himself when not in combat
/mob/living/simple_animal/hostile/cat_butcherer/Life()
	. = ..()
	if(prob(10) && health <= maxHealth && !target)
		adjustHealth(-(20+ 2*LAZYLEN(victims)))
		visible_message("[src] medicates themself.", span_notice("You medicate yourself."))

//attacking/catifying code
/mob/living/simple_animal/hostile/cat_butcherer/AttackingTarget()
	if(ishuman(target))
		var/mob/living/carbon/human/L = target
		if(!L.get_organ_by_type(/obj/item/organ/ears/cat) && L.stat) //target doesnt have cat ears
			visible_message("[src] slices off [L]'s ears, and replaces them with cat ears!", span_notice("You replace [L]'s ears with cat ears'."))
			var/obj/item/organ/ears/cat/newears = new
			newears.Insert(L)
		else if(!L.get_organ_by_type(/obj/item/organ/tail/cat) && L.stat)
			visible_message("[src] attaches a cat tail to [L]!", span_notice("You attach a tail to [L]."))
			var/obj/item/organ/tail/cat/newtail = new
			newtail.Insert(L)
			return
		else if(!L.has_trauma_type(/datum/brain_trauma/severe/pacifism) && L.get_organ_by_type(/obj/item/organ/ears/cat) && L.get_organ_by_type(/obj/item/organ/tail/cat) && L.stat) //still does damage.
			visible_message("[src] drills a hole in [L]'s skull!", span_notice("You pacify [L]. Another successful creation."))
			if(L.stat)
				L.emote("scream")
			if(victims.Find(L) || !L.mind)//this is mostly to avoid neurine-filled catgirls from giving him many free instant heals
				L.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_SURGERY)
			else
				L.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_BASIC)
			newvictim(L)
		else if(L.stat) //quickly heal them up and move on to our next target!
			healvictim(L)
			return
	return ..()

/mob/living/simple_animal/hostile/cat_butcherer/proc/healvictim(var/mob/living/carbon/human/L)
	visible_message("[src] injects [L] with an unknown medicine!", span_notice("You inject [L] with medicine."))
	L.SetSleeping(0, FALSE)
	L.SetUnconscious(0, FALSE)
	L.adjustOxyLoss(-50)// do CPR first
	L.reagents.remove_reagent(/datum/reagent/toxin/chloralhydrate, 100)
	if(L.blood_volume <= 500) //bandage them up and give em some blood if they're bleeding
		L.blood_volume += 30
		L.suppress_bloodloss(BLEED_DEEP_WOUND)
	if(L.getBruteLoss() >= 50)
		var/healing = min(L.getBruteLoss(), 120)
		L.adjustBruteLoss(-healing)
		L.suppress_bloodloss(BLEED_DEEP_WOUND)//bandage their ass
	FindTarget()

/mob/living/simple_animal/hostile/cat_butcherer/proc/newvictim(var/mob/living/carbon/human/L)
	if(victims.Find(L))
		adjustHealth(-(maxHealth))
		return FALSE
	if(L.mind)
		victims += L
		say(pick("I'm a genius!!", "KITTY!!", "Another successful experiment!!", "Substandard product.", "You had better not run off, now!", "You never cease to amaze me, me."))
		if(LAZYLEN(victims) <= 10)
			maxHealth = (100 + (20 * LAZYLEN(victims)))
		else
			maxHealth = (300 + (5 * (LAZYLEN(victims)-10)))
		switch(LAZYLEN(victims))
			if(2)
				projectiletype = /obj/projectile/bullet/dart/tranq/plus
			if(4)//gain space adaptation to make cheesing harder
				atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
				icon_state = "cat_butcher_fire"
				icon_living = "cat_butcher_fire"
			if(6) //at this point, it's probably out in the hall attacking several people at once
				ranged_cooldown_time = 20
				rapid_melee = 3
				transform *= 1.25
			if(8)
				projectiletype = /obj/projectile/bullet/dart/tranq/plusplus
			if(10)
				ranged_cooldown_time = 10
			if(15)//if he's gotten this powerful, someone has really fucked up
				ranged_cooldown_time = 5
				rapid_melee = 4
				transform *= 1.25
				icon_state = "cat_butcher_super"
				icon_living = "cat_butcher_super"
	adjustHealth(-(maxHealth))

//cat butcher ai shit
/mob/living/simple_animal/hostile/cat_butcherer/CanAttack(atom/the_target)
	if(iscarbon(target))
		var/mob/living/carbon/human/C = target
		if(C.get_organ_by_type(/obj/item/organ/ears/cat) && C.get_organ_by_type(/obj/item/organ/tail/cat) && C.has_trauma_type(/datum/brain_trauma/severe/pacifism))//he wont attack his creations
			if(C.stat && (!HAS_TRAIT(C, TRAIT_NOMETABOLISM) || !isipc(C))) //unless they need healing
				return ..()
			return FALSE
	return ..()

/mob/living/simple_animal/hostile/cat_butcherer/MoveToTarget(list/possible_targets)
	if(target)
		if(ishuman(target))
			var/mob/living/carbon/human/L = target
			if(L.health <=30 || L.stat || !L.can_inject(null, FALSE)) // base health to move in to attack is 30, not 40, as it accounts for armor somewhat
				retreat_distance = 0
			else
				retreat_distance = 3 //spam chems if they aren't low and can be injected
		else
			retreat_distance = 0//dont shoot chems at mobs that dont give a fuck
	return ..()

/mob/living/simple_animal/hostile/cat_butcherer/PickTarget(list/Targets)
	if(target)
		for(var/pos_targ in Targets)
			Targets[pos_targ] = 1
			var/atom/A = pos_targ
			var/atom/target_from = GET_TARGETS_FROM(src)
			var/target_dist = get_dist(target_from, target)
			var/possible_target_distance = get_dist(target_from, A)
			if(target_dist < max(possible_target_distance, 3))
				Targets -= A
	for(var/pos_targ in Targets)
		Targets[pos_targ] = 1
		if(ishuman(pos_targ))
			var/mob/living/carbon/human/H = pos_targ
			if(!CanAttack(H))
				Targets -= H
				continue
			if(H.stat == DEAD)
				Targets -= H
				continue
			if(H.stat)
				Targets[H] = 20
				continue
			else
				var/healthdiff = 10-round(H.health/10)
				Targets[H] = clamp(healthdiff,1,12)
	if(!Targets.len)//sanity check
		return
	return pick_weight(Targets)//Pick the remaining targets (if any) at random

/mob/living/simple_animal/hostile/cat_butcherer/death(gibbed)
	if(LAZYLEN(victims) >= 5)
		say("I made [LAZYLEN(victims)] creations! I have no regrets!!")
	return ..()
