/obj/machinery/status_display/ai_core // Pictograph display which the AI can use to emote.
	name = "\improper AI core display"
	desc = "A small screen which the AI can use to present itself."

	icon = 'icons/mob/ai.dmi'
	icon_state = "ai-empty"

	density = TRUE

	var/mode = SD_BLANK
	var/emotion = "Neutral"

/obj/machinery/status_display/ai_core/Initialize()
	. = ..()
	GLOB.ai_core_displays.Add(src)

/obj/machinery/status_display/ai_core/Destroy()
	GLOB.ai_core_displays.Remove(src)
	. = ..()

/obj/machinery/status_display/ai_core/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		user.pick_icon()

/obj/machinery/status_display/ai_core/proc/set_ai(new_icon_state, new_icon)
	icon = initial(icon)
	if(new_icon)
		icon = new_icon
	if(new_icon_state)
		icon_state = new_icon_state


/obj/machinery/status_display/ai_core/process()
	if(stat & NOPOWER)
		icon = initial(icon)
		icon_state = initial(icon_state)
		return PROCESS_KILL
