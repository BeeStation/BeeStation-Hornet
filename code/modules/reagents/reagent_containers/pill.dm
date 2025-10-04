/obj/item/reagent_containers/pill
	name = "pill"
	desc = "A tablet or capsule."
	icon = 'icons/obj/medicine_containers.dmi'
	icon_state = "pill_shape_capsule_purple_pink"
	inhand_icon_state = "pill_shape_capsule_purple_pink"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	has_variable_transfer_amount = FALSE
	volume = 50
	grind_results = list()
	var/apply_type = INGEST
	var/apply_method = "swallow"
	var/rename_with_volume = FALSE
	var/self_delay = 0 //pills are instant, this is because patches inheret their aplication from pills
	var/dissolvable = TRUE

/obj/item/reagent_containers/pill/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = pick(PILL_SHAPE_LIST)
	if(reagents.total_volume && rename_with_volume)
		name += " ([reagents.total_volume]u)"

/obj/item/reagent_containers/pill/attack(mob/M, mob/user, def_zone)
	perform_application(M, user, null)

/obj/item/reagent_containers/pill/proc/perform_application(mob/M, mob/user, obj/item/bodypart/affecting)
	if(!canconsume(M, user))
		return FALSE
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(/datum/surgery/dental_implant in C.surgeries)
			return
	if(M == user)
		M.visible_message(span_notice("[user] attempts to [apply_method] [src]."))
		if(self_delay)
			if(!do_after(user, self_delay, M))
				return FALSE
		to_chat(M, span_notice("You [apply_method] [src]."))

	else
		M.visible_message(span_danger("[user] attempts to force [M] to [apply_method] [src]."), \
							span_userdanger("[user] attempts to force you to [apply_method] [src]."))
		if(!do_after(user, CHEM_INTERACT_DELAY(3 SECONDS, user), M))
			return FALSE
		M.visible_message(span_danger("[user] forces [M] to [apply_method] [src]."), \
							span_userdanger("[user] forces you to [apply_method] [src]."))

	if(icon_state == "pill_shape_capsule_bloodred" && prob(5)) //you take the red pill - you stay in Wonderland, and I show you how deep the rabbit hole goes
		var/makes_me_think = pick(strings(REDPILL_FILE, "redpill_questions"))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), M, span_notice("[makes_me_think]")), 5 SECONDS)

	if(reagents.total_volume)
		reagents.expose(M, apply_type, affecting = affecting)
		reagents.trans_to(M, reagents.total_volume, transfered_by = user)
	qdel(src)
	return TRUE

/obj/item/reagent_containers/pill/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!dissolvable || !target.is_refillable())
		return
	if(target.is_drainable() && !target.reagents.total_volume)
		balloon_alert(user, "[target] is empty!")
		return

	if(target.reagents.holder_full())
		balloon_alert(user, "[target] is full!")
		return

	user.visible_message(span_warning("[user] slips something into [target]!"), span_notice("You dissolve [src] in [target]."), null, 2)
	reagents.trans_to(target, reagents.total_volume, transfered_by = user)
	qdel(src)

/obj/item/reagent_containers/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill_shape_capsule_red_whitelined"
	list_reagents = list(/datum/reagent/toxin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/cyanide
	name = "cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill_shape_capsule_red_whitelined"
	list_reagents = list(/datum/reagent/toxin/cyanide = 50)

/obj/item/reagent_containers/pill/adminordrazine
	name = "adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill_shape_tablet_blue_skyblue_lined"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 50)

/obj/item/reagent_containers/pill/morphine
	name = "morphine pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill_shape_tablet_skyblue_lined"
	list_reagents = list(/datum/reagent/medicine/morphine = 30)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/stimulant
	name = "stimulant pill"
	desc = "Often taken by overworked employees, athletes, and the inebriated. You'll snap to attention immediately!"
	icon_state = "pill_shape_capsule_white_redlined"
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/medicine/antihol = 10, /datum/reagent/consumable/coffee = 30)

/obj/item/reagent_containers/pill/salbutamol
	name = "salbutamol pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill_shape_tablet_blue_skyblue_lined"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 20)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/charcoal
	name = "charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill_shape_tablet_green_lined"
	list_reagents = list(/datum/reagent/medicine/charcoal = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/epinephrine
	name = "epinephrine pill"
	desc = "Used to stabilize patients."
	icon_state = "pill_shape_capsule_red_whitelined"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mannitol
	name = "mannitol pill"
	desc = "Used to treat brain damage."
	icon_state = "pill_shape_tablet_green_lined"
	list_reagents = list(/datum/reagent/medicine/mannitol = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mannitol/braintumor //For the brain tumor quirk
	list_reagents = list(/datum/reagent/medicine/mannitol = 30)

/obj/item/reagent_containers/pill/mutadone
	name = "mutadone pill"
	desc = "Used to treat genetic damage."
	icon_state = "pill_shape_capsule_purple_yellow"
	list_reagents = list(/datum/reagent/medicine/mutadone = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/bicaridine
	name = "bicaridine pill"
	desc = "Used to stimulate the healing of small brute injuries."
	icon_state = "pill_shape_tablet_white_lined"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/kelotane
	name = "kelotane pill"
	desc = "Used to stimulate the healing of small burns."
	icon_state = "pill_shape_tablet_lightgreen_flat"
	list_reagents = list(/datum/reagent/medicine/kelotane = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/salicyclic
	name = "salicylic acid pill"
	desc = "Used to dull pain."
	icon_state = "pill_shape_tablet_white_lined"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/oxandrolone
	name = "oxandrolone pill"
	desc = "Used to stimulate burn healing."
	icon_state = "pill_shape_tablet_lightgreen_flat"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/insulin
	name = "insulin pill"
	desc = "Handles hyperglycaemic coma."
	icon_state = "pill_shape_capsule_white"
	list_reagents = list(/datum/reagent/medicine/insulin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/psicodine
	name = "psicodine pill"
	desc = "Used to treat mental instability and phobias."
	list_reagents = list(/datum/reagent/medicine/psicodine = 10)
	icon_state = "pill_shape_capsule_lightgreen_white"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/penacid
	name = "pentetic acid pill"
	desc = "Used to expunge radiation and toxins."
	list_reagents = list(/datum/reagent/medicine/pen_acid = 10)
	icon_state = "pill_shape_capsule_lightgreen_white"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/neurine
	name = "neurine pill"
	desc = "Used to treat non-severe mental traumas."
	list_reagents = list(/datum/reagent/medicine/neurine = 10)
	icon_state = "pill_shape_capsule_lightgreen_white"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mutarad
	name = "radiation treatment deluxe pill"
	desc = "Used to treat heavy radition poisoning and genetic defects."
	icon_state = "pill_shape_capsule_black_white"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 15, /datum/reagent/medicine/potass_iodide = 15, /datum/reagent/medicine/mutadone = 15)

/obj/item/reagent_containers/pill/antirad_plus
	name = "radiation plus pill"
	desc = "Used to treat heavy radition poisoning."
	icon_state = "pill_shape_capsule_skyblue"

	list_reagents = list(/datum/reagent/medicine/potass_iodide = 50, /datum/reagent/medicine/charcoal = 20)

/obj/item/reagent_containers/pill/antirad
	name = "potassium iodide pill"
	desc = "Used to treat radition used to counter radiation poisoning."
	icon_state = "pill_shape_capsule_white"
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 30)


///////////////////////////////////////// this pill is used only in a legion mob drop
/obj/item/reagent_containers/pill/shadowtoxin
	name = "black pill"
	desc = "I wouldn't eat this if I were you."
	icon_state = "pill_shape_tablet_white_lined"
	color = "#454545"
	list_reagents = list(/datum/reagent/mutationtoxin/shadow = 5)

//////////////////////////////////////// drugs
/obj/item/reagent_containers/pill/zoom
	name = "yellow pill"
	desc = "A poorly made canary-yellow pill; it is slightly crumbly."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 10, /datum/reagent/drug/nicotine = 10, /datum/reagent/drug/methamphetamine = 1)
	icon_state = "pill_shape_tablet_yellow_lined"


/obj/item/reagent_containers/pill/happy
	name = "happy pill"
	desc = "They have little happy faces on them, and they smell like marker pens."
	list_reagents = list(/datum/reagent/consumable/sugar = 10, /datum/reagent/drug/space_drugs = 10)
	icon_state = "pill_shape_tablet_happy"


/obj/item/reagent_containers/pill/lsd
	name = "sunshine pill"
	desc = "Engraved on this split-coloured pill is a half-sun, half-moon."
	list_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 15, /datum/reagent/toxin/mindbreaker = 15)
	icon_state = "pill_shape_tablet_yellow_purple_lined"


/obj/item/reagent_containers/pill/aranesp
	name = "smooth pill"
	desc = "This blue pill feels slightly moist."
	list_reagents = list(/datum/reagent/drug/aranesp = 10)
	icon_state = "pill_shape_capsule_skyblue"


/obj/item/reagent_containers/pill/happiness
	name = "happiness pill"
	desc = "It has a creepy smiling face on it."
	icon_state = "pill_shape_tablet_happy"
	list_reagents = list(/datum/reagent/drug/happiness = 10)

/obj/item/reagent_containers/pill/floorpill
	name = "floorpill"
	desc = "A strange pill found in the depths of maintenance. Somehow, it can't be dissolved or used in a grinder."
	icon_state = "pill_shape_capsule_black_white"
	var/static/list/names = list("maintenance pill","floorpill","mystery pill","suspicious pill","strange pill")
	var/static/list/descs = list("Your feeling is telling you no, but...","Drugs are expensive, you can't afford not to eat any pills that you find."\
	, "Surely, there's no way this could go bad.")
	prevent_grinding = TRUE
	dissolvable = FALSE

/obj/item/reagent_containers/pill/floorpill/Initialize(mapload)
	list_reagents = list(get_random_reagent_id(CHEMICAL_RNG_FUN) = rand(10,50))
	. = ..()
	name = pick(names)


/obj/item/reagent_containers/pill/floorpill/examine(mob/user)
	. = ..()
	if(prob(20))
		. += "[pick(descs)]"
