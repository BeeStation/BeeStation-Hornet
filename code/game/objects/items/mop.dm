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
	w_class = WEIGHT_CLASS_MEDIUM
	attack_verb_continuous = list("mops", "bashes", "bludgeons", "whacks")
	attack_verb_simple = list("mop", "bash", "bludgeon", "whack")
	resistance_flags = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 15
	var/mopspeed = 15
	force_string = "robust... against germs"
	var/insertable = TRUE

/obj/item/mop/Initialize(mapload)
	. = ..()
	create_reagents(mopcap)
	GLOB.janitor_devices += src

/obj/item/mop/Destroy()
	GLOB.janitor_devices -= src
	return ..()

/obj/item/mop/proc/clean(turf/A, mob/living/cleaner)
	if(reagents.has_reagent(/datum/reagent/water, 1) || reagents.has_reagent(/datum/reagent/water/holywater, 1) || reagents.has_reagent(/datum/reagent/consumable/ethanol/vodka, 1) || reagents.has_reagent(/datum/reagent/space_cleaner, 1))
		A.wash(CLEAN_SCRUB)
	reagents.expose(A, TOUCH, 10)	//Needed for proper floor wetting.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(reagents.total_volume < 1)
		to_chat(user, span_warning("Your mop is dry!"))
		return

	var/turf/T = get_turf(A)

	if(istype(A, /obj/item/reagent_containers/cup/bucket) || istype(A, /obj/structure/janitorialcart))
		return

	if(T)
		user.visible_message("[user] begins to clean \the [T] with [src].", span_notice("You begin to clean \the [T] with [src]..."))

		if(do_after(user, src.mopspeed, target = T))
			to_chat(user, span_notice("You finish mopping."))
			clean(T)

/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	if(insertable)
		J.put_in_cart(src, user)
		J.mymop=src
		J.update_icon()
	else
		to_chat(user, span_warning("You are unable to fit your [name] into the [J.name]."))
		return

/obj/item/mop/cyborg
	insertable = FALSE

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	mopcap = 10
	icon_state = "advmop"
	item_state = "advmop"
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

/obj/item/mop/advanced/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj,src)
	to_chat(user, span_notice("You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position."))
	playsound(user, 'sound/machines/click.ogg', 30, 1)

/obj/item/mop/advanced/process(delta_time)
	var/amadd = min(mopcap - reagents.total_volume, refill_rate * delta_time)
	if(amadd > 0)
		reagents.add_reagent(refill_reagent, amadd)

/obj/item/mop/advanced/examine(mob/user)
	. = ..()
	. += span_notice("The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.")

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
	attack_verb_continuous = list("mops", "stabs", "shanks", "jousts")
	attack_verb_simple = list("mop", "stab", "shank", "joust")
	sharpness = SHARP
	bleed_force = BLEED_SURFACE
	embedding = list("armour_block" = 40)
