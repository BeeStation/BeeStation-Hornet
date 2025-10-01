/mob/living/simple_animal/bot/ed209
	name = "\improper ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "ed2090"
	density = TRUE
	anchored = FALSE
	health = 100
	maxHealth = 100
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_WALLS //Walls can't stop THE LAW
	mob_size = MOB_SIZE_LARGE

	radio_key = /obj/item/encryptionkey/headset_sec
	radio_channel = RADIO_CHANNEL_SECURITY
	bot_type = SEC_BOT
	model = "ED-209"
	bot_core_type = /obj/machinery/bot_core/secbot
	window_id = "autoed209"
	window_name = "Automatic Security Unit v2.6"
	allow_pai = 0
	data_hud_type = DATA_HUD_SECURITY_ADVANCED
	path_image_color = "#FF0000"
	carryable = FALSE

	var/lastfired = 0
	var/shot_delay = 15
	var/lasercolor = ""
	var/disabled = FALSE //A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag


	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/declare_arrests = TRUE //When making an arrest, should it notify everyone wearing sechuds?
	var/idcheck = TRUE //If true, arrest people with no IDs
	var/weaponscheck = TRUE //If true, arrest people for weapons if they don't have access
	var/check_records = TRUE //Does it check security records?
	var/arrest_type = FALSE //If true, don't handcuff
	var/projectile = /obj/projectile/energy/electrode //Holder for projectile type
	var/shoot_sound = 'sound/weapons/taser2.ogg'
	var/cell_type = /obj/item/stock_parts/cell
	var/vest_type = /obj/item/clothing/suit/armor/vest

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/bot/ed209)

/mob/living/simple_animal/bot/ed209/Initialize(mapload,created_name,created_lasercolor)
	. = ..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasercolor = created_lasercolor
	icon_state = "[lasercolor]ed209[on]"
	set_weapon() //giving it the right projectile and firing sound.

	var/datum/job/J = SSjob.GetJob(JOB_NAME_DETECTIVE)
	access_card.access = J.get_access()
	prev_access = access_card.access.Copy()
	if(lasercolor)
		shot_delay = 6//Longer shot delay because JESUS CHRIST
		check_records = 0//Don't actively target people set to arrest
		arrest_type = 1//Don't even try to cuff
		bot_core.req_access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
		arrest_type = 1
		if((lasercolor == "b") && (name == "\improper ED-209 Security Robot"))//Picks a name if there isn't already a custome one
			name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
		if((lasercolor == "r") && (name == "\improper ED-209 Security Robot"))
			name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")

	//SECHUD
	var/datum/atom_hud/secsensor = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	secsensor.add_hud_to(src)

/mob/living/simple_animal/bot/ed209/turn_on()
	. = ..()
	icon_state = "[lasercolor]ed209[on]"
	mode = BOT_IDLE

/mob/living/simple_animal/bot/ed209/turn_off()
	..()
	icon_state = "[lasercolor]ed209[on]"

/mob/living/simple_animal/bot/ed209/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = FALSE
	SSmove_manager.stop_looping(src)
	last_found = world.time
	set_weapon()

/mob/living/simple_animal/bot/ed209/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	return 0

/mob/living/simple_animal/bot/ed209/set_custom_texts()
	text_hack = "You disable [name]'s combat inhibitor."
	text_dehack = "You restore [name]'s combat inhibitor."
	text_dehack_fail = "[name] ignores your attempts to restrict him!"

/mob/living/simple_animal/bot/ed209/ui_data(mob/user)
	var/list/data = ..()
	if (!locked || issilicon(user) || IsAdminGhost(user))
		if(!lasercolor)
			data["custom_controls"]["check_id"] = idcheck
			data["custom_controls"]["check_weapons"] = weaponscheck
			data["custom_controls"]["check_warrants"] = check_records
			data["custom_controls"]["handcuff_targets"] = !arrest_type
			data["custom_controls"]["arrest_alert"] = declare_arrests
	return data

/mob/living/simple_animal/bot/ed209/ui_act(action, params)
	if(lasercolor && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && (istype(H.wear_suit, /obj/item/clothing/suit/redtag)))//Opposing team cannot operate it
			return TRUE
		else if((lasercolor == "r") && (istype(H.wear_suit, /obj/item/clothing/suit/bluetag)))
			return TRUE
	if(..())
		return TRUE

	switch(action)
		if("check_id")
			idcheck = !idcheck
		if("check_weapons")
			weaponscheck = !weaponscheck
		if("check_warrants")
			check_records = !check_records
		if("handcuff_targets")
			arrest_type = !arrest_type
		if("arrest_alert")
			declare_arrests = !declare_arrests

/mob/living/simple_animal/bot/ed209/proc/judgment_criteria()
	var/final = FALSE
	if(idcheck)
		final = final|JUDGE_IDCHECK
	if(check_records)
		final = final|JUDGE_RECORDCHECK
	if(weaponscheck)
		final = final|JUDGE_WEAPONCHECK
	if(emagged == 2)
		final = final|JUDGE_EMAGGED
	//ED209's ignore monkeys
	final = final|JUDGE_IGNOREMONKEYS
	return final

/mob/living/simple_animal/bot/ed209/proc/retaliate(mob/living/carbon/human/H)
	var/judgment_criteria = judgment_criteria()
	threatlevel = H.assess_threat(judgment_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT

/mob/living/simple_animal/bot/ed209/attack_hand(mob/living/carbon/human/H)
	if(H.combat_mode)
		retaliate(H)
	return ..()

/mob/living/simple_animal/bot/ed209/attackby(obj/item/W, mob/living/user, params)
	..()
	if(W.tool_behaviour == TOOL_WELDER && !user.combat_mode) // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(W.tool_behaviour != TOOL_SCREWDRIVER && (!target)) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		if(W.force && W.damtype != STAMINA)//If force is non-zero and damage type isn't stamina.
			retaliate(user)
			if(lasercolor)//To make up for the fact that lasertag bots don't hunt
				shootAt(user)

/mob/living/simple_animal/bot/ed209/on_emag(atom/target, mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, span_warning("You short out [src]'s target assessment circuits."))
			oldtarget_name = user.name
		audible_message(span_danger("[src] buzzes oddly!"))
		declare_arrests = FALSE
		icon_state = "[lasercolor]ed209[on]"
		set_weapon()

/mob/living/simple_animal/bot/ed209/bullet_act(obj/projectile/Proj)
	if(istype(Proj , /obj/projectile/beam/laser)||istype(Proj, /obj/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health && ishuman(Proj.firer))
				retaliate(Proj.firer)
	return ..()

/mob/living/simple_animal/bot/ed209/handle_automated_action()
	if(!..())
		return

	if(disabled)
		return

	var/judgment_criteria = judgment_criteria()
	var/list/targets = list()
	for(var/mob/living/carbon/C in view(7,src)) //Let's find us a target
		var/threatlevel = 0
		if(C.incapacitated())
			continue
		threatlevel = C.assess_threat(judgment_criteria, lasercolor, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
		//speak(C.real_name + ": threat: [threatlevel]")
		if(threatlevel < 4 )
			continue

		var/dst = get_dist(src, C)
		if(dst <= 1 || dst > 7)
			continue

		targets += C
	if(targets.len>0)
		var/mob/living/carbon/t = pick(targets)
		if(t.stat != DEAD && t.body_position == STANDING_UP && !t.handcuffed) //we don't shoot people who are dead, cuffed or lying down.
			shootAt(t)
	switch(mode)

		if(BOT_IDLE)		// idle
			SSmove_manager.stop_looping(src)
			if(!lasercolor) //lasertag bots don't want to arrest anyone
				look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				SSmove_manager.stop_looping(src)
				back_to_idle()

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc)) // if right next to perp
					stun_attack(target)

					mode = BOT_PREP_ARREST
					set_anchored(TRUE)
					target_lastloc = target.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					SSmove_manager.move_to(src, target, 1, 4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if(!Adjacent(target) || !isturf(target.loc) ||  target.AmountParalyzed() < 40)
				back_to_hunt()
				return

			if(iscarbon(target) && target.canBeHandcuffed())
				if(!arrest_type)
					if(!target.handcuffed)  //he's not cuffed? Try to cuff him!
						cuff(target)
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

		if(BOT_ARREST)
			if(!target)
				set_anchored(FALSE)
				mode = BOT_IDLE
				last_found = world.time
				frustration = 0
				return

			if(target.handcuffed) //no target or target cuffed? back to idle.
				back_to_idle()
				return

			if(!Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && target.AmountParalyzed() < 40)) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			else
				mode = BOT_PREP_ARREST
				set_anchored(FALSE)

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


	return

/mob/living/simple_animal/bot/ed209/proc/back_to_idle()
	anchored = FALSE
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action)) //ensure bot quickly responds

/mob/living/simple_animal/bot/ed209/proc/back_to_hunt()
	anchored = FALSE
	frustration = 0
	mode = BOT_HUNT
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action)) //ensure bot quickly responds

// look for a criminal in view of the bot

/mob/living/simple_animal/bot/ed209/proc/look_for_perp()
	if(disabled)
		return
	anchored = FALSE
	threatlevel = 0
	var/judgment_criteria = judgment_criteria()
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(judgment_criteria, lasercolor, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(src, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/edplaceholder.ogg'), 50, FALSE)
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			spawn(0)
				handle_automated_action()	// ensure bot quickly responds to a perp
			break
		else
			continue

/mob/living/simple_animal/bot/ed209/proc/check_for_weapons(obj/item/slot_item)
	if(slot_item && (slot_item.item_flags & NEEDS_PERMIT))
		return 1
	return 0

/mob/living/simple_animal/bot/ed209/explode()
	SSmove_manager.stop_looping(src)
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	var/obj/item/bot_assembly/ed209/Sa = new (Tsec)
	Sa.build_step = 1
	Sa.add_overlay("hs_hole")
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)
	drop_part(cell_type, Tsec)

	if(!lasercolor)
		var/obj/item/gun/energy/disabler/G = new (Tsec)
		G.cell.charge = 0
		G.update_icon()
	else if(lasercolor == "b")
		var/obj/item/gun/energy/laser/bluetag/G = new (Tsec)
		G.cell.charge = 0
		G.update_icon()
	else if(lasercolor == "r")
		var/obj/item/gun/energy/laser/redtag/G = new (Tsec)
		G.cell.charge = 0
		G.update_icon()

	if(prob(50))
		new /obj/item/bodypart/leg/left/robot(Tsec)
		if(prob(25))
			new /obj/item/bodypart/leg/right/robot(Tsec)
	if(prob(25))//50% chance for a helmet OR vest
		if(prob(50))
			new /obj/item/clothing/head/helmet(Tsec)
		else
			if(!lasercolor)
				drop_part(vest_type, Tsec)
			if(lasercolor == "b")
				new /obj/item/clothing/suit/bluetag(Tsec)
			if(lasercolor == "r")
				new /obj/item/clothing/suit/redtag(Tsec)

	do_sparks(3, TRUE, src)

	new /obj/effect/decal/cleanable/oil(loc)
	..()

/mob/living/simple_animal/bot/ed209/proc/set_weapon()  //used to update the projectile type and firing sound
	shoot_sound = 'sound/weapons/laser.ogg'
	if(emagged == 2)
		if(lasercolor)
			projectile = /obj/projectile/beam/lasertag
		else
			projectile = /obj/projectile/beam
	else
		if(!lasercolor)
			shoot_sound = 'sound/weapons/laser.ogg'
			projectile = /obj/projectile/beam/disabler
		else if(lasercolor == "b")
			projectile = /obj/projectile/beam/lasertag/bluetag
		else if(lasercolor == "r")
			projectile = /obj/projectile/beam/lasertag/redtag

/mob/living/simple_animal/bot/ed209/proc/shootAt(mob/target)
	if(world.time <= lastfired + shot_delay)
		return
	lastfired = world.time
	var/turf/T = loc
	var/turf/U = get_turf(target)
	if(!U)
		return
	if(!isturf(T))
		return

	if(!projectile)
		return

	var/obj/projectile/A = new projectile (loc)
	playsound(src, shoot_sound, 50, TRUE)
	A.preparePixelProjectile(target, src)
	A.fire()

/mob/living/simple_animal/bot/ed209/attack_alien(mob/living/carbon/alien/user)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT


/mob/living/simple_animal/bot/ed209/emp_act(severity)
	if(severity == 2 && prob(70))
		severity = 1
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (severity >= 2)
		new /obj/effect/temp_visual/emp(loc)
		var/list/mob/living/carbon/targets = new
		for(var/mob/living/carbon/C in view(12,src))
			if(C.stat==DEAD)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if(toshoot)
					targets-=toshoot
					if(prob(50) && emagged < 2)
						emagged = 2
						set_weapon()
						shootAt(toshoot)
						emagged = FALSE
						set_weapon()
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if(toarrest)
						target = toarrest
						mode = BOT_HUNT


/mob/living/simple_animal/bot/ed209/bullet_act(obj/projectile/Proj)
	if(!disabled)
		var/lasertag_check = 0
		if((lasercolor == "b"))
			if(istype(Proj, /obj/projectile/beam/lasertag/redtag))
				lasertag_check++
		else if((lasercolor == "r"))
			if(istype(Proj, /obj/projectile/beam/lasertag/bluetag))
				lasertag_check++
		if(lasertag_check)
			icon_state = "[lasercolor]ed2090"
			disabled = TRUE
			target = null
			addtimer(CALLBACK(src, PROC_REF(reenable)), 100)
			return BULLET_ACT_HIT
		else
			. = ..()
	else
		. = ..()

/mob/living/simple_animal/bot/ed209/proc/reenable()
	disabled = FALSE
	icon_state = "[lasercolor]ed2091"

/mob/living/simple_animal/bot/ed209/bluetag
	lasercolor = "b"

/mob/living/simple_animal/bot/ed209/redtag
	lasercolor = "r"

/mob/living/simple_animal/bot/ed209/UnarmedAttack(atom/A)
	if(!on)
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C.IsStun() || !C.IsParalyzed() || arrest_type)
			stun_attack(A)
		else if(C.canBeHandcuffed() && !C.handcuffed)
			cuff(A)
	else
		..()

/mob/living/simple_animal/bot/ed209/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.throwforce < src.health && I.thrownby && ishuman(I.thrownby))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)
	..()

/mob/living/simple_animal/bot/ed209/RangedAttack(atom/A)
	if(!on)
		return
	shootAt(A)

/mob/living/simple_animal/bot/ed209/proc/stun_attack(mob/living/carbon/C)
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	icon_state = "[lasercolor]ed209-c"
	spawn(2)
		icon_state = "[lasercolor]ed209[on]"
	var/threat = 5
	C.Paralyze(100)
	C.stuttering = 5
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		var/judgment_criteria = judgment_criteria()
		threat = H.assess_threat(judgment_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	log_combat(src,C,"stunned", src)
	if(declare_arrests)
		var/area/location = get_area(src)
		speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)
	C.visible_message(span_danger("[src] has stunned [C]!"),\
							span_userdanger("[src] has stunned you!"))

/mob/living/simple_animal/bot/ed209/proc/cuff(mob/living/carbon/C)
	mode = BOT_ARREST
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	C.visible_message(span_danger("[src] is trying to put zipties on [C]!"),\
						span_userdanger("[src] is trying to put zipties on you!"))
	addtimer(CALLBACK(src, PROC_REF(attempt_handcuff), C), 60)

/mob/living/simple_animal/bot/ed209/proc/attempt_handcuff(mob/living/carbon/C)
	if(!on || !Adjacent(C) || !isturf(C.loc) ) //if he's in a closet or not adjacent, we cancel cuffing.
		return
	if(!C.handcuffed)
		C.set_handcuffed(new /obj/item/restraints/handcuffs/cable/zipties/used(C))
		C.update_handcuffed()
		playsound(src, "law", 50, 0)
		back_to_idle()
