/datum/mood_event/handcuffed
	description = "I guess my antics have finally caught up with me."
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
	description = "I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow..."
	mood_change = -8

/datum/mood_event/on_fire
	description = "I'M ON FIRE!!!"
	mood_change = -12

/datum/mood_event/suffocation
	description = "CAN'T... BREATHE..."
	mood_change = -12

/datum/mood_event/cold
	description = "It's way too cold in here."
	mood_change = -5

/datum/mood_event/hot
	description = "It's getting hot in here."
	mood_change = -5

/datum/mood_event/eye_stab
	description = "AHHH my eyes, that was really sharp!"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "Those God damn engineers can't do anything right..."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/depression
	description = "I feel sad for no particular reason."
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/anxiety
	description = "I feel scared around all these people..."
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/anxiety_mute
	description = "I can't speak up, not with everyone here!"
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/anxiety_dumb
	description = "Oh god, I made a fool of myself."
	mood_change = -10
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
	description = "I can't even end it all!"
	mood_change = -15
	timeout = 60 SECONDS

/datum/mood_event/dismembered
	description = "AHH! MY LIMB! I WAS USING THAT!"
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/tased
	description = "There's no \"z\" in \"taser\". It's in the zap."
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = "Pull it out!"
	mood_change = -7

/datum/mood_event/brain_damage
	mood_change = -3

/datum/mood_event/brain_damage/add_effects()
	var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
	description = "Hurr durr... [damage_message]"

/datum/mood_event/hulk //Entire duration of having the hulk mutation
	description = "HULK SMASH!"
	mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
	description = "I should have paid attention to the epilepsy warning."
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/nyctophobia
	description = "It sure is dark around here..."
	mood_change = -3

/datum/mood_event/family_heirloom_missing
	description = "I'm missing my family heirloom..."
	mood_change = -4

/datum/mood_event/healsbadman
	description = "I feel a lot better, but wow that was disgusting." //when you read the latest felinid removal PR and realize you're really not that much of a degenerate
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/painful_medicine
	description = "Medicine may be good for me but right now it stings like hell."
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/spooked
	description = "The rattling of those bones...It still haunts me."
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/notcreeping
	description = "The voices are not happy, and they painfully contort my thoughts into getting back on task."
	mood_change = -6
	timeout = 30
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = "THEY NEEEEEEED OBSESSIONNNN!!!"
	mood_change = -30
	timeout = 30

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "THEY NEEEEEEED [unhinged]!!!"

/datum/mood_event/sapped
	description = "Some unexplainable sadness is consuming me..."
	mood_change = -15
	timeout = 90 SECONDS

/datum/mood_event/back_pain
	description = "Bags never sit right on my back, this hurts like hell!"
	mood_change = -15

/datum/mood_event/sad_empath
	description = "Someone seems upset..."
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = "[sadtarget.name] seems upset..."

/datum/mood_event/sacrifice_bad
	description = "Those darn savages!"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/gates_of_mansus
	description = "LIVING IN A PERFORMANCE IS WORSE THAN DEATH"
	mood_change = -25
	timeout = 4 MINUTES

/datum/mood_event/nanite_sadness
	description = "+++++++HAPPINESS SUPPRESSION+++++++"
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = "+++++++[message]+++++++"

/datum/mood_event/sec_insulated_gloves
	description = "I look like an Assistant..."
	mood_change = -1

/datum/mood_event/burnt_wings
	description = "MY PRECIOUS WINGS!!!"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/soda_spill
	description = "Cool! That's fine, I wanted to wear that soda, not drink it..."
	mood_change = -2
	timeout = 1 MINUTES

/datum/mood_event/observed_soda_spill
	description = "Ahaha! It's always funny to see someone get sprayed by a can of soda."
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/observed_soda_spill/add_effects(mob/spilled_mob, atom/soda_can)
	if(!spilled_mob)
		return

	description = "Ahaha! [spilled_mob] spilled [spilled_mob.p_their()] [soda_can ? soda_can.name : "soda"] all over [spilled_mob.p_them()]self! Classic."

/datum/mood_event/feline_dysmorphia
	description = "I'm so ugly. I wish I was cuter!"
	mood_change = -10

/datum/mood_event/nervous
	description = "I feel on edge... Gotta get a grip."
	mood_change = -3
	timeout = 30 SECONDS

/datum/mood_event/paranoid
	description = "I'm not safe! I can't trust anybody!"
	mood_change = -6
	timeout = 30 SECONDS

/datum/mood_event/saw_holopara_death
	description = "Oh god, they just painfully turned to dust... What an horrifying sight..."
	mood_change = -10
	timeout = 15 MINUTES

/datum/mood_event/saw_holopara_death/add_effects(name)
	description = "Oh god, [name] just painfully turned to dust... What an horrifying sight..."

/datum/mood_event/loud_gong
	description = "That loud gong noise really hurt my ears!"
	mood_change = -3
	timeout = 2 MINUTES
