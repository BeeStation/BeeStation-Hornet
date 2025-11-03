#define BRUJAH_FAVORITE_ghoul_ATTACK_BONUS 4

/datum/vampire_clan/brujah
	name = CLAN_BRUJAH
	description = "The Brujah seek societal advancement through direct (and usually violent) means.\n\
		With age they develop a powerful physique and become capable of obliterating almost anything with their bare hands.\n\
		Be wary, as they are ferverous insurgents, rebels, and anarchists who always attempt to undermine local authorities. \n\
		Their favorite ghoul gains the regular Brawn ability and substantially strengthened fists."
	join_icon_state = "brujah"
	join_description = "Gain an enhanced version of the brawn ability that lets you destroy most structures (including walls!) \
		Rebel against all authority and attempt to subvert it, but in turn \n\
		<b>IMPORTANT:</b> you break the Masquerade immediately upon joining!"
	default_humanity = 7

/datum/vampire_clan/brujah/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.remove_nondefault_powers(return_levels = TRUE)

	// TODO: this is where default powers should be given

/// Raise the damage of both of their hands by four. Copied from 'finalize_spend_rank()' in '_clan.dm'
/datum/vampire_clan/brujah/on_favorite_ghoul(datum/antagonist/ghoul/favorite/favorite_ghoul)
	. = ..()
	var/mob/living/carbon/human/human_ghoul = favorite_ghoul.owner.current
	if (istype(human_ghoul))
		var/datum/species/ghoul_species = human_ghoul.dna.species
		ghoul_species.punchdamage += BRUJAH_FAVORITE_ghoul_ATTACK_BONUS

#undef BRUJAH_FAVORITE_ghoul_ATTACK_BONUS
