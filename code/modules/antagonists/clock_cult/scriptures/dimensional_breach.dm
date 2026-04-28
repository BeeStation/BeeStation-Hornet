/datum/clockcult/scripture/ark_activation
	name = "Ark Invigoration"
	desc = "Prepares the Ark for activation, alerting the crew of your existence. Requires 6 invokers."
	tip = "Prepares the Ark for activation, alerting the crew of your existence."
	invokation_text = list("Oh great Engine, take my soul...", "it is time for you to rise...", "through rifts you shall come...", "to rise among the stars again!")
	recital_sound = 'sound/magic/clockwork/narsie_attack.ogg'
	invokation_time = 14 SECONDS
	invokers_required = 6
	button_icon_state = "Spatial Gateway"
	power_cost = 5000
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/ark_activation/can_invoke()
	. = ..()
	if(!.)
		return FALSE

	if(!is_on_reebe(invoker))
		invoker.balloon_alert(invoker, "must be on Reebe!")
		return FALSE

/datum/clockcult/scripture/ark_activation/on_invoke_success()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		return

	gateway.open_gateway()
	return ..()
