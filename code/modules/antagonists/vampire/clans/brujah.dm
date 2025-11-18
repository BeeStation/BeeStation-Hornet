#define BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS 4

/datum/vampire_clan/brujah
	name = CLAN_BRUJAH
	description = "The Brujah seek societal advancement through direct (and usually violent) means.\n\
		With age they develop a powerful physique and become capable of obliterating almost anything with their bare hands.\n\
		Be wary, as they are ferverous insurgents, rebels, and anarchists who always attempt to undermine local authorities. \n\
		Their favorite vassal gains the regular Brawn ability and substantially strengthened fists."
	clan_objective = /datum/objective/brujah
	join_icon_state = "brujah"
	join_description = "Gain an enhanced version of the brawn ability that lets you destroy most structures (including walls!) \
		Rebel against all authority and attempt to subvert it, but in turn \n\
		<b>IMPORTANT:</b> you break the Masquerade immediately upon joining!"

/datum/vampire_clan/brujah/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	owner_datum.special_vassals -= DISCORDANT_VASSAL // Removes Discordant Vassal, which is in the list by default.
	owner_datum.break_masquerade()
	vampiredatum.remove_nondefault_powers(return_levels = TRUE)
	// Copied over from 'clan_tremere.dm' with appropriate adjustment.
	for(var/datum/action/vampire/power as anything in vampiredatum.all_vampire_powers)
		if((initial(power.purchase_flags) & BRUJAH_DEFAULT_POWER))
			vampiredatum.grant_power(new power)

/// Raise the damage of both of their hands by four. Copied from 'finalize_spend_rank()' in '_clan.dm'
/datum/vampire_clan/brujah/on_favorite_vassal(datum/antagonist/vassal/favorite/favorite_vassal)
	. = ..()
	var/mob/living/carbon/human/human_vassal = favorite_vassal.owner.current
	if (istype(human_vassal))
		var/datum/species/vassal_species = human_vassal.dna.species
		vassal_species.punchdamage += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS

/**
 * Clan Objective
 * Brujah's Clan objective is to brainwash the highest ranking person on the station (if any.)
 * Made by referencing 'objective.dm'
 */
/datum/vampire_clan/brujah/give_clan_objective()
	if(!ispath(clan_objective))
		return
	clan_objective = new clan_objective()
	clan_objective.name = "Clan Objective"
	clan_objective.owner = vampiredatum.owner
	vampiredatum.objectives += clan_objective

	var/datum/objective/brujah/brujah_objective = clan_objective
	brujah_objective.choose_target()
	brujah_objective.update_explanation_text()
	vampiredatum.owner.announce_objectives()

/datum/objective/brujah
	name = "brujahrevolution"
	martyr_compatible = TRUE

	/// Set to true when the target is turned into a Discordant Vassal.
	var/target_subverted = FALSE
	/// I have no idea what this actually does. It's on a lot of other assassination/similar objectives though...
	var/target_role_type = FALSE

/datum/objective/brujah/check_completion()
	return target_subverted

/datum/objective/brujah/update_explanation_text()
	if(target?.current)
		explanation_text = "Subvert the authority of [target.name] the [!target_role_type ? target.assigned_role : target.special_role] \
			by turning [target.p_them()] into a Discordant Vassal with a persuassion rack."
	else
		explanation_text = "Free objective."

/datum/objective/brujah/proc/choose_target()
	var/list/target_options = SSjob.get_living_heads() //Look for heads...
	if(!length(target_options))
		target_options = SSjob.get_living_sec() //If no heads then look for security...
		if(!length(target_options))
			target_options = get_crewmember_minds() //If no security then look for ANY CREW MEMBER.

	if(length(target_options))
		target_options.Remove(owner)
	else
		update_explanation_text()
		return

	for(var/datum/mind/possible_target in target_options)
		if(!is_valid_target(possible_target))
			target_options.Remove(possible_target)

	if(length(target_options))
		target = pick(target_options)
	update_explanation_text()

#undef BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS
