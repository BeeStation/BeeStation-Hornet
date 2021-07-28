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

/datum/mood_event/burnt_thumb
	description = span_warning("I shouldn't play with lighters...") 
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/cold
	description = span_warning("It's way too cold in here.") 
	mood_change = -5

/datum/mood_event/hot
	description = span_warning("It's getting hot in here.") 
	mood_change = -5

/datum/mood_event/creampie
	description = span_warning("I've been creamed. Tastes like pie flavor.") 
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/slipped
	description = span_warning("I slipped. I should be more careful next time...") 
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eye_stab
	description = span_boldwarning("I used to be an adventurer like you, until I took a screwdriver to the eye.") 
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

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
  description = span_boldwarning("I can't even end it all!") 
  mood_change = -15
  timeout = 60 SECONDS

/datum/mood_event/dismembered
  description = span_boldwarning("AHH! I WAS USING THAT LIMB!") 
  mood_change = -10
  timeout = 8 MINUTES

/datum/mood_event/tased
	description = span_warning("There's no \"z\" in \"taser\". It's in the zap.") 
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = span_boldwarning("Pull it out!") 
	mood_change = -7

/datum/mood_event/table
	description = span_warning("Someone threw me on a table!") 
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
			description =  span_nicegreen("They want to play on the table!") 
			mood_change = 2



/datum/mood_event/table_headsmash
	description = span_warning("My fucking head, that hurt...")
	mood_change = -3
	timeout = 3 MINUTES

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

/datum/mood_event/family_heirloom_missing
	description = span_warning("I'm missing my family heirloom...") 
	mood_change = -4

/datum/mood_event/healsbadman
	description = span_warning("I feel a lot better, but wow that was disgusting.")  //when you read the latest felinid removal PR and realize you're really not that much of a degenerate
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/jittery
	description = span_warning("I'm nervous and on edge and I can't stand still!!") 
	mood_change = -2

/datum/mood_event/vomit
	description = span_warning("I just threw up. Gross.") 
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/vomitself
	description = span_warning("I just threw up all over myself. This is disgusting.") 
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/painful_medicine
	description = span_warning("Medicine may be good for me but right now it stings like hell.") 
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/spooked
	description = span_warning("The rattling of those bones...It still haunts me.") 
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/loud_gong
	description = span_warning("That loud gong noise really hurt my ears!") 
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/notcreeping
	description = span_warning("The voices are not happy, and they painfully contort my thoughts into getting back on task.") 
	mood_change = -6
	timeout = 30
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = span_boldwarning("THEY NEEEEEEED OBSESSIONNNN!!") 
	mood_change = -30
	timeout = 30

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = span_boldwarning("THEY NEEEEEEED [unhinged]!!") 

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

/datum/mood_event/artbad
	description = span_warning("I've produced better art than that from my ass.") 
	mood_change = -2
	timeout = 1200

/datum/mood_event/gates_of_mansus
	description = span_boldwarning("LIVING IN A PERFORMANCE IS WORSE THAN DEATH") 
	mood_change = -25
	timeout = 4 MINUTES

//These are unused so far but I want to remember them to use them later
/datum/mood_event/cloned_corpse
	description = span_boldwarning("I recently saw my own corpse...") 
	mood_change = -6

/datum/mood_event/surgery
	description = span_boldwarning("HE'S CUTTING ME OPEN!!") 
	mood_change = -8

/datum/mood_event/nanite_sadness
	description = "<span class='warning robot'>+++++++HAPPINESS SUPPRESSION+++++++</span>\n"
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = "<span class='warning robot'>+++++++[message]+++++++</span>\n"

/datum/mood_event/sec_insulated_gloves
	description = span_warning("I look like an Assistant...") 
	mood_change = -1

/datum/mood_event/burnt_wings
	description = span_boldwarning("MY PRECIOUS WINGS!!") 
	mood_change = -10
	timeout = 10 MINUTES