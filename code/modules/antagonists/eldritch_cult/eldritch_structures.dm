/obj/structure/eldritch_crucible
	name = "Mawed Crucible"
	desc = "Immortalized cast iron, the steel-like teeth holding it in place, it's vile extract has the power of rebirthing things, remaking them from the very beginning."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "crucible"
	anchored = FALSE
	density = TRUE
	///How much mass this currently holds
	var/current_mass = 5
	///Maximum amount of mass
	var/max_mass = 5
	///Check to see if it is currently being used.
	var/in_use = FALSE

/obj/structure/eldritch_crucible/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user) && !IS_HERETIC_MONSTER(user))
		return
	if(current_mass < max_mass)
		. += "The Crucible requires [max_mass - current_mass] more organs or bodyparts!"
	else
		. += "The Crucible is ready to be used!"

	. += "You can anchor and reanchor it using Codex Cicatrix!"
	. += "It is currently [anchored == FALSE ? "unanchored" : "anchored"]"
	. += "This structure can brew 'Brew of Crucible soul' - when used it gives you the ability to phase through matter for 15 seconds, after the time elapses it teleports you back to your original location"
	. += "This structure can brew 'Brew of Dusk and Dawn' - when used it gives you xray for 1 minute"

/obj/structure/eldritch_crucible/attacked_by(obj/item/I, mob/living/user)
	if(istype(I,/obj/item/nullrod))
		qdel(src)
		return

	if(!IS_HERETIC(user) && !IS_HERETIC_MONSTER(user))
		if(iscarbon(user))
			devour(user)
		return

	if(istype(I,/obj/item/forbidden_book))
		playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
		anchored = !anchored
		to_chat(user,"<span class='notice'>You [anchored == FALSE ? "unanchor" : "anchor"] the crucible</span>")
		return

	if(istype(I,/obj/item/bodypart) || istype(I,/obj/item/organ))
		if(current_mass >= max_mass)
			to_chat(user,"<span class='notice'> Crucible is already full!</span>")
			return
		playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
		to_chat(user,"<span class='notice'>Crucible devours [I.name] and fills itself with a little bit of liquid!</span>")
		current_mass++
		qdel(I)
		update_icon_state()
		return

	return ..()

/obj/structure/eldritch_crucible/attack_hand(mob/user)
	if(!IS_HERETIC(user) && !IS_HERETIC_MONSTER(user))
		if(iscarbon(user))
			devour(user)
		return

	if(in_use)
		to_chat(user,"<span class='notice'>Crucible is already in use!</span>")
		return

	if(current_mass < max_mass)
		to_chat(user,"<span class='notice'>Crucible isn't full! Bring it more organs or bodyparts!</span>")
		return

	in_use = TRUE
	var/list/lst = list()
	for(var/X in subtypesof(/obj/item/eldritch_potion))
		var/obj/item/eldritch_potion/potion = X
		lst[initial(potion.name)] = potion
	var/type = lst[input(user,"Choose your brew","Brew") in lst]
	playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
	new type(drop_location())
	current_mass = 0
	in_use = FALSE
	update_icon_state()

///Proc that eats the active limb of the victim
/obj/structure/eldritch_crucible/proc/devour(mob/living/carbon/user)
	if(HAS_TRAIT(user,TRAIT_NODISMEMBER))
		return
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	to_chat(user,"<span class='danger'>Crucible grabs your arm and devours it whole!</span>")
	var/obj/item/bodypart/arm = user.get_active_hand()
	arm.dismember()
	qdel(arm)
	current_mass += current_mass < max_mass ? 1 : 0
	update_icon_state()

/obj/structure/eldritch_crucible/update_icon_state()
	. = ..()
	if(current_mass == max_mass)
		icon_state = "crucible"
	else
		icon_state = "crucible_empty"

/obj/structure/trap/eldritch
	name = "elder carving"
	desc = "Collection of unknown symbols, they remind you of days long gone..."
	icon = 'icons/obj/eldritch.dmi'
	charges = 1
	///Owner of the trap
	var/mob/owner

/obj/structure/trap/eldritch/Crossed(atom/movable/AM)
	if(!isliving(AM))
		return ..()
	var/mob/living/living_mob = AM
	if((owner && living_mob == owner) || IS_HERETIC(living_mob) || IS_HERETIC_MONSTER(living_mob))
		return ..()
	return ..()

/obj/structure/trap/eldritch/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I,/obj/item/melee/rune_knife) || istype(I,/obj/item/nullrod))
		qdel(src)

///Proc that sets the owner
/obj/structure/trap/eldritch/proc/set_owner(mob/_owner)
	owner = _owner

/obj/structure/trap/eldritch/alert
	name = "alert carving"
	icon_state = "alert_rune"
	alpha = 10

/obj/structure/trap/eldritch/alert/trap_effect(mob/living/L)
	if(owner)
		to_chat(owner,"<span class='big boldwarning'>[L.real_name] has stepped foot on the alert rune in [get_area(src)]!</span>")
	return ..()

//this trap can only get destroyed by rune carving knife or nullrod
/obj/structure/trap/eldritch/alert/flare()
	return

/obj/structure/trap/eldritch/tentacle
	name = "grasping carving"
	icon_state = "tentacle_rune"

/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/L)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/carbon_victim = L
	carbon_victim.Paralyze(5 SECONDS)
	carbon_victim.apply_damage(20,BRUTE,BODY_ZONE_R_LEG)
	carbon_victim.apply_damage(20,BRUTE,BODY_ZONE_L_LEG)
	playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	return ..()

/obj/structure/trap/eldritch/mad
	name = "mad carving"
	icon_state = "madness_rune"

/obj/structure/trap/eldritch/mad/trap_effect(mob/living/L)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/carbon_victim = L
	carbon_victim.adjustStaminaLoss(80)
	carbon_victim.silent += 10
	carbon_victim.Jitter(10)
	carbon_victim.Dizzy(20)
	carbon_victim.blind_eyes(2)
	SEND_SIGNAL(carbon_victim, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return ..()
