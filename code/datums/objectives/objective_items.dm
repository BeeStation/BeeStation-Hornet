//Contains the target item datums for Steal objectives.

/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/requiredjob = list()			// If this list is not null, then at least 1 of these jobs must be spawned in order for this objective to be valid. Used for objectives that are hidden/non obvious when stolen.
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)
	var/list/special_equipment = list()
	/// Require that the target item is spawned at roundstart by closets.
	var/require_item_spawns_at_roundstart = TRUE
	/// If we want a different item other than the target to be the track target
	var/special_track_type
	/// Special flags for the target
	var/objective_flags = NONE

/datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/proc/is_valid()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

/datum/objective_item/steal/is_valid()
	if (!length(requiredjob))
		return TRUE
	for (var/mob/living/L in GLOB.mob_living_list)
		if (L.mind?.assigned_role in requiredjob)
			return TRUE
	return FALSE

/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun."
	targetitem = /obj/item/gun/energy/laser/captain
	difficulty = 5
	excludefromjob = list(JOB_NAME_CAPTAIN)
	objective_flags = STEAL_DIRECTIVE_TOXIN

/datum/objective_item/steal/hoslaser
	name = "the head of security's personal laser gun."
	targetitem = /obj/item/gun/energy/e_gun/hos
	difficulty = 10
	excludefromjob = list(JOB_NAME_HEADOFSECURITY)
	requiredjob = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN)
	objective_flags = STEAL_DIRECTIVE_TOXIN

/datum/objective_item/steal/handtele
	name = "a hand teleporter."
	targetitem = /obj/item/hand_tele
	difficulty = 5
	excludefromjob = list(JOB_NAME_CAPTAIN, JOB_NAME_RESEARCHDIRECTOR)
	objective_flags = STEAL_DIRECTIVE_TOXIN

/datum/objective_item/steal/jetpack
	name = "the Captain's jetpack."
	targetitem = /obj/item/tank/jetpack/oxygen/captain
	difficulty = 5
	excludefromjob = list(JOB_NAME_CAPTAIN)

/datum/objective_item/steal/magboots
	name = "the chief engineer's advanced magnetic boots."
	targetitem =  /obj/item/clothing/shoes/magboots/advance
	difficulty = 5
	excludefromjob = list(JOB_NAME_CHIEFENGINEER)
	requiredjob = list(JOB_NAME_CHIEFENGINEER)

/datum/objective_item/steal/capmedal
	name = "the medal of captaincy."
	targetitem = /obj/item/clothing/accessory/medal/gold/captain
	difficulty = 5
	excludefromjob = list(JOB_NAME_CAPTAIN)

/datum/objective_item/steal/hypo
	name = "the hypospray."
	targetitem = /obj/item/reagent_containers/hypospray/CMO
	difficulty = 5
	excludefromjob = list(JOB_NAME_CHIEFMEDICALOFFICER)
	requiredjob = list(JOB_NAME_CHIEFMEDICALOFFICER)
	objective_flags = STEAL_DIRECTIVE_TOXIN

/datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk."
	targetitem = /obj/item/disk/nuclear
	difficulty = 5
	excludefromjob = list(JOB_NAME_CAPTAIN)
	objective_flags = STEAL_DIRECTIVE_TOXIN

/datum/objective_item/steal/nukedisc/check_special_completion(obj/item/disk/nuclear/N)
	return !N.fake

/datum/objective_item/steal/reflector
	name = "a reflector vest."
	targetitem = /obj/item/clothing/suit/armor/laserproof
	difficulty = 3
	excludefromjob = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN)
	requiredjob = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN)

/datum/objective_item/steal/reactive
	name = "the reactive teleport armor."
	targetitem = /obj/item/clothing/suit/armor/reactive/teleport
	difficulty = 5
	excludefromjob = list(JOB_NAME_RESEARCHDIRECTOR)
	requiredjob = list(JOB_NAME_RESEARCHDIRECTOR)
	objective_flags = STEAL_DIRECTIVE_TOXIN

/datum/objective_item/steal/documents
	name = "any set of secret documents of any organization."
	targetitem = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	difficulty = 5

/datum/objective_item/steal/nuke_core
	name = "the heavily radioactive plutonium core from the onboard self-destruct. Take care to wear the proper safety equipment when extracting the core!"
	targetitem = /obj/item/nuke_core
	difficulty = 15

/datum/objective_item/steal/nuke_core/New()
	special_equipment += /obj/item/storage/box/syndie_kit/nuke
	..()

/datum/objective_item/steal/supermatter
	name = "a sliver of a supermatter crystal. Be sure to use the proper safety equipment when extracting the sliver!"
	targetitem = /obj/item/nuke_core/supermatter_sliver
	difficulty = 15
	special_track_type = /obj/machinery/power/supermatter_crystal

/datum/objective_item/steal/supermatter/New()
	special_equipment += /obj/item/storage/box/syndie_kit/supermatter
	..()

/datum/objective_item/steal/supermatter/TargetExists()
	return GLOB.main_supermatter_engine != null

/datum/objective_item/steal/functionalai
	name = "a functional AI."
	targetitem = /obj/item/aicard
	difficulty = 20 //beyond the impossible
	requiredjob = list(JOB_NAME_AI)
	special_track_type = /mob/living/silicon/ai

/datum/objective_item/steal/functionalai/New()
	. = ..()
	altitems += typesof(/obj/item/mod/control) // only here so we can account for AIs tucked away in a MODsuit.

/datum/objective_item/steal/functionalai/check_special_completion(obj/item/potential_storage)
	var/mob/living/silicon/ai/being

	if(istype(potential_storage, /obj/item/aicard))
		var/obj/item/aicard/card = potential_storage
		being = card.AI // why is this one capitalized and the other one not? i wish i knew.
	else if(istype(potential_storage, /obj/item/mod/control))
		var/obj/item/mod/control/suit = potential_storage
		if(isAI(suit.ai_assistant))
			being = suit.ai_assistant
	else
		stack_trace("check_special_completion() called on [src] with [potential_storage] ([potential_storage.type])! That's not supposed to happen!")
		return FALSE

	if(isAI(being) && being.stat != DEAD)
		return TRUE

	return FALSE

/datum/objective_item/steal/blueprints
	name = "the station blueprints."
	targetitem = /obj/item/areaeditor/blueprints
	difficulty = 10
	excludefromjob = list(JOB_NAME_CHIEFENGINEER)
	altitems = list(/obj/item/photo)
	requiredjob = list(JOB_NAME_CHIEFENGINEER)

/datum/objective_item/steal/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints))
		return TRUE
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.picture.has_blueprints)	//if the blueprints are in frame
			return TRUE
	return FALSE

/datum/objective_item/steal/blackbox
	name = "the blackbox."
	targetitem = /obj/item/blackbox
	difficulty = 10
	excludefromjob = list(JOB_NAME_CHIEFENGINEER,JOB_NAME_STATIONENGINEER,JOB_NAME_ATMOSPHERICTECHNICIAN)
	requiredjob = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_RESEARCHDIRECTOR)

//Unique Objectives
/datum/objective_item/unique/docs_red
	name = "the \"Red\" secret documents."
	targetitem = /obj/item/documents/syndicate/red
	difficulty = 10

/datum/objective_item/unique/docs_blue
	name = "the \"Blue\" secret documents."
	targetitem = /obj/item/documents/syndicate/blue
	difficulty = 10

/datum/objective_item/special/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/special/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Old ninja objectives.
/datum/objective_item/special/pinpointer/nuke
	name = "the captain's pinpointer."
	targetitem = /obj/item/pinpointer
	difficulty = 10

/datum/objective_item/special/aegun
	name = "an advanced energy gun."
	targetitem = /obj/item/gun/energy/e_gun/nuclear
	difficulty = 10

/datum/objective_item/special/ddrill
	name = "a diamond drill."
	targetitem = /obj/item/pickaxe/drill/diamonddrill
	difficulty = 10

/datum/objective_item/special/boh
	name = "a bag of holding."
	targetitem = /obj/item/storage/backpack/holding
	difficulty = 10

/datum/objective_item/special/hypercell
	name = "a hyper-capacity power cell."
	targetitem = /obj/item/stock_parts/cell/hyper
	difficulty = 5

/datum/objective_item/special/laserpointer
	name = "a laser pointer."
	targetitem = /obj/item/laser_pointer
	difficulty = 5

/datum/objective_item/special/corgimeat
	name = "a piece of corgi meat."
	targetitem = /obj/item/food/meat/slab/corgi
	difficulty = 5

/datum/objective_item/stack/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/stack/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Stack objectives get their own subtype
/datum/objective_item/stack
	name = "5 cardboard."
	targetitem = /obj/item/stack/sheet/cardboard
	difficulty = 9001
	require_item_spawns_at_roundstart = FALSE

/datum/objective_item/stack/check_special_completion(obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount>=target_amount

/datum/objective_item/stack/diamond
	name = "10 diamonds."
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10

/datum/objective_item/stack/gold
	name = "50 gold bars."
	targetitem = /obj/item/stack/sheet/mineral/gold
	difficulty = 15

/datum/objective_item/stack/uranium
	name = "25 refined uranium bars."
	targetitem = /obj/item/stack/sheet/mineral/uranium
	difficulty = 10
