/datum/clockcult/scripture/replica_fabricator
	name = "Replica Fabricator"
	desc = "Summons a replica fabricator, which can fabricate brass for building defenses."
	tip = "Create brass and repair structures"
	invokation_text = list("Their technology is no match for the power of Eng'ine.")
	invokation_time = 5 SECONDS
	button_icon_state = "Replica Fabricator"
	power_cost = 400
	cogs_required = 2
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/replica_fabricator/on_invoke_success()
	var/obj/item/clockwork/replica_fabricator/fabricator = new(invoker.drop_location())
	invoker.put_in_inactive_hand(fabricator)
	return ..()
