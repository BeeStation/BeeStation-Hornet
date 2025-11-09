/**
 * The wirebrush is a tool whose sole purpose is to remove rust from anything that is rusty.
 * Because of the inherent nature of hard countering rust heretics it does it very slowly.
 */
/obj/item/wirebrush
	name = "wirebrush"
	desc = "A tool that is used to scrub the rust thoroughly off walls. Not for hair!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "wirebrush"
	tool_behaviour = TOOL_RUSTSCRAPER
	toolspeed = 1

/**
 * An advanced form of the wirebrush that trades the safety of the user for instant rust removal.
 * If the person using this is unlucky they are going to die painfully.
 */
/obj/item/wirebrush/advanced
	name = "advanced wirebrush"
	desc = "An advanced wirebrush; uses radiation to almost instantly liquify rust."
	icon_state = "wirebrush_adv"
	toolspeed = 0.1

	/// How likely is a critical fail?
	var/crit_fail_prob = 1

/obj/item/wirebrush/advanced/examine(mob/user)
	. = ..()
	. += span_danger("There is a warning label that indicates extended use of [src] may result in loss of hair, yellowing skin, and death.")

/obj/item/wirebrush/advanced/proc/irradiate(mob/living/user)
	if(!istype(user))
		return

	if(prob(crit_fail_prob))
		to_chat(user, span_danger("You feel a sharp pain as \the [src] grows oddly warm."))
		SSradiation.irradiate(user, intensity = 100)
		user.emote("vomit")
		return

	if(prob(25))
		user.emote("cough")
