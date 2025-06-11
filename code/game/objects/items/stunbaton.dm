/obj/item/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	desc_controls = "Left click to stun, right click to baton shove."

	icon_state = "stunbaton"
	item_state = "baton"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'

	force = 8
	attack_verb_continuous = list("beats")
	attack_verb_simple = list("beat")

	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BELT
	item_flags = ISWEAPON
	armor_type = /datum/armor/melee_baton

	throwforce = 7
	var/throw_stun_chance = 35

	var/obj/item/stock_parts/cell/cell
	var/preload_cell_type //if not empty the baton starts with this type of cell
	var/cell_hit_cost = 1000
	var/can_remove_cell = TRUE

	var/turned_on = FALSE
	var/activate_sound = "sparks"

	var/stun_sound = 'sound/weapons/egloves.ogg'

	var/stutter_amt = 20
	var/stamina_loss_amt = 60
	var/stun_time = 4 SECONDS

/datum/armor/melee_baton
	bomb = 50
	fire = 80
	acid = 80

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/user)
	if(cell?.charge && turned_on)
		user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		. = (FIRELOSS)
		attack(user,user)
	else
		user.visible_message("<span class='suicide'>[user] is shoving the [name] down their throat! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		. = (OXYLOSS)

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	// Adding an extra break for the sake of presentation
	if(stamina_loss_amt != 0)
		offensive_notes = "\nVarious interviewed security forces report being able to beat criminals into exhaustion with only <span class='warning'>[round(100 / stamina_loss_amt, 0.1)] hit\s!</span>"
	if(preload_cell_type)
		if(!ispath(preload_cell_type,/obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	update_icon()


/obj/item/melee/baton/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/item/melee/baton/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		turned_on = FALSE
		update_icon()
	return ..()


/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	//Only mob/living types have stun handling
	if(turned_on && prob(throw_stun_chance) && iscarbon(hit_atom))
		baton_effect(hit_atom, throwingdatum.thrower)

/obj/item/melee/baton/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(cell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = cell.use(chrgdeductamt)
		if(turned_on && cell.charge < cell_hit_cost)
			//we're below minimum, turn off
			turned_on = FALSE
			update_icon()
			playsound(src, activate_sound, 75, TRUE, -1)


/obj/item/melee/baton/update_icon_state()
	if(obj_flags & OBJ_EMPED)
		icon_state = "[initial(icon_state)]"
	else if(turned_on)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("\The [src] is [round(cell.percent())]% charged.")
	else
		. += span_warning("\The [src] does not have a power source installed.")

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			balloon_alert(user, "[src] already has a cell.")
		else
			if(C.maxcharge < cell_hit_cost)
				balloon_alert(user, "[src] requires a higher capacity power cell.")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			balloon_alert(user, "You insert the power cell.")
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		tryremovecell(user)
	else
		return ..()

/obj/item/melee/baton/proc/tryremovecell(mob/user)
	if(cell && can_remove_cell)
		cell.update_icon()
		cell.forceMove(get_turf(src))
		cell = null
		balloon_alert(user, "You remove the power cell.")
		turned_on = FALSE
		update_icon()

/obj/item/melee/baton/attack_self(mob/user)
	toggle_on(user)

/obj/item/melee/baton/proc/toggle_on(mob/user)
	if((cell && cell.charge > cell_hit_cost) && !(obj_flags & OBJ_EMPED))
		turned_on = !turned_on
		balloon_alert(user, "You turn [src] [turned_on ? "on" : "off"].")
		playsound(src, activate_sound, 75, TRUE, -1)
	else
		turned_on = FALSE
		if(!cell)
			balloon_alert(user, "It has no power source!")
		else if(obj_flags & OBJ_EMPED)
			balloon_alert(user, "It's not responding!")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/proc/clumsy_check(mob/living/carbon/human/user)
	if(turned_on && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && !(obj_flags & OBJ_EMPED))
		playsound(src, stun_sound, 75, TRUE, -1)
		user.visible_message(span_danger("[user] accidentally hits [user.p_them()]self with [src], electrocuting themselves badly!"), \
							span_userdanger("You accidentally hit yourself with [src], electrocuting yourself badly!"))
		user.adjustStaminaLoss(stun_time*3)
		user.stuttering = stutter_amt
		user.do_jitter_animation(20)
		deductcharge(cell_hit_cost)
		return TRUE
	return FALSE

/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user, params)
	if(clumsy_check(user))
		return FALSE

	if(iscyborg(M))
		return ..()


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(check_martial_counter(L, user))
			return

	if(!user.combat_mode)
		if(turned_on)
			if(baton_effect(M, user, params))
				user.do_attack_animation(M)
				return
		else
			M.visible_message(span_warning("[user] has prodded [M] with [src]. Luckily it was off."), \
							span_warning("[user] has prodded you with [src]. Luckily it was off"))
	else
		if(turned_on)
			baton_effect(M, user, params)
		return ..()

/obj/item/melee/baton/proc/baton_effect(mob/living/target, mob/living/user, params)
	if(obj_flags & OBJ_EMPED)
		return FALSE
	if(shields_blocked(target, user))
		return FALSE
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(cell_hit_cost))
			return FALSE
	else
		if(!deductcharge(cell_hit_cost))
			return FALSE

	var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.get_combat_bodyzone(target)))
	var/armor_block = target.run_armor_check(affecting, STAMINA)
	// L.adjustStaminaLoss(stun_time)
	target.apply_damage(stun_time, STAMINA, affecting, armor_block)
	target.apply_effect(EFFECT_STUTTER, stun_time)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	target.stuttering = 20

	// Shoving
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/shove_dir = get_dir(user.loc, target.loc)
		var/turf/target_shove_turf = get_step(target.loc, shove_dir)
		var/mob/living/carbon/human/target_collateral_human = locate(/mob/living/carbon) in target_shove_turf.contents
		if (target_collateral_human && target_shove_turf != get_turf(user))
			target.Knockdown(0.5 SECONDS)
			target_collateral_human.Knockdown(0.5 SECONDS)
		target.Move(target_shove_turf, shove_dir)

	target.do_stun_animation()

	if (target.getStaminaLoss() > target.getMaxHealth() - HEALTH_THRESHOLD_CRIT)
		target.emote("scream")

	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.visible_message(span_danger("[user] has electrocuted [target] with [src]!"), \
								span_userdanger("[user] has electrocuted you with [src]!"))
		log_combat(user, target, "stunned", src)

	playsound(src, stun_sound, 50, TRUE, -1)

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.force_say(user)


	return 1

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF) && !(obj_flags & OBJ_EMPED))
		obj_flags |= OBJ_EMPED
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(emp_reset)), rand(1, 200 / severity))
		playsound(src, 'sound/machines/capacitor_discharge.ogg', 60, TRUE)

/obj/item/melee/baton/proc/emp_reset()
	obj_flags &= ~OBJ_EMPED
	update_icon()
	playsound(src, 'sound/machines/capacitor_charge.ogg', 100, TRUE)

/obj/item/melee/baton/proc/shields_blocked(mob/living/target, mob/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(H, 'sound/weapons/genhit.ogg', 50, TRUE)
			return TRUE
	return FALSE

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	stun_time = 4 SECONDS
	cell_hit_cost = 2000
	throw_stun_chance = 10
	slot_flags = ITEM_SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = 0

/obj/item/melee/baton/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/baton_effect()
	if(obj_flags & OBJ_EMPED)
		return FALSE
	if(sparkler.activate())
		..()

/obj/item/melee/baton/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()
