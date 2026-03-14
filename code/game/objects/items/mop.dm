/obj/item/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_MEDIUM
	attack_verb_continuous = list("mops", "bashes", "bludgeons", "whacks")
	attack_verb_simple = list("mop", "bash", "bludgeon", "whack")
	resistance_flags = FLAMMABLE
	force_string = "robust... against germs"
	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBALANCE
	var/max_reagent_volume = 15
	var/mopspeed = 1.5 SECONDS
	var/insertable = TRUE
	var/static/list/clean_blacklist = typecacheof(list(
		/obj/item/reagent_containers/cup/bucket,
		/obj/structure/janitorialcart,
		/obj/structure/mop_bucket,
	))

/obj/item/mop/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleaner, mopspeed, pre_clean_callback=CALLBACK(src, PROC_REF(should_clean)), on_cleaned_callback=CALLBACK(src, PROC_REF(apply_reagents)))
	create_reagents(max_reagent_volume)
	GLOB.janitor_devices += src

/obj/item/mop/Destroy()
	GLOB.janitor_devices -= src
	return ..()

///Checks whether or not we should clean.
/obj/item/mop/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(clean_blacklist[atom_to_clean.type])
		return CLEAN_BLOCKED
	if(reagents.total_volume < 0.1)
		cleaner.balloon_alert(cleaner, "mop is dry!")
		return CLEAN_BLOCKED
	if(reagents.has_reagent(amount = 1, chemical_flags = REAGENT_CLEANS))
		return CLEAN_ALLOWED
	return CLEAN_ALLOWED|CLEAN_NO_WASH

/**
 * Applies reagents to the cleaned floor and removes them from the mop.
 *
 * Arguments
 * * cleaning_source: the source of the cleaning
 * * cleaned_atom: the atom that is being cleaned
 * * cleaner: the mob that is doing the cleaning
 */
/obj/item/mop/proc/apply_reagents(datum/cleaning_source, atom/cleaned_atom, mob/living/cleaner, clean_succeeded)
	if(!clean_succeeded)
		return
	reagents.expose(cleaned_atom, TOUCH, 10) //Needed for proper floor wetting.
	reagents.remove_all(1) //reaction() doesn't use up the reagents

/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	if(!insertable)
		to_chat(user, span_warning("You are unable to fit your [name] into the [J.name]."))
		return
	J.put_in_cart(src, user)
	J.mymop=src
	J.update_icon()

/obj/item/mop/cyborg
	insertable = FALSE

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	icon_state = "advmop"
	inhand_icon_state = "advmop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 12
	throwforce = 14
	throw_range = 4
	max_reagent_volume = 10
	mopspeed = 0.8 SECONDS
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
	var/amadd = min(max_reagent_volume - reagents.total_volume, refill_rate * delta_time)
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
	force = 15
	throwforce = 18
	throw_speed = 4
	attack_verb_continuous = list("mops", "stabs", "shanks", "jousts")
	attack_verb_simple = list("mop", "stab", "shank", "joust")
	sharpness = SHARP
	bleed_force = BLEED_SURFACE
	embedding = list("armour_block" = 40)
