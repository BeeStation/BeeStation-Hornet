/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	name = "Ashen passage"
	desc = "Low range spell allowing you to pass through a few walls."
	school = "transmutation"
	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	charge_max = 150
	range = -1
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"
	jaunt_in_time = 13
	jaunt_duration = 10
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long
	jaunt_duration = 50

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/play_sound()
	return

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 13

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"

/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "Touch spell that let's you channel the power of the old gods through you."
	hand_path = /obj/item/melee/touch_attack/mansus_fist
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. Mutes, causes knockdown, major stamina damage aswell as some Brute. You also can lay and remove transmutation runes using this. It gains additional beneficial effects with certain knowledges you can research."
	icon_state = "mansus_grasp"
	item_state = "mansus_grasp"
	catchphrase = "R'CH T'H TR'TH"
	///Where we cannot create the rune?
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava))

/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || target == user)
		return FALSE
	if(istype(target,/obj/effect/eldritch))
		remove_rune(target,user)
		return FALSE
	playsound(user, 'sound/items/welder.ogg', 75, TRUE)
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.check_shields(src,10, "the [tar.name]"))
			return ..()
		if(tar.anti_magic_check())
			tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
			return ..()
	var/datum/mind/M = user.mind
	var/datum/antagonist/heretic/cultie = M.has_antag_datum(/datum/antagonist/heretic)

	var/use_charge = FALSE
	if(iscarbon(target))
		use_charge = TRUE
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(10)
		C.silent = 3 SECONDS
		C.AdjustKnockdown(5 SECONDS)
		C.adjustStaminaLoss(80)
	var/list/knowledge = cultie.get_all_knowledge()

	for(var/X in knowledge)
		var/datum/eldritch_knowledge/EK = knowledge[X]
		if(EK.on_mansus_grasp(target, user, proximity_flag, click_parameters))
			use_charge = TRUE
	if(use_charge)
		return ..()

///Draws a rune on a selected turf
/obj/item/melee/touch_attack/mansus_fist/attack_self(mob/user)

	for(var/turf/T in range(1,user))
		if(is_type_in_typecache(T, blacklisted_turfs))
			to_chat(user, "<span class='warning'>The targeted terrain doesn't support runes!</span>")
			return
	var/A = get_turf(user)
	to_chat(user, "<span class='danger'>You start drawing a rune...</span>")

	if(do_after(user,30 SECONDS,FALSE,A))
		new /obj/effect/eldritch/big(A)

///Removes runes from the selected turf
/obj/item/melee/touch_attack/mansus_fist/proc/remove_rune(atom/target,mob/user)
	to_chat(user, "<span class='danger'>You start removing a rune...</span>")
	if(do_after(user,2 SECONDS,user))
		qdel(target)

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby turfs."
	school = "transmutation"
	charge_max = 300 //twice as long as mansus grasp
	clothes_req = FALSE
	invocation = "A'GRSV SPR'D"
	invocation_type = INVOCATION_WHISPER
	range = 3
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "corrode"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/cast(list/targets, mob/user = usr)
	playsound(user, 'sound/items/welder.ogg', 75, TRUE)
	for(var/turf/T in targets)
		///What we want is the 3 tiles around the user and the tile under him to be rusted, so min(dist,1)-1 causes us to get 0 for these tiles, rest of the tiles are based on chance
		var/chance = 100 - (max(get_dist(T,user),1)-1)*100/(range+1)
		if(!prob(chance))
			continue
		T.rust_heretic_act()

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small
	name = "Rust Conversion"
	desc = "Spreads rust onto nearby turfs."
	range = 2

/obj/effect/proc_holder/spell/targeted/touch/blood_siphon
	name = "Blood Siphon"
	desc = "Touch spell that heals you while damaging the enemy."
	hand_path = /obj/item/melee/touch_attack/blood_siphon
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/blood_siphon
	name = "Blood Siphon"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	catchphrase = "R'BRTH"

/obj/item/melee/touch_attack/blood_siphon/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message("<span class='danger'>Spell bounces off of [target]!</span>","<span class='danger'>The spell bounces off of you!</span>")
			return ..()
	var/mob/living/carbon/human/C2 = user
	if(isliving(target))
		var/mob/living/L = target
		L.adjustBruteLoss(20)
		C2.adjustBruteLoss(-20)

	if(ishuman(target))
		var/mob/living/carbon/human/C1 = target
		C1.bleed_rate -= 5
		C2.bleed_rate += 5
		C1.blood_volume -= 20
		if(C2.blood_volume < BLOOD_VOLUME_MAXIMUM) //we dont want to explode after all
			C2.blood_volume += 20
		return ..()

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave
	name = "Patron's Reach"
	desc = "Channels energy into your gauntlet - firing it results in a wave of rust being created in it's wake."
	proj_type = /obj/item/projectile/magic/spell/rust_wave
	charge_max = 350
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "rust_wave"
	action_background_icon_state = "bg_ecult"
	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER

/obj/item/projectile/magic/spell/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	ignored_factions = list("heretics")
	range = 15
	speed = 1

/obj/item/projectile/magic/spell/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(dir,90))
	turflist += T1
	turflist += get_step(T1,turn(dir,90))
	T1 = get_step(src,turn(dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(dir,-90))
	for(var/X in turflist)
		if(!X || prob(25))
			continue
		var/turf/T = X
		T.rust_heretic_act()

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short
	name = "Small Patron's Reach"
	proj_type = /obj/item/projectile/magic/spell/rust_wave/short

/obj/item/projectile/magic/spell/rust_wave/short
	range = 7
	speed = 2

/obj/effect/proc_holder/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and people around them"
	school = "transmutation"
	charge_max = 350
	clothes_req = FALSE
	invocation = "CL'VE"
	invocation_type = INVOCATION_WHISPER
	range = 9
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	base_icon_state = "cleave"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	for(var/mob/living/carbon/human/C in hearers(1,targets[1]))
		targets |= C


	for(var/X in targets)
		var/mob/living/carbon/human/target = X
		if(target == user)
			continue
		if(target.anti_magic_check())
			to_chat(user, "<span class='warning'>The spell had no effect!</span>")
			target.visible_message("<span class='danger'>[target]'s veins flash with fire, but their magic protection repulses the blaze!</span>", \
							"<span class='danger'>Your veins flash with fire, but your magic protection repels the blaze!</span>")
			continue

		target.visible_message("<span class='danger'>[target]'s veins are shredded from within as an unholy blaze erupts from their blood!</span>", \
							"<span class='danger'>Your veins burst from within and unholy flame erupts from your blood!</span>")
		target.bleed_rate += 10
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/cleave(target.drop_location())

/obj/effect/proc_holder/spell/pointed/cleave/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to cleave [target]!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cleave/long
	charge_max = 650

/obj/effect/proc_holder/spell/pointed/ash_final
	name = "Nightwatcher's Rite"
	desc = "Powerful spell that releases 5 streams of fire away from you."
	school = "transmutation"
	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER
	charge_max = 300
	range = 15
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/ash_final/cast(list/targets, mob/user)
	for(var/X in targets)
		var/T
		T = line_target(-25, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(10, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(0, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(-10, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(25, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
	return ..()

/obj/effect/proc_holder/spell/pointed/ash_final/proc/line_target(offset, range, atom/at , atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (getline(user, T) - get_turf(user))

/obj/effect/proc_holder/spell/pointed/ash_final/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message("<span class='danger'>Spell bounces off of [L]!</span>","<span class='danger'>The spell bounces off of you!</span>")
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, "<span class='userdanger'>You're hit by [source]'s fire breath!</span>")

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, "melee", 1)
		sleep(1.5)

/obj/effect/proc_holder/spell/targeted/shapeshift/eldritch
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	possible_shapes = list(/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/carp,\
		/mob/living/simple_animal/bot/secbot, \
		/mob/living/simple_animal/pet/fox,\
		/mob/living/simple_animal/pet/cat )

/obj/effect/proc_holder/spell/targeted/emplosion/eldritch
	name = "Energetic Pulse"
	invocation = "E'P"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 300
	emp_heavy = 6
	emp_light = 10

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade
	name = "Fire Cascade"
	desc = "creates hot turfs around you."
	school = "transmutation"
	charge_max = 300 //twice as long as mansus grasp
	clothes_req = FALSE
	invocation = "C'SC'DE"
	invocation_type = INVOCATION_WHISPER
	range = 4
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/cast(list/targets, mob/user = usr)
	INVOKE_ASYNC(src, .proc/fire_cascade, user,range)

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/proc/fire_cascade(atom/centre,max_range)
	playsound(get_turf(centre), 'sound/items/welder.ogg', 75, TRUE)
	var/_range = 1
	for(var/i = 0, i <= max_range,i++)
		for(var/turf/open/T in spiral_range_turfs(_range,centre))
			new /obj/effect/hotspot(T)
			T.hotspot_expose(700,50,1)
		_range++
		sleep(3)

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big
	range = 6

/obj/effect/proc_holder/spell/targeted/telepathy/eldritch
	invocation = ""
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/targeted/fire_sworn
	name = "Oath of Fire"
	desc = "For a minute you will passively create a ring of fire around you."
	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 700
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"
	///how long it lasts
	var/duration = 1 MINUTES
	///who casted it right now
	var/mob/current_user
	///Determines if you get the fire ring effect
	var/has_fire_ring = FALSE

/obj/effect/proc_holder/spell/targeted/fire_sworn/cast(list/targets, mob/user)
	. = ..()
	current_user = user
	has_fire_ring = TRUE
	addtimer(CALLBACK(src, .proc/remove, user), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/proc_holder/spell/targeted/fire_sworn/proc/remove()
	has_fire_ring = FALSE

/obj/effect/proc_holder/spell/targeted/fire_sworn/process()
	. = ..()
	if(!has_fire_ring)
		return
	for(var/turf/open/T in RANGE_TURFS(1,current_user))
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)


/obj/effect/proc_holder/spell/targeted/worm_contract
	name = "Force Contract"
	desc = "Forces all the worm parts to collapse onto a single turf"
	invocation_type = "none"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 300
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "worm_contract"

/obj/effect/proc_holder/spell/targeted/worm_contract/cast(list/targets, mob/user)
	. = ..()
	if(!istype(user,/mob/living/simple_animal/hostile/eldritch/armsy))
		to_chat(user, "<span class='userdanger'>You try to contract your muscles but nothing happens...</span>")
	var/mob/living/simple_animal/hostile/eldritch/armsy/armsy = user
	armsy.contract_next_chain_into_single_tile()

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 10

/obj/effect/proc_holder/spell/targeted/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "Drains nearby alive people that are engulfed in flames. It heals 10 of each damage type per person. If a person is in critical condition it finishes them off."
	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 600
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/targeted/fiery_rebirth/cast(list/targets, mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	for(var/mob/living/carbon/target in ohearers(7,user))
		if(target.stat == DEAD || !target.on_fire)
			continue
		//This is essentially a death mark, use this to finish your opponent quicker.
		if(target.InCritical())
			target.death()
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/eldritch_smoke(target.drop_location())
		human_user.ExtinguishMob()
		human_user.adjustBruteLoss(-10, FALSE)
		human_user.adjustFireLoss(-10, FALSE)
		human_user.adjustStaminaLoss(-10, FALSE)
		human_user.adjustToxLoss(-10, FALSE)
		human_user.adjustOxyLoss(-10)

/obj/effect/proc_holder/spell/targeted/shed_human_form
	name = "Shed form"
	desc = "Shed your fragile form, become one with the arms, become one with the emperor."
	invocation_type = INVOCATION_SHOUT
	invocation = "REALITY UNCOIL!"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 100
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "worm_ascend"
	var/segment_length = 10

/obj/effect/proc_holder/spell/targeted/shed_human_form/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/target = user
	var/mob/living/mob_inside = locate() in target.contents - target

	if(!mob_inside)
		var/mob/living/simple_animal/hostile/eldritch/armsy/prime/outside = new(user.loc,TRUE,segment_length)
		target.mind.transfer_to(outside, TRUE)
		target.forceMove(outside)
		target.apply_status_effect(STATUS_EFFECT_STASIS,STASIS_ASCENSION_EFFECT)
		for(var/mob/living/carbon/human/humie in (viewers(9,outside)-target))
			if(IS_HERETIC(humie) || IS_HERETIC_MONSTER(humie))
				continue
			SEND_SIGNAL(humie, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
			///They see the very reality uncoil before their eyes.
			if(prob(25))
				var/trauma = pick(subtypesof(BRAIN_TRAUMA_MILD) + subtypesof(BRAIN_TRAUMA_SEVERE))
				humie.gain_trauma(new trauma(), TRAUMA_RESILIENCE_LOBOTOMY)
		return

	if(iscarbon(mob_inside))
		var/mob/living/simple_animal/hostile/eldritch/armsy/prime/armsy = target
		if(mob_inside.remove_status_effect(STATUS_EFFECT_STASIS,STASIS_ASCENSION_EFFECT))
			mob_inside.forceMove(armsy.loc)
		armsy.mind.transfer_to(mob_inside, TRUE)
		segment_length = armsy.get_length()
		qdel(armsy)
		return

/obj/effect/temp_visual/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	duration = 1 MINUTES
	layer = LOW_SIGIL_LAYER

/obj/effect/temp_visual/glowing_rune/Initialize()
	. = ..()
	pixel_y = rand(-6,6)
	pixel_x = rand(-6,6)
	icon_state = "small_rune_[rand(12)]"
	update_icon()

/obj/effect/proc_holder/spell/pointed/manse_link
	name = "Mansus Link"
	desc = "Piercing through reality, connecting minds. This spell allows you to add people to a mansus net, allowing them to communicate with eachother"
	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "PI'RC' TH' M'ND"
	invocation_type = "whisper"
	range = 10
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/manse_link/can_target(atom/target, mob/user, silent)
	if(!isliving(target))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/manse_link/cast(list/targets, mob/user)
	var/mob/living/simple_animal/hostile/eldritch/raw_prophet/originator = user

	var/mob/living/target = targets[1]

	to_chat(originator, "<span class='notice'>You begin linking [target]'s mind to yours...</span>")
	to_chat(target, "<span class='warning'>You feel your mind being pulled... connected... intertwined with the very fabric of reality...</span>")
	if(!do_after(originator, 6 SECONDS, target))
		return
	if(!originator.link_mob(target))
		to_chat(originator, "<span class='warning'>You can't seem to link [target]'s mind...</span>")
		to_chat(target, "<span class='warning'>The foreign presence leaves your mind.</span>")
		return
	to_chat(originator, "<span class='notice'>You connect [target]'s mind to your mansus link!</span>")


/datum/action/innate/mansus_speech
	name = "Mansus Link"
	desc = "Send a psychic message to everyone connected to your mansus link."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_ecult"
	var/mob/living/simple_animal/hostile/eldritch/raw_prophet/originator

/datum/action/innate/mansus_speech/New(_originator)
	. = ..()
	originator = _originator

/datum/action/innate/mansus_speech/Activate()
	var/mob/living/living_owner = owner
	if(!originator?.linked_mobs[living_owner])
		CRASH("Uh oh the mansus link got somehow activated without it being linked to a raw prophet or the mob not being in a list of mobs that should be able to do it.")

	var/message = sanitize(input("Message:", "Telepathy from the Manse") as text|null)

	if(QDELETED(living_owner))
		return

	if(!originator?.linked_mobs[living_owner])
		to_chat(living_owner, "<span class='warning'>The link seems to have been severed...</span>")
		Remove(living_owner)
		return
	if(message)
		var/msg = "<i><font color=#568b00>\[Mansus Link\] <b>[living_owner]:</b> [message]</font></i>"
		log_directed_talk(living_owner, originator, msg, LOG_SAY, "Mansus Link")
		to_chat(originator.linked_mobs, msg)

		for(var/dead_mob in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(dead_mob, living_owner)
			to_chat(dead_mob, "[link] [msg]")

/obj/effect/proc_holder/spell/pointed/trigger/blind/eldritch
	range = 10
	invocation = "E'E'S"
	action_background_icon_state = "bg_ecult"
