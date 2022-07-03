/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	block_upgrade_walk = 1
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 50 //MONKESTATION EDIT CHANGE
	var/mopspeed = 15
	force_string = "robust... against germs"
	var/insertable = TRUE

/obj/item/mop/Initialize(mapload)
	. = ..()
	create_reagents(mopcap)
	//MONKESTATION EDIT ADDITION
	AddElement(/datum/element/liquids_interaction, on_interaction_callback = /obj/item/mop/.proc/attack_on_liquids_turf)

/obj/item/mop/Destroy()
	. = ..()
	RemoveElement(/datum/element/liquids_interaction, on_interaction_callback = /obj/item/mop/.proc/attack_on_liquids_turf)

/obj/item/mop/proc/attack_on_liquids_turf(obj/item/mop/the_mop, turf/T, mob/user, obj/effect/abstract/liquid_turf/liquids)
	if(!user.Adjacent(T))
		return FALSE
	var/free_space = the_mop.reagents.maximum_volume - the_mop.reagents.total_volume
	if(free_space <= 0)
		to_chat(user, "<span class='warning'>Your mop can't absorb any more!</span>")
		return TRUE
	var/list/range_random = list()
	for(var/turf/temp in view(5, T))
		if(temp.liquids)
			range_random += temp
	for(var/turf in range_random)
		if(do_after(user, src.mopspeed, target = T))
			if(the_mop.reagents.total_volume == the_mop.mopcap)
				to_chat(user, "<span class='warning'>Your mop can't absorb any more!</span>")
				return TRUE
			var/turf/choice_turf = get_turf(pick(range_random))
			if(choice_turf.liquids)
				var/datum/reagents/tempr = choice_turf.liquids.take_reagents_flat(free_space)
				tempr.trans_to(the_mop.reagents, tempr.total_volume)
				range_random -= choice_turf
				to_chat(user, "<span class='notice'>You soak the mop with some liquids.</span>")
				qdel(tempr)
		else
			return FALSE
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE
	//MONKESTATION EDIT END

/obj/item/mop/proc/clean(turf/A)
	if(reagents.has_reagent(/datum/reagent/water, 1) || reagents.has_reagent(/datum/reagent/water/holywater, 1) || reagents.has_reagent(/datum/reagent/consumable/ethanol/vodka, 1) || reagents.has_reagent(/datum/reagent/space_cleaner, 1))
		SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_MEDIUM)
		for(var/obj/effect/O in A)
			if(is_cleanable(O))
				qdel(O)
	reagents.reaction(A, TOUCH, 10)	//Needed for proper floor wetting.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	. = ..()
	//MONKESTATION EDIT ADDITION
	if(.)
		return
	//MONKESTATION EDIT END
	if(!proximity)
		return

	if(reagents.total_volume < 1)
		to_chat(user, "<span class='warning'>Your mop is dry!</span>")
		return

	var/turf/T = get_turf(A)

	if(istype(A, /obj/item/reagent_containers/glass/bucket) || istype(A, /obj/structure/janitorialcart))
		return

	if(T)
		user.visible_message("[user] begins to clean \the [T] with [src].", "<span class='notice'>You begin to clean \the [T] with [src]...</span>")

		if(do_after(user, src.mopspeed, target = T))
			to_chat(user, "<span class='notice'>You finish mopping.</span>")
			clean(T)


/obj/effect/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	else
		return ..()


/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	if(insertable)
		J.put_in_cart(src, user)
		J.mymop=src
		J.update_icon()
	else
		to_chat(user, "<span class='warning'>You are unable to fit your [name] into the [J.name].</span>")
		return

/obj/item/mop/cyborg
	insertable = FALSE

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this! Due to the self-wetting technology, also comes equipped with a self drying mode toggle with ALT." //MONKESTATION EDIT
	name = "advanced mop"
	mopcap = 100 //MONKESTATION EDIT CHANGE
	icon_state = "advmop"
	item_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 12
	throwforce = 14
	throw_range = 4
	mopspeed = 8
	var/refill_enabled = TRUE //Self-refill toggle for when a janitor decides to mop with something other than water.
	/// Amount of reagent to refill per second
	var/refill_rate = 0.5
	var/refill_reagent = /datum/reagent/water //Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING
	var/drying_mode = FALSE
/obj/item/mop/advanced/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	if(drying_mode)
		to_chat(user, "<span class = 'notice'> Please turn off drying mode before enabling the condenser.</span>")
		return
	refill_enabled = !refill_enabled
	to_chat(user, "<span class='notice'>You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position.</span>")
	playsound(user, 'sound/machines/click.ogg', 30, 1)

/obj/item/mop/advanced/process(delta_time)
	if(refill_enabled)
		var/amadd = min(mopcap - reagents.total_volume, refill_rate * delta_time)
		if(amadd > 0)
			reagents.add_reagent(refill_reagent, amadd)
	else if(drying_mode)
		reagents.remove_all(mopcap)
/obj/item/mop/advanced/AltClick(mob/user)
	if(refill_enabled)
		to_chat(user, "<span class = 'notice'> Please turn off the condenser before enabling drying mode.</span>")
		return
	drying_mode = !drying_mode
	to_chat(user, "<span class = 'notice'>You set the drying switch to the '[drying_mode ? "ON" : "OFF"] position.'</span>" )
	playsound(user, 'sound/machines/click.ogg', 30, 1)
/obj/item/mop/advanced/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.</span>"
	. += "<span class='notice'>The drying switch is set to <b>[drying_mode ? "ON" : "OFF"]</b>.</span>"
/obj/item/mop/advanced/Destroy()
	if(refill_enabled)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mop/advanced/cyborg
	insertable = FALSE

/obj/item/mop/sharp //Basically a slightly worse spear.
	desc = "A mop with a sharpened handle. Careful!"
	name = "sharpened mop"
	force = 10
	throwforce = 18
	throw_speed = 4
	attack_verb = list("mopped", "stabbed", "shanked", "jousted")
	sharpness = IS_SHARP
	embedding = list("armour_block" = 40)
