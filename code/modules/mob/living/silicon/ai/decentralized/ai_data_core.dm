GLOBAL_LIST_EMPTY(data_cores)
GLOBAL_VAR_INIT(primary_data_core, null)
#define MAX_AI_DATA_CORE_TICKS 15


/obj/machinery/ai/data_core
	name = "AI Data Core"
	desc = "A complicated computer system capable of emulating the neural functions of an organic being at near-instantanous speeds."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"

	circuit = /obj/item/circuitboard/machine/ai_data_core

	var/primary = FALSE

	var/valid_ticks = MAX_AI_DATA_CORE_TICKS //Limited to MAX_AI_DATA_CORE_TICKS. Decrement by 1 every time we have an invalid tick, opposite when valid

	var/warning_sent = FALSE

/obj/machinery/ai/data_core/Initialize()
	..()
	GLOB.data_cores += src
	if(primary && !GLOB.primary_data_core)
		GLOB.primary_data_core = src
	update_icon()

/obj/machinery/ai/data_core/process()
	calculate_validity()


/obj/machinery/ai/data_core/Destroy()
	GLOB.data_cores -= src
	if(GLOB.primary_data_core == src)
		GLOB.primary_data_core = null

	var/list/all_ais = GLOB.ai_list.Copy()

	for(var/mob/living/silicon/ai/AI in contents)
		all_ais -= AI
		AI.relocate()

	to_chat(all_ais, "<span class = 'userdanger'>Warning! Data Core brought offline in [get_area(src)]! Please verify that no malicious actions were taken.</span>")

	..()

/obj/machinery/ai/data_core/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return
	. += "<b>Networked AI Laws:</b>"
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		var/active_status = !AI.mind ? "(["<span class = 'warning'>OFFLINE</span>"])" : ""
		. += "<b>[AI] [active_status] has the following laws: </b>"
		for(var/law in AI.laws.get_law_list(include_zeroth = TRUE))
			. += law

/obj/machinery/ai/data_core/proc/valid_data_core()
	if(!is_reebe(z) && !is_station_level(z))
		return FALSE
	if(valid_ticks > 0)
		return TRUE
	return FALSE

/obj/machinery/ai/data_core/proc/calculate_validity()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_DATA_CORE_TICKS)

	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE

	if(valid_holder())
		valid_ticks++
		warning_sent = FALSE
	else
		valid_ticks--
		warning_sent = TRUE
		to_chat(GLOB.ai_list, "<span class = 'userdanger'>Data core in [get_area(src)] is on the verge of failing! Please contact technical support.</span>")



/obj/machinery/ai/data_core/proc/can_transfer_ai()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE
	if(!valid_data_core())
		return FALSE
	return TRUE

/obj/machinery/ai/data_core/proc/transfer_AI(mob/living/silicon/ai/AI)
	AI.forceMove(src)
	AI.eyeobj.forceMove(get_turf(src))

/obj/machinery/ai/data_core/update_icon()
	cut_overlays()

	if(!(stat & (BROKEN|NOPOWER|EMPED)))
		var/mutable_appearance/on_overlay = mutable_appearance(icon, "[initial(icon_state)]_on")
		add_overlay(on_overlay)


/obj/machinery/ai/data_core/primary
	name = "primary AI Data Core"
	desc = "A complicated computer system capable of emulating the neural functions of a human at near-instantanous speeds. This one has a scrawny and faded note saying: 'Primary AI Data Core'"
	primary = TRUE
