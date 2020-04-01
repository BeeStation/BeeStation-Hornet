/obj/item/organ/genital/testicles
	name = "testicles"
	desc = "A male reproductive organ."
	icon_state = "testicles"
	icon = 'modular_citadel/icons/obj/genitals/testicles.dmi'
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TESTICLES
	size = BALLS_SIZE_MIN
	arousal_verb = "Your balls ache a little"
	unarousal_verb = "Your balls finally stop aching, again"
	linked_organ_slot = ORGAN_SLOT_PENIS
	genital_flags = CAN_MASTURBATE_WITH|MASTURBATE_LINKED_ORGAN|GENITAL_FUID_PRODUCTION
	var/size_name = "average"
	shape = "Single"
	var/sack_size = BALLS_SACK_SIZE_DEF
	fluid_id = /datum/reagent/consumable/semen
	masturbation_verb = "massage"
	layer_index = TESTICLES_LAYER_INDEX

/obj/item/organ/genital/testicles/generate_fluid()
	if(!linked_organ && !update_link())
		return FALSE
	. = ..()
	if(. && reagents.holder_full())
		to_chat(owner, "Your balls finally feel full, again.")

/obj/item/organ/genital/testicles/upon_link()
	size = linked_organ.size
	update_size()
	update_appearance()

/obj/item/organ/genital/testicles/update_size(modified = FALSE)
	switch(size)
		if(BALLS_SIZE_MIN)
			size_name = "average"
		if(BALLS_SIZE_DEF)
			size_name = "enlarged"
		if(BALLS_SIZE_MAX)
			size_name = "engorged"
		else
			size_name = "nonexistant"

/obj/item/organ/genital/testicles/update_appearance()
	. = ..()
	desc = "You see an [size_name] pair of testicles."
	if(owner)
		var/string
		if(owner.dna.species.use_skintones && owner.dna.features["genitals_use_skintone"])
			if(ishuman(owner)) // Check before recasting type, although someone fucked up if you're not human AND have use_skintones somehow...
				var/mob/living/carbon/human/H = owner // only human mobs have skin_tone, which we need.
				color = "#[skintone2hex(H.skin_tone)]"
				string = "testicles_[GLOB.balls_shapes_icons[shape]]_[size]-s"
		else
			color = "#[owner.dna.features["balls_color"]]"
			string = "testicles_[GLOB.balls_shapes_icons[shape]]_[size]"
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			icon_state = sanitize_text(string)
			H.update_genitals()

/obj/item/organ/genital/testicles/get_features(mob/living/carbon/human/H)
	var/datum/dna/D = H.dna
	if(D.species.use_skintones && D.features["genitals_use_skintone"])
		color = "#[skintone2hex(H.skin_tone)]"
	else
		color = "#[D.features["balls_color"]]"
	sack_size = D.features["balls_sack_size"]
	shape = D.features["balls_shape"]
	if(D.features["balls_shape"] == "Hidden")
		ENABLE_BITFIELD(genital_flags, GENITAL_INTERNAL)
	fluid_id = D.features["balls_fluid"]
	fluid_rate = D.features["balls_cum_rate"]
	fluid_mult = D.features["balls_cum_mult"]
	fluid_efficiency = D.features["balls_efficiency"]
