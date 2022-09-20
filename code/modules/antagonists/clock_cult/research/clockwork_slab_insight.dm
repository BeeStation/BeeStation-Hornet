/datum/clockcult_research_node/clockwork_slab
	name = "Insight - Clockwork Slab"
	desc = "Grant an insight to the follower, allowing them to create clockwork slabs, capable of invoking scriptures."
	total_cost = 5000000
	pre_requisits = list(/datum/clockcult_research_node/integration_cog)

/datum/clockcult_research_node/clockwork_slab/grant_believer_effect(mob/living/L)
	/// Grant the integration cog insight
	var/datum/action/innate/clockcult/spell/clockwork_slab/slab_insight = new()
	slab_insight.Grant(L)

/datum/clockcult_research_node/clockwork_slab/take_believer_effect(mob/living/L)
	// Delete the power
	for (var/datum/action/innate/clockcult/spell/clockwork_slab/slab_insight in L.actions)
		qdel(slab_insight)
