/obj/item/melee/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch."
	icon_state = "powerfist"
	inhand_icon_state = "powerfist"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	attack_verb_continuous = list("whacks", "fists", "power-punches")
	attack_verb_simple = list("whack", "fist", "power-punch")
	force = 20
	attack_weight = 1
	throwforce = 10
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = ISWEAPON
	armor_type = /datum/armor/melee_powerfist
	resistance_flags = FIRE_PROOF
	var/click_delay = 1.5
	var/fisto_setting = 1
	var/gasperfist = 3
	var/obj/item/tank/internals/tank = null //Tank used for the gauntlet's piston-ram.
	var/baseforce = 20



/datum/armor/melee_powerfist
	fire = 100
	acid = 40

/obj/item/melee/powerfist/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += span_notice("You'll need to get closer to see any more.")
		return
	if(tank)
		. += span_notice("[icon2html(tank, user)] It has \a [tank] mounted onto it.")
		. += span_notice("Its pressure gauge reads [round(tank.air_contents.total_moles(), 0.01)] mol at [round(tank.air_contents.return_pressure(),0.01)] kPa.")


/obj/item/melee/powerfist/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals))
		if(!tank)
			var/obj/item/tank/internals/IT = W
			if(IT.volume <= 3)
				to_chat(user, span_warning("\The [IT] is too small for \the [src]."))
				return
			updateTank(W, 0, user)
	else if(W.tool_behaviour == TOOL_WRENCH)
		switch(fisto_setting)
			if(1)
				fisto_setting = 2
			if(2)
				fisto_setting = 3
			if(3)
				fisto_setting = 1
		W.play_tool_sound(src)
		to_chat(user, span_notice("You tweak \the [src]'s piston valve to [fisto_setting]."))
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(tank)
			updateTank(tank, 1, user)

/obj/item/melee/powerfist/proc/updateTank(obj/item/tank/internals/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user, span_notice("\The [src] currently has no tank attached to it."))
			return
		to_chat(user, span_notice("You detach \the [thetank] from \the [src]."))
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, span_warning("\The [src] already has a tank."))
			return
		if(!user.transferItemToLoc(thetank, src))
			return
		to_chat(user, span_notice("You hook \the [thetank] up to \the [src]."))
		tank = thetank


/obj/item/melee/powerfist/attack(mob/living/target, mob/living/user)
	if(!tank)
		to_chat(user, span_warning("\The [src] can't operate without a source of gas!"))
		return
	var/datum/gas_mixture/gasused = tank.remove_air(gasperfist * fisto_setting)
	var/turf/T = get_turf(src)
	if(!T)
		return
	if(!gasused)
		to_chat(user, span_warning("\The [src]'s tank is empty!"))
		force = (baseforce / 5)
		attack_weight = 1
		playsound(loc, 'sound/weapons/punch1.ogg', 50, 1)
		target.visible_message(span_danger("[user]'s powerfist lets out a dull thunk as [user.p_they()] punch[user.p_es()] [target.name]!"), \
			span_userdanger("[user]'s punches you!"))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.check_shields(src, force))
				return
		return ..()
	if(!molar_cmp_equals(gasused.total_moles(), gasperfist * fisto_setting))
		T.assume_air(gasused)
		to_chat(user, span_warning("\The [src]'s piston-ram lets out a weak hiss, it needs more gas!"))
		playsound(loc, 'sound/weapons/punch4.ogg', 50, 1)
		force = (baseforce / 2)
		attack_weight = 1
		target.visible_message(span_danger("[user]'s powerfist lets out a weak hiss as [user.p_they()] punch[user.p_es()] [target.name]!"), \
			span_userdanger("[user]'s punch strikes with force!"), ignored_mobs = list(user))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.check_shields(src, force))
				return
		return ..()
	force = (baseforce * fisto_setting)
	attack_weight = fisto_setting
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, force))
			T.assume_air(gasused)
			return
	target.visible_message(span_danger("[user]'s powerfist lets out a loud hiss as [user.p_they()] punch[user.p_es()] [target.name]!"), \
		span_userdanger("You cry out in pain as [user]'s punch flings you backwards!"), ignored_mobs = list(user))
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, TRUE)

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

	target.throw_at(throw_target, 5 * fisto_setting, 0.5 + (fisto_setting / 2))

	log_combat(user, target, "power fisted", src)

	user.changeNext_move(CLICK_CD_MELEE * click_delay)

	T.assume_air(gasused)
	T.air_update_turf(FALSE, FALSE)

	return ..()
