/datum/smite/voice_of_god
	name = "Voice of God"

/datum/smite/voice_of_god/effect(client/user, mob/living/target)
	. = ..()
	var/target_sound = input(usr, "Enter the filepath of the sound they will hear.", "God Soundfile", 'sound/magic/clockwork/invoke_general.ogg') as null|text
	var/target_speech = input(usr, "What will they hear from God?", "Divine Command", "Cease your heresy.") as null|text
	if(isnull(target_sound) || isnull(target_speech)) //The user pressed "Cancel"
		return

	target.visible_message("<span class='warning'>[target] faints!</span>", "<span class='narsie'>[target_speech]</span>")
	target.playsound_local(get_turf(target), target_sound, 200, 1)
	target.Paralyze(300, ignore_canstun = TRUE)
	target.Jitter(100)
	target.confused += 50

