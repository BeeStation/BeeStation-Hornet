/datum/component/squeak
	var/squeak_chance = 100
	var/volume = 30

	// This is so shoes don't squeak every step
	var/steps = 0
	var/step_delay = 1

	// This is to stop squeak spam from inhand usage
	var/last_use = 0
	var/use_delay = 20

/datum/component/squeak/Initialize(volume_override, chance_override, step_delay_override, use_delay_override)
	if(datum_outputs)
		for(var/i in 1 to length(datum_outputs))
			datum_outputs[i] = SSoutputs.outputs[datum_outputs[i]]
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_PARENT_ATTACKBY), .proc/play_squeak)
	if(ismovableatom(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT), .proc/play_squeak)
		RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/play_squeak_crossed)
		RegisterSignal(parent, COMSIG_MOVABLE_DISPOSING, .proc/disposing_react)
		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ, COMSIG_ITEM_HIT_REACT), .proc/play_squeak)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/use_squeak)
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
			if(istype(parent, /obj/item/clothing/shoes))
				RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, .proc/step_squeak)

	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(isnum(step_delay_override))
		step_delay = step_delay_override
	if(isnum(use_delay_override))
		use_delay = use_delay_override

/datum/component/squeak/proc/play_squeak()
	if(prob(squeak_chance))
		if(!datum_outputs)
			CRASH("Squeak datum attempted to play missing datum")
		else
			playsound(parent, datum_outputs[1], volume, 1, -1, , , , , , src)

/datum/component/squeak/proc/step_squeak()
	if(steps > step_delay)
		play_squeak()
		steps = 0
	else
		steps++

/datum/component/squeak/proc/play_squeak_crossed(datum/source, atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.item_flags & ABSTRACT)
			return
		else if(istype(AM, /obj/item/projectile))
			var/obj/item/projectile/P = AM
			if(P.original != parent)
				return
	if(istype(AM, /obj/effect/dummy/phased_mob)) //don't squeek if they're in a phased/jaunting container.
		return
	var/atom/current_parent = parent
	if(isturf(current_parent.loc))
		play_squeak()

/datum/component/squeak/proc/use_squeak()
	if(last_use + use_delay < world.time)
		last_use = world.time
		play_squeak()

/datum/component/squeak/proc/on_equip(datum/source, mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_MOVABLE_DISPOSING, .proc/disposing_react, TRUE)

/datum/component/squeak/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_DISPOSING)

// Disposal pipes related shit
/datum/component/squeak/proc/disposing_react(datum/source, obj/structure/disposalholder/holder, obj/machinery/disposal/source)
	//We don't need to worry about unregistering this signal as it will happen for us automaticaly when the holder is qdeleted
	RegisterSignal(holder, COMSIG_ATOM_DIR_CHANGE, .proc/holder_dir_change)

/datum/component/squeak/proc/holder_dir_change(datum/source, old_dir, new_dir)
	//If the dir changes it means we're going through a bend in the pipes, let's pretend we bumped the wall
	if(old_dir != new_dir)
		play_squeak()

/datum/component/squeak/carp
	datum_outputs = list(/datum/outputs/bite)

/datum/component/squeak/bubbleplush
	datum_outputs = list(/datum/outputs/demonattack)

/datum/component/squeak/lizardplushie
	datum_outputs = list(/datum/outputs/slash)

/datum/component/squeak/snakeplushie
	datum_outputs = list(/datum/outputs/bite)

/datum/component/squeak/nukeplushie
	datum_outputs = list(/datum/outputs/punch)

/datum/component/squeak/slimeplushie
	datum_outputs = list(/datum/outputs/squelch)

/datum/component/squeak/beeplushie
	datum_outputs = list(/datum/outputs/bee)

/datum/component/squeak/mouse
	datum_outputs = list(/datum/outputs/squeak)

/datum/component/squeak/clownstep
	datum_outputs = list(/datum/outputs/clownstep)

/datum/component/squeak/bikehorn
	datum_outputs = list(/datum/outputs/bikehorn)

/datum/component/squeak/airhorn
	datum_outputs = list(/datum/outputs/airhorn)