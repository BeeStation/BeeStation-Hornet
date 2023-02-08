#define FROSTWING_SYNTHFLESH_REQUIRED 100
#define FROSTWING_INCUBATION_TIME (5 MINUTES)

/obj/machinery/frostwing_incubator
	name = "avian egg synthesizer"
	desc = "An egg synsthesizer, using modified cloning technology to produce a synthetic frostwing egg via the use of synthflesh. Includes an incubator specifically designed to cool eggs to a temperature suitable for frostwing hatching."
	density = TRUE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_incubator"
	verb_say = "states"
	max_integrity = 350
	COOLDOWN_DECLARE(incubation)
	/// If the cooldown being finished should result in an egg being created.
	var/incubating = FALSE
	/// The length of time for the incubation cooldown
	var/incubation_length = FROSTWING_INCUBATION_TIME

/obj/machinery/frostwing_incubator/Initialize(mapload)
	create_reagents(FROSTWING_SYNTHFLESH_REQUIRED, OPENCONTAINER)
	. = ..()

/obj/machinery/frostwing_incubator/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.examinate(src)

/obj/machinery/frostwing_incubator/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if (alert(user, "Are you sure you want to empty the incubator's synthflesh container?", "Empty Reagent Storage:", "Yes", "No") != "Yes")
		return
	to_chat(user, "<span class='notice'>You empty \the [src]'s release valve onto the floor.</span>")
	reagents.expose(user.loc)
	src.reagents.clear_reagents()

/obj/machinery/frostwing_incubator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The reagent display reads: [round(reagents.total_volume, 1)] / [reagents.maximum_volume] cm<sup>3</sup></span>"
	if(!COOLDOWN_FINISHED(src, incubation) && incubating)
		. += "Current incubation cycle has [DisplayTimeText(COOLDOWN_TIMELEFT(src, incubation), round_seconds_to = 1)] remaining."
	if(obj_integrity < max_integrity)
		. += "<span class='notice'>It can be <em>repaired</em> with a welder.</span>"

/obj/machinery/frostwing_incubator/process()
	if(!is_operational || !powered(AREA_USAGE_EQUIP))
		if(incubating && !COOLDOWN_FINISHED(src, incubation))
			end_incubation(complete = FALSE)
		return
	if(incubating)
		if(COOLDOWN_FINISHED(src, incubation))
			end_incubation()
		else
			use_power(5000)
	else
		if(reagents.has_reagent(/datum/reagent/medicine/synthflesh, FROSTWING_SYNTHFLESH_REQUIRED))
			start_incubation()
		use_power(200)

/obj/machinery/frostwing_incubator/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
			if(I.use_tool(src, user, 4 SECONDS, volume=40))
				obj_integrity = CLAMP(obj_integrity + 80, 0, max_integrity)
		return
	return ..()

/obj/machinery/frostwing_incubator/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF) && prob(100/severity))
		say(Gibberish("Exposure to electromagnetic fields has caused premature incubation failure."))
		end_incubation(complete = FALSE)

/obj/machinery/frostwing_incubator/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		end_incubation(complete = FALSE)

/obj/machinery/frostwing_incubator/proc/start_incubation()
	COOLDOWN_START(src, incubation, incubation_length)
	reagents.remove_reagent(/datum/reagent/medicine/synthflesh, FROSTWING_SYNTHFLESH_REQUIRED)
	icon_state = "pod_incubator_active"
	incubating = TRUE

/obj/machinery/frostwing_incubator/proc/end_incubation(complete = TRUE)
	incubating = FALSE
	COOLDOWN_RESET(src, incubation)
	icon_state = "pod_incubator"
	if(!complete)
		return
	var/turf/output_location
	for(var/dir_c in GLOB.cardinals)
		var/turf/T = get_step(loc, dir_c)
		if(!isopenturf(T))
			continue
		if(T.density)
			continue
		var/ok_turf = TRUE
		for(var/obj/checked_object in T)
			if(checked_object.density)
				ok_turf = FALSE
				break
		if(ok_turf)
			output_location = T
			break
	if(!output_location)
		output_location = loc
	new /obj/effect/mob_spawn/human/frostwing(output_location)

/// A special variant with a longer initial cooldown
/obj/machinery/frostwing_incubator/roundstart
	incubation_length = 8 MINUTES

/obj/machinery/frostwing_incubator/roundstart/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/medicine/synthflesh, FROSTWING_SYNTHFLESH_REQUIRED)
	start_incubation()
	incubation_length = FROSTWING_INCUBATION_TIME

#undef FROSTWING_SYNTHFLESH_REQUIRED
#undef FROSTWING_INCUBATION_TIME

/datum/map_template/frostwing_base
	name = "Frostwing Base"
	mappath = '_maps/templates/frostwing_base.dmm'

/area/frostwing_base
	name = "Frostwing Home Base"
	icon_state = "frostwing"
	has_gravity = TRUE
	area_flags = UNIQUE_AREA
	flags_1 = NONE // disable CAN_BE_DIRTY_1, VERY IMPORTANT or floors break
