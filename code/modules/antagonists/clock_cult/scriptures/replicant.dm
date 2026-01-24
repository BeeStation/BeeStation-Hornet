/datum/clockcult/scripture/replicant
	name = "Replicant"
	desc = "Causes the slab to summon a copy of itself, allowing you to replace slabs if they get lost."
	tip = "Make another slab as a backup."
	invokation_text = list("oh shit, I forgot that...")
	invokation_time = 3 SECONDS
	button_icon_state = "Replicant"
	power_cost = 50
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/replicant/on_invoke_success()
	var/obj/item/clockwork/clockwork_slab/new_slab = new(get_turf(invoker))
	invoker.put_in_hands(new_slab)
	return ..()
