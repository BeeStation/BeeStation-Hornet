#define CONFUSION_STACK_MAX_MULTIPLIER 2
#define FLASH_USE 2
#define FLASH_USE_BURNOUT 1
#define FLASH_FAIL 0

/obj/item/flashbulb
	name = "flashbulb"
	desc = "A powerful bulb that, when placed into a flash device can emit a bright light that will disorientate and subdue targets."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "flashbulb"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100)
	flags_1 = CONDUCT_1
	throw_speed = 3
	throw_range = 7
	var/charges_left = 10

/obj/item/flashbulb/update_icon()
	if(charges_left <= 0)
		icon_state = "flashbulbburnt"
	else
		icon_state = "flashbulb"

/obj/item/flashbulb/examine(mob/user)
	. = ..()
	. += "This one can probably just about handle [charges_left] more uses."

/obj/item/flashbulb/proc/check_working()
	return charges_left > 0

/obj/item/flashbulb/proc/use_flashbulb()
	if(charges_left <= 0)
		return FLASH_FAIL
	charges_left--
	if(charges_left == 0)
		icon_state = "flashbulbburnt"
		return FLASH_USE_BURNOUT
	return FLASH_USE

/obj/item/flashbulb/weak
	name = "weakened flashbulb"
	charges_left = 4

/obj/item/flashbulb/recharging
	charges_left = 3
	var/max_charges = 3
	var/charge_time = 10 SECONDS
	var/recharging = FALSE

/obj/item/flashbulb/recharging/proc/recharge()
	recharging = FALSE
	if(charges_left >= max_charges)
		return
	charges_left ++
	icon_state = "flashbulb"
	if(charges_left < max_charges)
		addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_UNIQUE)
		recharging = TRUE

/obj/item/flashbulb/recharging/use_flashbulb()
	. = ..()
	if(!recharging)
		addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_UNIQUE)
		recharging = TRUE

/obj/item/flashbulb/recharging/revolution
	name = "modified flashbulb"
	charges_left = 10
	max_charges = 10
	charge_time = 15 SECONDS

/obj/item/flashbulb/recharging/cyborg
	name = "cyborg flashbulb"

/obj/item/assembly/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production. \
		It is highly effective against targets who aren't standing or are suffering from exhaustion."
	icon_state = "flash"
	item_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/iron = 300, /datum/material/glass = 300)
	light_color = LIGHT_COLOR_WHITE
	light_system = MOVABLE_LIGHT //Used as a flash here.
	light_range = FLASH_LIGHT_RANGE
	light_power = FLASH_LIGHT_POWER
	light_on = FALSE
	item_flags = ISWEAPON
	var/flashing_overlay = "flash-f"
	var/last_used = 0 //last world.time it was used.
	var/cooldown = 20
	var/last_trigger = 0 //Last time it was successfully triggered.
	var/burnt_out = FALSE
	var/obj/item/flashbulb/bulb = /obj/item/flashbulb	//Store reference to object and run new when initialised.

/obj/item/assembly/flash/handheld/weak
	bulb = /obj/item/flashbulb/weak

/obj/item/assembly/flash/handheld/strong
	bulb = /obj/item/flashbulb/recharging/revolution

/obj/item/assembly/flash/Initialize(mapload)
	. = ..()
	bulb = new bulb

/obj/item/assembly/flash/examine(mob/user)
	. = ..()
	. += "[bulb ? "The bulb looks like it can handle just about [bulb.charges_left] more uses.\nIt looks like you can cut out the flashbulb with a pair of wirecutters." : "The device has no bulb installed."]"

/obj/item/assembly/flash/suicide_act(mob/living/user)
	if(!bulb)
		user.visible_message("<span class='suicide'>[user] raises \the [src] up to [user.p_their()] eyes and activates it ... but there is no bulb!</span>")
		return SHAME
	if(bulb.charges_left <= 0)
		user.visible_message("<span class='suicide'>[user] raises \the [src] up to [user.p_their()] eyes and activates it ... but it's burnt out!</span>")
		return SHAME
	else if(user.is_blind())
		user.visible_message("<span class='suicide'>[user] raises \the [src] up to [user.p_their()] eyes and activates it ... but [user.p_theyre()] blind!</span>")
		return SHAME
	user.visible_message("<span class='suicide'>[user] raises \the [src] up to [user.p_their()] eyes and activates it! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	attack(user,user)
	return FIRELOSS

/obj/item/assembly/flash/update_icon(flash = FALSE)
	cut_overlays()
	attached_overlays = list()
	if(!bulb)
		add_overlay("flashempty")
		attached_overlays += "flashempty"
	else if(burnt_out)
		add_overlay("flashburnt")
		attached_overlays += "flashburnt"
	if(flash)
		add_overlay(flashing_overlay)
		attached_overlays += flashing_overlay
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 5)
	if(holder)
		holder.update_icon()

/obj/item/assembly/flash/attackby(obj/item/W, mob/user, params)
	. = ..()
	var/obj/item/flashbulb/newflash = W
	if(!istype(newflash))
		return
	if(bulb)
		to_chat("<span class='warning'>You fail to put the bulb into \the [src] as it already has a bulb in it.</spawn>")
		return
	user.transferItemToLoc(newflash, src)
	bulb = newflash
	burnt_out = !bulb.check_working()
	update_icon()

/obj/item/assembly/flash/proc/clown_check(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		flash_carbon(user, user, 15, 0)
		return FALSE
	return TRUE

/obj/item/assembly/flash/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	bulb.charges_left = 0
	if(!burnt_out)
		burnt_out = TRUE
		update_icon()
	if(ismob(loc))
		var/mob/M = loc
		M.visible_message("<span class='danger'>[src] burns out!</span>","<span class='userdanger'>[src] burns out!</span>")
	else
		var/turf/T = get_turf(src)
		T.visible_message("<span class='danger'>[src] burns out!</span>")

/obj/item/assembly/flash/wirecutter_act(mob/living/user, obj/item/I)
	if(!bulb)
		to_chat(user, "<span class='notice'>There is no bulb in \the [src].</span>")
		return FALSE
	if(flags_1 & NODECONSTRUCT_1)
		to_chat(user, "<span class='notice'>You cannot remove the bulb from \the [src].</span>")
		return FALSE
	bulb.forceMove(drop_location())
	user.put_in_hands(bulb)
	bulb.update_icon()
	bulb = null
	to_chat(user, "<span class='notice'>You remove the bulb from \the [src].</span>")
	update_icon()
	return TRUE

//BYPASS CHECKS ALSO PREVENTS BURNOUT!
/obj/item/assembly/flash/proc/AOE_flash(bypass_checks = FALSE, range = 3, power = 5, targeted = FALSE, mob/user)
	if(!bypass_checks && !try_use_flash())
		return FALSE
	var/list/mob/targets = get_flash_targets(get_turf(src), range, FALSE)
	if(user)
		targets -= user
	for(var/mob/living/carbon/C in targets)
		flash_carbon(C, user, power, targeted, TRUE)
	return TRUE

/obj/item/assembly/flash/proc/get_flash_targets(atom/target_loc, range = 3, override_vision_checks = FALSE)
	if(!target_loc)
		target_loc = loc
	if(override_vision_checks)
		return get_hearers_in_view(range, get_turf(target_loc))
	if(isturf(target_loc) || (ismob(target_loc) && isturf(target_loc.loc)))
		return viewers(range, get_turf(target_loc))
	else
		return typecache_filter_list(target_loc.GetAllContents(), GLOB.typecache_living)

/obj/item/assembly/flash/proc/try_use_flash(mob/user = null)
	if(!bulb || (world.time < last_trigger + cooldown))
		return FALSE
	switch(bulb.use_flashbulb())
		if(FLASH_FAIL)
			return FALSE
		if(FLASH_USE_BURNOUT)
			burn_out()
	if(is_head_revolutionary(user) && !burnt_out)
		//Flash will drain to a minimum of 1 charge when used by a head rev.
		if(bulb.charges_left < rand(2, initial(bulb.charges_left) - 1))
			bulb.charges_left ++
	last_trigger = world.time
	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	set_light_on(TRUE)
	addtimer(CALLBACK(src, PROC_REF(flash_end)), FLASH_LIGHT_DURATION, TIMER_OVERRIDE|TIMER_UNIQUE)
	update_icon(TRUE)
	if(user && !clown_check(user))
		return FALSE
	return TRUE


/obj/item/assembly/flash/proc/flash_end()
	set_light_on(FALSE)


/obj/item/assembly/flash/proc/flash_carbon(mob/living/carbon/M, mob/user, power = 15, targeted = TRUE, generic_message = FALSE)
	if(!istype(M))
		return
	if(user)
		log_combat(user, M, "[targeted? "flashed(targeted)" : "flashed(AOE)"]", src)
	else //caused by emp/remote signal
		M.log_message("was [targeted? "flashed(targeted)" : "flashed(AOE)"]",LOG_ATTACK)
	if(generic_message && M != user)
		to_chat(M, "<span class='disarm'>[src] emits a blinding light!</span>")
	if(targeted)
		//No flash protection, blind and stun
		if(M.flash_act(1, TRUE))
			if(user)
				terrible_conversion_proc(M, user)
				visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>")
				to_chat(user, "<span class='danger'>You blind [M] with the flash!</span>")
				to_chat(M, "<span class='userdanger'>[user] blinds you with the flash!</span>")
			else
				to_chat(M, "<span class='userdanger'>You are blinded by [src]!</span>")
			//Will be 0 if the user has no stmaina loss, will be 1 if they are in stamcrit
			var/flash_proportion = CLAMP01(M.getStaminaLoss() / (M.maxHealth - M.crit_threshold))
			if (!(M.mobility_flags & MOBILITY_STAND))
				flash_proportion = 1
			if(flash_proportion > 0.4)
				M.Paralyze(70 * flash_proportion)
			else
				M.Knockdown(max(70 * flash_proportion, 5))
			M.confused = max(M.confused, 4)

		//Basic flash protection, only blind
		else if(M.flash_act(2, TRUE))
			if(user)
				//Tell the user that their flash failed
				visible_message("<span class='disarm'>[user] fails to blind [M] with the flash!</span>")
				to_chat(user, "<span class='warning'>You fail to blind [M] with the flash!</span>")
				//Tell the victim that they have been blinded
				to_chat(M, "<span class='userdanger'>[user] blinds you with the flash!</span>")
			else
				to_chat(M, "<span class='userdanger'>You are blinded by [src]!</span>")

		//Complete failure to blind
		else if(user)
			visible_message("<span class='disarm'>[user] fails to blind [M] with the flash!</span>")
			to_chat(user, "<span class='warning'>You fail to blind [M] with the flash!</span>")
			to_chat(M, "<span class='danger'>[user] fails to blind you with the flash!</span>")
		else
			to_chat(M, "<span class='danger'>[src] fails to blind you!</span>")
	else
		M.flash_act(2)

/obj/item/assembly/flash/attack(mob/living/M, mob/user)
	if(!try_use_flash(user))
		return FALSE
	if(iscarbon(M))
		flash_carbon(M, user, 5, 1)
		return TRUE
	else if(issilicon(M))
		var/mob/living/silicon/robot/R = M
		log_combat(user, R, "flashed", src)
		update_icon(1)
		R.Paralyze(70)
		R.flash_act(affect_silicon = 1, type = /atom/movable/screen/fullscreen/flash/static)
		user.visible_message("<span class='disarm'>[user] overloads [R]'s sensors with the flash!</span>", "<span class='danger'>You overload [R]'s sensors with the flash!</span>")
		return TRUE

	user.visible_message("<span class='disarm'>[user] fails to blind [M] with the flash!</span>", "<span class='warning'>You fail to blind [M] with the flash!</span>")

/obj/item/assembly/flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(holder)
		return FALSE
	if(!AOE_flash(FALSE, 3, 5, FALSE, user))
		return FALSE
	to_chat(user, "<span class='danger'>[src] emits a blinding light!</span>")

/obj/item/assembly/flash/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!try_use_flash())
		return
	AOE_flash()
	burn_out()

/obj/item/assembly/flash/activate()//AOE flash on signal received
	if(!..())
		return
	AOE_flash()

/obj/item/assembly/flash/proc/terrible_conversion_proc(mob/living/carbon/H, mob/user)
	if(istype(H) && H.stat != DEAD)
		if(user.mind)
			var/datum/antagonist/rev/head/converter = user.mind.has_antag_datum(/datum/antagonist/rev/head)
			if(!converter)
				return
			if(!H.client)
				to_chat(user, "<span class='warning'>This mind is so vacant that it is not susceptible to influence!</span>")
				return
			if(H.stat != CONSCIOUS)
				to_chat(user, "<span class='warning'>They must be conscious before you can convert [H.p_them()]!</span>")
				return
			if(!converter.add_revolutionary(H.mind))
				to_chat(user, "<span class='warning'>This mind seems resistant to the flash!</span>")


/obj/item/assembly/flash/cyborg
	bulb = /obj/item/flashbulb/recharging/cyborg

/obj/item/assembly/flash/cyborg/attack(mob/living/M, mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/assembly/flash/cyborg/attack_self(mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/assembly/flash/cyborg/attackby(obj/item/W, mob/user, params)
	return

/obj/item/assembly/flash/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/flash/cyborg/wirecutter_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/flash/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer"
	item_state = "nullrod"

/obj/item/assembly/flash/handheld //this is now the regular pocket flashes

/obj/item/assembly/flash/armimplant
	name = "photon projector"
	desc = "A high-powered photon projector implant normally used for lighting purposes, but also doubles as a flashbulb weapon. Self-repair protocols fix the flashbulb if it ever burns out."
	var/flashcd = 20
	var/overheat = 0
	//Wearef to our arm
	var/datum/weakref/arm

/obj/item/assembly/flash/armimplant/burn_out()
	var/obj/item/organ/cyberimp/arm/flash/real_arm = arm.resolve()
	if(real_arm?.owner)
		to_chat(real_arm.owner, "<span class='warning'>Your photon projector implant overheats and deactivates!</span>")
		real_arm.Retract()
	overheat = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), flashcd * 2)

/obj/item/assembly/flash/armimplant/try_use_flash(mob/user = null)
	if(overheat)
		var/obj/item/organ/cyberimp/arm/flash/real_arm = arm.resolve()
		if(real_arm?.owner)
			to_chat(real_arm.owner, "<span class='warning'>Your photon projector is running too hot to be used again so quickly!</span>")
		return FALSE
	overheat = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), flashcd)
	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	update_icon(1)
	return TRUE


/obj/item/assembly/flash/armimplant/proc/cooldown()
	overheat = FALSE

/obj/item/assembly/flash/armimplant/wirecutter_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/flash/hypnotic
	desc = "A modified flash device, programmed to emit a sequence of subliminal flashes that can send a vulnerable target into a hypnotic trance."
	flashing_overlay = "flash-hypno"
	light_color = LIGHT_COLOR_PINK
	cooldown = 20
	bulb = /obj/item/flashbulb/recharging/revolution

/obj/item/assembly/flash/hypnotic/burn_out()
	return

/obj/item/assembly/flash/hypnotic/wirecutter_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/flash/hypnotic/flash_carbon(mob/living/carbon/M, mob/user, power = 15, targeted = TRUE, generic_message = FALSE)
	if(!istype(M))
		return
	if(user)
		log_combat(user, M, "[targeted? "hypno-flashed(targeted)" : "hypno-flashed(AOE)"]", src)
	else //caused by emp/remote signal
		M.log_message("was [targeted? "hypno-flashed(targeted)" : "hypno-flashed(AOE)"]",LOG_ATTACK)
	if(generic_message && M != user)
		to_chat(M, "<span class='disarm'>[src] emits a soothing light...</span>")
	if(targeted)
		if(M.flash_act(1, 1))
			if(user)
				user.visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>", "<span class='danger'>You hypno-flash [M]!</span>")

			if(M.hypnosis_vulnerable())
				M.apply_status_effect(/datum/status_effect/trance, 200, TRUE)
			else
				to_chat(M, "<span class='notice'>The light makes you feel oddly relaxed...</span>")
				M.confused += min(M.confused + 10, 20)
				M.dizziness += min(M.dizziness + 10, 20)
				M.drowsyness += min(M.drowsyness + 10, 20)
				M.apply_status_effect(STATUS_EFFECT_PACIFY, 100)



		else if(user)
			user.visible_message("<span class='disarm'>[user] fails to blind [M] with the flash!</span>", "<span class='warning'>You fail to hypno-flash [M]!</span>")
		else
			to_chat(M, "<span class='danger'>[src] fails to blind you!</span>")

	else if(M.flash_act())
		to_chat(M, "<span class='notice'>Such a pretty light...</span>")
		M.confused += min(M.confused + 4, 20)
		M.dizziness += min(M.dizziness + 4, 20)
		M.drowsyness += min(M.drowsyness + 4, 20)
		M.apply_status_effect(STATUS_EFFECT_PACIFY, 40)

#undef FLASH_USE
#undef FLASH_USE_BURNOUT
#undef FLASH_FAIL
