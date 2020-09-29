/obj/item/reagent_containers/pill
	name = "pill"
	desc = "A tablet or capsule."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill"
	item_state = "pill"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	possible_transfer_amounts = list()
	volume = 50
	grind_results = list()
	var/apply_type = INGEST
	var/apply_method = "swallow"
	var/rename_with_volume = FALSE
	var/self_delay = 0 //pills are instant, this is because patches inheret their aplication from pills
	var/dissolvable = TRUE

/obj/item/reagent_containers/pill/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"
	if(reagents.total_volume && rename_with_volume)
		name += " ([reagents.total_volume]u)"


/obj/item/reagent_containers/pill/attack_self(mob/user)
	return


/obj/item/reagent_containers/pill/attack(mob/M, mob/user, def_zone)
	if(!canconsume(M, user))
		return FALSE
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(/datum/surgery/dental_implant in C.surgeries)
			return
	if(M == user)
		M.visible_message("<span class='notice'>[user] attempts to [apply_method] [src].</span>")
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return FALSE
		to_chat(M, "<span class='notice'>You [apply_method] [src].</span>")

	else
		M.visible_message("<span class='danger'>[user] attempts to force [M] to [apply_method] [src].</span>", \
							"<span class='userdanger'>[user] attempts to force you to [apply_method] [src].</span>")
		if(!do_mob(user, M))
			return FALSE
		M.visible_message("<span class='danger'>[user] forces [M] to [apply_method] [src].</span>", \
							"<span class='userdanger'>[user] forces you to [apply_method] [src].</span>")

	var/makes_me_think = pick(strings(REDPILL_FILE, "redpill_questions"))
	if(icon_state == "pill4" && prob(5)) //you take the red pill - you stay in Wonderland, and I show you how deep the rabbit hole goes
		sleep(50)
		to_chat(M, "<span class='notice'>[makes_me_think]</span>")

	if(reagents.total_volume)
		reagents.reaction(M, apply_type)
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
		to_chat(user, "<span class='warning'>[target] is empty! There's nothing to dissolve [src] in.</span>")
		return

	if(target.reagents.holder_full())
		to_chat(user, "<span class='warning'>[target] is full.</span>")
		return

	user.visible_message("<span class='warning'>[user] slips something into [target]!</span>", "<span class='notice'>You dissolve [src] in [target].</span>", null, 2)
	reagents.trans_to(target, reagents.total_volume, transfered_by = user)
	qdel(src)

/obj/item/reagent_containers/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/toxin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/cyanide
	name = "cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/toxin/cyanide = 50)

/obj/item/reagent_containers/pill/adminordrazine
	name = "adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 50)

/obj/item/reagent_containers/pill/morphine
	name = "morphine pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"
	list_reagents = list(/datum/reagent/medicine/morphine = 30)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/stimulant
	name = "stimulant pill"
	desc = "Often taken by overworked employees, athletes, and the inebriated. You'll snap to attention immediately!"
	icon_state = "pill19"
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/medicine/antihol = 10, /datum/reagent/consumable/coffee = 30)

/obj/item/reagent_containers/pill/salbutamol
	name = "salbutamol pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill16"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 30)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/charcoal
	name = "charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	list_reagents = list(/datum/reagent/medicine/charcoal = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/epinephrine
	name = "epinephrine pill"
	desc = "Used to stabilize patients."
	icon_state = "pill5"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mannitol
	name = "mannitol pill"
	desc = "Used to treat brain damage."
	icon_state = "pill17"
	list_reagents = list(/datum/reagent/medicine/mannitol = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mutadone
	name = "mutadone pill"
	desc = "Used to treat genetic damage."
	icon_state = "pill20"
	list_reagents = list(/datum/reagent/medicine/mutadone = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/salicyclic
	name = "salicylic acid pill"
	desc = "Used to dull pain."
	icon_state = "pill9"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 24)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/oxandrolone
	name = "oxandrolone pill"
	desc = "Used to stimulate burn healing."
	icon_state = "pill11"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 24)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/insulin
	name = "insulin pill"
	desc = "Handles hyperglycaemic coma."
	icon_state = "pill18"
	list_reagents = list(/datum/reagent/medicine/insulin = 50)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/psicodine
	name = "psicodine pill"
	desc = "Used to treat mental instability and phobias."
	list_reagents = list(/datum/reagent/medicine/psicodine = 10)
	icon_state = "pill22"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/penacid
	name = "pentetic acid pill"
	desc = "Used to expunge radiation and toxins."
	list_reagents = list(/datum/reagent/medicine/pen_acid = 10)
	icon_state = "pill22"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/neurine
	name = "neurine pill"
	desc = "Used to treat non-severe mental traumas."
	list_reagents = list(/datum/reagent/medicine/neurine = 10)
	icon_state = "pill22"
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/mutarad
	name = "radiation treatment deluxe pill"
	desc = "Used to treat heavy radition poisoning and genetic defects."
	icon_state = "pill21"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 15, /datum/reagent/medicine/potass_iodide = 15, /datum/reagent/medicine/mutadone = 15)

/obj/item/reagent_containers/pill/antirad_plus
	name = "radiation plus pill"
	desc = "Used to treat heavy radition poisoning."
	icon_state = "pill3"
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 50, /datum/reagent/medicine/charcoal = 20)

/obj/item/reagent_containers/pill/antirad
	name = "potassium iodide pill"
	desc = "Used to treat radition used to counter radiation poisoning."
	icon_state = "pill18"
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 30)
	

///////////////////////////////////////// this pill is used only in a legion mob drop
/obj/item/reagent_containers/pill/shadowtoxin
	name = "black pill"
	desc = "I wouldn't eat this if I were you."
	icon_state = "pill9"
	color = "#454545"
	list_reagents = list(/datum/reagent/mutationtoxin/shadow = 1)

//////////////////////////////////////// drugs
/obj/item/reagent_containers/pill/zoom
	name = "yellow pill"
	desc = "A poorly made canary-yellow pill; it is slightly crumbly."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 10, /datum/reagent/drug/nicotine = 10, /datum/reagent/drug/methamphetamine = 1)
	icon_state = "pill7"


/obj/item/reagent_containers/pill/happy
	name = "happy pill"
	desc = "They have little happy faces on them, and they smell like marker pens."
	list_reagents = list(/datum/reagent/consumable/sugar = 10, /datum/reagent/drug/space_drugs = 10)
	icon_state = "pill_happy"


/obj/item/reagent_containers/pill/lsd
	name = "sunshine pill"
	desc = "Engraved on this split-coloured pill is a half-sun, half-moon."
	list_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 15, /datum/reagent/toxin/mindbreaker = 15)
	icon_state = "pill14"


/obj/item/reagent_containers/pill/aranesp
	name = "smooth pill"
	desc = "This blue pill feels slightly moist."
	list_reagents = list(/datum/reagent/drug/aranesp = 10)
	icon_state = "pill3"

/obj/item/reagent_containers/pill/happiness
	name = "happiness pill"
	desc = "It has a creepy smiling face on it."
	icon_state = "pill_happy"
	list_reagents = list(/datum/reagent/drug/happiness = 10)

/obj/item/reagent_containers/pill/floorpill
	name = "floorpill"
	desc = "A strange pill found in the depths of maintenance. Somehow, it can't be dissolved or used in a grinder."
	icon_state = "pill21"
	var/static/list/names = list("maintenance pill","floorpill","mystery pill","suspicious pill","strange pill")
	var/static/list/descs = list("Your feeling is telling you no, but...","Drugs are expensive, you can't afford not to eat any pills that you find."\
	, "Surely, there's no way this could go bad.")
	prevent_grinding = TRUE
	dissolvable = FALSE

/obj/item/reagent_containers/pill/floorpill/Initialize()
	list_reagents = list(get_unrestricted_random_reagent_id() = rand(10,50))
	. = ..()
	name = pick(names)


/obj/item/reagent_containers/pill/floorpill/examine(mob/user)
	. = ..()
	if(prob(20))
		. += "[pick(descs)]"
	if(HAS_TRAIT(user, TRAIT_APPRAISAL))
		if(length(reagents.reagent_list))
			for(var/datum/reagent/R in reagents.reagent_list)
				. += "It contains [R.volume] units of [R.name]"
