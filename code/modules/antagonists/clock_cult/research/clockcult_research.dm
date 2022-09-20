/datum/clockcult_research_node
	/// Name of the node
	var/name = ""
	/// Description
	var/desc = ""
	/// Total power cost of the node, researched over time
	var/total_cost = 0
	/// Typepaths of nodes we require before this one
	var/list/pre_requisits = list()

/datum/clockcult_research_node/proc/grant_soul_effect(mob/living/L)

/datum/clockcult_research_node/proc/take_soul_effect(mob/living/L)

/datum/clockcult_research_node/proc/grant_believer_effect(mob/living/L)

/datum/clockcult_research_node/proc/take_believer_effect(mob/living/L)
