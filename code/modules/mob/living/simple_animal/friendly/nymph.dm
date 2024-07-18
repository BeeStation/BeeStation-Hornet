// This code is for dionae nymphs that get spread out in the room when a diona dies. One is player controlled.

/mob/living/simple_animal/nymph
	name = "diona nymph"
	desc = "Is that a plant?"
	icon = 'icons/mob/animal.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "nymph_dead"
	gender = NEUTER
	gold_core_spawnable = FRIENDLY_SPAWN
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/pets_held.dmi'
	held_state = "nymph"
	footstep_type = FOOTSTEP_MOB_CLAW
	hud_type = /datum/hud/nymph
	butcher_results = list(/obj/item/food/meat/slab/human/mutant/diona = 4)

	health = 100
	maxHealth = 100
	melee_damage = 0
	attack_sound = 'sound/weapons/slash.ogg'
	var/can_namepick_as_adult = FALSE
	var/adult_name = "diona gestalt"
	var/death_msg = "expires with a pitiful chirrup..."

	var/amount_grown = 0
	var/max_grown = 250
	var/time_of_birth
	var/instance_num
	var/is_ghost_spawn = FALSE //For if a ghost can become this.
	var/is_drone = FALSE //Is a remote controlled nymph from a diona.
	var/drone_parent //The diona which can control the nymph, if there is one
	var/old_name // The diona nymph's old name.
	var/datum/action/nymph/evolve/evolve_ability //The ability to grow up into a diona.
	var/datum/action/nymph/SwitchFrom/switch_ability //The ability to switch back to the parent diona as a drone.
	var/list/features = list()

/mob/living/simple_animal/nymph/Initialize()
	. = ..()
	time_of_birth = world.time
	add_verb(/mob/living/proc/lay_down)
	evolve_ability = new
	evolve_ability.Grant(src)
	instance_num = rand(1, 1000)
	name = "[initial(name)] ([instance_num])"
	real_name = name
	regenerate_icons()
	ADD_TRAIT(src, TRAIT_MUTE, "nymph")

/mob/living/simple_animal/nymph/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Health"] = GENERATE_STAT_TEXT("[round((health / maxHealth) * 100)]%")
	if(!is_drone)
		tab_data["Growth"] = GENERATE_STAT_TEXT("[(round(amount_grown / max_grown * 100))]%")
	return tab_data

/mob/living/simple_animal/nymph/Life(delta_time, times_fired)
	. = ..()
	if(!is_drone)
		update_progression()
	get_stat_tab_status()

/mob/living/simple_animal/nymph/death(gibbed)
	evolve_ability.Remove(src)
	if(is_drone)
		switch_ability.Remove(src)
	return ..(gibbed,death_msg)

/mob/living/simple_animal/nymph/UnarmedAttack(atom/A, proximity)
	melee_damage = 0
	. = ..()

/mob/living/simple_animal/nymph/attack_animal(mob/living/L)
	if(is_drone)
		. = ..()
		return
	if(istype(src, /mob/living/simple_animal/nymph) && stat != DEAD)
		if(mind == null) // No RRing fellow nymphs
			var/mob/living/simple_animal/nymph/M = L
			M.melee_damage = 50
			M.amount_grown += 50
			M.visible_message("<span class='warning'>[L] devours [src]!</span>",
							  "<span class='warning'> You devour [src]!</span>")
	. = ..()
	melee_damage = 0

/mob/living/simple_animal/nymph/spawn_gibs()
	new /obj/effect/decal/cleanable/insectguts(drop_location())
	playsound(drop_location(), 'sound/effects/blobattack.ogg', 60, TRUE)

/mob/living/simple_animal/nymph/attack_ghost(mob/dead/observer/user)
	if(client || key || ckey)
		to_chat(user, "<span class='warning'>\The [src] already has a player.")
		return
	if(!is_ghost_spawn)
		to_chat(user, "<span class='warning'>\The [src] is not possessable!")
		return
	var/control_ask = alert("Do you wish to take control of \the [src]", "Chirp Time?", "Yes", "No")
	if(control_ask == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(QDELETED(src) || QDELETED(user) || !user.client)
		return
	var/mob/living/simple_animal/nymph/newnymph = src
	newnymph.key = user.key
	newnymph.unique_name = TRUE
	to_chat(newnymph, "<span class='boldwarning'>Remember that you have forgotten all of your past lives and are a new person!</span>")

/mob/living/simple_animal/nymph/proc/update_progression()
	if(amount_grown < max_grown)
		amount_grown++
	if(amount_grown > max_grown)
		amount_grown = max_grown

/datum/action/nymph/evolve
	name = "Evolve"
	desc = "Evolve into your adult form."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "grow"

/datum/action/nymph/evolve/Trigger()
	. = ..()
	var/mob/living/simple_animal/nymph/user = owner
	if(!isnymph(user))
		return
	if(user.is_drone)
		to_chat(user, "<span class='danger'>You can't grow up as a lone nymph drone!")
		return
	if(user.movement_type & VENTCRAWLING)
		to_chat(user, "<span class='danger'>You cannot evolve while in a vent.</span>")
		return

	if(user.amount_grown >= user.max_grown)
		if(user.incapacitated()) //something happened to us while we were choosing.
			return
		user.evolve()
		return TRUE
	else
		to_chat(user, "<span class='danger'>You are not fully grown.</span>")
		return FALSE


/mob/living/simple_animal/nymph/verb/evolve()
	if(stat != CONSCIOUS)
		return

	if(amount_grown < max_grown)
		to_chat(src, "<span class='warning'>You are not fully grown.")
		return
	if(src.movement_type & VENTCRAWLING)
		to_chat(src, "<span class='danger'>You cannot evolve while in a vent.</span>")
		return
	if(istype(loc, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/L = loc
		src.loc = L.loc
		qdel(L)

	src.visible_message(
		("<span class='warning'>[src] begins to shift and quiver, and erupts in a shower of shed bark as it splits into a tangle of nearly a dozen new dionaea."),
		("<span class='warning'>You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients to surge with growth, splitting into a tangle of at least a dozen new dionaea. We have attained our gestalt form.")
	)

	var/mob/living/carbon/human/species/diona/adult = new /mob/living/carbon/human/species/diona(src.loc)
	adult.set_species(SPECIES_DIONA)
	adult.dna.features = src.features
	adult.update_body()
	if(!("neutral" in src.faction))
		adult.faction = src.faction
	if(old_name)
		adult.real_name = src.old_name
	else
		adult.fully_replace_character_name(name, adult.dna.species.random_name(gender))
	if(mind)
		mind.transfer_to(adult)
	else
		adult.key = src.key
	qdel(src)

/datum/action/nymph/SwitchFrom
	name = "Return"
	desc = "Return back into your adult form."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "return"

/datum/action/nymph/SwitchFrom/Trigger(DroneParent)
	. = ..()
	var/mob/living/simple_animal/nymph/user = owner
	if(!isnymph(user))
		return
	if(user.movement_type & VENTCRAWLING)
		to_chat(user, "<span class='danger'>You cannot switch while in a vent.</span>")
		return
	SwitchFrom(user, DroneParent)

/datum/action/nymph/SwitchFrom/proc/SwitchFrom(mob/living/simple_animal/nymph/user, mob/living/carbon/M)
	var/datum/mind/C = user.mind
	M = user.drone_parent
	if(user.stat == CONSCIOUS)
		user.visible_message("<span class='notice'>[user] \
			stops moving and starts staring vacantly into space.</span>",
			"<span class='notice'>You stop moving this form...</span>")
	else
		to_chat(M, "<span class='notice'>You abandon this nymph...</span>")
	C.transfer_to(M)
	M.mind = C
	M.visible_message("<span class='notice'>[M] blinks and looks \
		around.</span>",
		"<span class='notice'>...and move this one instead.</span>")

