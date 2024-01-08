/datum/xenoartifact_trait/minor
	priority = TRAIT_PRIORITY_MINOR
	register_targets = FALSE

/*
	Charged
	Increases the artifact trait strength by 25%
*/
/datum/xenoartifact_trait/minor/charged
	examine_desc = "charged"
	label_name = "Charged"
	label_desc = "Charged: The Artifact's design seems to incorporate a feedback loop. This will cause the artifact to produce more powerful effects."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT

/datum/xenoartifact_trait/minor/charged/New(atom/_parent)
	. = ..()
	parent.trait_strength *= 0.25

/datum/xenoartifact_trait/minor/charged/Destroy(force, ...)
	. = ..()
	parent.trait_strength /= 0.25
