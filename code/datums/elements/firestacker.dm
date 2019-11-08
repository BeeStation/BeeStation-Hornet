/**
  * Can be applied to /atom/movable subtypes to make them apply fire stacks to things they hit
  */
/datum/element/firestacker
	element_flags = ELEMENT_DETACH
	/// A list in format {atom/movable/owner, number}
	/// Used to keep track of movables which want to apply a different number of fire stacks than default
	var/list/amount_by_owner = list()

/datum/element/firestacker/Attach(datum/target, amount)
	. = ..()
	if(!ismovableatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, .proc/impact)
	if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/item_attack)
		RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, .proc/item_attack_self)

	if(amount) // If amount is not given we default to 1 and don't need to save it here
		amount_by_owner[target] = amount

/datum/element/firestacker/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_SELF))
	amount_by_owner -= source

/datum/element/firestacker/proc/stack_on(datum/owner, mob/living/target)
	target.adjust_fire_stacks(amount_by_owner[owner] || 1)

/datum/element/firestacker/proc/impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isliving(hit_atom))
		stack_on(source, hit_atom)

/datum/element/firestacker/proc/item_attack(datum/source, atom/movable/target, mob/living/user)
	if(isliving(target))
		stack_on(source, target)

/datum/element/firestacker/proc/item_attack_self(datum/source, mob/user)
	if(isliving(user))
		stack_on(source, user)
