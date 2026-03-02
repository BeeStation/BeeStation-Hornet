//An ore-devouring but easily scared creature
/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	vision_range = 2
	aggro_vision_range = 9
	move_to_delay = 5
	friendly_verb_continuous = "harmlessly rolls into"
	friendly_verb_simple = "harmlessly roll into"
	maxHealth = 23
	health = 23
	melee_damage = 0
	attack_verb_continuous = "barrels into"
	attack_verb_simple = "barrel into"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = FALSE
	speak_emote = list("screeches")
	throw_message = "sinks in slowly, before being pushed out of "
	deathmessage = "spits up the contents of its stomach before dying!"
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
							/obj/item/stack/ore/uranium)

	var/chase_time = 100
	var/will_burrow = TRUE

/mob/living/simple_animal/hostile/asteroid/goldgrub/Initialize(mapload)
	. = ..()
	var/i = rand(1,3)
	while(i)
		loot += pick(/obj/item/stack/ore/silver, /obj/item/stack/ore/gold, /obj/item/stack/ore/uranium, /obj/item/stack/ore/diamond)
		i--

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(new_target)
	add_target(new_target)
	if(target != null)
		if(istype(target, /obj/item/stack/ore) && loot.len < 10)
			visible_message(span_notice("The [name] looks at [target.name] with hungry eyes."))
		else if(isliving(target))
			Aggro()
			visible_message(span_danger("The [name] tries to flee from [target.name]!"))
			retreat_distance = 10
			minimum_distance = 10
			if(will_burrow)
				addtimer(CALLBACK(src, PROC_REF(Burrow)), chase_time)

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/stack/ore))
		EatOre(target)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(atom/targeted_ore)
	for(var/obj/item/stack/ore/O in get_turf(targeted_ore))
		if(length(loot) < 10)
			var/using = min(10 - length(loot), O.amount)
			for(var/i in 1 to using)
				loot += O.type
			O.use(using)
	visible_message(span_notice("The ore was swallowed whole!"))

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!stat)
		visible_message(span_danger("The [name] buries into the ground, vanishing from sight!"))
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/projectile/P)
	visible_message(span_danger("The [P.name] was repelled by [name]'s girth!"))
	return BULLET_ACT_BLOCK

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	vision_range = 9
	. = ..()
