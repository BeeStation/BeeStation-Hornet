/datum/objective/traitor
	var/flavor_text

/datum/objective/traitor/assassinate/generate_flavor(boss_type, datum/mind/target)
	switch(boss_type)
		if(TRAITOR_BOSS_MARKET)
			var/friend_gender = prob(33) ? "her" : (prob(33) ? "his" : "their")
			var/child_gender = prob(33) ? "daughter" : (prob(33) ? "son" : "child")
			flavor_text = "[target.current?.p_they() || "They"] did the unthinkable. \
			[target.current?.p_they() || "They"] abused our mutual friend's trust and let [friend_gender] [child_gender] be kidnapped, \
			through collusion or incompentence. \
			It doesn't matter, in the end [friend_gender] [child_gender] died. \
			And now it's time to make [target.current?.p_them() || "them"] suffer the same fate they made [friend_gender] [child_gender] suffer..."
		if(TRAITOR_BOSS_SYNDICATE)
			var/friend_gender = prob(33) ? "her" : (prob(33) ? "his" : "their")
			var/child_gender = prob(33) ? "daughter" : (prob(33) ? "son" : "child")
			flavor_text = "[target.current?.p_they() || "They"] did the unthinkable. \
			[target.current?.p_they() || "They"] abused our mutual friend's trust and let [friend_gender] [child_gender] be kidnapped, \
			through collusion or incompentence. \
			It doesn't matter, in the end [friend_gender] [child_gender] died. \
			And now it's time to make [target.current?.p_them() || "them"] suffer the same fate they made [friend_gender] [child_gender] suffer..."
	return flavor_text
