/datum/clockcult/scripture/integration_cog
	name = "Integration Cog"
	desc = "Fabricates an integration cog, which can be inserted into APCs to draw power and unlock scriptures."
	tip = "Install integration cogs into APCs to power the cult and unlock new scriptures."
	invokation_text = list("Tick tock Eng'Ine...")
	button_icon_state = "Integration Cog"
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/integration_cog/on_invoke_success()
	var/obj/item/clockwork/integration_cog/cog = new()
	invoker.put_in_hands(cog)

	to_chat(invoker, span_brass("You summon an integration cog!"))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	return ..()

