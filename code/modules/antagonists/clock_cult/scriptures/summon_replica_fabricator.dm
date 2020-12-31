//==================================//
// !       Replica Fab       ! //
//==================================//

/datum/clockcult/scripture/replica_fabricator
	name = "Replica Fabricator"
	desc = "Summons a replica fabricator, which can fabricate brass for building defenses."
	tip = "Create brass and repair structures"
	button_icon_state = "Replica Fabricator"
	power_cost = 400
	cogs_required = 2
	invokation_time = 50
	invokation_text = list("Their technology is no match for the power of Eng'ine.")
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/replica_fabricator/invoke_success()
	var/obj/item/clockwork/replica_fabricator/RF = new(get_turf(invoker))
	invoker.put_in_inactive_hand(RF)
