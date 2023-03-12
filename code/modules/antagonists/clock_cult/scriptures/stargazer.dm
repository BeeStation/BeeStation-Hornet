//==================================//
// !      Stargazer     ! //
//==================================//
/datum/clockcult/scripture/create_structure/stargazer
	name = "Stargazer"
	desc = "Allows you to enchant your weapons and armor, however enchanting can have risky side effects."
	tip = "Make your gear more powerful by enchanting them with stargazers."
	button_icon_state = "Stargazer"
	power_cost = 300
	invokation_time = 80
	invokation_text = list("A light of Eng'ine shall empower my armaments!")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/stargazer
	cogs_required = 2
	category = SPELLTYPE_STRUCTURES

//Stargazer light

/obj/effect/stargazer_light
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "stargazer_closed"
	pixel_y = 10
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 160
	var/active_timer

/obj/effect/stargazer_light/ex_act()
	return

/obj/effect/stargazer_light/Destroy(force)
	cancel_timer()
	. = ..()

/obj/effect/stargazer_light/proc/finish_opening()
	icon_state = "stargazer_light"
	active_timer = null

/obj/effect/stargazer_light/proc/finish_closing()
	icon_state = "stargazer_closed"
	active_timer = null

/obj/effect/stargazer_light/proc/open()
	icon_state = "stargazer_opening"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_opening)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)

/obj/effect/stargazer_light/proc/close()
	icon_state = "stargazer_closing"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_closing)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)

/obj/effect/stargazer_light/proc/cancel_timer()
	if(active_timer)
		deltimer(active_timer)

#define STARGAZER_COOLDOWN 1800

//Stargazer structure
/obj/structure/destructible/clockwork/gear_base/stargazer
	name = "stargazer"
	desc = "A small pedestal, glowing with a divine energy."
	clockwork_desc = "A small pedestal, glowing with a divine energy. Used to provide special powers and abilities to items."
	default_icon_state = "stargazer"
	anchored = TRUE
	break_message = "<span class='warning'>The stargazer collapses.</span>"
	var/cooldowntime = 0
	var/mobs_in_range = FALSE
	var/fading = FALSE
	var/obj/effect/stargazer_light/sg_light

/obj/structure/destructible/clockwork/gear_base/stargazer/Initialize(mapload)
	. = ..()
	sg_light = new(get_turf(src))
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/gear_base/stargazer/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(!QDELETED(sg_light))
		qdel(sg_light)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/stargazer/process()
	if(QDELETED(sg_light))
		return
	var/mob_nearby = FALSE
	for(var/mob/living/M in viewers(2, get_turf(src)))
		if(is_servant_of_ratvar(M))
			mob_nearby = TRUE
			break
	if(mob_nearby && !mobs_in_range)
		sg_light.open()
		mobs_in_range = TRUE
	else if(!mob_nearby && mobs_in_range)
		mobs_in_range = FALSE
		sg_light.close()

/obj/structure/destructible/clockwork/gear_base/stargazer/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent != INTENT_HELP)
		. = ..()
		return
	if(!anchored)
		to_chat(user, "<span class='brass'>You need to anchor [src] to the floor first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='brass'>[src] is still warming up, it will be ready in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	if(HAS_TRAIT(I, TRAIT_STARGAZED))
		to_chat(user, "<span class='brass'>[I] has already been enhanced!</span>")
		return
	to_chat(user, "<span class='brass'>You begin placing [I] onto [src].</span>")
	if(do_after(user, 60, target=I))
		if(cooldowntime > world.time)
			to_chat(user, "<span class='brass'>[src] is still warming up, it will be ready in [DisplayTimeText(cooldowntime - world.time)].</span>")
			return
		if(HAS_TRAIT(I, TRAIT_STARGAZED))
			to_chat(user, "<span class='brass'>[I] has already been enhanced!</span>")
			return
		if(istype(I, /obj/item) && !istype(I, /obj/item/clothing) && I.force)
			upgrade_weapon(I, user)
			cooldowntime = world.time + STARGAZER_COOLDOWN
			return
		to_chat(user, "<span class='brass'>You cannot upgrade [I].</span>")

/obj/structure/destructible/clockwork/gear_base/stargazer/proc/upgrade_weapon(obj/item/I, mob/living/user)
	//Prevent re-enchanting
	ADD_TRAIT(I, TRAIT_STARGAZED, STARGAZER_TRAIT)
	//Add a glowy colour
	I.add_atom_colour(rgb(243, 227, 183), ADMIN_COLOUR_PRIORITY)
	//Pick a random effect
	var/static/list/possible_components = subtypesof(/datum/component/enchantment)
	I.AddComponent(pick(possible_components))
	to_chat(user, "<span class='notice'>[I] glows with a brilliant light!</span>")
