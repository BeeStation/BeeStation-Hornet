#define TRAIT_ABSTRACTION_HOLOGRAM "abstraction_hologram"
#define ABSTRACTION_CRYSTAL_RANGE 5

GLOBAL_LIST_INIT(abstraction_crystals, list())

/datum/clockcult/scripture/create_structure/abstraction_crystal
	name = "Abstraction Crystal"
	desc = "Summons an Abstraction Crystal, which allows servants to manifest themself to protect the nearby area."
	tip = "Upon your manifestation taking damage, you will only receive 40% of the damage."
	invokation_text = list("Through the boundaries and planes..", "..we break with ease")
	invokation_time = 5 SECONDS
	button_icon_state = "Clockwork Obelisk"
	power_cost = 750
	cogs_required = 5
	summoned_structure = /obj/structure/destructible/clockwork/abstraction_crystal
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/create_structure/abstraction_crystal/can_invoke()
	. = ..()
	if(!.)
		return FALSE

	for(var/obj/structure/destructible/clockwork/abstraction_crystal/crystal in range(ABSTRACTION_CRYSTAL_RANGE))
		invoker.balloon_alert(invoker, "too close to another crystal!")
		return FALSE

/datum/clockcult/scripture/create_structure/abstraction_crystal/on_invoke_success()
	var/created_structure = new summoned_structure.type(get_turf(invoker))
	var/obj/structure/destructible/clockwork/abstraction_crystal/clockwork_structure = created_structure

	// Chose keyword for the crystal
	var/chosen_keyword = tgui_input_text(invoker, "Enter a keyword for the crystal.", "Keyword", "Abstraction Crystal - [length(GLOB.abstraction_crystals) + 1]")
	if(!chosen_keyword)
		clockwork_structure.deconstruct(FALSE)
		return

	clockwork_structure.key_word = chosen_keyword

	// Check if the keyword is already taken
	if(clockwork_structure.key_word in GLOB.abstraction_crystals)
		clockwork_structure.deconstruct(FALSE)
		return

	// Add the crystal to the global list
	GLOB.abstraction_crystals[clockwork_structure.key_word] = clockwork_structure

	// Don't call parent because it will spawn another crystal
	GLOB.clockcult_power -= power_cost
	GLOB.clockcult_vitality -= vitality_cost

/*
* A human that can do human things, however it is linked to a crystal
* Instead of receiving damage normally, damage is applied to the crystal
* This mobs health is equal to the health of the crystal
*/
/datum/antagonist/servant_of_ratvar/manifestation
	name = "Servant Manifestation"
	counts_towards_total = FALSE

/mob/living/carbon/human/abstraction_hologram
	/// The crystal that summoned this hologram
	var/obj/structure/destructible/clockwork/abstraction_crystal/linked_crystal
	/// The original body of the person who manifested this hologram
	var/mob/living/owner
	/// The hologram's health from the last life tick
	var/previous_health = 100

/mob/living/carbon/human/abstraction_hologram/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_ABSTRACTION_HOLOGRAM)
	ADD_TRAIT(src, TRAIT_NODISMEMBER, TRAIT_ABSTRACTION_HOLOGRAM)
	ADD_TRAIT(src, TRAIT_NO_BLOOD, TRAIT_ABSTRACTION_HOLOGRAM)

/mob/living/carbon/human/abstraction_hologram/death(gibbed)
	// Put the person back in their body
	if(!QDELETED(owner))
		owner.key = key
		owner.log_message("lost control of the abstraction crystal they were manifested at", LOG_ATTACK)
	return ..()

/mob/living/carbon/human/abstraction_hologram/Move(NewLoc, direct)
	if(get_dist(NewLoc, linked_crystal) > ABSTRACTION_CRYSTAL_RANGE)
		return FALSE
	return ..()

/mob/living/carbon/human/abstraction_hologram/Life()
	if(QDELETED(owner) || QDELETED(src))
		return
	if(QDELETED(linked_crystal))
		return

	// Damage the crystal and hologram's owner
	var/health_lost = previous_health - health
	if(health_lost > 0)
		damage_crystal(health_lost)
	previous_health = health

	// We were forcibly moved out of the crystal's range, lets break the crystal
	if(incapacitated() || get_dist(src, linked_crystal) > ABSTRACTION_CRYSTAL_RANGE)
		linked_crystal.deconstruct(FALSE)
	return ..()
/*
* On taking damage, 40% goes to the owner's mob and 60% goes to the crystal
*/
/mob/living/carbon/human/abstraction_hologram/proc/damage_crystal(amount)
	if(QDELETED(src) || QDELETED(linked_crystal) || QDELETED(owner))
		return

	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.take_overall_damage(amount * 0.4)
	linked_crystal.take_damage(amount * 0.6)

/obj/structure/destructible/clockwork/abstraction_crystal
	name = "abstraction crystal"
	desc = "An other-worldly structure, its lattice pulsating with a bright, pulsating light."
	icon_state = "obelisk_inactive"
	clockwork_desc = span_brass("A powerful crystal allowing the user to manifest themselves at other abstraction crystals.")
	max_integrity = 200
	break_message = span_warning("The crystal explodes into a shower of shards!")

	/// Crystals have identifiers to easily find them when manifesting
	var/key_word = ""
	/// The original body of the person who manifested the crystal
	var/mob/living/activator
	/// The hologram that this crystal manifested
	var/mob/living/carbon/human/abstraction_hologram/linked_hologram
	/// The equipment that the hologram is spawned with. Stored here so it can be deleted when the hologram is dusted
	var/list/tracked_items = list()
	/// Whether or not we're processing
	var/processing = FALSE
	/// Whether or not we're currently dusting the hologram.
	/// PowerfulBacon from 4 years ago says this will crash the game if not here but I need to test it out
	var/dusting_hologram = FALSE
	/// The beam effect from the crystal to the abstraction
	var/datum/beam/abstraction_beam

/obj/structure/destructible/clockwork/abstraction_crystal/Destroy()
	GLOB.abstraction_crystals.Remove(key_word)
	clear_ghost()

	// Stop processing
	if(processing)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE
	return ..()

/obj/structure/destructible/clockwork/abstraction_crystal/eminence_act(mob/living/simple_animal/eminence/eminence)
	manifest(eminence)

/obj/structure/destructible/clockwork/abstraction_crystal/process()
	if(QDELETED(linked_hologram) || QDELETED(activator) || activator.stat == DEAD)
		clear_ghost()
		return

	// If someone other than the linked hologram holds any of the manifested items, delete the item
	for(var/obj/item as anything in tracked_items)
		if(!QDELETED(item))
			if(ismob(item.loc) && item.loc != linked_hologram)
				derez(item)

/obj/structure/destructible/clockwork/abstraction_crystal/attack_hand(mob/user)
	. = ..()

	// Manifested holograms can interact with their linked crystal to return to their original body
	if(istype(user, /mob/living/carbon/human/abstraction_hologram))
		if(!QDELETED(linked_hologram))
			if(user == linked_hologram)
				clear_ghost()
				return

		balloon_alert(user, "not your crystal!")
		return

	if(!IS_SERVANT_OF_RATVAR(user))
		return
	if(!iscarbon(user))
		return

	// Get a list of valid crystals
	var/list/valid_crystals = GLOB.abstraction_crystals.Copy()
	valid_crystals.Remove(key_word)
	if(!length(valid_crystals))
		balloon_alert(user, "no crystals to manifest at!")
		return

	// Choose a crystal
	var/selected = tgui_input_list(user, "Select a crystal to manifest at", "Manifestation", valid_crystals)
	if(!selected)
		return

	// Manifest
	var/obj/structure/destructible/clockwork/abstraction_crystal/chosen_crystal = GLOB.abstraction_crystals[selected]
	if(!chosen_crystal)
		balloon_alert(user, "chosen crystal no longer exists!")
		return
	chosen_crystal.manifest(user)

/obj/structure/destructible/clockwork/abstraction_crystal/proc/manifest(mob/living/user)
	if(!IS_SERVANT_OF_RATVAR(user))
		return
	if(!iscarbon(user) && !iseminence(user))
		return
	if(!QDELETED(linked_hologram))
		return

	dusting_hologram = FALSE
	activator = user

	// Create hologram
	linked_hologram = new(get_turf(src))
	linked_hologram.owner = user
	linked_hologram.key = user.key
	linked_hologram.linked_crystal = src
	linked_hologram.alpha = 150 //Makes them translucent

	// Set name
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		linked_hologram.real_name = carbon_user.real_name
	else
		linked_hologram.real_name = "The Eminence"

	// Effects
	var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", CALCULATE_MOB_OVERLAY_LAYER(MUTATIONS_LAYER))
	linked_hologram.add_overlay(forbearance)

	to_chat(linked_hologram, span_neovgre("You manifest yourself at [key_word]."))

	// Equip with generic gear
	add_servant_of_ratvar(linked_hologram, silent = TRUE, servant_type=/datum/antagonist/servant_of_ratvar/manifestation)
	linked_hologram.equipOutfit(/datum/outfit/clockcult/armaments)

	tracked_items = list()
	for(var/obj/item in linked_hologram.get_contents())
		item.alpha = 180
		item.flags_1 |= HOLOGRAM_1
		tracked_items += item

	// Create a beam from the crystal to the linked hologram
	abstraction_beam = Beam(linked_hologram, icon_state = "nzcrentrs_power", time = INFINITY)

	// Start processing
	START_PROCESSING(SSobj, src)
	processing = TRUE

/obj/structure/destructible/clockwork/abstraction_crystal/proc/clear_ghost()
	if(dusting_hologram)
		return
	dusting_hologram = TRUE

	// Stop processing
	if(processing)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE

	// Delete tracked items
	for(var/obj/item as anything in tracked_items)
		derez(item)

	// Clear beam
	qdel(abstraction_beam)

	// Drop any items the hologram may have picked up and dust them
	if(!QDELETED(linked_hologram))
		for(var/atom/movable/atom in linked_hologram.get_contents())
			atom.forceMove(get_turf(linked_hologram))

		linked_hologram.dust()

/obj/structure/destructible/clockwork/abstraction_crystal/proc/derez(obj/object)
	tracked_items -= object
	if(QDELETED(object))
		return

	var/turf/turf = get_turf(object)
	for(var/atom/movable/atom in object)
		atom.forceMove(turf)

	qdel(object)

#undef TRAIT_ABSTRACTION_HOLOGRAM
#undef ABSTRACTION_CRYSTAL_RANGE
