/*
	Echoing
	The artifact plays a random sound
*/
/datum/xenoartifact_trait/major/noise
	label_name = "Echoing"
	label_desc = "Echoing: The artifact seems to contain echoing components. Triggering these components will cause the artifact to make a noise."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	///List of possible noises
	var/list/possible_noises = list('sound/effects/adminhelp.ogg', 'sound/effects/applause.ogg', 'sound/effects/bubbles.ogg',
					'sound/effects/empulse.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/explosion_distant.ogg',
					'sound/effects/laughtrack.ogg', 'sound/effects/magic.ogg', 'sound/effects/meteorimpact.ogg',
					'sound/effects/phasein.ogg', 'sound/effects/supermatter.ogg', 'sound/weapons/armbomb.ogg',
					'sound/weapons/blade1.ogg')
	///The noise we will make
	var/noise

/datum/xenoartifact_trait/major/noise/New(atom/_parent)
	. = ..()
	noise = pick(possible_noises)

/datum/xenoartifact_trait/major/noise/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	playsound(get_turf(component_parent.parent), noise, 50, FALSE)

/datum/xenoartifact_trait/major/noise/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED)
