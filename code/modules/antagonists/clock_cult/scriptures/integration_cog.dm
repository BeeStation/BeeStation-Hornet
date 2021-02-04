//==================================//
// !       Integration Cog       ! //
//==================================//

/datum/clockcult/scripture/integration_cog
	name = "Integration Cog"
	desc = "Fabricates an integration cog, which can be inserted into APCs to draw power and unlock scriptures."
	tip = "Install integration cogs into APCs to power the cult and unlock new scriptures."
	button_icon_state = "Integration Cog"
	power_cost = 0
	invokation_time = 10
	invokation_text = list("Tick tock Eng'Ine...")
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/integration_cog/invoke_success()
	var/obj/item/clockwork/integration_cog/IC = new()
	if(invoker.put_in_hands(IC, TRUE))
		to_chat(invoker, "<span class='brass'>You summon an integration cog!</span>")
		playsound(src, 'sound/machines/click.ogg', 50)
	else
		to_chat(invoker, "<span class='brass'>You need to have your inactive hand free to summon an integration cog!</span>")
		return FALSE
