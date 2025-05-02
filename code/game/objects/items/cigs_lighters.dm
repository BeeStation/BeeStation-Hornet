//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	/// How long the match lasts in seconds
	var/smoketime = 10
	w_class = WEIGHT_CLASS_TINY
	heat = 1000
	throw_verb = "flick"
	grind_results = list(/datum/reagent/phosphorus = 2)
	item_flags = ISWEAPON

/obj/item/match/process(delta_time)
	smoketime -= delta_time
	if(smoketime <= 0)
		matchburnout()
	else
		open_flame(heat)

/obj/item/match/fire_act(exposed_temperature, exposed_volume)
	matchignite()

/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		playsound(src, "sound/items/match_strike.ogg", 15, TRUE)
		lit = TRUE
		icon_state = "match_lit"
		damtype = BURN
		force = 3
		hitsound = 'sound/items/welder.ogg'
		item_state = "cigon"
		name = "lit [initial(name)]"
		desc = "A [initial(name)]. This one is lit."
		attack_verb_continuous = list("burns", "sings")
		attack_verb_simple = list("burn", "sing")
		START_PROCESSING(SSobj, src)
		update_icon()

/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		damtype = BRUTE
		force = initial(force)
		icon_state = "match_burnt"
		item_state = "cigoff"
		name = "burnt [initial(name)]"
		desc = "A [initial(name)]. This one has seen better days."
		attack_verb_continuous = list("flicks")
		attack_verb_simple = list("flick")
		STOP_PROCESSING(SSobj, src)

/obj/item/match/extinguish()
	matchburnout()

/obj/item/match/dropped(mob/user)
	..()
	matchburnout()

/obj/item/match/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!isliving(M))
		return
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && !user.combat_mode)
		if(cig.lit)
			to_chat(user, span_notice("[cig] is already lit."))
		if(M == user)
			cig.attackby(src, user)
		else
			if(cig.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
				message_admins("[cig] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
				log_game("[cig] that contains plasma was lit by [key_name(user)] for [key_name(M)]!")
			if(cig.reagents.get_reagent_amount(/datum/reagent/fuel))
				message_admins("[cig] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
				log_game("[cig] that contains fuel was lit by [key_name(user)] for [key_name(M)]!")
			cig.light(span_notice("[user] holds [src] out for [M], and lights [cig]."))
	else
		..()

/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/is_hot()
	return lit * heat

/obj/item/match/firebrand
	name = "firebrand"
	desc = "An unlit firebrand. It makes you wonder why it's not just called a stick."
	smoketime = 40
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/match/firebrand/Initialize(mapload)
	. = ..()
	matchignite()

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	grind_results = list()
	heat = 1000
	item_flags = ISWEAPON
	var/dragtime = 10
	var/nextdragtime = 0
	var/lit = FALSE
	var/starts_lit = FALSE
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/cigbutt
	var/lastHolder = null
	/// How long the cigarette lasts in seconds
	var/smoketime = 360
	var/chem_volume = 30
	var/smoke_all = FALSE /// Should we smoke all of the chems in the cig before it runs out. Splits each puff to take a portion of the overall chems so by the end you'll always have consumed all of the chems inside.
	var/list/list_reagents = list(/datum/reagent/drug/nicotine = 15)

/obj/item/clothing/mask/cigarette/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is huffing [src] as quickly as [user.p_they()] can! It looks like [user.p_theyre()] trying to give [user.p_them()]self cancer."))
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/cigarette/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	if(starts_lit)
		light()
	AddComponent(/datum/component/knockoff,90,list(BODY_ZONE_PRECISE_MOUTH),list(ITEM_SLOT_MASK))//90% to knock off when wearing a mask

/obj/item/clothing/mask/cigarette/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/attackby(obj/item/W, mob/user, params)
	if(!lit && smoketime > 0)
		var/lighting_text = W.ignition_effect(src, user)
		if(lighting_text)
			if(src.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
				message_admins("[src] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)]!")
				log_game("[src] that contains plasma was lit by  [key_name(user)]!")
			if(src.reagents.get_reagent_amount(/datum/reagent/fuel))
				message_admins("[src] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)]!")
				log_game("[src] that contains fuel was lit by [key_name(user)]!")
			light(lighting_text)
	else
		return ..()

/obj/item/clothing/mask/cigarette/proc/dip(obj/item/reagent_containers/cup/glass, mob/user, proximity)
	if(!proximity || lit) //can't dip if cigarette is lit (it will heat the reagents in the glass instead)
		return
	if(istype(glass))	//you can dip cigarettes into beakers
		if(glass.reagents.trans_to(src, chem_volume, transfered_by = user))	//if reagents were transfered, show the message
			to_chat(user, span_notice("You dip \the [src] into \the [glass]."))
			message_admins("[ADMIN_LOOKUPFLW(user)] added reagents to [src], it now contains [english_list(src.reagents.reagent_list)]!")
			log_game("[key_name(user)] added reagents to [src], it now contains [english_list(src.reagents.reagent_list)]!")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, span_notice("[glass] is empty."))
			else
				to_chat(user, span_notice("[src] is full."))

/obj/item/clothing/mask/cigarette/proc/butt(mob/living/M, mob/living/user, proximity)
	if(!istype(M))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(lit && user.combat_mode)
		force = 4
		var/target_zone = user.get_combat_bodyzone()
		M.apply_damage(force, BURN, target_zone)
		qdel(src)
		var/cig_butt = new type_butt()
		user.put_in_hands(cig_butt)
		new /obj/effect/decal/cleanable/ash(M.loc)
		playsound(user, 'sound/surgery/cautery2.ogg', 25, 1)
		return
	if(lit && !user.combat_mode)
		smoketime -= 120
		if(prob(40))
			src.extinguish()
			if(src.smoketime <= 0)
				qdel(src)
				var/cig_butt = new type_butt()
				user.put_in_hands(cig_butt)
				playsound(user, 'sound/items/cig_snuff.ogg', 25, 1)

/obj/item/clothing/mask/cigarette/afterattack(var/target, mob/living/user, proximity)
	if (istype(target, /mob/living))
		butt(target, user, proximity)
		. = ..()
	else
		. = ..()
		dip(target, user, proximity)

/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return
	if(!(flags_1 & INITIALIZED_1))
		icon_state = icon_on
		item_state = icon_on
		return

	lit = TRUE
	name = "lit [name]"
	attack_verb_continuous = list("burns", "sings")
	attack_verb_simple = list("burn", "sing")
	hitsound = 'sound/items/welder.ogg'
	damtype = BURN
	force = 4
	var/turf/T = get_turf(src)
	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		plasma_ignition(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)/10)
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes too, but much less violently
		T.visible_message("<b>[span_userdanger("[src] violently explodes!")]</b>")
		explosion(src, 0, 0, 1, 0, flame_range = 1)
		qdel(src)
		return
	// allowing reagents to react after being lit
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	icon_state = icon_on
	item_state = icon_on
	if(flavor_text)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)

	//can't think of any other way to update the overlays :<
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_mask()
		M.update_inv_hands()

	playsound(src, 'sound/items/cig_light.ogg', 75, 1, -1)

/obj/item/clothing/mask/cigarette/extinguish()
	if(!lit)
		return
	name = copytext_char(name, 5) //5 == length_char("lit ") + 1
	attack_verb_continuous = null
	attack_verb_simple = null
	hitsound = null
	damtype = BRUTE
	force = 0
	icon_state = icon_off
	item_state = icon_off
	STOP_PROCESSING(SSobj, src)
	ENABLE_BITFIELD(reagents.flags, NO_REACT)
	lit = FALSE
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, span_notice("Your [name] goes out."))
		M.update_inv_wear_mask()
		M.update_inv_hands()

/obj/item/clothing/mask/cigarette/proc/handle_reagents()
	if(reagents.total_volume)
		var/to_smoke = REAGENTS_METABOLISM
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.wear_mask) // if it's in the human/monkey mouth, transfer reagents to the mob
				var/fraction = min(REAGENTS_METABOLISM/reagents.total_volume, 1)
				/*
				 * Given the amount of time the cig will last, and how often we take a hit, find the number
				 * of chems to give them each time so they'll have smoked it all by the end
				 */
				if (smoke_all)
					to_smoke = reagents.total_volume / (smoketime / dragtime)

				reagents.expose(C, INGEST, fraction)
				if(!reagents.trans_to(C, to_smoke))
					reagents.remove_any(to_smoke)
				return
		reagents.remove_any(to_smoke)

/obj/item/clothing/mask/cigarette/process(delta_time)
	var/turf/location = get_turf(src)
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime -= delta_time
	if(smoketime <= 0)
		new type_butt(location)
		if(ismob(loc))
			to_chat(M, span_notice("Your [name] goes out."))
			playsound(src, 'sound/items/cig_snuff.ogg', 25, 1)
		qdel(src)
		return
	open_flame()
	if((reagents && reagents.total_volume) && (nextdragtime <= world.time))
		nextdragtime = world.time + dragtime SECONDS
		handle_reagents()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message(span_notice("[user] calmly drops and treads on \the [src], putting it out instantly."))
		new type_butt(user.loc)
		new /obj/effect/decal/cleanable/ash(user.loc)
		playsound(src, 'sound/items/cig_snuff.ogg', 25, 1)
		qdel(src)
	. = ..()

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()
	if(M.on_fire && !lit)
		if(src.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
			message_admins("[src] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)]!")
			log_game("[src] that contains plasma was lit by [key_name(user)]!")
		if(src.reagents.get_reagent_amount(/datum/reagent/fuel))
			message_admins("[src] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)]!")
			log_game("[src] that contains fuel was lit by [key_name(user)]!")
		light(span_notice("[user] lights [src] with [M]'s burning body. What a cold-blooded badass."))
		return
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && !user.combat_mode)
		if(cig.lit)
			to_chat(user, span_notice("The [cig.name] is already lit."))
		if(M == user)
			if(cig.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
				message_admins("[cig] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)]!")
				log_game("[cig] that contains plasma was lit by [key_name(user)]!")
			if(cig.reagents.get_reagent_amount(/datum/reagent/fuel))
				message_admins("[cig] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)]!")
				log_game("[cig] that contains fuel was lit by [key_name(user)]!")
			cig.attackby(src, user)
		else
			if(cig.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
				message_admins("[cig] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
				log_game("[cig] that contains plasma was lit by [key_name(user)] for [key_name(M)]!")
			if(cig.reagents.get_reagent_amount(/datum/reagent/fuel))
				message_admins("[cig] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
				log_game("[cig] that contains fuel was lit by [key_name(user)] for [key_name(M)]!")
			cig.light(span_notice("[user] holds the [name] out for [M], and lights [M.p_their()] [cig.name]."))

	else
		return ..()

/obj/item/clothing/mask/cigarette/fire_act(exposed_temperature, exposed_volume)
	if(src.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
		message_admins("[src] that contains plasma was lit by the environment - Last touched by [src.fingerprintslast]!")
		log_game("[src] that contains plasma was lit by the environment - Last touched by [src.fingerprintslast]!")
	if(src.reagents.get_reagent_amount(/datum/reagent/fuel))
		message_admins("[src] that contains fuel was lit by the environment - Last touched by [src.fingerprintslast]!")
		log_game("[src] that contains fuel was lit by the environment - Last touched by [src.fingerprintslast]!")
	light()

/obj/item/clothing/mask/cigarette/is_hot()
	return lit * heat

// Cigarette brands.

/obj/item/clothing/mask/cigarette/space_cigarette
	desc = "A Space Cigarette brand cigarette."

/obj/item/clothing/mask/cigarette/dromedary
	desc = "A DromedaryCo brand cigarette."

/obj/item/clothing/mask/cigarette/uplift
	desc = "An Uplift Smooth brand cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 13, /datum/reagent/consumable/menthol = 5)

/obj/item/clothing/mask/cigarette/robust
	desc = "A Robust brand cigarette."

/obj/item/clothing/mask/cigarette/robustgold
	desc = "A Robust Gold brand cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/gold = 3) // Just enough to taste a hint of expensive metal.

/obj/item/clothing/mask/cigarette/carp
	desc = "A Carp Classic brand cigarette."

/obj/item/clothing/mask/cigarette/plasma
	list_reagents = list(/datum/reagent/toxin/plasma = 5)

/obj/item/clothing/mask/cigarette/syndicate
	desc = "An unknown brand cigarette."
	chem_volume = 60
	smoketime = 2 * 60
	smoke_all = TRUE
	list_reagents = list(/datum/reagent/drug/nicotine = 10, /datum/reagent/medicine/omnizine = 15)

/obj/item/clothing/mask/cigarette/shadyjims
	desc = "A Shady Jim's Super Slims cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/toxin/lipolicide = 4, /datum/reagent/ammonia = 2, /datum/reagent/toxin/plantbgone = 1, /datum/reagent/toxin = 1.5)

/obj/item/clothing/mask/cigarette/xeno
	desc = "A Xeno Filtered brand cigarette."
	list_reagents = list (/datum/reagent/drug/nicotine = 20, /datum/reagent/medicine/regen_jelly = 15, /datum/reagent/drug/krokodil = 4)

// Rollies.

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper."
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	item_state = "spliffoff"
	smoketime = 4 * 60
	chem_volume = 50
	list_reagents = null

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/nicotine
	list_reagents = list(/datum/reagent/drug/nicotine = 15)

/obj/item/clothing/mask/cigarette/rollie/trippy
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/drug/mushroomhallucinogen = 35)
	starts_lit = TRUE

/obj/item/clothing/mask/cigarette/rollie/cannabis
	list_reagents = list(/datum/reagent/drug/space_drugs = 15, /datum/reagent/toxin/lipolicide = 35)

/obj/item/clothing/mask/cigarette/rollie/mindbreaker
	list_reagents = list(/datum/reagent/toxin/mindbreaker = 35, /datum/reagent/toxin/lipolicide = 15)

/obj/item/cigbutt/roach
	name = "roach"
	desc = "A manky old roach, or for non-stoners, a used rollup."
	icon_state = "roach"

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 11 * 60
	chem_volume = 40
	list_reagents = list(/datum/reagent/drug/nicotine = 25)

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 20 * 60
	chem_volume = 80
	list_reagents =list(/datum/reagent/drug/nicotine = 40)

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 30 * 60
	chem_volume = 50
	list_reagents =list(/datum/reagent/drug/nicotine = 15)

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meerschaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 0
	chem_volume = 100
	list_reagents = null
	w_class = WEIGHT_CLASS_SMALL
	/// Name of the stuff packed inside this pipe
	var/packeditem

/obj/item/clothing/mask/cigarette/pipe/Initialize(mapload)
	. = ..()
	name = "empty [initial(name)]"

/obj/item/clothing/mask/cigarette/pipe/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/pipe/process(delta_time)
	var/turf/location = get_turf(src)
	smoketime -= delta_time
	if(smoketime <= 0)
		new /obj/effect/decal/cleanable/ash(location)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, span_notice("Your [name] goes out."))
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask()
			packeditem = 0
			name = "empty [initial(name)]"
		STOP_PROCESSING(SSobj, src)
		return
	open_flame()
	if(reagents?.total_volume)	//	check if it has any reagents at all
		handle_reagents()


/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/food/grown))
		var/obj/item/food/grown/G = O
		if(!packeditem)
			if(HAS_TRAIT(G, TRAIT_DRIED))
				to_chat(user, span_notice("You stuff [O] into [src]."))
				smoketime = 13 * 60
				packeditem = TRUE
				name = "[O.name]-packed [initial(name)]"
				if(O.reagents)
					O.reagents.trans_to(src, O.reagents.total_volume, transfered_by = user)
				qdel(O)
			else
				to_chat(user, span_warning("It has to be dried first!"))
		else
			to_chat(user, span_warning("It is already packed!"))
	else
		var/lighting_text = O.ignition_effect(src,user)
		if(lighting_text)
			if(smoketime > 0)
				light(lighting_text)
			else
				to_chat(user, span_warning("There is nothing to smoke!"))
		else
			return ..()

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user)
	var/turf/location = get_turf(user)
	if(lit)
		user.visible_message(span_notice("[user] puts out [src]."), span_notice("You put out [src]."))
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return
	if(!lit && smoketime > 0)
		to_chat(user, span_notice("You empty [src] onto [location]."))
		new /obj/effect/decal/cleanable/ash(location)
		packeditem = 0
		smoketime = 0
		reagents.clear_reagents()
		name = "empty [initial(name)]"
	return

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters. Can be loaded with objects."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 0


/////////
//ZIPPO//
/////////
/obj/item/lighter
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "zippo"
	item_state = "zippo"
	worn_icon_state = "lighter"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_on = FALSE
	item_flags = ISWEAPON
	var/lit = 0
	var/fancy = TRUE
	var/overlay_state
	var/overlay_list = list(
		"plain",
		"dame",
		"thirteen",
		"snake"
		)
	heat = 1500
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_FIRE
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/oil = 5)

/obj/item/lighter/Initialize(mapload)
	. = ..()
	if(!overlay_state)
		overlay_state = pick(overlay_list)
	update_icon()

/obj/item/lighter/cyborg_unequip(mob/user)
	if(!lit)
		return
	set_lit(FALSE)

/obj/item/lighter/suicide_act(mob/living/carbon/user)
	if (lit)
		user.visible_message(span_suicide("[user] begins holding \the [src]'s flame up to [user.p_their()] face! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/items/welder.ogg', 50, 1)
		return FIRELOSS
	else
		user.visible_message(span_suicide("[user] begins whacking [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

/obj/item/lighter/update_overlays()
	. = ..()
	. += create_lighter_overlay()

/obj/item/lighter/update_icon_state()
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	return ..()

/obj/item/lighter/proc/create_lighter_overlay()
	return mutable_appearance(icon, "lighter_overlay_[overlay_state][lit ? "-on" : ""]")

/obj/item/lighter/ignition_effect(atom/A, mob/user)
	if(is_hot())
		. = span_rose("With a single flick of [user.p_their()] wrist, [user] smoothly lights [A] with [src]. Damn [user.p_theyre()] cool.")

/obj/item/lighter/proc/set_lit(new_lit)
	if(lit == new_lit)
		return
	lit = new_lit
	if(lit)
		force = 5
		damtype = BURN
		hitsound = 'sound/items/welder.ogg'
		attack_verb_continuous = list("burns", "sings")
		attack_verb_simple = list("burn", "sing")
		START_PROCESSING(SSobj, src)
	else
		hitsound = "swing_hit"
		force = 0
		attack_verb_continuous = null //human_defense.dm takes care of it
		attack_verb_simple = null
		STOP_PROCESSING(SSobj, src)
	set_light_on(lit)
	update_icon()

/obj/item/lighter/extinguish()
	set_lit(FALSE)

/obj/item/lighter/attack_self(mob/living/user)
	if(user.is_holding(src))
		if(!lit)
			set_lit(TRUE)
			if(fancy)
				user.visible_message("Without even breaking stride, [user] flips open and lights [src] in one smooth movement.", span_notice("Without even breaking stride, you flip open and light [src] in one smooth movement."))
				playsound(src.loc, 'sound/items/zippo_on.ogg', 100, 1)
			else
				var/mob/living/carbon/human/H = user

				var/prot = !istype(H) || H.gloves

				if(prot || prob(75))
					user.visible_message("After a few attempts, [user] manages to light [src].", span_notice("After a few attempts, you manage to light [src]."))
				else
					var/hitzone = user.held_index_to_dir(user.active_hand_index) == "r" ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND
					user.apply_damage(5, BURN, hitzone)
					user.visible_message(span_warning("After a few attempts, [user] manages to light [src] - however, [user.p_they()] burn [user.p_their()] finger in the process."), span_warning("You burn yourself while lighting the lighter!"))
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "burnt_thumb", /datum/mood_event/burnt_thumb)
				playsound(src.loc, 'sound/items/lighter_on.ogg', 100, 1)

		else
			set_lit(FALSE)
			if(fancy)
				user.visible_message("You hear a quiet click, as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow.", span_notice("You quietly shut off [src] without even looking at what you're doing. Wow."))
				playsound(src.loc, 'sound/items/zippo_off.ogg', 100, 1)
			else
				user.visible_message("[user] quietly shuts off [src].", span_notice("You quietly shut off [src]."))
				playsound(src.loc, 'sound/items/lighter_off.ogg', 100, 1)
	else
		. = ..()

/obj/item/lighter/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && !user.combat_mode)
		if(cig.lit)
			to_chat(user, span_notice("The [cig.name] is already lit."))
		if(M == user)
			cig.attackby(src, user)
		else
			if(fancy)
				if(cig.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
					message_admins("[cig.name] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
					log_game("[cig.name] that contains plasma was lit by [key_name(user)] for [key_name(M)]!")
				if(cig.reagents.get_reagent_amount(/datum/reagent/fuel))
					message_admins("[cig.name] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
					log_game("[cig.name] that contains fuel was lit by [key_name(user)] for [key_name(M)]!")
				cig.light(span_rose("[user] whips the [name] out and holds it for [M]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light[user.p_s()] \the [cig] with."))
			else
				if(cig.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
					message_admins("[cig.name] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
					log_game("[cig.name] that contains plasma was lit by [key_name(user)] for [key_name(M)]!")
				if(cig.reagents.get_reagent_amount(/datum/reagent/fuel))
					message_admins("[cig.name] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
					log_game("[cig.name] that contains fuel was lit by [key_name(user)] for [key_name(M)]!")
				cig.light(span_notice("[user] holds the [name] out for [M], and lights [M.p_their()] [cig.name]."))
	else
		..()

/obj/item/lighter/process()
	open_flame()

/obj/item/lighter/is_hot()
	return lit * heat


/obj/item/lighter/greyscale
	name = "cheap lighter"
	desc = "A cheap lighter."
	icon_state = "lighter"
	fancy = FALSE
	overlay_list = list(
		"transp",
		"tall",
		"matte",
		"zoppo" //u cant stoppo th zoppo
		)
	var/lighter_color
	var/list/color_list = list( //Same 16 color selection as electronic assemblies
		COLOR_ASSEMBLY_BLACK,
		COLOR_FLOORTILE_GRAY,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

/obj/item/lighter/greyscale/Initialize(mapload)
	. = ..()
	if(!lighter_color)
		lighter_color = pick(color_list)
	update_icon()

/obj/item/lighter/greyscale/create_lighter_overlay()
	var/mutable_appearance/lighter_overlay = ..()
	lighter_overlay.color = lighter_color
	return lighter_overlay

/obj/item/lighter/greyscale/ignition_effect(atom/A, mob/user)
	if(is_hot())
		. = span_notice("After some fiddling, [user] manages to light [A] with [src].")


/obj/item/lighter/slime
	name = "slime zippo"
	desc = "A specialty zippo made from slimes and industry. Has a much hotter flame than normal."
	icon_state = "slighter"
	heat = 3000 //Blue flame!
	light_color = LIGHT_COLOR_CYAN
	overlay_state = "slime"
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/medicine/pyroxadone = 5)


///////////
//ROLLING//
///////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/item/food/grown))
		var/obj/item/food/grown/O = target
		if(HAS_TRAIT(O, TRAIT_DRIED))
			var/obj/item/clothing/mask/cigarette/rollie/R = new /obj/item/clothing/mask/cigarette/rollie(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to(R, R.chem_volume, transfered_by = user)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, span_notice("You roll the [target.name] into a rolling paper."))
			R.desc = "Dried [target.name] rolled up in a thin piece of paper."
		else
			to_chat(user, span_warning("You need to dry this first!"))

///////////////
//VAPE NATION//
///////////////
/obj/item/clothing/mask/vape
	name = "\improper E-Cigarette"
	desc = "A classy and highly sophisticated electronic cigarette, for classy and dignified gentlemen. A warning label reads \"Warning: Do not fill with flammable materials.\""//<<< i'd vape to that.
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "red_vape"
	item_state = null
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	var/chem_volume = 100
	var/vapetime = 0 //this so it won't puff out clouds every tick
	/// How often we take a drag in seconds
	var/vapedelay = 8
	var/screw = FALSE // kinky
	var/super = FALSE //for the fattest vapes dude.

/obj/item/clothing/mask/vape/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is puffin hard on dat vape, [user.p_they()] trying to join the vape life on a whole notha plane!"))//it doesn't give you cancer, it is cancer
	return (TOXLOSS|OXYLOSS)


CREATION_TEST_IGNORE_SUBTYPES(/obj/item/clothing/mask/vape)

/obj/item/clothing/mask/vape/Initialize(mapload, param_color)
	. = ..()
	create_reagents(chem_volume, NO_REACT)
	reagents.add_reagent(/datum/reagent/drug/nicotine, 50)
	if(!icon_state)
		if(!param_color)
			param_color = pick("red","blue","black","white","green","purple","yellow","orange")
		icon_state = "[param_color]_vape"
		item_state = "[param_color]_vape"

/obj/item/clothing/mask/vape/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_SCREWDRIVER)
		if(!screw)
			screw = TRUE
			to_chat(user, span_notice("You open the cap on [src]."))
			ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)
			if(obj_flags & EMAGGED)
				add_overlay("vapeopen_high")
			else if(super)
				add_overlay("vapeopen_med")
			else
				add_overlay("vapeopen_low")
		else
			screw = FALSE
			to_chat(user, span_notice("You close the cap on [src]."))
			DISABLE_BITFIELD(reagents.flags, OPENCONTAINER)
			cut_overlays()

	if(O.tool_behaviour == TOOL_MULTITOOL)
		if(screw && !(obj_flags & EMAGGED))//also kinky
			if(!super)
				cut_overlays()
				super = 1
				to_chat(user, span_notice("You increase the voltage of [src]."))
				add_overlay("vapeopen_med")
			else
				cut_overlays()
				super = 0
				to_chat(user, span_notice("You decrease the voltage of [src]."))
				add_overlay("vapeopen_low")

		if(screw && (obj_flags & EMAGGED))
			to_chat(user, span_notice("[src] can't be modified!"))
		else
			..()

/obj/item/clothing/mask/vape/should_emag(mob/user)
	if(!..())
		return FALSE
	if(!screw)
		to_chat(user, span_notice("The cryptographic sequencer attempts to connect to \the [src], but the cap is in the way."))
		return FALSE
	return TRUE

/obj/item/clothing/mask/vape/on_emag(mob/user)
	..()
	cut_overlays()
	super = 0
	to_chat(user, span_warning("You maximize the voltage of [src]."))
	add_overlay("vapeopen_high")
	var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread //for effect
	sp.set_up(5, 1, src)
	sp.start()

/obj/item/clothing/mask/vape/attack_self(mob/user)
	if(reagents.total_volume > 0)
		to_chat(user, span_notice("You empty [src] of all reagents."))
		reagents.clear_reagents()

/obj/item/clothing/mask/vape/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_MASK)
		if(!screw)
			to_chat(user, span_notice("You start puffing on the vape."))
			DISABLE_BITFIELD(reagents.flags, NO_REACT)
			START_PROCESSING(SSobj, src)
		else //it will not start if the vape is opened.
			to_chat(user, span_warning("You need to close the cap first!"))

/obj/item/clothing/mask/vape/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_MASK) == src)
		ENABLE_BITFIELD(reagents.flags, NO_REACT)
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/vape/proc/hand_reagents()//had to rename to avoid duplicate error
	if(reagents.total_volume)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.wear_mask) // if it's in the human/monkey mouth, transfer reagents to the mob
				var/fraction = min(REAGENTS_METABOLISM/reagents.total_volume, 1) //this will react instantly, making them a little more dangerous than cigarettes
				reagents.expose(C, INGEST, fraction)
				if(!reagents.trans_to(C, REAGENTS_METABOLISM))
					reagents.remove_any(REAGENTS_METABOLISM)
				if(reagents.get_reagent_amount(/datum/reagent/fuel))
					//HOT STUFF
					C.fire_stacks = 2
					C.IgniteMob()

				if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
					var/datum/effect_system/reagents_explosion/e = new()
					e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
					e.start()
					qdel(src)
				return
		reagents.remove_any(REAGENTS_METABOLISM)

/obj/item/clothing/mask/vape/process(delta_time)
	var/mob/living/M = loc

	if(isliving(loc))
		M.IgniteMob()

	vapetime += delta_time

	if(!reagents.total_volume)
		if(ismob(loc))
			to_chat(M, span_notice("[src] is empty!"))
			STOP_PROCESSING(SSobj, src)
			//it's reusable so it won't unequip when empty
		return
	//open flame removed because vapes are a closed system, they wont light anything on fire

	if(super && vapetime >= vapedelay)//Time to start puffing those fat vapes, yo.
		var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
		s.set_up(reagents, 1, 24, loc)
		s.start()
		vapetime -= vapedelay

	if((obj_flags & EMAGGED) && vapetime >= vapedelay)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
		s.set_up(reagents, 4, 24, loc)
		s.start()
		vapetime -= vapedelay
		if(prob(5))//small chance for the vape to break and deal damage if it's emagged
			playsound(get_turf(src), 'sound/effects/pop_expl.ogg', 50, 0)
			M.apply_damage(20, BURN, BODY_ZONE_HEAD)
			M.Paralyze(300)
			var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
			sp.set_up(5, 1, src)
			sp.start()
			to_chat(M, span_userdanger("[src] suddenly explodes in your mouth!"))
			qdel(src)
			return

	if(reagents && reagents.total_volume)
		hand_reagents()
