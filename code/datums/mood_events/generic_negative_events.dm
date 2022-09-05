/datum/mood_event/handcuffed
	description = "I guess my antics have finally caught up with me.\n"
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
  description = "I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow...\n"
  mood_change = -8

/datum/mood_event/on_fire
	description = "I'M ON FIRE!!!\n"
	mood_change = -12

/datum/mood_event/suffocation
	description = "CAN'T... BREATHE...\n"
	mood_change = -12

/datum/mood_event/burnt_thumb
	description = "I shouldn't play with lighters...\n"
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/cold
	description = "It's way too cold in here.\n"
	mood_change = -5

/datum/mood_event/hot
	description = "It's getting hot in here.\n"
	mood_change = -5

/datum/mood_event/creampie
	description = "I've been creamed. Tastes like pie flavor.\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/slipped
	description = "I slipped. I should be more careful next time...\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eye_stab
	description = "I used to be an adventurer like you, until I took a screwdriver to the eye.\n"
	mood_change = -4
	span = "boldwarning"
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "Those God damn engineers can't do anything right...\n"
	mood_change = -2
	span = "boldwarning"
	timeout = 4 MINUTES

/datum/mood_event/depression
	description = "I feel sad for no particular reason.\n"
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/anxiety
	description = "I feel scared around all these people..\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/anxiety_mute
	description = "I can't speak up, not with everyone here!\n"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/anxiety_dumb
	description = "Oh god, I made a fool of myself.\n"
	mood_change = -10
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
  description = "I can't even end it all!\n"
  mood_change = -15
  timeout = 60 SECONDS

/datum/mood_event/dismembered
  description = "AHH! I WAS USING THAT LIMB!\n"
  mood_change = -10
  timeout = 8 MINUTES

/datum/mood_event/tased
	description = "There's no \"z\" in \"taser\". It's in the zap.\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = "Pull it out!\n"
	mood_change = -7

/datum/mood_event/table
	description = "Someone threw me on a table!\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/table/add_effects()
	var/datum/component/L = owner //owner is lying about its type, its component/mood while pretending to be mob. You must cast it to use it properly
	var/mob/living/T = L.parent
	if(ishuman(T))
		var/mob/living/carbon/human/H = T
		if(iscatperson(H))
			H.dna.species.start_wagging_tail(H)
			addtimer(CALLBACK(H.dna.species, /datum/species.proc/stop_wagging_tail, H), 30)
			description =  "<span class='nicegreen'>They want to play on the table!</span>\n"
			mood_change = 2



/datum/mood_event/table_headsmash
	description = "My fucking head, that hurt..."
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/brain_damage
  mood_change = -3

/datum/mood_event/brain_damage/add_effects()
  var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
  description = "Hurr durr... [damage_message]\n"

/datum/mood_event/hulk //Entire duration of having the hulk mutation
  description = "HULK SMASH!\n"
  mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
  description = "I should have paid attention to the epilepsy warning.\n"
  mood_change = -3
  timeout = 5 MINUTES

/datum/mood_event/nyctophobia
	description = "It sure is dark around here...\n"
	mood_change = -3

/datum/mood_event/family_heirloom_missing
	description = "I'm missing my family heirloom...\n"
	mood_change = -4

/datum/mood_event/healsbadman
	description = "I feel a lot better, but wow that was disgusting.\n" //when you read the latest felinid removal PR and realize you're really not that much of a degenerate
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/jittery
	description = "I'm nervous and on edge and I can't stand still!!\n"
	mood_change = -2

/datum/mood_event/vomit
	description = "I just threw up. Gross.\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/vomitself
	description = "I just threw up all over myself. This is disgusting.\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/painful_medicine
	description = "Medicine may be good for me but right now it stings like hell.\n"
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/spooked
	description = "The rattling of those bones...It still haunts me.\n"
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/loud_gong
	description = "That loud gong noise really hurt my ears!\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/notcreeping
	description = "The voices are not happy, and they painfully contort my thoughts into getting back on task.\n"
	mood_change = -6
	timeout = 30
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = "THEY NEEEEEEED OBSESSIONNNN!!\n"
	mood_change = -30
	timeout = 30

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "THEY NEEEEEEED [unhinged]!!\n"

/datum/mood_event/sapped
	description = "Some unexplainable sadness is consuming me...\n"
	mood_change = -15
	timeout = 90 SECONDS

/datum/mood_event/back_pain
	description = "Bags never sit right on my back, this hurts like hell!\n"
	mood_change = -15

/datum/mood_event/sad_empath
	description = "Someone seems upset...\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = "[sadtarget.name] seems upset...\n"

/datum/mood_event/sacrifice_bad
	description ="Those darn savages!\n"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/artbad
	description = "I've produced better art than that from my ass.\n"
	mood_change = -2
	timeout = 1200

/datum/mood_event/gates_of_mansus
	description = "LIVING IN A PERFORMANCE IS WORSE THAN DEATH\n"
	mood_change = -25
	timeout = 4 MINUTES

//These are unused so far but I want to remember them to use them later
/datum/mood_event/cloned_corpse
	description = "I recently saw my own corpse...\n"
	mood_change = -6

/datum/mood_event/surgery
	description = "HE'S CUTTING ME OPEN!!\n"
	mood_change = -8

/datum/mood_event/nanite_sadness
	description = "+++++++HAPPINESS SUPPRESSION+++++++\n"
	span = "warning robot"
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = "+++++++[message]+++++++\n"
	span = "warning robot"

/datum/mood_event/sec_insulated_gloves
	description = "I look like an Assistant...\n"
	mood_change = -1

/datum/mood_event/burnt_wings
	description = "MY PRECIOUS WINGS!!\n"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/aquarium_negative
	description = "All the fish are dead...\n"
	mood_change = -3
	timeout = 1.5 MINUTES

/datum/mood_event/feline_dysmorphia
	description = "I'm so ugly. I wish I was cuter!\n"
	mood_change = -10

/datum/mood_event/nervous
	description = "I feel on edge... Gotta get a grip.\n"
	mood_change = -3
	timeout = 30 SECONDS

/datum/mood_event/paranoid
	description = "I'm not safe! I can't trust anybody!\n"
	mood_change = -6
	timeout = 30 SECONDS
