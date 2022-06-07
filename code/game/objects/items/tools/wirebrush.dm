/// The amount of radiation to give to the user of this tool; regardless of what they did with it.
#define CRIT_FAIL_PROB 1
/// The amount of damage to take in BOTH Tox and Oxy on critical fail
#define CRIT_FAIL_DAMAGE 15
/// The amount of radiation to give to the user of this tool; regardless of what they did with it.
#define RADIATION_ON_USE 20
/// The amount of radiation to give to the user if they roll the worst effects. Negative numbers will heal radiation instead!
#define CRIT_FAIL_RADS 50
/// We only apply damage and force vomit if the user has OVER this many rads
#define CRIT_FAIL_RADS_THRESHOLD 300


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

/obj/item/wirebrush/advanced/examine(mob/user)
	. = ..()
	. += "<span class='danger'>There is a warning label that indicates extended use of [src] may result in loss of hair, yellowing skin, and death.</span>"

/obj/item/wirebrush/advanced/pre_attack(atom/A, mob/living/carbon/user)
	. = ..()

	if(!istype(user))
		return

	user.rad_act(RADIATION_ON_USE) //Apply rads on user

	if(user.radiation > 100) //To warn the user
		if(prob(10))
			to_chat(user, "<span class='danger'>You feel an odd warm tingling sensation coming from the brush.</span>")

	if(prob(CRIT_FAIL_PROB))
		if(HAS_TRAIT(user, TRAIT_RADIMMUNE)) // For those with radimmunity
			to_chat(user, "<span class='danger'>You feel oddly warmer.</span>")
			user.rad_act(CRIT_FAIL_RADS)
			return

		to_chat(user, "<span class='danger'>You feel a sharp pain as your entire body grows oddly warm.</span>")
		user.emote("cough")
		if(user.radiation > CRIT_FAIL_RADS_THRESHOLD) // If you ignore the warning signs you get punished
			user.vomit()
			user.adjustToxLoss(CRIT_FAIL_DAMAGE, forced=TRUE)
			user.adjustOxyLoss(CRIT_FAIL_DAMAGE, forced=TRUE)
		return


#undef CRIT_FAIL_PROB
#undef CRIT_FAIL_DAMAGE
#undef RADIATION_ON_USE
#undef CRIT_FAIL_RADS
#undef CRIT_FAIL_RADS_THRESHOLD
