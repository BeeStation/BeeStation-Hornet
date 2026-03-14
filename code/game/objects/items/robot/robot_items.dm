/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'


/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/charge_cost = 30

/obj/item/borg/stun/attack(mob/living/M, mob/living/user)
	var/armor_block = M.run_armor_check(attack_flag = STAMINA)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(src, 0, "[M]'s [name]", MELEE_ATTACK))
			playsound(M, 'sound/weapons/genhit.ogg', 50, 1)
			return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(charge_cost))
			return
	M.apply_damage(80, STAMINA, blocked = armor_block)
	user.do_attack_animation(M)
	M.adjust_stutter(10 SECONDS)

	M.visible_message(span_danger("[user] has prodded [M] with [src]!"), \
					span_userdanger("[user] has prodded you with [src]!"))

	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)

	log_combat(user, M, "electrified", src, "(Combat mode: [user.combat_mode ? "On" : "Off"])")

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	var/mode = 0 //0 = Hugs 1 = "Hug" 2 = Shock 3 = CRUSH
	var/ccooldown = 0
	var/scooldown = 0
	var/shockallowed = FALSE//Can it be a stunarm when emagged. Only PK borgs get this by default.
	var/boop = FALSE

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged&&shockallowed == 1)
			if(mode < 3)
				mode++
			else
				mode = 0
		else if(mode < 1)
			mode++
		else
			mode = 0
	switch(mode)
		if(0)
			to_chat(user, "Power reset. Hugs!")
		if(1)
			to_chat(user, "Power increased!")
		if(2)
			to_chat(user, "BZZT. Electrifying arms...")
		if(3)
			to_chat(user, "ERROR: ARM ACTUATORS OVERLOADED.")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user, params)
	if(M == user)
		return
	switch(mode)
		if(0)
			if(M.health >= 0)
				if(isanimal_or_basicmob(M))
					var/list/modifiers = params2list(params)
					if (!user.combat_mode && !LAZYACCESS(modifiers, RIGHT_CLICK))
						M.attack_hand(user, modifiers) //This enables borgs to get the floating heart icon and mob emote from simple_animal's that have petbonus == true.
					return
				if(user.is_zone_selected(BODY_ZONE_HEAD, precise_only = TRUE))
					user.visible_message(span_notice("[user] playfully boops [M] on the head!"), \
									span_notice("You playfully boop [M] on the head!"))
					user.do_attack_animation(M, ATTACK_EFFECT_BOOP)
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
				else if(ishuman(M))
					if(user.body_position == LYING_DOWN)
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), \
										span_notice("You shake [M] trying to get [M.p_them()] up!"))
					else
						user.visible_message(span_notice("[user] hugs [M] to make [M.p_them()] feel better!"), \
								span_notice("You hug [M] to make [M.p_them()] feel better!"))
					if(M.resting)
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message(span_notice("[user] pets [M]!"), \
							span_notice("You pet [M]!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(1)
			if(M.health >= 0)
				if(ishuman(M))
					M.adjust_status_effects_on_shake_up()
					if(M.body_position == LYING_DOWN)
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), \
										span_notice("You shake [M] trying to get [M.p_them()] up!"))
					else if(user.is_zone_selected(BODY_ZONE_HEAD, precise_only = TRUE))
						user.visible_message(span_warning("[user] bops [M] on the head!"), \
										span_warning("You bop [M] on the head!"))
						user.do_attack_animation(M, ATTACK_EFFECT_PUNCH)
					else
						user.visible_message(span_warning("[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable..."), \
								span_warning("You hug [M] firmly to make [M.p_them()] feel better! [M] looks uncomfortable..."))
					if(M.resting)
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message(span_warning("[user] bops [M] on the head!"), \
							span_warning("You bop [M] on the head!"))
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
		if(2)
			if(scooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						M.electrocute_act(5, "[user]", flags = SHOCK_NOGLOVES)
						user.visible_message(span_userdanger("[user] electrocutes [M] with [user.p_their()] touch!"), \
							span_danger("You electrocute [M] with your touch!"))
					else
						if(!iscyborg(M))
							M.adjustFireLoss(10)
							user.visible_message(span_userdanger("[user] shocks [M]!"), \
								span_danger("You shock [M]!"))
						else
							user.visible_message(span_userdanger("[user] shocks [M]. It does not seem to have an effect"), \
								span_danger("You shock [M] to no effect."))
					playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, -1)
					user.cell.charge -= 500
					scooldown = world.time + 20
		if(3)
			if(ccooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						user.visible_message(span_userdanger("[user] crushes [M] in [user.p_their()] grip!"), \
							span_danger("You crush [M] in your grip!"))
					else
						user.visible_message(span_userdanger("[user] crushes [M]!"), \
								span_danger("You crush [M]!"))
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1, -1)
					M.adjustBruteLoss(15)
					user.cell.charge -= 300
					ccooldown = world.time + 10

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = TRUE

/obj/item/borg/cyborghug/medical
	boop = TRUE

#define MODE_DRAW "draw"
#define MODE_CHARGE "charge"

/obj/item/borg/charger
	name = "power connector"
	icon_state = "charger_draw"
	item_flags = NOBLUDGEON
	var/mode = MODE_DRAW
	var/work_mode	// mode the loops have been started with, to check with do_after
	var/active = FALSE
	var/cyborg_minimum_charge = 50 	// minimum charge cyborgs cannot go under when charging things
	var/static/list/charge_machines = typecacheof(list(
		/obj/machinery/cell_charger,
		/obj/machinery/recharger,
		/obj/machinery/recharge_station,
		/obj/machinery/mech_bay_recharge_port,
	))
	var/static/list/charge_items = typecacheof(list(
		/obj/item/stock_parts/cell,
		/obj/item/gun/energy,
	))

/obj/item/borg/charger/update_icon_state()
	icon_state = "charger_[mode]"
	return ..()

/obj/item/borg/charger/attack_self(mob/user)
	if(mode == MODE_DRAW)
		mode = MODE_CHARGE
	else
		mode = MODE_DRAW
	balloon_alert(user, "You toggle [src] to [mode] mode")
	update_appearance()

/obj/item/borg/charger/afterattack(obj/item/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user))
		return
	if(active)
		if(mode == MODE_DRAW)
			to_chat(user, span_warning("You're already drawing power from something!"))
		else
			to_chat(user, span_warning("You're already charging something!"))
		return

	if(mode == MODE_DRAW)
		if(is_type_in_list(target, charge_machines))
			var/obj/machinery/M = target

			if((M.machine_stat & (NOPOWER|BROKEN)) || !M.anchored)
				to_chat(user, span_warning("[M] is unpowered!"))
				return

			to_chat(user, span_notice("You connect to [M]'s power line..."))
			active = TRUE

			powerdraw_loop(user, M)

		else if(is_type_in_list(target, charge_items))
			var/obj/item/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/stock_parts/cell) in target
			if(!cell)
				to_chat(user, span_warning("[target] has no power cell!"))
				return

			if(istype(target, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = target
				if(!E.can_charge)
					to_chat(user, span_warning("[target] has no power port!"))
					return

			if(!cell.charge)
				to_chat(user, span_warning("[target] has no power!"))
				return

			to_chat(user, span_notice("You connect to [target]'s power port..."))
			active = TRUE

			powerdraw_loop(user, target, cell)

	else
		if(is_type_in_list(target, charge_items))
			if(user.cell.charge <= cyborg_minimum_charge) //leave them a bit
				to_chat(user, span_warning("You don't have enough power to charge [target]!"))
				return

			var/obj/item/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/stock_parts/cell) in target
			if(!cell)
				to_chat(user, span_warning("[target] has no power cell!"))
				return

			if(istype(target, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = target
				if(!E.can_charge)
					to_chat(user, span_warning("[target] has no power port!"))
					return

			if(cell.charge >= cell.maxcharge)
				to_chat(user, span_warning("[target] is already fully charged!"))
				return

			to_chat(user, span_notice("You connect to [target]'s power port..."))
			active = TRUE

			charging_loop(user, target, cell)

/obj/item/borg/charger/proc/powerdraw_loop(mob/living/silicon/robot/user, atom/target, obj/item/stock_parts/cell/cell)
	work_mode = mode

	if(istype(cell))
		while(do_after(user, 15, target = target, extra_checks = CALLBACK(src, PROC_REF(mode_check))))
			if(!user?.cell)
				active = FALSE
				return

			if(!cell || !target)
				active = FALSE
				return

			if(cell != target && cell.loc != target)
				active = FALSE
				return

			var/draw = min(cell.charge, cell.chargerate*0.5, user.cell.maxcharge-user.cell.charge)
			if(!cell.use(draw))
				break

			if(!user.cell.give(draw))
				break

			target.update_icon()

			if(!cell.charge)
				to_chat(user, span_warning("[target] has no power!"))
				active = FALSE
				return

			if(user.cell.charge == user.cell.maxcharge)
				to_chat(user, span_notice("You finish charging from [target]."))
				active = FALSE
				return

		to_chat(user, span_notice("You stop drawing power from [target]."))
		active = FALSE
	else
		var/obj/machinery/M = target
		while(do_after(user, 15, target = M, extra_checks = CALLBACK(src, PROC_REF(mode_check))))
			if(!user?.cell)
				active = FALSE
				return

			if(!target)
				active = FALSE
				return

			if((M.machine_stat & (NOPOWER|BROKEN)) || !M.anchored)
				break

			if(!user.cell.give(15))
				break

			M.use_power(20)

			if(user.cell.charge == user.cell.maxcharge)
				to_chat(user, span_notice("You finish charging from [target]."))
				active = FALSE
				return

		to_chat(user, span_notice("You stop charging yourself."))
		active = FALSE

/obj/item/borg/charger/proc/charging_loop(mob/living/silicon/robot/user, atom/target, obj/item/stock_parts/cell/cell)
	work_mode = mode

	while(do_after(user, 15, target = target, extra_checks = CALLBACK(src, PROC_REF(mode_check))))
		if(!user?.cell)
			active = FALSE
			return

		if(!cell || !target)
			active = FALSE
			return

		if(cell != target && cell.loc != target)
			active = FALSE
			return

		var/draw = min(max(user.cell.charge - cyborg_minimum_charge, 0), cell.chargerate*0.5, cell.maxcharge-cell.charge)
		if(!draw)
			to_chat(user, span_warning("Safeties prevent you from going under [cyborg_minimum_charge] charge!"))
			active = FALSE
			return

		if(!user.cell.use(draw))
			break

		if(!cell.give(draw))
			break

		target.update_icon()

		if(cell.charge == cell.maxcharge)
			to_chat(user, span_notice("You finish charging [target]."))
			active = FALSE
			return

		if(user.cell.charge <= cyborg_minimum_charge) //leave them a bit
			to_chat(user, span_warning("You don't have enough power to continue charging [target]!"))
			active = FALSE
			return

	to_chat(user, span_notice("You stop charging [target]."))
	active = FALSE

/obj/item/borg/charger/proc/mode_check()
	return mode == work_mode

#undef MODE_DRAW
#undef MODE_CHARGE

/obj/item/harmalarm
	name = "\improper Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	emag_toggleable = TRUE
	var/cooldown = 0

/obj/item/harmalarm/on_emag(mob/user)
	..()
	if(obj_flags & EMAGGED)
		to_chat(user, "<font color='red'>You short out the safeties on [src]!</font>")
	else
		to_chat(user, "<font color='red'>You reset the safeties on [src]!</font>")

/obj/item/harmalarm/attack_self(mob/user)
	var/safety = !(obj_flags & EMAGGED)
	if(cooldown > world.time)
		to_chat(user, "<font color='red'>The device is still recharging!</font>")
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 1200)
			to_chat(user, "<font color='red'>You don't have enough charge to do this!</font>")
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE

	if(safety == TRUE)
		user.visible_message("<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>", \
			span_userdanger("The siren pierces your hearing and confuses you!"), \
			span_danger("The siren pierces your hearing!"))
		for(var/mob/living/carbon/carbon in get_hearers_in_view(9, user))
			if(carbon.get_ear_protection())
				continue
			carbon.adjust_confusion(6 SECONDS)

		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/ai/harmalarm.ogg', 70, 3)
		cooldown = world.time + 200
		log_game("[key_name(user)] used a Cyborg Harm Alarm in [AREACOORD(user)]")
		if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			to_chat(R.connected_ai, "<br>[span_notice("NOTICE - Peacekeeping 'HARM ALARM' used by: [user]")]<br>")

		return

	if(safety == FALSE)
		user.audible_message("<font color='red' size='7'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</font>")
		for(var/mob/living/carbon/C in hearers(9, user))
			var/bang_effect = C.soundbang_act(2, 0, 0, 5)
			switch(bang_effect)
				if(1)
					C.adjust_confusion(5 SECONDS)
					C.adjust_stutter(20 SECONDS)
					C.adjust_jitter(20 SECONDS)
				if(2)
					C.Paralyze(40)
					C.adjust_confusion(10 SECONDS)
					C.adjust_stutter(30 SECONDS)
					C.adjust_jitter(50 SECONDS)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
		cooldown = world.time + 600
		log_game("[key_name(user)] used an emagged Cyborg Harm Alarm in [AREACOORD(user)]")

#define DISPENSE_LOLLIPOP_MODE 1
#define THROW_LOLLIPOP_MODE 2
#define THROW_GUMBALL_MODE 3
#define DISPENSE_ICECREAM_MODE 4

/obj/item/borg/lollipop
	name = "treat fabricator"
	desc = "Reward humans with various treats. Toggle in-module to switch between dispensing and high velocity ejection modes."
	icon_state = "lollipop"
	var/candy = 30
	var/candymax = 30
	var/charge_delay = 10
	var/charging = FALSE
	var/mode = DISPENSE_LOLLIPOP_MODE

	var/firedelay = 0
	var/hitspeed = 2
	var/hitdamage = 0
	var/emaggedhitdamage = 3

/obj/item/borg/lollipop/clown
	emaggedhitdamage = 0

/obj/item/borg/lollipop/equipped()
	. = ..()
	check_amount()

/obj/item/borg/lollipop/dropped()
	. = ..()
	check_amount()

/obj/item/borg/lollipop/proc/check_amount()	//Doesn't even use processing ticks.
	if(charging)
		return
	if(candy < candymax)
		addtimer(CALLBACK(src, PROC_REF(charge_lollipops)), charge_delay)
		charging = TRUE

/obj/item/borg/lollipop/proc/charge_lollipops()
	candy++
	charging = FALSE
	check_amount()

/obj/item/borg/lollipop/proc/dispense(atom/A, mob/user)
	if(candy <= 0)
		to_chat(user, span_warning("No treats left in storage!"))
		return FALSE
	var/turf/T = get_turf(A)
	if(!T || !istype(T) || !isopenturf(T))
		return FALSE
	if(isobj(A))
		var/obj/O = A
		if(O.density)
			return FALSE

	var/obj/item/food_item
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE)
			food_item = new /obj/item/food/lollipop(T)
		if(DISPENSE_ICECREAM_MODE)
			food_item = new /obj/item/food/icecream(T)
			var/obj/item/food/icecream/I = food_item
			I.add_ice_cream("vanilla")
			I.desc = "Eat the ice cream."

	var/into_hands = FALSE
	if(ismob(A))
		var/mob/M = A
		into_hands = M.put_in_hands(food_item)

	candy--
	check_amount()

	if(into_hands)
		user.visible_message(span_notice("[user] dispenses a treat into the hands of [A]."), span_notice("You dispense a treat into the hands of [A]."), span_italics("You hear a click."))
	else
		user.visible_message(span_notice("[user] dispenses a treat."), span_notice("You dispense a treat."), span_italics("You hear a click."))

	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	return TRUE

/obj/item/borg/lollipop/proc/shootL(atom/target, mob/living/user, params)
	if(candy <= 0)
		to_chat(user, span_warning("Not enough lollipops left!"))
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/lollipop/A = new /obj/item/ammo_casing/caseless/lollipop(src)
	A.BB.damage = hitdamage
	if(hitdamage)
		A.BB.nodamage = FALSE
	A.BB.speed = 0.5
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	A.fire_casing(target, user, params, fired_from = src)
	user.visible_message(span_warning("[user] blasts a flying lollipop at [target]!"))
	check_amount()

/obj/item/borg/lollipop/proc/shootG(atom/target, mob/living/user, params)	//Most certainly a good idea.
	if(candy <= 0)
		to_chat(user, span_warning("Not enough gumballs left!"))
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/gumball/A = new /obj/item/ammo_casing/caseless/gumball(src)
	A.BB.damage = hitdamage
	if(hitdamage)
		A.BB.nodamage = FALSE
	A.BB.speed = 0.5
	A.BB.color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	playsound(src.loc, 'sound/weapons/bulletflyby3.ogg', 50, 1)
	A.fire_casing(target, user, params, fired_from = src)
	user.visible_message(span_warning("[user] shoots a high-velocity gumball at [target]!"))
	check_amount()

/obj/item/borg/lollipop/afterattack(atom/target, mob/living/user, proximity, click_params)
	. = ..()
	check_amount()
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(12))
			to_chat(user, span_warning("Not enough power."))
			return FALSE
		if(R.emagged)
			hitdamage = emaggedhitdamage
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE, DISPENSE_ICECREAM_MODE)
			if(!proximity)
				return FALSE
			dispense(target, user)
		if(THROW_LOLLIPOP_MODE)
			shootL(target, user, click_params)
		if(THROW_GUMBALL_MODE)
			shootG(target, user, click_params)
	hitdamage = initial(hitdamage)

/obj/item/borg/lollipop/attack_self(mob/living/user)
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE)
			mode = THROW_LOLLIPOP_MODE
			to_chat(user, span_notice("Module is now throwing lollipops."))
		if(THROW_LOLLIPOP_MODE)
			mode = THROW_GUMBALL_MODE
			to_chat(user, span_notice("Module is now blasting gumballs."))
		if(THROW_GUMBALL_MODE)
			mode = DISPENSE_ICECREAM_MODE
			to_chat(user, span_notice("Module is now dispensing ice cream."))
		if(DISPENSE_ICECREAM_MODE)
			mode = DISPENSE_LOLLIPOP_MODE
			to_chat(user, span_notice("Module is now dispensing lollipops."))
	..()

#undef DISPENSE_LOLLIPOP_MODE
#undef THROW_LOLLIPOP_MODE
#undef THROW_GUMBALL_MODE
#undef DISPENSE_ICECREAM_MODE

/obj/item/ammo_casing/caseless/gumball
	name = "Gumball"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/projectile/bullet/reusable/gumball


/obj/projectile/bullet/reusable/gumball
	name = "gumball"
	desc = "Oh noes! A fast-moving gumball!"
	icon_state = "gumball"
	ammo_type = /obj/item/food/gumball/cyborg
	nodamage = TRUE
	bleed_force = 0

/obj/projectile/bullet/reusable/gumball/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/food/gumball/S = new ammo_type(T)
		S.color = color
		dropped = TRUE

/obj/item/ammo_casing/caseless/lollipop	//NEEDS RANDOMIZED COLOR LOGIC.
	name = "Lollipop"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/projectile/bullet/reusable/lollipop

/obj/projectile/bullet/reusable/lollipop
	name = "lollipop"
	desc = "Oh noes! A fast-moving lollipop!"
	icon_state = "lollipop_1"
	ammo_type = /obj/item/food/lollipop/cyborg
	var/color2 = rgb(0, 0, 0)
	nodamage = TRUE
	bleed_force = 0

/obj/projectile/bullet/reusable/lollipop/Initialize(mapload)
	. = ..()
	var/obj/item/food/lollipop/S = new ammo_type(src)
	color2 = S.headcolor
	var/mutable_appearance/head = mutable_appearance('icons/obj/projectiles.dmi', "lollipop_2")
	head.color = color2
	add_overlay(head)

/obj/projectile/bullet/reusable/lollipop/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/food/lollipop/S = new ammo_type(T)
		S.change_head_color(color2)
		dropped = TRUE

#define PKBORG_DAMPEN_CYCLE_DELAY 2 SECONDS

//Peacekeeper Cyborg Projectile Dampenening Field
/obj/item/borg/projectile_dampen
	name = "\improper Hyperkinetic Dampening projector"
	desc = "A device that projects a dampening field that weakens kinetic energy above a certain threshold. " + span_boldnotice("Projects a field that drains power per second while active, that will weaken and slow damaging projectiles inside its field.") + " Still being a prototype, it tends to induce a charge on ungrounded metallic surfaces."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	base_icon_state = "shield"
	var/maxenergy = 1500
	var/energy = 1500
	/// Recharging rate in energy per second
	var/energy_recharge = 37.5
	var/energy_recharge_cyborg_drain_coefficient = 0.4
	var/cyborg_cell_critical_percentage = 0.05
	var/mob/living/silicon/robot/host = null
	var/datum/proximity_monitor/advanced/projectile_dampener/peaceborg/dampening_field
	var/projectile_damage_coefficient = 0.5
	/// Energy cost per tracked projectile damage amount per second
	var/projectile_damage_tick_ecost_coefficient = 10
	var/projectile_speed_coefficient = 1.5		//Higher the coefficient slower the projectile.
	var/projectile_tick_speed_ecost = 75
	var/list/obj/projectile/tracked
	var/image/projectile_effect
	var/field_radius = 3
	var/active = FALSE
	var/cycle_delay = 0

/obj/item/borg/projectile_dampen/debug
	maxenergy = 50000
	energy = 50000
	energy_recharge = 5000

/obj/item/borg/projectile_dampen/Initialize(mapload)
	. = ..()
	projectile_effect = image('icons/effects/fields.dmi', "projectile_dampen_effect")
	tracked = list()
	icon_state = "shield0"
	START_PROCESSING(SSfastprocess, src)
	host = loc
	RegisterSignal(host, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/borg/projectile_dampen/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	deactivate_field()

/obj/item/borg/projectile_dampen/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/borg/projectile_dampen/attack_self(mob/user)
	if(cycle_delay > world.time)
		to_chat(user, span_boldwarning("[src] is still recycling its projectors!"))
		return
	cycle_delay = world.time + PKBORG_DAMPEN_CYCLE_DELAY
	if(!active)
		if(!user.has_buckled_mobs())
			activate_field()
		else
			to_chat(user, span_warning("[src]'s safety cutoff prevents you from activating it due to living beings being ontop of you!"))
	else
		deactivate_field()
	update_appearance()
	to_chat(user, span_boldnotice("You [active? "activate":"deactivate"] [src]."))

/obj/item/borg/projectile_dampen/update_icon_state()
	icon_state = "[base_icon_state][active]"
	return ..()

/obj/item/borg/projectile_dampen/proc/activate_field()
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	var/mob/living/silicon/robot/owner = get_host()
	dampening_field = new(owner, field_radius, TRUE, src)
	RegisterSignal(dampening_field, COMSIG_DAMPENER_CAPTURE,  PROC_REF(dampen_projectile))
	RegisterSignal(dampening_field, COMSIG_DAMPENER_RELEASE,  PROC_REF(restore_projectile))
	owner?.model.allow_riding = FALSE
	active = TRUE

/obj/item/borg/projectile_dampen/proc/deactivate_field()
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	visible_message(span_warning("\The [src] shuts off!"))
	for(var/P in tracked)
		restore_projectile(P)
	active = FALSE

	var/mob/living/silicon/robot/owner = get_host()
	if(owner)
		owner.model.allow_riding = TRUE

/obj/item/borg/projectile_dampen/proc/get_host()
	if(istype(host))
		return host
	else
		if(iscyborg(host.loc))
			return host.loc
	return null

/obj/item/borg/projectile_dampen/dropped()
	..()
	host = loc

/obj/item/borg/projectile_dampen/equipped()
	. = ..()
	host = loc

/obj/item/borg/projectile_dampen/cyborg_unequip(mob/user)
	if(!active)
		return
	deactivate_field()
	update_appearance()
	to_chat(user, span_boldnotice("[src] deactivates itself."))

/obj/item/borg/projectile_dampen/process(delta_time)
	process_recharge(delta_time)
	process_usage(delta_time)

/obj/item/borg/projectile_dampen/proc/process_usage(delta_time)
	var/usage = 0
	for(var/I in tracked)
		var/obj/projectile/P = I
		if(!P.stun && P.nodamage)	//No damage
			continue
		usage += projectile_tick_speed_ecost * delta_time
		usage += (tracked[I] * projectile_damage_tick_ecost_coefficient * delta_time)
	energy = clamp(energy - usage, 0, maxenergy)
	if(energy <= 0)
		deactivate_field()
		visible_message(span_warning("[src] blinks \"ENERGY DEPLETED\"."))

/obj/item/borg/projectile_dampen/proc/process_recharge(delta_time)
	if(!istype(host))
		if(iscyborg(host.loc))
			host = host.loc
		else
			energy = clamp(energy + energy_recharge * delta_time, 0, maxenergy)
			return
	if(host.cell && (host.cell.charge >= (host.cell.maxcharge * cyborg_cell_critical_percentage)) && (energy < maxenergy))
		host.cell.use(energy_recharge * delta_time * energy_recharge_cyborg_drain_coefficient)
		energy += energy_recharge * delta_time

/obj/item/borg/projectile_dampen/proc/dampen_projectile(obj/projectile/projectile)
	tracked[projectile] = projectile.damage
	projectile.damage *= projectile_damage_coefficient
	projectile.speed *= projectile_speed_coefficient
	projectile.add_overlay(projectile_effect)

/obj/item/borg/projectile_dampen/proc/restore_projectile(obj/projectile/P)
	tracked -= P
	P.damage *= (1/projectile_damage_coefficient)
	P.speed *= (1/projectile_speed_coefficient)
	P.cut_overlay(projectile_effect)

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "\proper X-ray vision"
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	sight_mode = BORGXRAY

/obj/item/borg/sight/xray/truesight_lens
	name = "truesight lens"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "truesight_lens"

/obj/item/borg/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"


/obj/item/borg/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"

/obj/item/borg/sight/material
	name = "\proper material vision"
	sight_mode = BORGMATERIAL
	icon_state = "material"

/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"

/obj/item/borg/sight/hud/med/Initialize(mapload)
	. = ..()
	hud = new /obj/item/clothing/glasses/hud/health(src)


/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"

/obj/item/borg/sight/hud/sec/Initialize(mapload)
	. = ..()
	hud = new /obj/item/clothing/glasses/hud/security(src)

/**********************************************************************
						Borg apparatus
***********************************************************************/
//These are tools that can hold only specific items. For example, the mediborg and service borg get one that can only hold reagent containers

/obj/item/borg/apparatus/
	name = "unknown storage apparatus"
	desc = "This device seems nonfunctional."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "hugmodule"
	var/obj/item/stored
	var/list/storable = list()

/obj/item/borg/apparatus/Initialize(mapload)
	. = ..()
	RegisterSignal(loc.loc, COMSIG_BORG_SAFE_DECONSTRUCT, PROC_REF(safedecon))

/obj/item/borg/apparatus/Destroy()
	if(stored)
		qdel(stored)
	. = ..()

///If we're safely deconstructed, we put the item neatly onto the ground, rather than deleting it.
/obj/item/borg/apparatus/proc/safedecon()
	SIGNAL_HANDLER

	if(stored)
		stored.forceMove(get_turf(src))
		stored = null

/obj/item/borg/apparatus/Exited(atom/movable/gone, direction)
	if(gone == stored) //sanity check
		UnregisterSignal(stored, COMSIG_ATOM_UPDATE_ICON)
		stored = null
	update_icon()
	return ..()

///A right-click verb, for those not using hotkey mode.
/obj/item/borg/apparatus/verb/verb_dropHeld()
	set category = "Object"
	set name = "Drop"

	if(usr != loc || !stored)
		return
	stored.forceMove(get_turf(usr))
	return

/obj/item/borg/apparatus/attack_self(mob/living/silicon/robot/user)
	if(!stored)
		return ..()
	stored.attack_self(user)

//Alt click drops stored item
/obj/item/borg/apparatus/AltClick(mob/living/silicon/robot/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(!stored)
		return ..()
	stored.forceMove(get_turf(user))

/obj/item/borg/apparatus/pre_attack(atom/A, mob/living/user, params)
	if(!stored)
		var/itemcheck = FALSE
		for(var/i in storable)
			if(istype(A, i))
				itemcheck = TRUE
				break
		if(itemcheck)
			var/obj/item/O = A
			O.forceMove(src)
			stored = O
			RegisterSignal(stored, COMSIG_ATOM_UPDATE_ICON, TYPE_PROC_REF(/atom, update_icon))
			update_icon()
			return
	else
		stored.melee_attack_chain(user, A, params)
		return
	. = ..()

/obj/item/borg/apparatus/attackby(obj/item/W, mob/user, params)
	if(stored)
		W.melee_attack_chain(user, stored, params)
		return
	. = ..()

////////////////////
//container holder//
////////////////////

/obj/item/borg/apparatus/container
	name = "container storage apparatus"
	desc = "A special apparatus for carrying containers without spilling the contents. It can also synthesize new beakers!"
	icon_state = "borg_beaker_apparatus"
	storable = list(/obj/item/reagent_containers/cup)
	var/defaultcontainer = /obj/item/reagent_containers/cup/beaker

/obj/item/borg/apparatus/container/Destroy()
	if(stored)
		var/obj/item/reagent_containers/C = stored
		C.SplashReagents(get_turf(src))
		QDEL_NULL(stored)
	. = ..()

/obj/item/borg/apparatus/container/examine()
	. = ..()
	//apparatus/container/service means this will not always be true.
	if(istype(stored, /obj/item/reagent_containers/cup))
		var/obj/item/reagent_containers/C = stored
		. += "The apparatus currently has [C] secured, which contains:"
		if(length(C.reagents.reagent_list))
			for(var/datum/reagent/R in C.reagents.reagent_list)
				. += "[R.volume] units of [R.name]"
		else
			. += "Nothing."
		. += span_notice("<i>Alt-click</i> will drop the currently stored [stored].")

/obj/item/borg/apparatus/container/update_overlays()
	. = ..()
	var/mutable_appearance/arm = mutable_appearance(icon = icon, icon_state = "borg_beaker_apparatus_arm")
	if(stored)
		COMPILE_OVERLAYS(stored)
		stored.pixel_x = 0
		stored.pixel_y = 0
		var/mutable_appearance/stored_copy = new /mutable_appearance(stored)
		if(istype(stored, /obj/item/reagent_containers/cup/beaker))
			arm.pixel_y = arm.pixel_y - 3
		stored_copy.layer = FLOAT_LAYER
		stored_copy.plane = FLOAT_PLANE
		. += stored_copy
	else
		arm.pixel_y = arm.pixel_y - 5
	. += arm

/obj/item/borg/apparatus/container/attack_self(mob/living/silicon/robot/user)
	if(!stored)
		var/newcontainer = new defaultcontainer(src)
		stored = newcontainer
		to_chat(user, span_notice("You synthesize a new [newcontainer]!"))
		playsound(src, 'sound/machines/click.ogg', 10, 1)
		update_icon()
		return
	if(stored && !user.client?.keys_held["Alt"] && user.combat_mode)
		var/obj/item/reagent_containers/C = stored
		C.SplashReagents(get_turf(user))
		loc.visible_message(span_notice("[user] spills the contents of the [C] all over the floor."))
		return
	. = ..()

/obj/item/borg/apparatus/container/extra
	name = "container storage apparatus"
	desc = "A supplementary container storage apparatus."

////////////////////
//engi part holder//
////////////////////

/obj/item/borg/apparatus/circuit
	name = "circuit manipulation apparatus"
	desc = "A special apparatus for carrying and manipulating circuit boards."
	icon_state = "borg_hardware_apparatus"
	storable = list(/obj/item/circuitboard,
				/obj/item/electronics)

/obj/item/borg/apparatus/circuit/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/borg/apparatus/circuit/update_overlays()
	. = ..()
	var/mutable_appearance/arm = mutable_appearance(icon, "borg_hardware_apparatus_arm1")
	if(stored)
		COMPILE_OVERLAYS(stored)
		stored.pixel_x = -3
		stored.pixel_y = 0
		if(!istype(stored, /obj/item/circuitboard))
			arm.icon_state = "borg_hardware_apparatus_arm2"
		var/mutable_appearance/stored_copy = new /mutable_appearance(stored)
		stored_copy.layer = FLOAT_LAYER
		stored_copy.plane = FLOAT_PLANE
		. += stored_copy
	. += arm

/obj/item/borg/apparatus/circuit/examine()
	. = ..()
	if(stored)
		. += "The apparatus currently has [stored] secured."
		. += span_notice("<i>Alt-click</i> will drop the currently stored [stored].")

/obj/item/borg/apparatus/circuit/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(istype(A, /obj/item/ai_module) && !stored) //If an admin wants a borg to upload laws, who am I to stop them? Otherwise, we can hint that it fails
		to_chat(user, span_warning("This circuit board doesn't seem to have standard robot apparatus pin holes. You're unable to pick it up."))

////////////////////
//versatile service holder//
////////////////////

/obj/item/borg/apparatus/container/service
	name = "versatile service grasper"
	desc = "Specially designed for carrying glasses, food and seeds. It can also synthesize glasses for drinks!"
	storable = list(
	/obj/item/food,
	/obj/item/reagent_containers/condiment,
	/obj/item/reagent_containers/cup,
	/obj/item/seeds,
	/obj/item/storage/fancy/donut_box,
	/obj/item/storage/fancy/egg_box,
	/obj/item/clothing/mask/cigarette,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/reagent_containers/cup/beaker,
	/obj/item/reagent_containers/cup/bottle,
	/obj/item/reagent_containers/cup/bucket
	)
	defaultcontainer = /obj/item/reagent_containers/cup/glass/drinkingglass


/obj/item/borg/apparatus/container/service/examine()
	. = ..()
	//Parent type handles this type. All other objects held are handled here.
	if(!istype(stored, /obj/item/reagent_containers/cup))
		. += "You are currently holding [stored]."
		. += span_notice("<i>Alt-click</i> will drop the currently stored [stored].")

#undef PKBORG_DAMPEN_CYCLE_DELAY
