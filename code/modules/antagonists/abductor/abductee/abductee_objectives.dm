/datum/objective/abductee
	completed = 1
	explanation_text = "<b>They</b> took you... you can't remember...? The pale faces.. the hands... <b>They</b> control us now. You must protect yourself."

/datum/objective/abductee/fearful
	explanation_text = "They're in league with <b>them</b>. You know their plans now. You must tell the others:<br>"

/datum/objective/abductee/fearful/New()
	var/target = pick(list("Security", "Medical", "Command"))

	var/transgression = pick(list(
		"putting drugs in the water supply",
		"putting nanomachine trackers into our bodies",
		"using the cameras to track our emotions",
		"putting drugs in the food"))

	explanation_text += "[target] is [transgression] to keep us compliant and sheepish. They know that you know it. Hide! Run! Don't let them catch you!"


/datum/objective/abductee/violent
	explanation_text = "You are filled with an otherworldly rage simmering within. Threatening to boil over at the slightest provocation:<br>"

/datum/objective/abductee/violent/New()
	// we use suit sensors because we really want to make sure that this person can be found by our little crackhead here
	var/target
	if(length(GLOB.suit_sensors_list))
		target = "[pick(GLOB.suit_sensors_list)]"
	else
		target = "the first person I see"

	var/list/your_poison = list(
		"I am [target], <b>they</b> have changed my face and tried to replace me by sending a clone!! I must kill them first and resume my life as my original identity.",
		"THEY'RE ALL INSANE!!! THEY ALL WANT ME DEAD!!! I MUST KILL THEM ALL I MUST SHOW THEM THAT I WON'T GO DOWN SO EASY!!! TRY ME!!!")

	explanation_text += pick(your_poison)


/datum/objective/abductee/paranoid
	explanation_text = "<b>They</b> are everywhere, hear everything. They're out to get you, anyone could be one of their agents!<br>"

/datum/objective/abductee/paranoid/New()
	var/holeinthewall = pick(list("engineering", "tool storage", "the chapel"))

	var/list/your_poison = list(
		"I must hole myself up in [holeinthewall] and turn it into a veritable fortress. NONE may enter. It will be my safe space.",
		"They are sending cancer radio mindcontrol waves through the telecoms equipment. All of us are at risk. I must save the station by disabling every piece of radio equipment I can find.",
		"This station is lost. We are all lost. It won't be long now, until <b>they</b> come to take us all away. I have to get the shuttle called. I have to make sure we evacuate as fast as possible. For the good of all.")

	explanation_text += pick(your_poison)
