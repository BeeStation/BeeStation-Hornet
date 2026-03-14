
/************************
* PORTABLE TURRET COVER *
************************/

/obj/machinery/porta_turret_cover
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	layer = HIGH_OBJ_LAYER
	density = FALSE
	max_integrity = 80
	var/obj/machinery/porta_turret/parent_turret = null

/obj/machinery/porta_turret_cover/Destroy()
	if(parent_turret)
		parent_turret.cover = null
		parent_turret.invisibility = 0
		parent_turret = null
	return ..()

//The below code is pretty much just recoded from the initial turret object. It's necessary but uncommented because it's exactly the same!
//>necessary
//I'm not fixing it because i'm fucking bored of this code already, but someone should just reroute these to the parent turret's procs.

/obj/machinery/porta_turret_cover/attack_silicon(mob/user)
	. = ..()
	if(.)
		return

	return parent_turret.attack_ai(user)

/obj/machinery/porta_turret_cover/attack_hand(mob/user, list/modifiers)
	return ..() || parent_turret.attack_hand(user, modifiers)


/obj/machinery/porta_turret_cover/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && !parent_turret.on)
		if(parent_turret.raised)
			return
		if(!parent_turret.anchored)
			parent_turret.set_anchored(TRUE)
			to_chat(user, span_notice("You secure the exterior bolts on the turret."))
			parent_turret.invisibility = 0
			parent_turret.update_appearance()
		else
			parent_turret.set_anchored(FALSE)
			to_chat(user, span_notice("You unsecure the exterior bolts on the turret."))
			parent_turret.invisibility = INVISIBILITY_MAXIMUM
			parent_turret.update_appearance()
			qdel(src)
		return

	if(I.GetID())
		if(parent_turret.allowed(user))
			parent_turret.locked = !parent_turret.locked
			to_chat(user, span_notice("Controls are now [parent_turret.locked ? "locked" : "unlocked"]."))
			updateUsrDialog()
		else
			to_chat(user, span_notice("Access denied."))
	else
		return ..()

REGISTER_BUFFER_HANDLER(/obj/machinery/porta_turret_cover)

DEFINE_BUFFER_HANDLER(/obj/machinery/porta_turret_cover)
	if (TRY_STORE_IN_BUFFER(buffer_parent, parent_turret))
		to_chat(user, span_notice("You add [parent_turret] to multitool buffer."))
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/porta_turret_cover/attacked_by(obj/item/I, mob/user)
	parent_turret.attacked_by(I, user)

/obj/machinery/porta_turret_cover/attack_alien(mob/living/carbon/alien/humanoid/user)
	parent_turret.attack_alien(user)

/obj/machinery/porta_turret_cover/attack_animal(mob/living/simple_animal/user)
	parent_turret.attack_animal(user)

/obj/machinery/porta_turret_cover/attack_hulk(mob/living/carbon/human/user)
	return parent_turret.attack_hulk(user)

/obj/machinery/porta_turret_cover/can_be_overridden()
	. = 0

/obj/machinery/porta_turret_cover/should_emag(mob/user)
	return parent_turret.should_emag(user)

/obj/machinery/porta_turret_cover/on_emag(mob/user)
	..()
	parent_turret.obj_flags |= EMAGGED
	to_chat(user, span_notice("You short out [parent_turret]'s threat assessment circuits."))
	visible_message("[parent_turret] hums oddly...")
	parent_turret.on = FALSE
	addtimer(VARSET_CALLBACK(parent_turret, on, TRUE), 40)
