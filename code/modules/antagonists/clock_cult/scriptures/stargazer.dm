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
	active_timer = addtimer(CALLBACK(src, .proc/finish_opening), 2, TIMER_STOPPABLE | TIMER_UNIQUE)

/obj/effect/stargazer_light/proc/close()
	icon_state = "stargazer_closing"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, .proc/finish_closing), 2, TIMER_STOPPABLE | TIMER_UNIQUE)

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

/obj/structure/destructible/clockwork/gear_base/stargazer/Initialize()
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
		if(istype(I, /obj/item))
			upgrade_weapon(I, user)
			cooldowntime = world.time + STARGAZER_COOLDOWN
			return
		to_chat(user, "<span class='brass'>You cannot upgrade [I].</span>")

/obj/structure/destructible/clockwork/gear_base/stargazer/proc/upgrade_weapon(obj/item/I, mob/living/user)
	ADD_TRAIT(I, TRAIT_STARGAZED, STARGAZER_TRAIT)
	switch(rand(1, 10))
		if(1)
			to_chat(user, "<span class='neovgre'>You feel [I] tighten to your hand.</span>")
			ADD_TRAIT(I, TRAIT_NODROP, STARGAZER_TRAIT)
			return
		if(2)
			to_chat(user, "<span class='neovgre'>[I] looks as if it could cut through anything.</span>")
			I.force += 6
			return
		if(3)
			I.w_class = WEIGHT_CLASS_TINY
			to_chat(user, "<span class='neovgre'>[I] suddenly shrinks!</span>")
			return
		if(4)
			I.light_power = 3
			I.light_range = 2
			I.light_color = LIGHT_COLOR_CLOCKWORK
			to_chat(user, "<span class='neovgre'>[I] shines with a brilliant light!</span>")
			return
		if(5)
			I.damtype = BURN
			I.force += 2
			I.light_power = 1.5
			I.light_range = 2
			I.light_color = LIGHT_COLOR_FIRE
			to_chat(user, "<span class='neovgre'>[I] emits off an intense heat!</span>")
			return
		if(6)
			I.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
			to_chat(user, "<span class='neovgre'>[I] becomes unbreakable!</span>")
			return
		if(7)
			to_chat(user, "<span class='neovgre'>You feel [I] attempting to communicate with you.</span>")
			var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the spirit of [user.real_name]'s [I]?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				var/mob/living/simple_animal/shade/S = new(src)
				S.ckey = C.ckey
				S.fully_replace_character_name(null, "The spirit of [name]")
				S.status_flags |= GODMODE
				S.copy_languages(user, LANGUAGE_MASTER)	//Make sure the sword can understand and communicate with the user.
				S.update_atom_languages()
				S.grant_all_languages(FALSE, FALSE, TRUE)	//Grants omnitongue
				var/input = sanitize_name(stripped_input(S,"What are you named?", ,"", MAX_NAME_LEN))

				if(src && input)
					name = input
					S.fully_replace_character_name(null, "The spirit of [input]")
			else
				to_chat(user, "<span class='neovgre'>The [I] stops talking to you...</span>")
			return
		if(8)
			to_chat(user, "<span class='neovgre'>[I] goes blunt.</span>")
			I.force = max(I.force - 4, 0)
			return
		if(9)
			to_chat(user, "<span class='neovgre'>Your scriptures seem to bend around [I], it is protecting you from magic!</span>")
			I.AddComponent(/datum/component/anti_magic, TRUE, TRUE)
			return
		if(10)
			to_chat(user, "<span class='neovgre'>[I] suddenly transforms, gaining the magical properties of shungite, it will protect your from all the evil forces!</span>")
			I.AddComponent(/datum/component/empprotection)
			I.AddComponent(/datum/component/anti_magic, TRUE, TRUE)
			I.color = COLOR_ALMOST_BLACK
			return
