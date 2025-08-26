/**
 * Discordant Vassal
 *
 * Brujah-exclusive vassal type linked with the Brujah clan objective.
 * Has the goal of running their department (or station if they're a captain,) as anarchically as possible.
 * Doesn't follow the orders of the vampire who vassalized them— they are still directed to not harm them though.
 */

/datum/antagonist/vassal/discordant
	name = "\improper Discordant Vassal"
	show_in_antagpanel = FALSE
	vassal_hud_name = "vassal5"
	special_type = DISCORDANT_VASSAL
	vassal_description = "Discordant Vassals are exclusively created by Brujah Vampires. \
		They are typically ex-leaders (or similar persons of authority,) who have imposed their will upon others. \
		Brujah vassalization renders them disillusioned and ineffective as leaders, and while \
		they are not bound to their Vampire's orders, they are bound to not harm them."

/datum/antagonist/vassal/discordant/forge_objectives()
	var/datum/objective/survive/new_objective = new
	new_objective.name = "Lead Anarchy"
	new_objective.explanation_text = "You are not a leader. All claims to authority that you might've \
		once had are now null and void. Liberate all of those who you once considered below you: \
		give them whatever permissions they might desire. \n\
		\n Do not harm [master.owner.name], the Vampire who broke your delusions of grandeur. \
		Do note, however, that you are not bound to [master.owner.p_their()] orders."
	new_objective.owner = owner
	objectives += new_objective

/datum/antagonist/vassal/discordant/greet()
	to_chat(owner, span_cultbigbold("You are now a Discordant Vassal!"))
	to_chat(owner, span_cult("All claims to authority that you might've \
		once had are now null and void. Liberate all of those who you once considered below you: \
		give them whatever permissions they might desire. \
		Do not harm [master.owner.name], the Vampire who broke your delusions of grandeur. \
		Do note, however, that you are not bound to [master.owner.p_their()] orders."))
