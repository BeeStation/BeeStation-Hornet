
// Rig probability
GLOBAL_VAR_INIT(rigged_prob, null)

/proc/safe_prob(probability)
	if (!isnull(GLOB.rigged_prob))
		return GLOB.rigged_prob
	return prob(probability)
