/obj/item/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	item_state = "inducer-engi"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 7
	var/powertransfer = 1000
	var/opened = FALSE
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/recharging = FALSE

/obj/item/inducer/Initialize()
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type

/obj/item/inducer/proc/induce(obj/item/stock_parts/cell/target, coefficient)
	var/totransfer = min(cell.charge,(powertransfer * coefficient))
	var/transferred = target.give(totransfer)
	cell.use(transferred)
	cell.update_icon()
	target.update_icon()

/obj/item/inducer/get_cell()
	return cell

/obj/item/inducer/emp_act(severity)
	. = ..()
	if(cell && !(. & EMP_PROTECT_CONTENTS))
		cell.emp_act(severity)

/obj/item/inducer/attack_obj(obj/O, mob/living/carbon/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(O, user))
		return

	return ..()

/obj/item/inducer/proc/cantbeused(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use [src]!</span>")
		return TRUE

	if(!cell)
		to_chat(user, "<span class='warning'>[src] doesn't have a power cell installed!</span>")
		return TRUE

	if(!cell.charge)
		to_chat(user, "<span class='warning'>[src]'s battery is dead!</span>")
		return TRUE
	return FALSE


/obj/item/inducer/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		W.play_tool_sound(src)
		if(!opened)
			to_chat(user, "<span class='notice'>You unscrew the battery compartment.</span>")
			opened = TRUE
			update_icon()
			return
		else
			to_chat(user, "<span class='notice'>You close the battery compartment.</span>")
			opened = FALSE
			update_icon()
			return
	if(istype(W, /obj/item/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
				cell = W
				update_icon()
				return
			else
				to_chat(user, "<span class='notice'>[src] already has \a [cell] installed!</span>")
				return

	if(cantbeused(user))
		return

	if(recharge(W, user))
		return

	return ..()

/obj/item/inducer/proc/recharge(atom/movable/A, mob/user)
	if(!isturf(A) && user.loc == A)
		return FALSE
	if(recharging)
		return TRUE
	else
		recharging = TRUE
	var/obj/item/stock_parts/cell/C = A.get_cell()
	var/obj/O
	var/coefficient = 1
	if(istype(A, /obj/item/gun/energy))
		if (obj_flags & EMAGGED)		
			coefficient = 50/powertransfer //always charge 5% of power cell, so that guns take 10 seconds to recharge, making it effectively pointless in combat
		else
			to_chat(user,"Error unable to interface with device")
			return FALSE
	if(istype(A, /obj))
		O = A
	if(C)
		var/done_any = FALSE
		if(C.charge >= C.maxcharge)
			if(!(obj_flags & EMAGGED))
				to_chat(user, "<span class='notice'>[A] is fully charged!</span>")
				recharging = FALSE
				return TRUE
		user.visible_message("[user] starts recharging [A] with [src].","<span class='notice'>You start recharging [A] with [src].</span>")
		var/continue = TRUE
		while(continue)
			if(do_after(user, 10, target = user) && cell.charge)
				done_any = TRUE
				if(!O || !C)
					continue = FALSE
				else if(C.charge < C.maxcharge)
					induce(C, coefficient)					
				else if(obj_flags & EMAGGED)
					var/burndamage = min(cell.charge,powertransfer)
					cell.use(burndamage)
					cell.update_icon()
					O.take_damage(burndamage/10, BURN, "energy")
					user.visible_message("<span class='warning'>You overcharge the [O].</span>")
				else
					continue = FALSE
					
				if (continue)
					O.update_icon()
					do_sparks(1, FALSE, A)
					if (powertransfer>1000)
						var/mob/living/carbon/human = user
						if (human.electrocute_act( (powertransfer-1000)/400,human,stun = TRUE))
							continue = FALSE
			else
				continue = FALSE
		if(done_any) // Only show a message if we succeeded at least once
			user.visible_message("[user] recharged [A]!","<span class='notice'>You recharged [A]!</span>")
		recharging = FALSE
		return TRUE
	recharging = FALSE

/obj/item/inducer/proc/do_harm(mob/living/carbon/victim, mob/living/user)	//maybe a good idea to leave this out?
	if(recharging)
		return FALSE	
	var/tesla_strength = min(cell.charge,powertransfer)
	cell.use(tesla_strength)
	cell.update_icon()
	
	do_sparks(1, TRUE, victim)
	log_combat(user, victim, " stunned ", src)
	victim.electrocute_act(3 + 5 * tesla_strength/600,user,stun = FALSE,override = TRUE)
	victim.Knockdown(10 * tesla_strength/5000)

/obj/item/inducer/attack(mob/M, mob/user)
	if(cantbeused(user))
		return
		
	if(user.a_intent == INTENT_HARM && (obj_flags & EMAGGED))	
		if (istype(M, /mob/living/carbon) && do_harm(M,user))
			return ..()

	if(recharge(M, user))
		return
	return ..()


/obj/item/inducer/attack_self(mob/user)
	if(opened && cell)
		user.visible_message("[user] removes [cell] from [src]!","<span class='notice'>You remove [cell].</span>")
		cell.update_icon()
		user.put_in_hands(cell)
		cell = null
		update_icon()


/obj/item/inducer/examine(mob/living/M)
	. = ..()
	if(cell)
		. += "<span class='notice'>Its display shows: [DisplayEnergy(cell.charge)].</span>"
	else
		. += "<span class='notice'>Its display is dark.</span>"
	if(opened)
		. += "<span class='notice'>Its battery compartment is open.</span>"

/obj/item/inducer/update_icon()
	cut_overlays()
	if(opened)
		if(!cell)
			add_overlay("inducer-nobat")
		else
			add_overlay("inducer-bat")

obj/item/inducer/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='notice'>You short circuit the [src]!</span>")
	Emag()

/obj/item/inducer/proc/Emag()
	obj_flags ^= EMAGGED
	playsound(src.loc, "sparks", 100, 1)
	if(obj_flags & EMAGGED)
		name = "shortcircuited [initial(name)]"
		force = 0
	else
		name = initial(name)

/obj/item/inducer/sci
	icon_state = "inducer-sci"
	item_state = "inducer-sci"
	desc = "A tool for inductively charging internal power cells. This one has a science color scheme, and is less potent than its engineering counterpart."
	cell_type = null
	powertransfer = 500
	opened = TRUE

/obj/item/inducer/sci/Initialize()
	. = ..()
	update_icon()

/obj/item/inducer/super
	name = "super inducer"
	desc = "A tool for inductively charging internal power cells. This one has a warning label on it, reading 'wear insulated gloves'."
	powertransfer = 2000
	cell_type = null
	opened = TRUE