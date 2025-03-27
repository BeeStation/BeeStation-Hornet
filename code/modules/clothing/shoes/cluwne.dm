/obj/item/clothing/shoes/cluwne
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = DROPDEL
	slowdown = SHOES_SLOWDOWN+1
	var/footstep = 1
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes/clown

/obj/item/clothing/shoes/cluwne/Initialize(mapload)
	.=..()
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, PROC_REF(on_step))
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/shoes/cluwne/proc/on_step()
	SIGNAL_HANDLER

	if(footstep > 1)
		playsound(src, "clownstep", 50, 1)
		footstep = 0
	else
		footstep++

/obj/item/clothing/shoes/cluwne/equipped(mob/user, slot)
	. = ..()
	if(!user.has_dna())
		return
	if(slot == ITEM_SLOT_FEET)
		var/mob/living/carbon/C = user
		C.dna.add_mutation(CLUWNEMUT)
	return
