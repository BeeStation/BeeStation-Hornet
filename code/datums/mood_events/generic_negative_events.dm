/datum/mood_event/handcuffed
	description = span_warning("I guess my antics have finally caught up with me.")
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
	description = span_boldwarning("I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow...")
	mood_change = -8

/datum/mood_event/on_fire
	description = span_boldwarning("I'M ON FIRE!!!")
	mood_change = -12

/datum/mood_event/suffocation
	description = span_boldwarning("CAN'T... BREATHE...")
	mood_change = -12

/datum/mood_event/cold
	description = span_warning("It's way too cold in here.")
	mood_change = -5

/datum/mood_event/hot
	description = span_warning("It's getting hot in here.")
	mood_change = -5

/datum/mood_event/eye_stab
	description = span_boldwarning("AHHH my eyes, that was really sharp!")
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = span_boldwarning("Those God damn engineers can't do anything right...")
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/depression
	description = span_warning("I feel sad for no particular reason.")
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/anxiety
	description = span_warning("I feel scared around all these people...")
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/anxiety_mute
	description = span_boldwarning("I can't speak up, not with everyone here!")
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/anxiety_dumb
	description = span_boldwarning("Oh god, I made a fool of myself.")
	mood_change = -10
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
	description = span_boldwarning("I can't even end it all!")
	mood_change = -15
	timeout = 60 SECONDS

/datum/mood_event/dismembered
	description = span_boldwarning("AHH! MY LIMB! I WAS USING THAT!")
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/tased
	description = span_warning("There's no \"z\" in \"taser\". It's in the zap.")
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = span_boldwarning("Pull it out!")
	mood_change = -7

/datum/mood_event/brain_damage
	mood_change = -3

/datum/mood_event/brain_damage/add_effects()
	var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
	description = span_warning("Hurr durr... [damage_message]")

/datum/mood_event/hulk //Entire duration of having the hulk mutation
	description = span_warning("HULK SMASH!")
	mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
	description = span_warning("I should have paid attention to the epilepsy warning.")
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/nyctophobia
	description = span_warning("It sure is dark around here...")
	mood_change = -3

/datum/mood_event/bright_light
	description = "I hate it in the light... I need to find a darker place..."
	mood_change = -12

/datum/mood_event/family_heirloom_missing
	description = span_warning("I'm missing my family heirloom...")
	mood_change = -4

/datum/mood_event/healsbadman
	description = span_warning("I feel a lot better, but wow that was disgusting.") //when you read the latest felinid removal PR and realize you're really not that much of a degenerate
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/painful_medicine
	description = span_warning("Medicine may be good for me but right now it stings like hell.")
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/spooked
	description = span_warning("The rattling of those bones...It still haunts me.")
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/notcreeping
	description = span_warning("The voices are not happy, and they painfully contort my thoughts into getting back on task.")
	mood_change = -6
	timeout = 30
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = span_boldwarning("THEY NEEEEEEED OBSESSIONNNN!!!")
	mood_change = -30
	timeout = 30

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = span_boldwarning("THEY NEEEEEEED [unhinged]!!!")

/datum/mood_event/sapped
	description = span_boldwarning("Some unexplainable sadness is consuming me...")
	mood_change = -15
	timeout = 90 SECONDS

/datum/mood_event/back_pain
	description = span_boldwarning("Bags never sit right on my back, this hurts like hell!")
	mood_change = -15

/datum/mood_event/sad_empath
	description = span_warning("Someone seems upset...")
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = span_warning("[sadtarget.name] seems upset...")

/datum/mood_event/sacrifice_bad
	description =span_warning("Those darn savages!")
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/gates_of_mansus
	description = span_boldwarning("LIVING IN A PERFORMANCE IS WORSE THAN DEATH")
	mood_change = -25
	timeout = 4 MINUTES

/datum/mood_event/nanite_sadness
	description = span_warningrobot("+++++++HAPPINESS SUPPRESSION+++++++")
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = span_warningrobot("+++++++[message]+++++++")

/datum/mood_event/sec_insulated_gloves
	description = span_warning("I look like an Assistant...")
	mood_change = -1

/datum/mood_event/tail_lost
	description = "My tail!! Why?!"
	mood_change = -8
	timeout = 10 MINUTES

/datum/mood_event/tail_balance_lost
	description = "I feel off-balance without my tail."
	mood_change = -2

/datum/mood_event/tail_regained_wrong
	description = "Is this some kind of sick joke?! This is NOT the right tail."
	mood_change = -12 // -8 for tail still missing + -4 bonus for being frakenstein's monster
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_species
	description = "This tail is not mine, but at least it balances me out..."
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_right
	description = "My tail is back, but that was traumatic..."
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/burnt_wings
	description = span_boldwarning("MY PRECIOUS WINGS!!!")
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
	description = span_boldwarning("I'm so ugly. I wish I was cuter!")
	mood_change = -10

/datum/mood_event/nervous
	description = span_warning("I feel on edge... Gotta get a grip.")
	mood_change = -3
	timeout = 30 SECONDS

/datum/mood_event/paranoid
	description = span_boldwarning("I'm not safe! I can't trust anybody!")
	mood_change = -6
	timeout = 30 SECONDS

/datum/mood_event/saw_holopara_death
	description = span_warning("Oh god, they just painfully turned to dust... What an horrifying sight...")
	mood_change = -10
	timeout = 15 MINUTES

/datum/mood_event/saw_holopara_death/add_effects(name)
	description = span_warning("Oh god, [name] just painfully turned to dust... What an horrifying sight...")

/datum/mood_event/loud_gong
	description = span_warning("That loud gong noise really hurt my ears!")
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/bald
	description = "I need something to cover my head..."
	mood_change = -3

/datum/mood_event/bald_reminder
	description = "I was reminded that I can't grow my hair back at all! This is awful!"
	mood_change = -5
	timeout = 4 MINUTES
