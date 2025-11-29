/obj/item/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	desc_controls = "Left click to stun, right click to baton shove."

	icon_state = "stunbaton"
	inhand_icon_state = "baton"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'

	force = 8 				//BRUTE when off
	var/active_force = 40 	//STAMINA when on
	damtype = BRUTE 		//becomes STAMINA when turned on, and is used to track whether the baton is off or on

	block_flags = BLOCKING_EFFORTLESS

	attack_verb_continuous = list("beats")
	attack_verb_simple = list("beat")

	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BELT
	item_flags = ISWEAPON
	armor_type = /datum/armor/melee_baton
	custom_price = 100
	hitsound = 'sound/effects/woodhit.ogg' //Smack

	var/obj/item/stock_parts/cell/cell
	var/preload_cell_type //if not empty the baton starts with this type of cell
	var/cell_hit_cost = 10 KILOWATT
	var/can_remove_cell = TRUE
	var/activate_sound = "sparks"
	var/active_hitsound = 'sound/weapons/egloves.ogg' //ZZZT

/datum/armor/melee_baton
	bomb = 50
	fire = 80
	acid = 80

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/living/user)
	if(damtype == STAMINA)
		user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		. = (FIRELOSS)
		user.electrocute_act(200, "suicide by stun baton", 1, SHOCK_NOGLOVES)
	else
		user.visible_message(span_suicide("[user] is shoving the [name] down their throat! It looks like [user.p_theyre()] trying to commit suicide!"))
		. = (OXYLOSS)

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = active_force, \
		hitsound_on = active_hitsound, \
		w_class_on = w_class, \
		attack_verb_continuous_on = list("beats"), \
		attack_verb_simple_on = list("beat"), \
		inhand_icon_change = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

	if(active_force != 0)
		offensive_notes = "\nVarious interviewed security forces report being able to beat criminals into exhaustion with only [span_warning("[round(100 / active_force, 0.1)] hit\s!")]"
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
		if(damtype == STAMINA)
			attack_self()
		update_icon()
	return ..()

/obj/item/melee/baton/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	if(user) //In case the baton is thrown and fully depletes, it will have no user
		balloon_alert(user, active ? "activated" : "deactivated")

	if(active)
		playsound(src, activate_sound, 75, TRUE)
		damtype = STAMINA
	else
		damtype = BRUTE

	update_icon()
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	//Only a 35% success chance if you throw it
	if(damtype == STAMINA && prob(65))
		attack_self()
	return ..()

/obj/item/melee/baton/attack_self(mob/user)
	//Always allow it to be turned off if it is on, this proc is how the baton turns off when depleted.
	if(damtype == STAMINA)
		return ..()

	if(cell?.charge < cell_hit_cost)
		balloon_alert(user, "It has no power!")
		return FALSE

	else if(obj_flags & OBJ_EMPED)
		balloon_alert(user, "It's not responding!")
		return FALSE

	//It has enough charge and hasn't been hit with an EMP, so turn it on.
	return ..()

///Check if there is enough remaining charge to attack with, and turn it off if not
/obj/item/melee/baton/proc/check_charge()
	if(isnull(cell) || cell.charge < cell_hit_cost)
		if(damtype == STAMINA)
			attack_self() //turn it off if there isn't enough

/obj/item/melee/baton/update_icon_state()
	if(obj_flags & OBJ_EMPED)
		icon_state = "[initial(icon_state)]"
	else if(damtype == STAMINA)
		icon_state = "[initial(icon_state)]_on"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("\The [src] has [floor(cell.charge / cell_hit_cost)] remaining uses.")
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
		if(damtype == STAMINA)
			attack_self()
		update_icon()

/obj/item/melee/baton/attack(mob/living/target, mob/living/user, params)
	//Clumsy gives a 50% chance to hit themselves if the baton is on
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && !(obj_flags & OBJ_EMPED) && damtype == STAMINA)
		target = user

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(check_martial_counter(human_target, user))
			return FALSE

	//Drain the cell regardless of attack success
	if(damtype == STAMINA)
		cell.use(cell_hit_cost)

	//Proceed with the attack chain
	. = ..()

	//After the attack chain has resolved, check if the baton should turn itself off
	check_charge()

	return .

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if(cell)
		cell.use(cell.charge)
		check_charge()

//This one starts with a cell pre-installed.
/obj/item/melee/baton/loaded
	preload_cell_type = /obj/item/stock_parts/cell/high

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	inhand_icon_state = "prod"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	cell_hit_cost = 20 KILOWATT
	slot_flags = ITEM_SLOT_BACK
	var/obj/item/assembly/igniter/sparkler
	custom_price = 25

/obj/item/melee/baton/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/attack(mob/target, mob/living/carbon/human/user, params)
	if(damtype == STAMINA)
		sparkler.activate()
	return ..()


/obj/item/melee/baton/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()
