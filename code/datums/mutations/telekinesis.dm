//Telekinesis lets you interact with objects from range, and gives you a light blue halo around your head.
/datum/mutation/telekinesis
	name = "Telekinesis"
	desc = "A strange mutation that allows the holder to interact with objects purely through thought."
	quality = POSITIVE
	difficulty = 18
	limb_req = BODY_ZONE_HEAD
	instability = 30
	///Typecache of atoms that TK shouldn't interact with
	var/static/list/blacklisted_atoms = typecacheof(list(/atom/movable/screen))

/datum/mutation/telekinesis/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "telekinesishead"))

/datum/mutation/telekinesis/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/datum/mutation/telekinesis/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_RANGED)

/datum/mutation/telekinesis/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/telekinesis/proc/on_ranged_attack(mob/source, atom/target)
	SIGNAL_HANDLER

	if(is_type_in_typecache(target, blacklisted_atoms))
		return
	if(!tkMaxRangeCheck(source, target) || source.z != target.z)
		return
	return target.attack_tk(source)
