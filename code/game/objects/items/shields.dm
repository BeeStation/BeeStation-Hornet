/obj/item/shield
	name = "shield"
	icon = 'icons/obj/shields.dmi'
	canblock = TRUE
	slot_flags = ITEM_SLOT_BACK
	block_flags = BLOCKING_PROJECTILE
	w_class = WEIGHT_CLASS_NORMAL

	//Shields have no blocking cooldown so they can block until integrity gives out or 50 stamina damage is reached,
	//be very careful if you increase this
	block_power = 25
	max_integrity =  120
	item_flags = ISWEAPON
	var/transparent = FALSE	// makes beam projectiles pass through the shield
	var/shield_break_sound = 'sound/effects/glassbr3.ogg'
	///Energy shields do not get disarmed and instead falter
	var/is_energy_shield = FALSE

/obj/item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(transparent && (hitby.pass_flags & PASSTRANSPARENT))
		return FALSE
	return ..()

/obj/item/shield/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(damage_amount >= atom_integrity)
		shatter()
		return
	..()

/obj/item/shield/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	. = ..()
	if(QDELETED(src))
		return FALSE
	if(owner.getStaminaLoss() >= 45 && !is_energy_shield)
		//If we are too tired to keep blocking, but can't drop the shield, shatter it because something cheesy is going on
		if(HAS_TRAIT(src, TRAIT_NODROP))
			shatter(owner)
			return FALSE

		//Otherwise, send the shield flying out of our hand
		else
			var/turf/this_turf = get_turf(src)
			var/list/turf/nearby_turfs = RANGE_TURFS(2, this_turf) - this_turf
			forceMove(this_turf)
			throw_at(pick(nearby_turfs), 2, 1)
			owner.visible_message(span_danger("[owner]'s [src] is sent flying from thier hands!"))
			return FALSE

/obj/item/shield/attackby(obj/item/weldingtool/W, mob/living/user, params)
	if(istype(W))
		if(atom_integrity < max_integrity)
			if(!W.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] is welding the [src].", \
									span_notice("You begin repairing the [src]]..."))
			if(W.use_tool(src, user, 40, volume=50))
				atom_integrity += 20
				user.visible_message("[user.name] has repaired some dents on [src].", \
									span_notice("You finish repairing some of the dents on [src]."))
			else
				to_chat(user, span_notice("The [src] doesn't need repairing."))
	return ..()

/obj/item/shield/examine(mob/user)
	. = ..()
	var/healthpercent = round((atom_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += span_info("It looks slightly damaged.")
		if(25 to 50)
			. += span_info("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")

/obj/item/shield/proc/shatter()
	var/turf/T = get_turf(src)
	T.visible_message(span_warning("[src] is destroyed!"))
	playsound(src, shield_break_sound, 100)
	qdel(src)

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	item_flags = SLOWS_WHILE_IN_HAND | ISWEAPON
	slowdown = 2
	canblock = TRUE
	block_power = 50
	max_integrity = 300
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/glass=7500, /datum/material/iron=1000)
	attack_verb_continuous = list("shoves", "bashes")
	attack_verb_simple = list("shove", "bash")
	var/cooldown = 0 //shield bash cooldown. based on world.time
	transparent = TRUE
	custom_price = 100

/obj/item/shield/riot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet/mineral/titanium))
		if (atom_integrity >= max_integrity)
			to_chat(user, span_notice("[src] is already in perfect condition."))
		else
			var/obj/item/stack/sheet/mineral/titanium/T = W
			T.use(1)
			atom_integrity = max_integrity
			to_chat(user, span_notice("You repair [src] with [T]."))
	else
		return ..()

/obj/item/shield/riot/roman
	name = "\improper Roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	inhand_icon_state = "roman_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	transparent = FALSE
	custom_materials = list(/datum/material/iron=8500)
	max_integrity = 250
	shield_break_sound = 'sound/effects/grillehit.ogg'

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	item_flags = ISWEAPON
	slowdown = null
	block_power = 0
	max_integrity = 80

/obj/item/shield/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	inhand_icon_state = "buckler"
	canblock = TRUE

	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 10)
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_NORMAL
	shield_break_sound = 'sound/effects/bang.ogg'

/obj/item/shield/goliath
	name = "Goliath shield"
	desc = "A shield made from interwoven plates of goliath hide."
	icon_state = "goliath_shield"
	inhand_icon_state = "goliath_shield"
	canblock = TRUE
	block_power = 50
	max_integrity = 200

	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	custom_materials = null
	shield_break_sound = 'sound/effects/bang.ogg'

/obj/item/shield/riot/flash
	name = "strobe shield"
	desc = "A shield with a built in, high intensity light capable of blinding and disorienting suspects. Takes regular handheld flashes as bulbs."
	icon_state = "flashshield"
	inhand_icon_state = "flashshield"
	var/obj/item/assembly/flash/handheld/embedded_flash

/obj/item/shield/riot/flash/Initialize(mapload)
	. = ..()
	embedded_flash = new(src)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/shield/riot/flash/attack(mob/living/M, mob/user)
	. =  embedded_flash.attack(M, user)
	update_icon()

/obj/item/shield/riot/flash/attack_self(mob/living/carbon/user)
	. = embedded_flash.attack_self(user)
	update_icon()

/obj/item/shield/riot/flash/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if (. && !embedded_flash.burnt_out)
		INVOKE_ASYNC(embedded_flash, TYPE_PROC_REF(/obj/item/assembly/flash/handheld, activate))
		update_icon()


/obj/item/shield/riot/flash/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/flash = W
		if(flash.burnt_out)
			to_chat(user, "No sense replacing it with a broken bulb.")
			return
		else
			to_chat(user, "You begin to replace the bulb.")
			if(do_after(user, 20, target = user))
				if(flash.burnt_out || !flash || QDELETED(flash))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				qdel(embedded_flash)
				embedded_flash = flash
				flash.forceMove(src)
				update_icon()
				return
	..()

/obj/item/shield/riot/flash/emp_act(severity)
	. = ..()
	embedded_flash.emp_act(severity)
	update_icon()

/obj/item/shield/riot/flash/update_icon_state()
	if(!embedded_flash || embedded_flash.burnt_out)
		icon_state = "riot"
		inhand_icon_state = "riot"
	else
		icon_state = "flashshield"
		inhand_icon_state = "flashshield"
	return ..()

/obj/item/shield/riot/flash/examine(mob/user)
	. = ..()
	if (embedded_flash?.burnt_out)
		. += span_info("The mounted bulb has burnt out. You can try replacing it with a new one.")

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "An advanced hard-light shield. It can be retracted, expanded, and stored anywhere, but can't take much punishment before needing a reset"
	icon_state = "eshield"
	inhand_icon_state = "eshield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("shoves", "bashes")
	attack_verb_simple = list("shove", "bash")
	throw_range = 5
	force = 3
	throwforce = 3
	throw_speed = 3
	max_integrity = 50
	block_sound = 'sound/weapons/egloves.ogg'
	block_flags = BLOCKING_PROJECTILE | BLOCKING_UNBLOCKABLE
	block_power = 100 //Easily broken, but absorb the full impact of the blow.
	is_energy_shield = TRUE //Prevents the shield from being disarmed in the event the holder takes stamina damage somehow
	/// Force of the shield when active.
	var/active_force = 10
	/// Throwforce of the shield when active.
	var/active_throwforce = 8
	/// Throwspeed of ethe shield when active.
	var/active_throw_speed = 2
	/// Whether clumsy people can transform this without side effects.
	var/can_clumsy_use = FALSE

	var/recharging = FALSE
	var/cooldown_duration = 10 SECONDS

	shield_break_sound = 'sound/effects/turbolift/turbolift-close.ogg'

/obj/item/shield/energy/shatter()
	if(!recharging) //This should never be possible but just in case
		attack_self()
		recharging = TRUE
		playsound(src, shield_break_sound, 200, 1)
		addtimer(CALLBACK(src, PROC_REF(recharged)), cooldown_duration)

/obj/item/shield/energy/proc/recharged()
	recharging = FALSE
	atom_integrity = max_integrity
	playsound(src, 'sound/machines/ping.ogg', 85, 1)

/obj/item/shield/energy/attack_self(mob/user, modifiers)
	if(recharging == TRUE)
		playsound(src, shield_break_sound, 200, 1)
		return
	. = ..()

/obj/item/shield/energy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = active_force, \
		throwforce_on = active_throwforce, \
		throw_speed_on = active_throw_speed, \
		hitsound_on = hitsound, \
		clumsy_check = !can_clumsy_use)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/shield/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		if(isprojectile(hitby))
			var/obj/projectile/P = hitby
			if(P.reflectable)
				P.firer = src
				P.set_angle(get_dir(owner, hitby))
				return 1
		return ..()
	return FALSE

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 */
/obj/item/shield/energy/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	if(user)
		balloon_alert(user, active ? "activated" : "deactivated")
	playsound(src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 35, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon_state = "teleriot"
	worn_icon_state = "teleriot"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	block_power = 25
	max_integrity =  120
	slowdown = 0
	item_flags = ISWEAPON

/obj/item/shield/riot/tele/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = 5, \
		throwforce_on = 5, \
		throw_speed_on = 2, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_BULKY, \
		attack_verb_continuous_on = list("smacks", "strikes", "cracks", "beats"), \
		attack_verb_simple_on = list("smack", "strike", "crack", "beat"))
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/shield/riot/tele/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return ..()
	return FALSE

/**
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Allows it to be placed on back slot when active.
 */
/obj/item/shield/riot/tele/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	slot_flags = active ? ITEM_SLOT_BACK : null
	if(user)
		balloon_alert(user, active ? "extended" : "collapsed")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE
