//==================================//
// !      Dimensional Breach      ! //
//==================================//
/datum/clockcult/scripture/ark_activation
	name = "Ark Invigoration"
	desc = "Prepares the Ark for activation, alerting the crew of your existence. Requires 6 invokers."
	tip = "Prepares the Ark for activation, alerting the crew of your existence."
	button_icon_state = "Spatial Gateway"
	power_cost = 5000
	invokation_time = 140
	invokation_text = list("Oh great Engine, take my soul...", "it is time for you to rise...", "through rifts you shall come...", "to rise among the stars again!")
	invokers_required = 6
	category = SPELLTYPE_SERVITUDE
	recital_sound = 'sound/magic/clockwork/narsie_attack.ogg'

/datum/clockcult/scripture/ark_activation/New()
	. = ..()

/datum/clockcult/scripture/ark_activation/check_special_requirements(mob/user)
	if(!..())
		return FALSE
	if(!is_reebe(get_area(invoker).z))
		to_chat(invoker, "<span class='brass'>You need to be near the gateway to channel its energy!</span>")
		return FALSE
	return TRUE

/datum/clockcult/scripture/ark_activation/invoke_success()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		to_chat(invoker, "<span class='brass'>No celestial gateway located, contact the admins.</span>")
		return FALSE
	gateway.open_gateway()
