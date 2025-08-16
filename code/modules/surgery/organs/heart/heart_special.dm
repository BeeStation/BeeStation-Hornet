/obj/item/organ/heart/freedom
	name = "heart of freedom"
	desc = "This heart pumps with the passion to give... something freedom."
	organ_flags = ORGAN_SYNTHETIC //the power of freedom prevents heart attacks
	/// The cooldown until the next time this heart can give the host an adrenaline boost.
	COOLDOWN_DECLARE(adrenaline_cooldown)

/obj/item/organ/heart/freedom/on_life(delta_time, times_fired)
	. = ..()
	if(owner.health < 5 && COOLDOWN_FINISHED(src, adrenaline_cooldown))
		COOLDOWN_START(src, adrenaline_cooldown, rand(25 SECONDS, 1 MINUTES))
		to_chat(owner, span_userdanger("You feel yourself dying, but you refuse to give up!"))
		owner.heal_overall_damage(15, 15, 0, BODYTYPE_ORGANIC)
		if(owner.reagents.get_reagent_amount(/datum/reagent/medicine/ephedrine) < 20)
			owner.reagents.add_reagent(/datum/reagent/medicine/ephedrine, 10)

/obj/item/organ/heart/diona
	name = "polypment segment"
	desc = "A segment of plant matter that is resposible for pumping nutrients around the body."
	icon_state = "diona_heart"

/obj/item/organ/heart/ethereal
	name = "crystal core"
	icon_state = "ethereal_heart-on"
	base_icon_state = "ethereal_heart"
	visual = TRUE //This is used by the ethereal species for color
	desc = "A crystal-like organ that functions similarly to a heart for Ethereals."

	///Color of the heart, is set by the species on gain
	var/ethereal_color = "#9c3030"

/obj/item/organ/heart/ethereal/Initialize(mapload)
	. = ..()
	add_atom_colour(ethereal_color, FIXED_COLOUR_PRIORITY)
	update_appearance()

/obj/item/organ/heart/ethereal/update_overlays()
	. = ..()
	var/mutable_appearance/shine = mutable_appearance(icon, icon_state = "[base_icon_state]_overlay-[beating ? "on" : "off"]")
	shine.appearance_flags = RESET_COLOR //No color on this, just pure white
	. += shine
