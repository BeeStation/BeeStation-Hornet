//==================================//
// !           Replicant          ! //
//==================================//
/datum/clockcult/scripture/replicant
	name = "Replicant"
	desc = "Causes the slab to summon a copy of itself, allowing you to replace slabs if they get lost."
	tip = "Make another slab as a backup."
	button_icon_state = "Replicant"
	power_cost = 50
	invokation_time = 30
	invokation_text = list("oh shit, I forgot that...")
	category = SPELLTYPE_SERVITUDE
	cogs_required = 0

/datum/clockcult/scripture/replicant/invoke_success()
	var/obj/item/clockwork/clockwork_slab/slab = new(get_turf(invoker))
	invoker.put_in_hands(slab)
