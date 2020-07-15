/obj/item/organ/wings
	name = "Pair of wings"
	desc = "A pair of wings. They look skinny and useless"
	icon_state = "severedtail"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_WINGS
	var/flight_level = WINGS_COSMETIC
	var/basewings = "wings" //right now, this just determines whether the wings are normal wings or moth wings
	var/wing_type = "Angel"
	var/canopen = TRUE
	var/datum/action/innate/flight/fly

/obj/item/organ/wings/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		if(!(basewings in H.dna.species.mutant_bodyparts))
			H.dna.species.mutant_bodyparts |= basewings
			H.dna.features[basewings] = wing_type
			H.update_body()
		if(flight_level >= WINGS_FLYING)
			fly = new
			fly.Grant(H)

/obj/item/organ/wings/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= basewings
		wing_type = H.dna.features[basewings]
		H.update_body()
	if(flight_level >= WINGS_FLYING)
		fly.Remove(H)
		QDEL_NULL(fly)
		if(H.movement_type & FLYING)
			H.dna.species.toggle_flight(H)

/obj/item/organ/wings/proc/toggleopen(mob/living/carbon/human/H) //opening and closing wings are purely cosmetic
	if(!canopen)
		return FALSE
	if(basewings == "wings")
		if("wings" in H.dna.species.mutant_bodyparts)
			H.dna.species.mutant_bodyparts -= "wings"
			H.dna.species.mutant_bodyparts |= "wingsopen"
		else if("wingsopen" in H.dna.species.mutant_bodyparts)
			H.dna.species.mutant_bodyparts -= "wingsopen"
			H.dna.species.mutant_bodyparts |= "wings"
		else //it appears we don't actually have wing icons. apply them!!
			Insert(H)
		H.update_body()
		return TRUE
	return FALSE

/obj/item/organ/wings/moth
	name = "pair of moth wings"
	desc = "A pair of moth wings."
	icon_state = "severedtail"
	flight_level = WINGS_FLIGHTLESS
	basewings = "moth_wings"
	wing_type = "plain"
	canopen = FALSE

/obj/item/organ/wings/moth/on_life()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(flight_level >= WINGS_FLIGHTLESS && H.bodytemperature >= 800 && H.fire_stacks > 0)
			flight_level = WINGS_COSMETIC
			to_chat(H, "<span class='danger'>Your precious wings burn to a crisp!</span>")
			H.dna.features["moth_wings"] = "Burnt Off"
			wing_type = "Burnt Off"
			H.dna.species.handle_mutant_bodyparts(H)
		
/obj/item/organ/wings/angel
	name = "pair of feathered wings"
	desc = "A pair of feathered wings. They seem robust enough for flight"
	icon_state = "severedtail"
	flight_level = WINGS_FLYING

/obj/item/organ/wings/dragon
	name = "pair of dragon wings"
	desc = "A pair of dragon wings. They seem robust enough for flight"
	icon_state = "severedtail"
	flight_level = WINGS_FLYING
	wing_type = "Dragon"

/obj/item/organ/wings/bee
	name = "pair of bee wings"
	desc = "A pair of bee wings. They seem tiny and undergrown"
	icon_state = "severedtail"
	flight_level = WINGS_FLIGHTLESS
	wing_type = "Bee"

/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUN
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/S = H.dna.species
	if(S.CanFly(H))
		S.toggle_flight(H)
		if(!(H.movement_type & FLYING))
			to_chat(H, "<span class='notice'>You settle gently back onto the ground...</span>")
		else
			to_chat(H, "<span class='notice'>You beat your wings and begin to hover gently above the ground...</span>")
			H.set_resting(FALSE, TRUE)