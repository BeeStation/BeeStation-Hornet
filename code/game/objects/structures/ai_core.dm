/obj/structure/AIcore
	density = TRUE
	anchored = FALSE
	name = "\improper AI core"
	icon = 'icons/mob/ai.dmi'
	icon_state = "0"
	desc = "The framework for an artificial intelligence core."
	max_integrity = 500
	var/state = EMPTY_CORE
	var/datum/ai_laws/laws
	var/obj/item/mmi/brain
	var/can_deconstruct = FALSE

/obj/structure/AIcore/Initialize()
	. = ..()
	laws = new
	laws.set_laws_config()

/obj/structure/AIcore/handle_atom_del(atom/A)
	if(A == brain)
		brain = null
	. = ..()


/obj/structure/AIcore/Destroy()
	if(brain)
		qdel(brain)
		brain = null
	return ..()

/obj/structure/AIcore/latejoin_inactive
	name = "networked AI beacon"
	desc = "This machine is connected by bluespace transmitters to NTNet, allowing for an AI personality to be downloaded to it on the fly mid-shift."
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE
	var/available = TRUE
	var/safety_checks = TRUE
	var/active = TRUE

/obj/structure/AIcore/latejoin_inactive/examine(mob/user)
	. = ..()
	. += "Its transmitter seems to be <b>[active? "on" : "off"]</b>."
	. += "<span class='notice'>You could [active? "deactivate" : "activate"] it with a multitool.</span>"

/obj/structure/AIcore/latejoin_inactive/proc/is_available()			//If people still manage to use this feature to spawn-kill AI latejoins ahelp them.
	if(!available)
		return FALSE
	if(!safety_checks)
		return TRUE
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(!(A.area_flags & BLOBS_ALLOWED))
		return FALSE
	if(!A.power_equip)
		return FALSE
	if(!SSmapping.level_trait(T.z,ZTRAIT_STATION))
		return FALSE
	if(!istype(T, /turf/open/floor))
		return FALSE
	return TRUE

/obj/structure/AIcore/latejoin_inactive/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL)
		active = !active
		to_chat(user, "You [active? "activate" : "deactivate"] \the [src]'s transmitters.")
		return
	return ..()

/obj/structure/AIcore/latejoin_inactive/Initialize()
	. = ..()
	GLOB.latejoin_ai_cores += src

/obj/structure/AIcore/latejoin_inactive/Destroy()
	GLOB.latejoin_ai_cores -= src
	return ..()

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_WRENCH)
		return default_unfasten_wrench(user, P, 20)
	if(!anchored)
		if(P.tool_behaviour == TOOL_WELDER && can_deconstruct)
			if(state != EMPTY_CORE)
				to_chat(user, "<span class='warning'>The core must be empty to deconstruct it!</span>")
				return

			if(!P.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>You start to deconstruct the frame...</span>")
			if(P.use_tool(src, user, 20, volume=50) && state == EMPTY_CORE)
				to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
				deconstruct(TRUE)
			return
	return ..()

/obj/structure/AIcore/update_icon()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(brain)
				icon_state = "3b"
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.

/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol.")
			return FALSE
	return TRUE

// Unused for now, only here as reference
/*
/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.radio_enabled = TRUE
		AI.forceMove(loc) // to replace the terminal.
		to_chat(AI, "You have been uploaded to a stationary terminal. Remote device connection restored.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		AI.battery = circuit.battery
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "There is no AI loaded on this terminal!")
*/
