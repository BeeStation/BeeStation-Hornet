/obj/item/melee/baton
	name = "stun baton"
	desc = "A stun baton which uses localised electrical shocks to cause muscular fatigue."
	icon_state = "stunbaton"
	item_state = "baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 8
	throwforce = 7
	w_class = WEIGHT_CLASS_LARGE
	item_flags = ISWEAPON
	attack_verb = list("enforced the law upon")
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 80, ACID = 80, STAMINA = 0)

	var/stunforce = 75
	var/turned_on = FALSE
	var/obj/item/stock_parts/cell/cell
	var/hitcost = 1000
	var/throw_hit_chance = 35
	var/preload_cell_type //if not empty the baton starts with this type of cell

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return FIRELOSS

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
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
	if(turned_on && prob(throw_hit_chance) && iscarbon(hit_atom))
		baton_stun(hit_atom)

/obj/item/melee/baton/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(cell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = cell.use(chrgdeductamt)
		if(turned_on && cell.charge < hitcost)
			//we're below minimum, turn off
			turned_on = FALSE
			update_icon()
			playsound(src, "sparks", 75, TRUE, -1)


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
		. += "<span class='notice'>\The [src] is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>\The [src] does not have a power source installed.</span>"

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			balloon_alert(user, "[src] already has a cell.")
		else
			if(C.maxcharge < hitcost)
				balloon_alert(user, "[src] requires a higher capacity power cell.")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			balloon_alert(user, "You insert the power cell.")
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(src))
			cell = null
			balloon_alert(user, "You remove the power cell.")
			turned_on = FALSE
			update_icon()
	else
		return ..()

/obj/item/melee/baton/attack_self(mob/user)
	if(cell && cell.charge > hitcost && !(obj_flags & OBJ_EMPED))
		turned_on = !turned_on
		balloon_alert(user, "[src] [turned_on ? "on" : "off"]")
		playsound(src, "sparks", 75, TRUE, -1)
	else
		turned_on = FALSE
		if(!cell)
			balloon_alert(user, "It has no power source!")
		else if(obj_flags & OBJ_EMPED)
			balloon_alert(user, "It's not responding!")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(turned_on && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && !(obj_flags & OBJ_EMPED))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src], electrocuting themselves badly!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src], electrocuting yourself badly!</span>")
		user.adjustStaminaLoss(stunforce*3)
		user.stuttering = 20
		user.do_jitter_animation(20)
		deductcharge(hitcost)
		return

	if(iscyborg(M))
		return ..()


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(check_martial_counter(L, user))
			return

	if(user.a_intent != INTENT_HARM)
		if(turned_on)
			if(baton_stun(M, user))
				user.do_attack_animation(M)
				return
		else
			M.visible_message("<span class='warning'>[user] has prodded [M] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
	else
		if(turned_on)
			baton_stun(M, user)
		return ..()

/obj/item/melee/baton/proc/baton_stun(mob/living/target, mob/living/user)
	if(obj_flags & OBJ_EMPED)
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(H, 'sound/weapons/genhit.ogg', 50, TRUE)
			return FALSE
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return FALSE
	else
		if(!deductcharge(hitcost))
			return FALSE

	var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.get_combat_bodyzone(target)))
	var/armor_block = target.run_armor_check(affecting, STAMINA)
	// L.adjustStaminaLoss(stunforce)
	target.apply_damage(stunforce, STAMINA, affecting, armor_block)
	target.apply_effect(EFFECT_STUTTER, stunforce)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK) //Only used for nanites
	target.stuttering = 20
	target.do_jitter_animation(20)
	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.visible_message("<span class='danger'>[user] has electrocuted [target] with [src]!</span>", \
								"<span class='userdanger'>[user] has electrocuted you with [src]!</span>")
		log_combat(user, target, "stunned")

	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)

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

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	stunforce = 70
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = ITEM_SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = 0

/obj/item/melee/baton/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/baton_stun()
	if(obj_flags & OBJ_EMPED)
		return FALSE
	if(sparkler.activate())
		..()

/obj/item/melee/baton/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()
