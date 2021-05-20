#define ABSTRACTION_HOLOGRAM_TRAIT "abstractionHologram"
#define ABSTRACTION_CRYSTAL_RANGE 5

GLOBAL_LIST_INIT(abstraction_crystals, list())

/datum/antagonist/servant_of_ratvar/manifestation
	name = "Servant Manifestation"
	counts_towards_total = FALSE

/datum/clockcult/scripture/create_structure/abstraction_crystal
	name = "Abstraction Crystal"
	desc = "Summons an Abstraction Crystal, which allows servants to manifest themself to protect the nearby area."
	tip = "Upon your manifestation taking damage, you will only receive 40% of the damage."
	button_icon_state = "Clockwork Obelisk"
	power_cost = 750
	invokation_time = 50
	invokation_text = list("Through the boundaries and planes..", "..we break with ease")
	summoned_structure = /obj/structure/destructible/clockwork/abstraction_crystal
	cogs_required = 5
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/create_structure/abstraction_crystal/check_special_requirements(mob/user)
	if(!..())
		return FALSE
	var/obj/structure/destructible/clockwork/structure = locate() in get_turf(invoker)
	if(structure)
		to_chat(invoker, "<span class='brass'>You cannot invoke that here, the tile is occupied by [structure].</span>")
		return FALSE
	if(locate(/obj/structure/destructible/clockwork/abstraction_crystal) in range(5))
		to_chat(invoker, "<span class='brass'>There is an Abstraction Crystal nearby, you cannot place this here.</span>")
		return FALSE
	return TRUE

/datum/clockcult/scripture/create_structure/abstraction_crystal/invoke_success()
	var/created_structure = new summoned_structure(get_turf(invoker))
	var/obj/structure/destructible/clockwork/abstraction_crystal/clockwork_structure = created_structure
	var/chosen_keyword = stripped_input(invoker, "Enter a keyword for the crystal.", "Keyword")
	if(chosen_keyword)
		clockwork_structure.key_word = chosen_keyword
	else
		clockwork_structure.key_word = "Abstraction Crystal - [GLOB.abstraction_crystals.len]"
	if(clockwork_structure.key_word in GLOB.abstraction_crystals)
		clockwork_structure.deconstruct(FALSE)
		return
	GLOB.abstraction_crystals[clockwork_structure.key_word] = clockwork_structure
	if(istype(clockwork_structure))
		clockwork_structure.owner = invoker.mind

//=============
// A human that can do human things, however it is linked to a crystal
// Instead of receiving damage normally, damage is applied to the crystal
// and this mobs health is equal to the health of the crystal
//=============

/mob/living/carbon/human/abstraction_hologram
	var/obj/structure/destructible/clockwork/abstraction_crystal/linked_crystal
	var/mob/living/owner
	var/last_check_health = 0

/mob/living/carbon/human/abstraction_hologram/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN, ABSTRACTION_HOLOGRAM_TRAIT)
	ADD_TRAIT(src, TRAIT_NODISMEMBER, ABSTRACTION_HOLOGRAM_TRAIT)
	dna.species.species_traits |= NOBLOOD

/mob/living/carbon/human/abstraction_hologram/death(gibbed)
	//Put the person back in their body
	if(!QDELETED(owner))
		owner.key = key
		owner.log_message("lost control of the abstraction crystal they were manifested at", LOG_ATTACK)
	. = ..()

/mob/living/carbon/human/abstraction_hologram/Move(NewLoc, direct)
	if(get_dist(NewLoc, linked_crystal) > ABSTRACTION_CRYSTAL_RANGE)
		return FALSE
	. = ..()

/mob/living/carbon/human/abstraction_hologram/Life()
	if(QDELETED(owner) || QDELETED(src))
		return
	if(QDELETED(linked_crystal))
		return
	. = ..()
	//Convert any body part damage loss to clone
	var/health_lost = last_check_health - health
	if(health_lost > 0)
		damage_crystal(health_lost)
	var/required_health =  (linked_crystal.obj_integrity / linked_crystal.max_integrity) * maxHealth
	var/health_delta_needed = max(health - required_health, 0)
	adjustCloneLoss(health_delta_needed)	//Adjust clone loss so that our health = crystals health
	last_check_health = health
	if(incapacitated() || get_dist(src, linked_crystal) > ABSTRACTION_CRYSTAL_RANGE)
		linked_crystal.deconstruct(FALSE)

/mob/living/carbon/human/abstraction_hologram/proc/damage_crystal(amount)
	if(QDELETED(src) || QDELETED(linked_crystal) || QDELETED(owner))
		return
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.take_overall_damage(amount * 0.4)
	linked_crystal.take_damage(amount)

//===================
// ABSTRACTION CRYSTAL
// Allows cultists to manifest themselves at another crystal with a phantom that can attack
// and perform all normal human actions. On taking damage, 30% goes to the user's mob and 70% goes to the crystal (which only has 100 health)
//===================

/obj/structure/destructible/clockwork/abstraction_crystal
	name = "abstraction crystal"
	desc = "An other-worldly structure, its lattice pulsating with a bright, pulsating light."
	icon_state = "obelisk_inactive"
	clockwork_desc = "A powerful crystal allowing the user to manifest themselves at other abstraction crystals."
	max_integrity = 200
	break_message = "<span class='warning'>The crystal explodes into a shower of shards!</span>"
	var/key_word = ""
	var/mob/living/activator
	var/mob/living/carbon/human/abstraction_hologram/active_hologram
	var/list/tracked_items
	var/processing = FALSE
	var/dusting_hologram = FALSE	//Prevents us from crashing the game by dusting a hologram being dusted

/obj/structure/destructible/clockwork/abstraction_crystal/Initialize()
	. = ..()
	tracked_items = list()

/obj/structure/destructible/clockwork/abstraction_crystal/attack_hand(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	if(!iscarbon(user))
		return
	if(!QDELETED(active_hologram))
		if(istype(user, /mob/living/carbon/human/abstraction_hologram))
			if(user == active_hologram)
				clear_ghost_items()
			return
		return
	var/list/valid_crystals = GLOB.abstraction_crystals.Copy()
	valid_crystals.Remove(key_word)
	var/selected = input(user, "Select a crystal to manifest at", "Manifestation") as null|anything in valid_crystals
	if(!selected || !(selected in valid_crystals))
		return
	var/obj/structure/destructible/clockwork/abstraction_crystal/AC = GLOB.abstraction_crystals[selected]
	AC.manifest(user)

/obj/structure/destructible/clockwork/abstraction_crystal/eminence_act(mob/living/simple_animal/eminence/eminence)
	manifest(eminence)

/obj/structure/destructible/clockwork/abstraction_crystal/proc/manifest(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return
	if(!(iscarbon(user) || iseminence(user)))
		return
	if(istype(user, /mob/living/carbon/human/abstraction_hologram))
		return
	if(!QDELETED(active_hologram))
		return
	new /obj/effect/temp_visual/steam_release(get_turf(src))
	clear_ghost_items()	//This dusts the manifestation, so make sure it is before the creation of the mob or the game will crash hard.
	activator = user
	dusting_hologram = FALSE
	active_hologram = new(get_turf(src))
	active_hologram.owner = user
	active_hologram.linked_crystal = src
	active_hologram.alpha = 150 //Makes them translucent
	active_hologram.key = user.key
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		active_hologram.real_name = C.real_name
	else
		active_hologram.real_name = "the eminence"

	var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
	active_hologram.add_overlay(forbearance)

	to_chat(active_hologram, "<span class='neovgre'>You manifest yourself at [src].</span>")
	to_chat(active_hologram, "<span class='neovgre'>You will only take a fraction of the damage your manifestation receives.</span>")
	to_chat(active_hologram, "<span class='neovgre'>Peer into the crystal again to return to your old body.</span>")

	//Equip with generic gear
	add_servant_of_ratvar(active_hologram, silent=TRUE, servant_type=/datum/antagonist/servant_of_ratvar/manifestation)
	active_hologram.equipOutfit(/datum/outfit/clockcult/armaments)
	for(var/obj/item in active_hologram.get_contents())
		item.alpha = 180
		item.flags_1 |= HOLOGRAM_1
		tracked_items += item
	Beam(active_hologram, icon_state="nzcrentrs_power", time=INFINITY)
	START_PROCESSING(SSobj, src)
	processing = TRUE

/obj/structure/destructible/clockwork/abstraction_crystal/Destroy()
	GLOB.abstraction_crystals.Remove(key_word)
	clear_ghost_items()
	. = ..()

/obj/structure/destructible/clockwork/abstraction_crystal/process()
	if(QDELETED(active_hologram) || QDELETED(activator) || activator.stat)
		clear_ghost_items()
		return
	for(var/obj/I as anything in tracked_items)
		if(!QDELETED(I))
			//manifested items will persist until picked up or the hologram is destroyed
			if(ismob(I.loc) && I.loc != active_hologram)
				derez(I)

/obj/structure/destructible/clockwork/abstraction_crystal/proc/clear_ghost_items()
	if(dusting_hologram)
		return
	dusting_hologram = TRUE
	if(processing)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE
	for(var/obj/I as anything in tracked_items)
		derez(I)
	if(!QDELETED(active_hologram))
		for(var/atom/movable/M in active_hologram.get_contents())//Drop everything so real items don't get dusted
			M.forceMove(get_turf(active_hologram))
		active_hologram.dust()
	tracked_items = list()

/obj/structure/destructible/clockwork/abstraction_crystal/proc/derez(obj/O)
	tracked_items -= O
	if(QDELETED(O))
		return
	var/turf/T = get_turf(O)
	for(var/atom/movable/AM in O)
		AM.forceMove(T)
	qdel(O)

#undef ABSTRACTION_HOLOGRAM_TRAIT
