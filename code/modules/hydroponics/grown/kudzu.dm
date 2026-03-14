/obj/item/plant_seeds/preset/kudzu
	name = "kudzu seeds"
	name_override = "kudzu"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/bush_vine/nettle/kudzu, /datum/plant_feature/fruit/kudzu)
	//list of space vine mutations
	var/list/mutations = list()

/obj/item/plant_seeds/preset/kudzu/copy()
	. = ..()
	//transfer our special space vine mutations to the new seed
	var/obj/item/plant_seeds/preset/kudzu/new_seed = .
	new_seed.mutations = src.mutations.Copy()
	return new_seed

/obj/item/plant_seeds/preset/kudzu/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] swallows the pack of kudzu seeds! It looks like [user.p_theyre()] trying to commit suicide!"))
	start_kudzu(user)
	return BRUTELOSS

/obj/item/plant_seeds/preset/kudzu/proc/start_kudzu(mob/user)
//Flight checks - Make sure the user it out in the open when planting
	//Space is not ground
	if(isspaceturf(user.loc))
		return
	//lockers & bags is not ground
	if(!isturf(user.loc))
		to_chat(user, span_warning("You need more space to plant [src]."))
		return
	//Town aint big enough
	if(locate(/obj/structure/spacevine) in user.loc)
		to_chat(user, span_warning("There is too much kudzu here to plant [src]."))
		return
//Start the show
	to_chat(user, span_notice("You plant [src]."))
	message_admins("Kudzu planted by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(user)]")
	investigate_log("was planted by [key_name(user)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	new /datum/spacevine_controller(get_turf(user), mutations, 50, 7) //potency max 100, production max 10 - 50 & 7 should simulate an above average plant
	qdel(src)

/obj/item/plant_seeds/preset/kudzu/attack_self(mob/user)
	user.visible_message(span_danger("[user] begins throwing seeds on the ground..."))
	if(do_after(user, 50, target = user.drop_location(), progress = TRUE))
		start_kudzu(user)
		to_chat(user, span_warning("You plant the kudzu. You monster!"))

/obj/item/plant_seeds/preset/kudzu/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	//We handle our own extra scanner info, sue me
	var/obj/item/plant_scanner/scanner = I
	if(!istype(scanner))
		return
	if(!scanner.advanced)
		return
	var/text_string = ""
	for(var/datum/spacevine_mutation/SM in mutations)
		text_string += "<span class='plant_sub'>[(text_string == "") ? "" : ", "][SM.name]</span>"
	to_chat(user, "<span class='plant_scan'><b>Vine Mutations</b></span><span class='plant_scan'>[text_string]</span>")


/obj/item/plant_seeds/preset/kudzu/on_reagent_change(changetype)
	. = ..()
//Special reagent interactions to edit out vine mutations
	var/list/temp_mut_list = list()
	//Sterilizine adds 'negative traits'
	if(reagents.has_reagent(/datum/reagent/space_cleaner/sterilizine, 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == NEGATIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()
	//Fuel adds 'positive traits'
	if(reagents.has_reagent(/datum/reagent/fuel, 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == POSITIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()
	//Phenol adds minor 'negative traits'
	if(reagents.has_reagent(/datum/reagent/phenol, 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == MINOR_NEGATIVE)
				temp_mut_list += SM
		if(prob(20) && temp_mut_list.len)
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()

/*
	Kudzu food item
*/
/obj/item/food/grown/kudzupod
	seed = /obj/item/plant_seeds/preset/kudzu
	seed_base = /obj/item/plant_seeds/preset/kudzu
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	foodtypes = VEGETABLES | GROSS
	tastes = list("kudzu" = 1)
	wine_power = 20
