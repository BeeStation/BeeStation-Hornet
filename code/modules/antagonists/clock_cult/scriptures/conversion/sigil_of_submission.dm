//==================================//
// !      Sigil of Submission     ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_submission
	name = "Sigil of Submission"
	desc = "Summons a sigil of submission, used to enlighten weak minds."
	tip = "Creats a sigil of submission, useful for showing untruths the light."
	button_icon_state = "Sigil of Submission"
	power_cost = 250
	invokation_time = 50
	invokation_text = list("Relax you animal...", "...for I shall show you the truth.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/submission
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE
