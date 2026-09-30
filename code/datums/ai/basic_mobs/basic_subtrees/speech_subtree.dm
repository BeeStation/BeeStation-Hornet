/datum/ai_planning_subtree/random_speech
	//The chance of an emote occurring each second
	var/speech_chance = 0
	///Hearable emotes
	var/list/emote_hear
	///Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see
	///Possible lines of speech the AI can have
	var/list/speak
	///The sound effects associated with this speech, if any
	var/list/sound

/datum/ai_planning_subtree/random_speech/New()
	. = ..()
	if(LAZYLEN(speak))
		speak = string_list(speak)
	if(LAZYLEN(sound))
		sound = string_list(sound)
	if(LAZYLEN(emote_hear))
		emote_hear = string_list(emote_hear)
	if(LAZYLEN(emote_see))
		emote_see = string_list(emote_see)

/datum/ai_planning_subtree/random_speech/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!DT_PROB(speech_chance, delta_time))
		return
	speak(controller)

/// Actually perform an action
/datum/ai_planning_subtree/random_speech/proc/speak(datum/ai_controller/controller)
	var/audible_emotes_length = LAZYLEN(emote_hear)
	var/non_audible_emotes_length = LAZYLEN(emote_see)
	var/speak_lines_length = LAZYLEN(speak)

	var/total_choices_length = audible_emotes_length + non_audible_emotes_length + speak_lines_length

	if (total_choices_length == 0)
		return

	var/random_number_in_range = rand(1, total_choices_length)
	var/sound_to_play = length(sound) > 0 ? pick(sound) : null

	if(random_number_in_range <= audible_emotes_length)
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_hear), sound_to_play)
	else if(random_number_in_range <= (audible_emotes_length + non_audible_emotes_length))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_see))
	else
		controller.queue_behavior(/datum/ai_behavior/perform_speech, pick(speak), sound_to_play)

/datum/ai_planning_subtree/random_speech/insect
	speech_chance = 1
	sound = list('sound/mobs/non-humanoids/insect/chitter.ogg')
	emote_hear = list("chitters.")

/datum/ai_planning_subtree/random_speech/mothroach
	speech_chance = 2
	emote_hear = list("flutters.", "flaps its wings.", "flaps its wings aggressively!")

/datum/ai_planning_subtree/random_speech/mouse
	speech_chance = 1
	speak = list("Squeak!", "SQUEAK!", "Squeak?")
	sound = list('sound/effects/mousesqueek.ogg')
	emote_hear = list("squeaks.")
	emote_see = list("runs in a circle.", "shakes.")

/datum/ai_planning_subtree/random_speech/chicken
	speech_chance = 15 // really talkative ladies
	speak = list("Cluck!", "BWAAAAARK BWAK BWAK BWAK!", "Bwaak bwak.")
	sound = list('sound/mobs/non-humanoids/chicken/clucks.ogg', 'sound/mobs/non-humanoids/chicken/bagawk.ogg')
	emote_hear = list("clucks.", "croons.")
	emote_see = list("pecks at the ground.","flaps her wings viciously.")

/datum/ai_planning_subtree/random_speech/chick
	speech_chance = 4
	speak = list("Cherp.", "Cherp?", "Chirrup.", "Cheep!")
	sound = list('sound/mobs/non-humanoids/chicken/chick_peep.ogg')
	emote_hear = list("cheeps.")
	emote_see = list("pecks at the ground.","flaps her tiny wings.")

/datum/ai_planning_subtree/random_speech/cow
	speech_chance = 1
	speak = list("moo?","moo","MOOOOOO")
	sound = list('sound/mobs/non-humanoids/cow/cow.ogg')
	emote_hear = list("brays.")
	emote_see = list("shakes her head.")

///unlike normal cows, wisdom cows speak of wisdom and won't shut the fuck up
/datum/ai_planning_subtree/random_speech/cow/wisdom
	speech_chance = 15

/datum/ai_planning_subtree/random_speech/cow/wisdom/New()
	. = ..()
	speak = GLOB.wisdoms //Done here so it's setup properly

/datum/ai_planning_subtree/random_speech/dog
	speech_chance = 1

/datum/ai_planning_subtree/random_speech/dog/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!isdog(controller.pawn))
		return

	// Stay in sync with dog fashion.
	var/mob/living/basic/pet/dog/dog_pawn = controller.pawn
	dog_pawn.update_dog_speech(src)

	return ..()

/datum/ai_planning_subtree/random_speech/garden_gnome
	speech_chance = 5
	speak = list("Gnot a gnelf!", "Gnot a gnoblin!", "Howdy chum!")
	emote_hear = list("snores.", "burps.")
	emote_see = list("blinks.")

/datum/ai_planning_subtree/random_speech/fox
	speech_chance = 1
	speak = list("Ack-Ack", "Ack-Ack-Ack-Ackawoooo", "Geckers", "Awoo", "Tchoff")
	emote_hear = list("howls.", "barks.", "screams.")
	emote_see = list("shakes their head.", "shivers.")

/datum/ai_planning_subtree/random_speech/crab
	speech_chance = 1
	sound = list('sound/mobs/non-humanoids/crab/claw_click.ogg')
	emote_hear = list("clicks.")
	emote_see = list("clacks.")

/datum/ai_planning_subtree/random_speech/penguin
	speech_chance = 5
	speak = list("Gah Gah!", "NOOT NOOT!", "NOOT!", "Noot", "noot", "Prah!", "Grah!")
	emote_hear = list("squawks", "gakkers")

/datum/ai_planning_subtree/random_speech/penguin/baby
	speak = list("gah", "noot noot", "noot!", "noot", "squeee!", "noo!")

/datum/ai_planning_subtree/random_speech/cats
	speech_chance = 10
	sound = list("cat_meow")
	emote_hear = list("meows.")
	emote_see = list("meows.")

/datum/ai_planning_subtree/random_speech/hamster
	speech_chance = 5
	speak = list("Squeak", "SQUEAK!")
	emote_hear = list("squeaks.", "hisses.", "squeals.")
	emote_see = list("skitters", "examines its claws", "rolls around")

/datum/ai_planning_subtree/random_speech/snake
	speech_chance = 5
	speak = list("hsssss", "sssSSsssss...", "hiisssss")
	sound = list('sound/mobs/non-humanoids/snake/snake_hissing1.ogg', 'sound/mobs/non-humanoids/snake/snake_hissing2.ogg')
	emote_hear = list("hisses.")
	emote_see = list("slithers around.", "glances.", "stares.")
