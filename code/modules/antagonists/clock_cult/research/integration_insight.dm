/datum/clockcult_research_node/integration_cog
	name = "Insight - Integration Cog"
	desc = "Deliver a vision to believers, allowing them to create integration cogs which generate power for the ark."
	// This node is free and started with
	total_cost = 0

/datum/clockcult_research_node/integration_cog/grant_believer_effect(mob/living/L)
	/// Grant the integration cog insight
	var/datum/action/innate/clockcult/spell/integration_cog/integration_cog_power = new()
	integration_cog_power.Grant(L)

/datum/clockcult_research_node/integration_cog/take_believer_effect(mob/living/L)
	// Delete the power
	for (var/datum/action/innate/clockcult/spell/integration_cog/integration_cog_insight in L.actions)
		qdel(integration_cog_insight)
