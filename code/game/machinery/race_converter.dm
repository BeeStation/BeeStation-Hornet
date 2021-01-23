/obj/machiney/species_converter
	name = "species conversion chamber"
	desc = "Safely and efficiently converts the species of the subject, warrenty void if exposed to plasma."
	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "fat"
	state_open = FALSE
	density = TRUE
	var/processing = FALSE
	var/list/possible_races = list()
	var/datum/species/desired_race = /datum/species/human/felinid
	var/datum/looping_sound/microwave/soundloop

/obj/machinery/species_converter/Initialize()
	. = ..()
	soundloop = new(list(src),  FALSE)
	update_icon()

/obj/machinery/species_converter/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/species_converter/close_machine(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You need to close the maintenance hatch first!</span>")
		return
	if(occupant)
		if(!iscarbon(occupant))
			occupant.forceMove(drop_location())
			occupant = null
			return
		to_chat(occupant, "<span class='notice'>You enter [src]</span>")
		addtimer(CALLBACK(src, .proc/start_extracting), 20, TIMER_OVERRIDE|TIMER_UNIQUE)
		update_icon()

/obj/machinery/species_converter/open_machine(mob/user)
	playsound(src, 'sound/machines/click.ogg', 50)
	if(processing)
		stop()
	..()
/obj/machinery/species_converter/proc/stop()
	processing = FALSE
	soundloop.stop()
	set_light(0, 0)

/obj/machinery/species_converter/interact(mob/user)
	if(state_open)
		close_machine()
	else if(!processing)
		open_machine()
	else
		to_chat(user, "<span class='warning'>You can't open the [src] while it's active!</span>")

/obj/machinery/species_converter/update_icon()
	overlays.Cut()
	if(!state_open)
		if(processing)
			overlays += "[icon_state]_door_on"
			overlays += "[icon_state]_stack"
			overlays += "[icon_state]_smoke"
			overlays += "[icon_state]_green"
		else
			overlays += "[icon_state]_door_off"
			if(occupant)
				if(powered(AREA_USAGE_EQUIP))
					overlays += "[icon_state]_stack"
					overlays += "[icon_state]_yellow"
			else
				overlays += "[icon_state]_red"
	else if(powered(AREA_USAGE_EQUIP))
		overlays += "[icon_state]_red"
	if(panel_open)
		overlays += "[icon_state]_panel"

/obj/machinery/species_converter/process()
	if(!processing)
		return
	if(!is_operational() || !occupant || !iscarbon(occupant))
		open_machine()
		return

	var/mob/living/carbon/C = occupant
	if(C.dna.species == desired_race)
		open_machine()
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
		return

	else if(prob(20))
		C.set_species(desired_race)

	use_power(500)

/obj/machinery/species_converter/New()
	if(!length(possible_races))
		for(var/datum/species/ST in subtypesof(/datum/species))
			if(ST.check_roundstart_eligible())
				possible_races += ST
		possible_races = sortList(possible_races)
	..()

/obj/machinery/species_converter/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || processing)
		return
	desired_race = input("Select desired race") as null|anything in possible_races

/*
/obj/machinery/species_converter/emag_act(mob/living/user)
	if(LAZYLEN(possible_races))
		desired_race = pick(possible_races)
		to_chat(user, "<span class='notice'>You scramble \the [src]'s target species!</span>")
*/
