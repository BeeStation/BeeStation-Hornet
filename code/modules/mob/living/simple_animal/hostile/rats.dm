#define PASSIVE_REGEN 1
#define WEDGE_HEAL 25
#define WHEEL_HEAL 100

/mob/living/simple_animal/hostile/rat
	name = "rat"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent with anger issues."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak_emote = list("squeaks","chitters")
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	melee_damage = 5
	obj_damage = 5
	turns_per_move = -1
	see_in_dark = 5
	maxHealth = 15
	health = 15
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	faction = list("rat")
	mobsay_color = "#82AF84"
	can_be_held = FALSE

/mob/living/simple_animal/hostile/rat/AttackingTarget()
	. = ..()
	if(health >= maxHealth)
		to_chat(src, "<span class='warning'>You feel fine, no need to eat anything!</span>")
		return
	if(istype(target, /obj/item/reagent_containers/food/snacks/cheesewedge))
		to_chat(src, "<span class='green'>You eat [src], restoring some health.</span>")
		heal_bodypart_damage(WEDGE_HEAL)
		qdel(target)
		return
	if(istype(target, /obj/item/reagent_containers/food/snacks/store/cheesewheel))
		to_chat(src, "<span class='green'>You eat [src], restoring a lot of health.</span>")
		heal_bodypart_damage(WHEEL_HEAL)
		qdel(target)
		return

/mob/living/simple_animal/hostile/rat/simp
	speak_chance = 1
	speak = list("Squeak!","SQUEAK!","Squeak?")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/mouse = 1)

/mob/living/simple_animal/hostile/rat/simp/death(gibbed)
	if(!ckey)
		..(TRUE)
		if(!gibbed)
			var/obj/item/reagent_containers/food/snacks/deadmouse/mouse = new(loc)
			mouse.icon_state = icon_dead
			mouse.name = name
	return ..()

/mob/living/simple_animal/hostile/rat/simp/examine(mob/user)
	. = ..()
	if(istype(user,/mob/living/simple_animal/hostile/rat))
		var/mob/living/simple_animal/hostile/rat/ratself = user
		if(ratself.faction_check_mob(src, TRUE))
			. += "<span class='notice'>You both serve the same king.</span>"
		else
			. += "<span class='warning'>This fool serves a different king!</span>"

		var/mob/living/simple_animal/hostile/rat/king/ratking = user
		if(ratking.faction_check_mob(src, TRUE))
			. += "<span class='notice'>This rat serves under you.</span>"
		else
			. += "<span class='warning'>This peasant serves a different king! Strike him down!</span>"

/mob/living/simple_animal/hostile/rat/simp/CanAttack(atom/the_target)
	if(istype(the_target,/mob/living/simple_animal))
		var/mob/living/A = the_target
		if(istype(the_target, /mob/living/simple_animal/hostile/rat/king) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/rat/king/ratking = the_target
			if(ratking.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
		if(istype(the_target, /mob/living/simple_animal/hostile/rat) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/rat/R = the_target
			if(R.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
	return ..()

/mob/living/simple_animal/hostile/rat/simp/handle_automated_action()
	. = ..()
	if(prob(40))
		var/turf/open/floor/F = get_turf(src)
		if(istype(F) && !F.intact)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.avail())
					visible_message("<span class='warning'>[src] chews through the [C]. It's toast!</span>")
					playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
					C.deconstruct()
					death()
			else if(C?.avail())
				visible_message("<span class='warning'>[src] chews through the [C]. It looks unharmed!</span>")
				playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
				C.deconstruct()


/mob/living/simple_animal/hostile/rat/king
	name = "rat king"
	desc = "An evolved rat, self proclaimed king of other rats. It leads nearby rats with deadly efficiency to protect its kingdom. Not technically a king, but don't tell him that."
	gender = NEUTER
	maxHealth = 70
	health = 70

	melee_damage = 15
	obj_damage = 10
	attacktext = "claws"
	attack_sound = 'sound/weapons/punch1.ogg'

	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"

	armour_penetration = 40

	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3,/obj/item/trash/candy = 1,/obj/item/reagent_containers/pill/floorpill = 1)
	unique_name = TRUE

	var/rummaging = FALSE
	var/obj/effect/proc_holder/spell/aoe_turf/riot
	var/obj/effect/proc_holder/spell/aoe_turf/domain

/mob/living/simple_animal/hostile/rat/king/Initialize()
	. = ..()
	riot = new /obj/effect/proc_holder/spell/aoe_turf/riot
	AddSpell(riot)
	domain = new /obj/effect/proc_holder/spell/aoe_turf/domain
	AddSpell(domain)
	
/mob/living/simple_animal/hostile/rat/king/named/Initialize()
	var/kingdom = pick("Plague","Miasma","Maintenance","Trash","Garbage","Rat","Vermin","Cheese")
	var/title = pick("King","Lord","Prince","Emperor","Supreme","Overlord","Master","Shogun","Bojar","Tsar")
	name = kingdom + " " + title

/mob/living/simple_animal/hostile/rat/king/handle_environment(datum/gas_mixture/environment)
	. = ..()
	if(stat == DEAD || !environment)
		return
	var/miasma_percentage = environment.total_moles() ? (environment.get_moles(/datum/gas/miasma) / environment.total_moles()) : 0
	if(miasma_percentage>=0.25)
		heal_bodypart_damage(PASSIVE_REGEN)

/mob/living/simple_animal/hostile/rat/king/handle_automated_action()
	if(prob(20))
		riot.Click()
	if(prob(10))
		domain.Click()
	return ..()

/mob/living/simple_animal/hostile/rat/king/CanAttack(atom/the_target)
	if(istype(the_target,/mob/living/simple_animal))
		var/mob/living/A = the_target
		if(istype(the_target, /mob/living/simple_animal/hostile/rat/king) && A.stat == CONSCIOUS)
			return TRUE
		if(istype(the_target, /mob/living/simple_animal/hostile/rat) && A.stat == CONSCIOUS)
			var/mob/living/simple_animal/hostile/rat/R = the_target
			if(R.faction_check_mob(src, TRUE))
				return FALSE
			else
				return TRUE
		return ..()

/mob/living/simple_animal/hostile/rat/king/examine(mob/user)
	. = ..()
	if(istype(user,/mob/living/simple_animal/hostile/rat/king))
		. += "<span class='warning'>Who is this foolish false king? This will not stand!</span>"
	else if(istype(user,/mob/living/simple_animal/hostile/rat))
		var/mob/living/simple_animal/hostile/rat/ratself = user
		if(ratself.faction_check_mob(src, TRUE))
			. += "<span class='notice'>This is your king. Long live his majesty!</span>"
		else
			. += "<span class='warning'>This is a false king! Strike him down!</span>"


/mob/living/simple_animal/hostile/rat/king/AttackingTarget()	
	if (rummaging)
		return
	if(istype(target, /obj/machinery/disposal))
		src.visible_message("<span class='warning'>[src] starts rummaging through the [target].</span>","<span class='notice'>You rummage through the [target]...</span>")
		rummaging = TRUE
		if (do_after(src,3 SECONDS, target))
			var/loot = rand(1,100)
			switch(loot)
				if(1 to 5)
					to_chat(src, "<span class='notice'>Ah! A form of currency!</span>")
					new /obj/item/reagent_containers/pill/floorpill(get_turf(src))
				if(6 to 33)
					src.say(pick("Treasure!","Our precious!","Cheese!"))
					to_chat(src, "<span class='notice'>Score! You find some cheese!</span>")
					new /obj/item/reagent_containers/food/snacks/cheesewedge(get_turf(src))
				else
					var/pickedtrash = pick(/obj/item/trash/candy,/obj/item/trash/raisins,/obj/item/trash/chips,/obj/item/trash/can,/obj/item/grown/bananapeel)
					to_chat(src, "<span class='notice'>You just find more garbage and dirt. Lovely, but beneath you now.</span>")
					new pickedtrash(get_turf(src))
		rummaging = FALSE
		return
	if (target.reagents && istype(target,/obj) && target.is_injectable(src,TRUE))
		src.visible_message("<span class='warning'>[src] starts licking the [target] passionately!</span>","<span class='notice'>You start licking the [target]...</span>")
		rummaging = TRUE
		if (do_after(src,2 SECONDS, target) && target)
			target.reagents.add_reagent(/datum/reagent/rat_spit,1,no_react = TRUE)
			to_chat(src, "<span class='notice'>You finish licking the [target].</span>")
		rummaging = FALSE
		return
	. = ..()
	

/**
 *This spell checks all nearby mice, and converts them into hostile rats. If no mice are nearby, creates a new one.
 */

/obj/effect/proc_holder/spell/aoe_turf/riot
	name = "Raise Army"
	desc = "Raise an army out of the hordes of mice and pests crawling around the maintenance shafts."
	charge_max = 12 SECONDS
	range = 5
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "screech"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = "none"
	sound = 'sound/effects/mousesqueek.ogg'


/obj/effect/proc_holder/spell/aoe_turf/riot/cast(list/targets, mob/user = usr)
	. = ..()
	var/something_from_nothing = FALSE
	for(var/mob/living/simple_animal/mouse/M in oview(user, range))
		var/mob/living/simple_animal/hostile/rat/new_rat = new(get_turf(M))
		something_from_nothing = TRUE
		if(M.mind && M.stat == CONSCIOUS)
			M.mind.transfer_to(new_rat)
		if(istype(user,/mob/living/simple_animal/hostile/rat/king))
			var/mob/living/simple_animal/hostile/rat/king/giantrat = user
			new_rat.faction = giantrat.faction
		qdel(M)
	if(!something_from_nothing)
		new /mob/living/simple_animal/mouse(user.loc)
		user.visible_message("<span class='warning'>[user] commands a mouse to its side!</span>")
	else
		user.visible_message("<span class='warning'>[user] commands its army to action, mutating them into rats!</span>")

/**
 *This spell spreads some miasma and makes some filth on the floor.
 */

/obj/effect/proc_holder/spell/aoe_turf/domain
	name = "Rat King's Domain"
	desc = "Corrupts this area to be more suitable for your rat army."
	charge_max = 6 SECONDS
	range = 5
	message = "<span class='notice'>You feel more at home...</span>"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "screech"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = "none"
	sound = 'sound/effects/splat.ogg'

/obj/effect/proc_holder/spell/aoe_turf/domain/cast(list/targets, mob/user = usr)
	. = ..()
	var/turf/open/T = get_turf(user)
	if(istype(T))
		T.atmos_spawn_air("miasma=1;TEMP=[T20C]")
		switch (rand(1,10))
			if (8)
				new /obj/effect/decal/cleanable/vomit(T)
			if (9)
				new /obj/effect/decal/cleanable/vomit/old(T)
			if (10)
				new /obj/effect/decal/cleanable/oil/slippery(T)
			else
				new /obj/effect/decal/cleanable/dirt(T)

/**
 *Spittle; harmless reagent that is added by rat king, and makes you disgusted.
 */
 
/datum/reagent/rat_spit
	name = "Rat Spit"
	description = "Something coming from a rat. Dear god! Who knows where it's been!"
	reagent_state = LIQUID
	color = "#C8C8C8"
	metabolization_rate = 0.03 * REAGENTS_METABOLISM
	taste_description = "feces"
	
/datum/reagent/rat_spit/on_mob_life(mob/living/carbon/M)
	if(prob(15))
		to_chat(M, "<span class='notice'>Your stomach rumbles!</span>")
		M.adjust_disgust(3)
	else if(prob(10))
		to_chat(M, "<span class='warning'>You almost vomit!</span>")
		M.adjust_disgust(5)
	else if(prob(5))
		M.vomit()
	..()

#undef PASSIVE_REGEN
#undef WEDGE_HEAL
#undef WHEEL_HEAL