/obj/item/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=100)
	throwforce = 2
	throw_speed = 3
	throw_range = 7
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

	var/is_position_sensitive = FALSE	//set to true if the device has different icons for each position.
										//This will prevent things such as visible lasers from facing the incorrect direction when transformed by assembly_holder's update_icon()
	var/assembly_flags = NONE
	var/secured = TRUE
	var/list/attached_overlays = null
	var/obj/item/assembly_holder/holder = null
	var/obj/structure/reagent_dispensers/rig = null
	var/attachable = FALSE // can this be attached to wires
	var/datum/wires/connected = null
	var/next_activate = 0 //When we're next allowed to activate - for spam control

/obj/item/assembly/Destroy()
	holder = null
	return ..()

/obj/item/assembly/get_part_rating()
	return 1
/**
 * on_attach: Called when attached to a holder, wiring datum, or other special assembly
 *
 * Will also be called if the assembly holder is attached to a plasma (internals) tank or welding fuel (dispenser) tank.
 */

/obj/item/assembly/proc/on_attach(var/obj/structure/reagent_dispensers/T)
	if(!holder && connected)
		holder = connected.holder
	if(T)
		rig = T

/**
 * on_detach: Called when removed from an assembly holder or wiring datum
 */
/obj/item/assembly/proc/on_detach()
	if(connected)
		connected = null
	if(!holder)
		return FALSE
	forceMove(holder.drop_location())
	holder = null
	return TRUE

/**
 * holder_movement: Called when the assembly's holder detects movement
 */
/obj/item/assembly/proc/holder_movement()
	if(!holder)
		return FALSE
	setDir(holder.dir)
	return TRUE

/obj/item/assembly/proc/is_secured(mob/user)
	if(!secured)
		to_chat(user, "<span class='warning'>The [name] is unsecured!</span>")
		return FALSE
	return TRUE


//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
/obj/item/assembly/proc/pulsed(mob/pulser)
	INVOKE_ASYNC(src, PROC_REF(activate), pulser)
	SEND_SIGNAL(src, COMSIG_ASSEMBLY_PULSED)
	return TRUE


//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
/obj/item/assembly/proc/pulse(radio = FALSE)
	if(connected) // if we have connected wires and are a pulsing assembly, pulse it
		connected.pulse_assembly(src)
	else if(holder) // otherwise if we're attached to a holder, process the activation of it with our flags
		holder.process_activation(src)
	return TRUE


// What the device does when turned on
/obj/item/assembly/proc/activate(mob/activator)
	if(QDELETED(src) || !secured || (next_activate > world.time))
		return FALSE
	next_activate = world.time + 30
	return TRUE


/obj/item/assembly/proc/toggle_secure()
	secured = !secured
	update_appearance()
	return secured

// This is overwritten so that clumsy people can set off mousetraps even when in a holder.
// We are not going deeper than that however (won't set off if in a tank bomb or anything with wires)
// That would need to be added to all parent objects, or a signal created, whatever.
// Anyway this return check prevents you from picking up every assembly inside the holder at once.
/obj/item/assembly/attack_hand(mob/living/user, list/modifiers)
	if(holder || connected)
		return
	. = ..()

/obj/item/assembly/attackby(obj/item/W, mob/user, params)
	if(isassembly(W))
		var/obj/item/assembly/new_assembly = W

		// Check both our's and their's assembly flags to see if either should not duplicate
		// If so, and we match types, don't create a holder - block it
		if(((new_assembly.assembly_flags|assembly_flags) & ASSEMBLY_NO_DUPLICATES) && istype(new_assembly, type))
			balloon_alert(user, "can't attach another of that!")
			return
		if(new_assembly.secured || secured)
			balloon_alert(user, "both devices not attachable!")
			return

		holder = new /obj/item/assembly_holder(get_turf(src))
		holder.assemble(src, new_assembly, user)
		to_chat(user, "<span class='notice'>You attach and secure \the [new_assembly] to \the [src]!</span>")
		return

	if(istype(W, /obj/item/assembly_holder))
		var/obj/item/assembly_holder/added_to_holder = W
		added_to_holder.try_add_assembly(src, user)
		return

	return ..()

/obj/item/assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(toggle_secure())
		to_chat(user, "<span class='notice'>\The [src] is ready!</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] can now be attached!</span>")
	add_fingerprint(user)
	return TRUE

/obj/item/assembly/examine(mob/user)
	. = ..()
	. += "<span class='notice'>\The [src] [secured? "is secured and ready to be used!" : "can be attached to other things."]</span>"

/obj/item/assembly/ui_host(mob/user)
	// In order, return:
	// - The conencted wiring datum's owner, or
	// - The thing your assembly holder is attached to, or
	// - the assembly holder itself, or
	// - us
	return connected?.holder || holder?.master || holder || src

/obj/item/assembly/ui_state(mob/user)
	return GLOB.hands_state
