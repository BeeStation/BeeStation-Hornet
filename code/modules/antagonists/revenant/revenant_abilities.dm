
/mob/living/simple_animal/revenant/ClickOn(atom/A, params) //revenants can't interact with the world directly.
	if(check_click_intercept(params,A))
		return

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
		AltClickNoInteract(src, A)
		return

	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return

	if(ishuman(A))
		if(A in drained_mobs)
			to_chat(src, span_revenwarning("[A]'s soul is dead and empty.") )
		else if(in_range(src, A))
			Harvest(A)

	if(isturf(A))
		var/turf/T = A
		if(T == get_turf(src))
			T.show_zmove_radial(src)


// double-click or ctrl-click for two abilities
/mob/living/simple_animal/revenant/CtrlClickOn(atom/A)
	if(incorporeal_move == INCORPOREAL_MOVE_JAUNT)
		check_orbitable(A)
		return
	..() // pull the thing

/mob/living/simple_animal/revenant/DblClickOn(atom/A, params)
	if(get_dist(src, A) < 5) // message spam when you spam phase shift is annoying
		check_orbitable(A)
	..()

// Orbit: literally obrits people like how ghosts do
/mob/living/simple_animal/revenant/check_orbitable(atom/A)
	if(revealed)
		to_chat(src, span_revenwarning("You can't orbit while you're revealed!"))
		return
	if(!Adjacent(A))
		to_chat(src, span_revenwarning("You can only orbit things that are next to you!"))
		return
	if(isobserver(A) || isrevenant(A))
		to_chat(src, span_revenwarning("You can't orbit a ghost!"))
		return
	if(notransform || inhibited || !incorporeal_move_check(A))
		return
	..()

/mob/living/simple_animal/revenant/orbit(atom/target)
	setDir(SOUTH) // reset dir so the right directional sprites show up
	REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, "ghost")
	return ..()


//Harvest; activated by clicking the target, will try to drain their essence.
/mob/living/simple_animal/revenant/proc/Harvest(mob/living/carbon/human/target)
	if(!castcheck(0))
		return
	if(draining)
		to_chat(src, span_revenwarning("You are already siphoning the essence of a soul!"))
		return
	if(orbiting)
		to_chat(src, span_revenwarning("You can't siphon essence during orbiting!"))
		return
	if(!target.stat && !HAS_TRAIT_FROM(target, TRAIT_INCAPACITATED, STAMINA))
		to_chat(src, span_revennotice("[target.p_Their()] soul is too strong to harvest."))
		if(prob(10))
			to_chat(target, "You feel as if you are being watched.")
		return
	draining = TRUE
	essence_drained += rand(15, 20)
	to_chat(src, span_revennotice("You search for the soul of [target]."))
	if(do_after(src, rand(10, 20), target, timed_action_flags = IGNORE_HELD_ITEM)) //did they get deleted in that second?
		if(target.ckey)
			to_chat(src, span_revennotice("[target.p_Their()] soul burns with intelligence."))
			essence_drained += rand(20, 30)
		if(target.stat != DEAD)
			to_chat(src, span_revennotice("[target.p_Their()] soul blazes with life!"))
			essence_drained += rand(40, 50)
		else
			to_chat(src, span_revennotice("[target.p_Their()] soul is weak and faltering."))
		if(do_after(src, rand(15, 20), target, timed_action_flags = IGNORE_HELD_ITEM)) //did they get deleted NOW?
			switch(essence_drained)
				if(1 to 30)
					to_chat(src, span_revennotice("[target] will not yield much essence. Still, every bit counts."))
				if(30 to 70)
					to_chat(src, span_revennotice("[target] will yield an average amount of essence."))
				if(70 to 90)
					to_chat(src, span_revenboldnotice("Such a feast! [target] will yield much essence to you."))
				if(90 to INFINITY)
					to_chat(src, span_revenbignotice("Ah, the perfect soul. [target] will yield massive amounts of essence to you."))
			if(do_after(src, rand(15, 25), target, timed_action_flags = IGNORE_HELD_ITEM)) //how about now
				if(!target.stat && !HAS_TRAIT_FROM(target, TRAIT_INCAPACITATED, STAMINA))
					to_chat(src, span_revenwarning("[target.p_Theyre()] now powerful enough to fight off your draining."))
					to_chat(target, span_boldannounce("You feel something tugging across your body before subsiding."))
					draining = 0
					essence_drained = 0
					return //hey, wait a minute...
				to_chat(src, span_revenminor("You begin siphoning essence from [target]'s soul."))
				if(target.stat != DEAD)
					to_chat(target, span_warning("You feel a horribly unpleasant draining sensation as your grip on life weakens..."))
				if(target.stat == SOFT_CRIT)
					target.Stun(46)
				reveal(46)
				stun(46)
				target.visible_message(span_warning("[target] suddenly rises slightly into the air, [target.p_their()] skin turning an ashy gray."))
				if(target.can_block_magic(MAGIC_RESISTANCE_HOLY))
					to_chat(src, span_revenminor("Something's wrong! [target] seems to be resisting the siphoning, leaving you vulnerable!"))
					target.visible_message(span_warning("[target] slumps onto the ground."), \
											   span_revenwarning("Violet lights, dancing in your vision, receding--"))
					draining = FALSE
					return
				var/datum/beam/B = Beam(target,icon_state="drain_life")
				if(do_after(src, 46, target, timed_action_flags = IGNORE_HELD_ITEM)) //As one cannot prove the existance of ghosts, ghosts cannot prove the existance of the target they were draining.
					change_essence_amount(essence_drained, FALSE, target)
					if(essence_drained <= 90 && target.stat != DEAD)
						essence_regen_cap += 5
						to_chat(src, span_revenboldnotice("The absorption of [target]'s living soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap]."))
					if(essence_drained > 90)
						essence_regen_cap += 15
						perfectsouls++
						to_chat(src, span_revenboldnotice("The perfection of [target]'s soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap]."))
					to_chat(src, span_revennotice("[target]'s soul has been considerably weakened and will yield no more essence for the time being."))
					target.visible_message(span_warning("[target] slumps onto the ground."), \
										   span_revenwarning("Violets lights, dancing in your vision, getting clo--"))
					drained_mobs.Add(target)
					if(target.stat != DEAD)
						target.investigate_log("has died from revenant harvest.", INVESTIGATE_DEATHS)
					target.death(FALSE)
				else
					to_chat(src, span_revenwarning("[target ? "[target] has":"[target.p_Theyve()]"] been drawn out of your grasp. The link has been broken."))
					if(target) //Wait, target is WHERE NOW?
						target.visible_message(span_warning("[target] slumps onto the ground."), \
											   span_revenwarning("Violets lights, dancing in your vision, receding--"))
				qdel(B)
			else
				to_chat(src, span_revenwarning("You are not close enough to siphon [target ? "[target]'s":"[target.p_their()]"] soul. The link has been broken."))
	draining = FALSE
	essence_drained = 0

// -------------------------------------------
// ------------- action skills ---------------
// -------------------------------------------

//Toggle night vision: lets the revenant toggle its night vision
/datum/action/spell/night_vision/revenant
	name = "Toggle Darkvision"
	background_icon_state = "bg_revenant"
	button_icon = 'icons/hud/actions/actions_revenant.dmi'
	button_icon_state = "r_nightvision"
	toggle_span = "revennotice"

//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
/datum/action/spell/telepathy/revenant
	name = "Revenant Transmit"
	background_icon_state = "bg_revenant"

	telepathy_span = "revennotice"
	bold_telepathy_span = "revenboldnotice"

	use_runechat_telepathy = TRUE

/datum/action/spell/aoe/revenant
	background_icon_state = "bg_revenant"
	button_icon = 'icons/hud/actions/actions_revenant.dmi'
	button_icon_state = "r_default"
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	spell_requirements = NONE

	/// If it's locked, and needs to be unlocked before use
	var/locked = TRUE
	/// How much essence it costs to unlock
	var/unlock_amount = 100
	/// How much essence it costs to use
	var/cast_amount = 50

	/// How long it reveals the revenant
	var/reveal_duration = 8 SECONDS
	// How long it stuns the revenant
	var/stun_duration = 2 SECONDS

/datum/action/spell/aoe/revenant/New(master)
	. = ..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]SE)"
	else
		name = "[initial(name)] ([cast_amount]E)"

/datum/action/spell/aoe/revenant/Grant(mob/grant_to)
	if (!istype(grant_to, /mob/living/simple_animal/revenant))
		CRASH("Attempted to grant a revenant spell to a non-revenant mob which si not allowed.")
	. = ..()

/datum/action/spell/aoe/revenant/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(owner, /mob/living/simple_animal/revenant))
		stack_trace("[type] was owned by a non-revenant mob, please don't.")
		return FALSE

	var/mob/living/simple_animal/revenant/ghost = owner
	if(ghost.inhibited)
		return FALSE
	if(locked && ghost.essence_excess <= unlock_amount)
		return FALSE
	if(ghost.essence <= cast_amount)
		return FALSE

	return TRUE

/datum/action/spell/aoe/revenant/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/turf/nearby_turf in range(aoe_radius, center))
		things += nearby_turf

	return things

/datum/action/spell/aoe/revenant/pre_cast(mob/living/simple_animal/revenant/cast_on, atom/target)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return FALSE

	if(locked)
		if(!cast_on.unlock(unlock_amount))
			to_chat(cast_on, span_revenwarning("You don't have enough essence to unlock [initial(name)]!"))
			reset_spell_cooldown()
			return . | SPELL_CANCEL_CAST

		name = "[initial(name)] ([cast_amount]E)"
		to_chat(cast_on, span_revennotice("You have unlocked [initial(name)]!"))
		locked = FALSE
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	if(!cast_on.castcheck(-cast_amount))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/spell/aoe/revenant/post_cast(mob/living/simple_animal/revenant/user, atom/target)
	. = ..()
	if(reveal_duration > 0 SECONDS)
		user.reveal(reveal_duration)
	if(stun_duration > 0 SECONDS)
		user.stun(stun_duration)

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/datum/action/spell/aoe/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	button_icon_state = "overload_lights"
	cooldown_time = 20 SECONDS

	aoe_radius = 5
	unlock_amount = 25
	cast_amount = 40
	stun_duration = 3 SECONDS

	/// The range the shocks from the lights go
	var/shock_range = 2
	/// The damage the shcoskf rom the lgihts do
	var/shock_damage = 15

/datum/action/spell/aoe/revenant/overload/cast_on_thing_in_aoe(turf/victim, mob/living/simple_animal/revenant/caster)
	for(var/obj/machinery/light/light in victim)
		if(!light.on)
			continue

		light.visible_message(("<span class='boldwarning'>[light] suddenly flares brightly and begins to spark!</span>"))
		var/datum/effect_system/spark_spread/light_sparks = new /datum/effect_system/spark_spread()
		light_sparks.set_up(4, 0, light)
		light_sparks.start()
		new /obj/effect/temp_visual/revenant(get_turf(light))
		addtimer(CALLBACK(src, PROC_REF(overload_shock), light, caster), 20)

/datum/action/spell/aoe/revenant/overload/proc/overload_shock(obj/machinery/light/to_shock, mob/living/simple_animal/revenant/caster)
	flick("[to_shock.base_state]2", to_shock)
	for(var/mob/living/carbon/human/human_mob in view(shock_range, to_shock))
		if(human_mob == caster)
			continue
		to_shock.Beam(human_mob, icon_state = "purple_lightning", time = 0.5 SECONDS)
		if(!human_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
			human_mob.electrocute_act(shock_damage, to_shock, flags = SHOCK_NOGLOVES)

		do_sparks(4, FALSE, human_mob)
		playsound(human_mob, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/datum/action/spell/aoe/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors."
	button_icon_state = "defile"
	cooldown_time = 15 SECONDS

	aoe_radius = 4
	unlock_amount = 10
	cast_amount = 30
	reveal_duration = 4 SECONDS
	stun_duration = 2 SECONDS

/datum/action/spell/aoe/revenant/defile/cast_on_thing_in_aoe(turf/victim, mob/living/simple_animal/revenant/caster)
	for(var/obj/effect/blessing/blessing in victim)
		qdel(blessing)
		new /obj/effect/temp_visual/revenant(victim)

	if(!isplatingturf(victim) && !istype(victim, /turf/open/floor/engine/cult) && isfloorturf(victim) && prob(15))
		var/turf/open/floor/floor = victim
		if(floor.overfloor_placed && floor.floor_tile)
			new floor.floor_tile(floor)
		floor.broken = 0
		floor.burnt = 0
		floor.make_plating(TRUE)

	if(victim.type == /turf/closed/wall && prob(15) && !HAS_TRAIT(victim, TRAIT_RUSTY))
		new /obj/effect/temp_visual/revenant(victim)
		victim.AddElement(/datum/element/rust)
	if(victim.type == /turf/closed/wall/r_wall && prob(10) && !HAS_TRAIT(victim, TRAIT_RUSTY))
		new /obj/effect/temp_visual/revenant(victim)
		victim.AddElement(/datum/element/rust)
	for(var/obj/effect/decal/cleanable/food/salt/salt in victim)
		new /obj/effect/temp_visual/revenant(victim)
		qdel(salt)
	for(var/obj/structure/closet/closet in victim.contents)
		closet.open()
	for(var/obj/structure/bodycontainer/corpseholder in victim)
		if(corpseholder.connected.loc == corpseholder)
			corpseholder.open()
	for(var/obj/machinery/dna_scannernew/dna in victim)
		dna.open_machine()
	for(var/obj/structure/window/window in victim)
		window.take_damage(rand(30, 80))
		if(window?.fulltile)
			new /obj/effect/temp_visual/revenant/cracks(window.loc)
	for(var/obj/machinery/light/light in victim)
		light.flicker(20) //spooky

//Malfunction: Makes bad stuff happen to robots and machines.
/datum/action/spell/aoe/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	button_icon_state = "malfunction"
	cooldown_time = 20 SECONDS

	aoe_radius = 4
	cast_amount = 60
	unlock_amount = 125

// A note to future coders: do not replace this with an EMP because it will wreck malf AIs and everyone will hate you.
/datum/action/spell/aoe/revenant/malfunction/cast_on_thing_in_aoe(turf/victim, mob/living/simple_animal/revenant/caster)
	for(var/mob/living/simple_animal/bot/bot in victim)
		if(!bot.emagged)
			new /obj/effect/temp_visual/revenant(bot.loc)
			bot.locked = FALSE
			bot.open = TRUE
			bot.use_emag(caster)

	for(var/mob/living/carbon/human/human in victim)
		if(human == caster)
			continue
		if(human.can_block_magic(MAGIC_RESISTANCE_HOLY))
			continue
		to_chat(human, span_revenwarning("You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")]."))
		new /obj/effect/temp_visual/revenant(human.loc)
		human.emp_act(EMP_HEAVY)

	for(var/obj/thing in victim)
		if(prob(20))
			new /obj/effect/temp_visual/revenant(thing.loc)
			thing.use_emag(caster)
		else
			thing.emp_act(EMP_HEAVY)

	// Only works on cyborgs, not AI!
	for(var/mob/living/silicon/robot/cyborg in victim)
		new /obj/effect/temp_visual/revenant(cyborg.loc)
		cyborg.spark_system.start()
		cyborg.emp_act(EMP_HEAVY)

//Blight: Infects nearby humans and in general messes living stuff up.
/datum/action/spell/aoe/revenant/blight
	name = "Blight"
	desc = "Causes nearby living things to waste away."
	button_icon_state = "blight"
	cooldown_time = 20 SECONDS

	aoe_radius = 3
	cast_amount = 50
	unlock_amount = 75

/datum/action/spell/aoe/revenant/blight/cast_on_thing_in_aoe(turf/victim, mob/living/simple_animal/revenant/caster)
	for(var/mob/living/mob in victim)
		if(mob == caster)
			continue
		if(mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
			to_chat(caster, ("<span class='warning'>The spell had no effect on [mob]!</span>"))
			continue
		new /obj/effect/temp_visual/revenant(mob.loc)
		if(iscarbon(mob))
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				//H.set_haircolor("#1d2953", override = TRUE) //will be reset when blight is cured
				var/blightfound = FALSE
				for(var/datum/disease/revblight/blight in H.diseases)
					blightfound = TRUE
					if(blight.stage < 5)
						blight.stage++
				if(!blightfound)
					H.ForceContractDisease(new /datum/disease/revblight(), FALSE, TRUE)
					to_chat(H, span_revenminor("You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <i>wrong</i>")]."))
			else
				if(mob.reagents)
					mob.reagents.add_reagent(/datum/reagent/toxin/plasma, 5)
		else
			mob.adjustToxLoss(5)
	for(var/obj/structure/spacevine/vine in victim) //Fucking with botanists, the ability.
		vine.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(vine.loc)
		QDEL_IN(vine, 10)
	for(var/obj/structure/glowshroom/shroom in victim)
		shroom.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(shroom.loc)
		QDEL_IN(shroom, 10)
	for(var/obj/machinery/hydroponics/tray in victim)
		new /obj/effect/temp_visual/revenant(tray.loc)
		tray.pestlevel = (rand(8, 10))
		tray.weedlevel = (rand(8, 10))

/datum/action/spell/teleport/area_teleport/revenant
	name = "Revenant Teleport"
	desc = "Brings you to a location of your choosing on the station"
	background_icon_state = "bg_revenant"
	button_icon = 'icons/hud/actions/actions_revenant.dmi'
	button_icon_state = "r_teleport"
	post_teleport_sound = 'sound/magic/voidblink.ogg'
	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/spell/teleport/area_teleport/revenant/on_cast(mob/user, atom/target)
	if((isrevenant(user)))
		var/mob/living/simple_animal/revenant/revenant = user

		//If the revenant is currently recovering from casting an ability which stuns and forcibly reveals them
		if(revenant.unreveal_time)
			to_chat(user, span_warning("You can't pass through the incorporeal plane right now! You need to recover!"))
			return
	..()

/datum/action/revenant_phase_shift
	name = "Phase Shift"
	desc = "Shift in and out of your corporeal form"
	background_icon_state = "bg_revenant"
	button_icon = 'icons/hud/actions/actions_revenant.dmi'
	button_icon_state = "r_phase"

/datum/action/revenant_phase_shift/on_activate(mob/user)
	if(!isrevenant(user))
		return FALSE
	var/mob/living/simple_animal/revenant/revenant = user
	if(!revenant.castcheck(0))
		return FALSE
	// if they're trapped in consecrated tiles, they can get out with this. but they can't hide back on these tiles.
	if(revenant.incorporeal_move != INCORPOREAL_MOVE_JAUNT)
		var/turf/open/floor/stepTurf = get_turf(user)
		if(stepTurf)
			var/obj/effect/decal/cleanable/food/salt/salt = locate() in stepTurf
			if(salt)
				to_chat(user, span_warning("[salt] blocks your way to spirit realm!"))
				// the purpose is just letting not them hide onto salt tiles incorporeally. no need to stun.
				return
			if(stepTurf.flags_1 & NOJAUNT_1)
				to_chat(user, span_warning("Some strange aura blocks your way to spirit realm."))
				return
			if(stepTurf.is_holy())
				to_chat(user, span_warning("Holy energies block your way to spirit realm!"))
				return
	revenant.phase_shift()
	revenant.orbiting?.end_orbit(revenant)
