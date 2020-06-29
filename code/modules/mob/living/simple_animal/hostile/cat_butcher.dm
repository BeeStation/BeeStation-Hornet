/mob/living/simple_animal/hostile/cat_butcherer
	name = "Cat Surgeon"
	desc = "A man with the quest of chasing endless feline tail."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "cat_butcher"
	icon_living = "cat_butcher"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	projectiletype = /obj/item/projectile/bullet/dart/tranq
	projectilesound = 'sound/items/syringeproj.ogg'
	ranged = 1
	ranged_message = "fires the syringe gun at"
	ranged_cooldown_time = 30
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 100
	health = 100
	melee_damage = 15
	attacktext = "slashes at"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	a_intent = INTENT_HARM
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	loot = list(/obj/effect/mob_spawn/human/corpse/cat_butcher, /obj/item/circular_saw, /obj/item/gun/syringe)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("hostile")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1
	var/impatience = 0
	rapid_melee = 2 //this lets him attack nearly as fast as a normal player, instead of half as fast as one. Without this, due to mood differences, a greytider in melee can actually facetank and beat him to death with only fists
	hardattacks = TRUE
	dodging = TRUE

/mob/living/simple_animal/hostile/cat_butcherer/Life()
	. = ..()
	if(prob(10) && health <= maxHealth && !target) //heal himself when not in combat
		var/healamount = min(maxHealth-health, 20)
		visible_message("[src] medicates themself.", "<span class='notice'>You medicate yourself.</span>")
		health += healamount

/mob/living/simple_animal/hostile/cat_butcherer/CanAttack(atom/the_target)
	if(iscarbon(target))
		var/mob/living/carbon/human/C = target
		if(C.getorgan(/obj/item/organ/ears/cat) && C.getorgan(/obj/item/organ/tail/cat) && C.has_trauma_type(/datum/brain_trauma/severe/pacifism))//he wont attack his creations
			if(C.stat && (!HAS_TRAIT(C, TRAIT_NOMETABOLISM) || !istype(C.dna.species, /datum/species/ipc)))//unless they need healing
				return ..()
			else
				return FALSE 
	return ..()

/mob/living/simple_animal/hostile/cat_butcherer/AttackingTarget()
	if(iscarbon(target))
		var/mob/living/carbon/human/L = target
		if(!L.getorgan(/obj/item/organ/ears/cat) && L.stat) //target doesnt have cat ears
			if(L.getorgan(/obj/item/organ/ears)) //slice off the old ears
				var/obj/item/organ/ears/ears = L.getorgan(/obj/item/organ/ears)
				visible_message("[src] slices off [L]'s ears!", "<span class='notice'>You slice [L]'s ears off.</span>")
				ears.Remove(L)
				ears.forceMove(get_turf(L))
			else //implant new ears
				visible_message("[src] attaches a pair of cat ears to [L]!", "<span class='notice'>You attach a pair of cat ears to [L].</span>")
				var/obj/item/organ/ears/cat/newears = new
				newears.Insert(L, drop_if_replaced = FALSE)
				return
		else if(!L.getorgan(/obj/item/organ/tail/cat) && L.stat)
			if(L.getorgan(/obj/item/organ/tail)) //cut off the tail if they have one already
				var/obj/item/organ/tail/tail = L.getorgan(/obj/item/organ/tail)
				visible_message("[src] severs [L]'s tail in one swift swipe!", "<span class='notice'>You sever [L]'s tail in one swift swipe.</span>")
				tail.Remove(L)
				tail.forceMove(get_turf(L))
			else //put a cat tail on
				visible_message("[src] attaches a cat tail to [L]!", "<span class='notice'>You attach a tail to [L].</span>")
				var/obj/item/organ/tail/cat/newtail = new
				newtail.Insert(L, drop_if_replaced = FALSE)
				return
		else if(!L.has_trauma_type(/datum/brain_trauma/severe/pacifism) && L.getorgan(/obj/item/organ/ears/cat) && L.getorgan(/obj/item/organ/tail/cat)) //still does damage. This also lacks a Stat check- felinids beware.
			visible_message("[src] drills a hole in [L]'s skull!", "<span class='notice'>You pacify [L]. Another successful creation.</span>")
			if(!L.stat)
				L.emote("scream")
			L.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_SURGERY)
			say("I'm a genius!!")
			if(L.mind && maxHealth <= 300) //if he robusts a tider, he becomes stronger
				maxHealth += 20
			adjustHealth(-(maxHealth)) //he heals whenever he finishes
		else if(L.stat) //quickly heal them up and move on to our next target! 
			visible_message("[src] injects [L] with an unknown medicine!", "<span class='notice'>You inject [L] with medicine.</span>")
			L.SetSleeping(0, FALSE)
			L.SetUnconscious(0, FALSE)
			L.adjustOxyLoss(-50)// do CPR first
			if(L.blood_volume <= 500) //bandage them up and give em some blood if they're bleeding
				L.blood_volume += 30
				L.suppress_bloodloss(1800)
			if(L.getBruteLoss() >= 50)// first, did we beat them into crit? if so, heal that
				var/healing = min(L.getBruteLoss(), 120)
				L.adjustBruteLoss(-healing)
				L.suppress_bloodloss(1800)//bandage their ass
				return
			else if(L.getFireLoss() >= 50) // are they still down from other damage? fix it, but not as fast as the burns
				var/healing = min(L.getFireLoss(), 50)
				L.adjustFireLoss(-healing)
			else //well, we probably got them with morphine then, let's fix that, in a fun way.
				var/obj/effect/sweatsplash/S = new(L.loc) //I've gotten too addicted to this little block of code...
				for(var/datum/reagent/R in L.reagents.reagent_list)
					var/amount = R.volume
					L.reagents.remove_reagent(R.type, amount)
					S.reagents.add_reagent(R.type, amount)
				S.splash()
				FindTarget() //we want someone else! we can't fix this one.
			impatience += 50
			if(prob(impatience))
				FindTarget()//so we don't focus on some unconscious dude when we could get our eyes on the prize
				impatience = 0
				say("Bah!!")
			return
	return ..()
