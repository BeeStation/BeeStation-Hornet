/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 400
	/// Id of the blood type we're filled with
	var/blood_type = null
	var/labelled = 0
	initial_reagent_flags = TRANSPARENT | ABSOLUTELY_GRINDABLE | INJECTABLE | DRAWABLE
	fill_icon_thresholds = list(10, 40, 60, 80, 100, 120, 140, 160, 180, 200)

/obj/item/reagent_containers/blood/Initialize(mapload)
	. = ..()
	if(!blood_type)
		return
	var/datum/blood_type/bloodtype = get_blood_type(blood_type)
	reagents.add_reagent(bloodtype.reagent_type, volume, list("blood_type" = bloodtype, "blood_DNA" = bloodtype.dna_string), creation_callback = CALLBACK(src, PROC_REF(on_blood_created)))

/obj/item/reagent_containers/blood/proc/on_blood_created(datum/reagent/new_blood)
	new_blood.AddElement(/datum/element/blood_reagent, null, get_blood_type(blood_type))
	update_appearance()

/obj/item/reagent_containers/blood/examine(mob/user)
	. = ..()
	if(reagents)
		if(volume == reagents.total_volume)
			. += span_notice("It is fully filled.")
		else if(!reagents.total_volume)
			. += span_notice("It's empty.")
		else
			. += span_notice("It seems [round(reagents.total_volume/volume*100)]% filled.")

/obj/item/reagent_containers/blood/on_reagent_change(changetype)
	if(reagents)
		var/datum/blood_type/held_type
		for(var/datum/reagent/held_reagent as anything in reagents.reagent_list)
			var/datum/blood_type/reagent_blood_type = held_reagent.data?["blood_type"]
			if(istype(reagent_blood_type))
				held_type = reagent_blood_type
				break
		blood_type = held_type?.id
	update_pack_name()
	update_icon()

/obj/item/reagent_containers/blood/proc/update_pack_name()
	if(!labelled)
		name = "blood pack[blood_type ? " - [blood_type]" : ""]"

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload)
	icon_state = "bloodpack"
	blood_type = pick(BLOOD_TYPE_A_PLUS, BLOOD_TYPE_A_MINUS, BLOOD_TYPE_B_PLUS, BLOOD_TYPE_B_MINUS, BLOOD_TYPE_O_PLUS, BLOOD_TYPE_O_MINUS, BLOOD_TYPE_LIZARD, BLOOD_TYPE_ETHEREAL, BLOOD_TYPE_SYNTHETIC)
	return ..()

/obj/item/reagent_containers/blood/a_plus
	blood_type = BLOOD_TYPE_A_PLUS

/obj/item/reagent_containers/blood/a_minus
	blood_type = BLOOD_TYPE_A_MINUS

/obj/item/reagent_containers/blood/b_plus
	blood_type = BLOOD_TYPE_B_PLUS

/obj/item/reagent_containers/blood/b_minus
	blood_type = BLOOD_TYPE_B_MINUS

/obj/item/reagent_containers/blood/o_plus
	blood_type = BLOOD_TYPE_O_PLUS

/obj/item/reagent_containers/blood/o_minus
	blood_type = BLOOD_TYPE_O_MINUS

/obj/item/reagent_containers/blood/lizard
	blood_type = BLOOD_TYPE_LIZARD

/obj/item/reagent_containers/blood/ethereal
	blood_type = BLOOD_TYPE_ETHEREAL

/obj/item/reagent_containers/blood/ethereal/Initialize(mapload)
	. = ..()
	set_light(2, 1, BLOOD_COLOR_ETHEREAL)

/obj/item/reagent_containers/blood/synthetic
	blood_type = BLOOD_TYPE_SYNTHETIC

/obj/item/reagent_containers/blood/oozeling
	labelled = TRUE
	name = "blood pack - OZ"
	blood_type = BLOOD_TYPE_TOX

/obj/item/reagent_containers/blood/universal
	blood_type = BLOOD_TYPE_UNIVERSAL

/obj/item/reagent_containers/blood/attackby(obj/item/tool, mob/user, list/modifiers)
	if(istype(tool, /obj/item/pen) || istype(tool, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the label of [src]!"))
			return
		var/custom_label = tgui_input_text(user, "What would you like to label the blood pack?", "Blood Pack", name, max_length = MAX_NAME_LEN)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(user.get_active_held_item() != tool)
			return
		if(custom_label)
			labelled = TRUE
			name = "blood pack - [custom_label]"
			balloon_alert(user, "new label set")
		else
			labelled = FALSE
			update_pack_name()
	else
		return ..()

/obj/item/reagent_containers/blood/attack(mob/living/victim, mob/living/attacker, list/modifiers)
	if(!can_drink(victim, attacker))
		return

	var/to_feed = reagents.total_volume

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(victim)

	if(victim != attacker)
		attacker.visible_message(
			span_notice("[attacker] puts \the [src] up to [victim]'s mouth."),
			span_notice("You put \the [src] up to [victim]'s mouth."))
		if(!do_after(attacker, 5 SECONDS, victim))
			return
		attacker.visible_message(
			span_notice("[attacker] forces [victim] to drink from \the [src]."),
			span_notice("You force [victim] to drink from \the [src]."))

		reagents.trans_to(victim, to_feed, transfered_by = attacker, method = INGEST)

		// I would add more flavor, but I don't want to make this an antag check
		if(vampiredatum?.my_clan?.blood_drink_type != VAMPIRE_DRINK_SNOBBY)
			vampiredatum?.adjust_vitae(to_feed / 4)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
		return TRUE

	if(vampiredatum?.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY)
		balloon_alert(victim, "Eugh. Not fresh!")
		return TRUE

	attacker.visible_message(
			span_notice("[victim] puts \the [src] up to [victim.p_their()] mouth."),
			span_notice("You put \the [src] up to your mouth."))

	if(!do_after(victim, 5 SECONDS, attacker, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_drink), victim, attacker)))
		return

	victim.visible_message(
		span_notice("[victim] sucks the contents out of \the [src]!"),
		span_notice("You feed from \the [src]."))

	reagents.trans_to(victim, to_feed, transfered_by = attacker, method = INGEST)
	vampiredatum?.adjust_vitae(to_feed / 4)
	playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)

	return TRUE

/obj/item/reagent_containers/blood/proc/can_drink(mob/living/victim, mob/living/attacker)
	if(!canconsume(victim, attacker))
		return FALSE
	if(!reagents?.total_volume)
		to_chat(victim, span_warning("[src] is empty!"))
		return FALSE
	if(!IS_VAMPIRE(victim))
		return FALSE
	return TRUE
