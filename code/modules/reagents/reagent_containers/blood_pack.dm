/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 400
	var/datum/blood_type/blood_type = null
	var/unique_blood = null
	var/labelled = 0
	reagent_flags = TRANSPARENT | ABSOLUTELY_GRINDABLE | INJECTABLE | DRAWABLE
	fill_icon_thresholds = list(10, 40, 60, 80, 100, 120, 140, 160, 180, 200)

/obj/item/reagent_containers/blood/Initialize(mapload)
	. = ..()
	if(blood_type != null)
		reagents.add_reagent(unique_blood ? unique_blood : /datum/reagent/blood, 400, list("viruses"=null,"blood_DNA"=null,"blood_type"=get_blood_type(blood_type),"resistances"=null,"trace_chem"=null))
		update_icon()

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
		var/datum/reagent/blood/B = reagents.has_reagent(/datum/reagent/blood)
		if(B?.data && B.data["blood_type"])
			blood_type = B.data["blood_type"]
		else
			blood_type = null
	update_pack_name()
	update_icon()

/obj/item/reagent_containers/blood/proc/update_pack_name()
	if(!labelled)
		if(blood_type)
			name = "blood pack[blood_type ? " - [unique_blood ? blood_type : blood_type.name]" : null]"
		else
			name = "blood pack"

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload)
	icon_state = "bloodpack"
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-", "L", "E", "Coolant")
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
	blood_type = "E"

/obj/item/reagent_containers/blood/synthetic
	blood_type = "Coolant"

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

/obj/item/reagent_containers/blood/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the label of [src]!"))
			return
		var/t = stripped_input(user, "What would you like to label the blood pack?", name, null, 53)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(user.get_active_held_item() != I)
			return
		if(t)
			labelled = 1
			name = "blood pack - [t]"
		else
			labelled = 0
			update_pack_name()
	else
		return ..()

/obj/item/reagent_containers/blood/attack(mob/living/victim, mob/living/attacker, params)
	if(!can_drink(victim, attacker))
		return

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(victim)

	if(victim != attacker)
		if(!do_after(victim, 5 SECONDS, attacker))
			return
		attacker.visible_message(
			span_notice("[attacker] forces [victim] to drink from the [src]."),
			span_notice("You put the [src] up to [victim]'s mouth."))
		reagents.trans_to(victim, 5, transfered_by = attacker, method = INGEST)
		// I would add more flavor, but I don't want to make this an antag check
		if(vampiredatum?.my_clan?.blood_drink_type != VAMPIRE_DRINK_SNOBBY)
			vampiredatum?.AddBloodVolume(5)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
		return TRUE

	if(vampiredatum?.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY)
		balloon_alert(victim, "not fresh!")
		return TRUE

	while(do_after(victim, 1 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_drink), victim, attacker)))
		victim.visible_message(
			span_notice("[victim] puts the [src] up to their mouth."),
			span_notice("You take a sip from the [src]."))
		reagents.trans_to(victim, 5, transfered_by = attacker, method = INGEST)
		vampiredatum?.AddBloodVolume(5)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
	return TRUE

/obj/item/reagent_containers/blood/proc/can_drink(mob/living/victim, mob/living/attacker)
	if(!canconsume(victim, attacker))
		return FALSE
	if(!reagents || !reagents.total_volume)
		to_chat(victim, span_warning("[src] is empty!"))
		return FALSE
	return TRUE
