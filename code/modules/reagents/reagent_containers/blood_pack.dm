/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 400
	var/blood_type = null
	var/unique_blood = null
	var/labelled = FALSE
	reagent_flags = TRANSPARENT | ABSOLUTELY_GRINDABLE | INJECTABLE | DRAWABLE
	fill_icon_thresholds = list(10, 40, 60, 80, 100, 120, 140, 160, 180, 200)

/obj/item/reagent_containers/blood/Initialize(mapload)
	. = ..()
	if(blood_type != null)
		reagents.add_reagent(unique_blood ? unique_blood : /datum/reagent/blood, 400, list("viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
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

/// Handles updating the container when the reagents change.
/obj/item/reagent_containers/blood/on_reagent_change(datum/reagents/holder, ...)
	var/datum/reagent/blood/new_reagent = holder.has_reagent(/datum/reagent/blood)
	if(new_reagent && new_reagent.data && new_reagent.data["blood_type"])
		blood_type = new_reagent.data["blood_type"]
	else if(holder.has_reagent(/datum/reagent/consumable/liquidelectricity))
		blood_type = "LE"
	else
		blood_type = null
	return ..()

/obj/item/reagent_containers/blood/update_name(updates)
	. = ..()
	if(labelled)
		return
	name = "blood pack[blood_type ? " - [blood_type]" : null]"

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload)
	icon_state = "bloodpack"
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-", "L")
	return ..()

/obj/item/reagent_containers/blood/APlus
	blood_type = "A+"

/obj/item/reagent_containers/blood/AMinus
	blood_type = "A-"

/obj/item/reagent_containers/blood/BPlus
	blood_type = "B+"

/obj/item/reagent_containers/blood/BMinus
	blood_type = "B-"

/obj/item/reagent_containers/blood/OPlus
	blood_type = "O+"

/obj/item/reagent_containers/blood/OMinus
	blood_type = "O-"

/obj/item/reagent_containers/blood/lizard
	blood_type = "L"

/obj/item/reagent_containers/blood/ethereal
	labelled = 1
	name = "blood pack - LE"
	blood_type = "LE"
	unique_blood = /datum/reagent/consumable/liquidelectricity

/obj/item/reagent_containers/blood/oozeling
	labelled = 1
	name = "blood pack - OZ"
	blood_type = "OZ"
	unique_blood = /datum/reagent/toxin/slimejelly

/obj/item/reagent_containers/blood/universal
	blood_type = "U"

/obj/item/reagent_containers/blood/attackby(obj/item/tool, mob/user, params)
	if (istype(tool, /obj/item/pen) || istype(tool, /obj/item/toy/crayon))
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
			update_name()
	else
		return ..()
