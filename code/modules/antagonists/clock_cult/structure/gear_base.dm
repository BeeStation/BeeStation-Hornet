/obj/structure/destructible/clockwork/gear_base
	name = "gear base"
	desc = "A large cog lying on the floor at feet level."
	clockwork_desc = "A large cog lying on the floor at feet level."
	anchored = FALSE
	break_message = span_warning("Oh, that broke. I guess you could report it to the coders, or just you know ignore this message and get on with killing those god damn heretics coming to break the Ark.")
	icon_state = "gear_base"

	/// This is added to the end of the icon state when unanchored
	var/unwrenched_suffix = "_unwrenched"
	/// The transmission sigil supplying power to this gear base
	var/obj/structure/destructible/clockwork/sigil/transmission/linked_transmission_sigil
	/// Makes sure the depowered proc is only called when its depowered and not while its depowered
	var/depowered = FALSE
	/// Minimum operation power
	var/minimum_power = 0

/obj/structure/destructible/clockwork/gear_base/Initialize(mapload)
	. = ..()
	update_icon_state()

	// Find a sigil
	for(var/obj/structure/destructible/clockwork/sigil/transmission/sigil in range(src, SIGIL_TRANSMISSION_RANGE))
		linked_transmission_sigil = sigil

/obj/structure/destructible/clockwork/gear_base/Destroy()
	linked_transmission_sigil.linked_structures -= src
	. = ..()

/obj/structure/destructible/clockwork/gear_base/attackby(obj/item/I, mob/user, params)
	if(IS_SERVANT_OF_RATVAR(user) && I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You begin to [anchored ? "unwrench" : "wrench"] [src]."))
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, span_notice("You successfully [anchored ? "unwrench" : "wrench"] [src]."))
			set_anchored(!anchored)
			update_icon_state()
		return TRUE
	else
		return ..()

/obj/structure/destructible/clockwork/gear_base/update_icon_state()
	icon_state = initial(icon_state) + (anchored ? "" : unwrenched_suffix)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/proc/unlink_sigil(obj/structure/destructible/clockwork/sigil/transmission/unliked_sigil)
	linked_transmission_sigil = null

	// Try and replace the linked transmission sigil with another one
	for(var/obj/structure/destructible/clockwork/sigil/transmission/new_sigil in range(src, SIGIL_TRANSMISSION_RANGE))
		if(new_sigil == unliked_sigil)
			continue

		linked_transmission_sigil = new_sigil

	// Couldn't find a new sigil, depower the structure
	if(!linked_transmission_sigil)
		depowered()
		depowered = TRUE

//Power procs, for all your power needs, that is... if you have any

/obj/structure/destructible/clockwork/gear_base/proc/update_power()
	if(depowered)
		if(GLOB.clockcult_power > minimum_power && linked_transmission_sigil)
			repowered()
			depowered = FALSE
			return TRUE
		return FALSE
	else
		if(GLOB.clockcult_power <= minimum_power || !linked_transmission_sigil)
			depowered()
			depowered = TRUE
			return FALSE
		return TRUE

/obj/structure/destructible/clockwork/gear_base/proc/check_power(amount)
	if(!linked_transmission_sigil)
		return FALSE
	if(depowered)
		return FALSE
	if(GLOB.clockcult_power < amount)
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/gear_base/proc/use_power(amount)
	update_power()
	if(!check_power(amount))
		return FALSE
	GLOB.clockcult_power -= amount
	update_power()
	return TRUE

//We lost power
/obj/structure/destructible/clockwork/gear_base/proc/depowered()
	return

/obj/structure/destructible/clockwork/gear_base/proc/repowered()
	return
