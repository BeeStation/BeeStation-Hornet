/*
		Ported from /vg/station:
		https://github.com/vgstation-coders/vgstation13/blob/Bleeding-Edge/code/game/objects/items/devices/sound_synth.dm
*/

/obj/item/soundsynth
	name = "sound synthesizer"
	desc = "A device that is able to create sounds."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	item_state = "radio"
	w_class = WEIGHT_CLASS_TINY
	siemens_coefficient = 1

	var/selected_sound_name = "Honk" // just so we can select it by default in the input list
	var/sound/selected_sound = sound('sound/items/bikehorn.ogg')
	var/shiftpitch = 1
	var/volume = 50
	var/has_cooldown = TRUE
	var/added_cooldown = 1 SECONDS
	COOLDOWN_DECLARE(play_cooldown)

	var/static/list/sound_list = list(
		"Honk" = "selected_sound=sound/items/bikehorn.ogg&shiftpitch=1&volume=50",
		"Applause" = "selected_sound=sound/effects/applause.ogg&shiftpitch=1&volume=65",
		"Laughter" = "selected_sound=sound/effects/laughtrack.ogg&shiftpitch=1&volume=65",
		"Rimshot" = "selected_sound=sound/effects/rimshot.ogg&shiftpitch=1&volume=65",
		"Trombone" = "selected_sound=sound/misc/sadtrombone.ogg&shiftpitch=1&volume=50",
		"Airhorn" = "selected_sound=sound/items/airhorn.ogg&shiftpitch=1&volume=50",
		"Alert" = "selected_sound=sound/effects/alert.ogg&shiftpitch=1&volume=50",
		"Boom" = "selected_sound=sound/effects/explosion1.ogg&shiftpitch=1&volume=50",
		"Boom from Afar" = "selected_sound=sound/effects/explosionfar.ogg&shiftpitch=1&volume=50",
		"Bubbles" = "selected_sound=sound/effects/bubbles.ogg&shiftpitch=1&volume=50",
		"Countdown" = "selected_sound=sound/ambience/countdown.ogg&shiftpitch=0&volume=55",
		"Creepy Whisper" = "selected_sound=sound/hallucinations/turn_around1.ogg&shiftpitch=1&volume=50",
		"Ding" = "selected_sound=sound/machines/ding.ogg&shiftpitch=1&volume=50",
		"Bwoink" = "selected_sound=sound/effects/adminhelp.ogg&shiftpitch=1&volume=50",
		"Double Beep" = "selected_sound=sound/machines/twobeep.ogg&shiftpitch=1&volume=50",
		"Flush" = "selected_sound=sound/machines/disposalflush.ogg&shiftpitch=1&volume=40",
		"Kawaii" = "selected_sound=sound/ai/default/animes.ogg&shiftpitch=0&volume=60",
		"Startup" = "selected_sound=sound/mecha/nominal.ogg&shiftpitch=0&volume=50",
		"Welding Noises" = "selected_sound=sound/items/welder.ogg&shiftpitch=1&volume=55",
		"Short Slide Whistle" = "selected_sound=sound/effects/slide_whistle_short.ogg&shiftpitch=1&volume=50",
		"Long Slide Whistle" = "selected_sound=sound/effects/slide_whistle_long.ogg&shiftpitch=1&volume=50",
		"YEET" = "selected_sound=sound/effects/yeet.ogg&shiftpitch=1&volume=50",
		"Time Stop" = "selected_sound=sound/magic/timeparadox2.ogg&shiftpitch=0&volume=80",
		"Click" = "selected_sound=sound/machines/click.ogg&shiftpitch=0&volume=80",
		"Booing" = "selected_sound=sound/effects/audience-boo.ogg&shiftpitch=0&volume=80",
		"Awwing" = "selected_sound=sound/effects/audience-aww.ogg&shiftpitch=0&volume=80",
		"Gasping" = "selected_sound=sound/effects/audience-gasp.ogg&shiftpitch=0&volume=80",
		"Oohing" = "selected_sound=sound/effects/audience-ooh.ogg&shiftpitch=0&volume=80"
	)
	var/static/list/sound_lengths = list()

/obj/item/soundsynth/verb/pick_sound()
	set category = "Object"
	set name = "Select Sound Playback"
	var/new_sound = tgui_input_list(usr, "Pick a sound!", "Sound Synthesizer", sound_list, default = selected_sound_name)
	if(!new_sound || !sound_list[new_sound])
		return
	to_chat(usr, "<span class='notice'>Sound playback set to: <b>[new_sound]</b>!</span>")
	selected_sound_name = new_sound
	var/list/assblast = params2list(sound_list[new_sound])
	selected_sound = sound(assblast["selected_sound"])
	shiftpitch = text2num(assblast["shiftpitch"])
	volume = text2num(assblast["volume"])
	SSblackbox.record_feedback("tally", "synth_sound_selected", 1, selected_sound_name)

/obj/item/soundsynth/attack_self(mob/user)
	if(!selected_sound || !selected_sound_name)
		to_chat(user, "<span class='warning'>No sound has been selected!</span>")
		return
	if(has_cooldown && !COOLDOWN_FINISHED(src, play_cooldown))
		to_chat(user, "<span class='warning'>You must wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, play_cooldown))] before you can play another sound!</span>")
		return
	for(var/mob/target in hearers(user))
		if(!target.client || !(target.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS))
			continue
		target.playsound_local(src, selected_sound, volume, shiftpitch)
	SSblackbox.record_feedback("tally", "synth_sound_played", 1, selected_sound_name)
	if(has_cooldown)
		COOLDOWN_START(src, play_cooldown, added_cooldown + get_sound_length(user))

/obj/item/soundsynth/AltClick(mob/living/carbon/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	pick_sound()

/obj/item/soundsynth/attack(mob/living/target, mob/living/user, def_zone)
	if(target == user)
		pick_sound()
		return
	if(!selected_sound || !selected_sound_name)
		to_chat(user, "<span class='warning'>No sound has been selected!</span>")
		return
	if(has_cooldown && !COOLDOWN_FINISHED(src, play_cooldown))
		to_chat(user, "<span class='warning'>You must wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, play_cooldown))] before you can play another sound!</span>")
		return
	if(target.client && (target.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS))
		target.playsound_local(get_turf(src), selected_sound, volume, shiftpitch)
	SSblackbox.record_feedback("tally", "synth_sound_played", 1, selected_sound_name)
	if(has_cooldown)
		COOLDOWN_START(src, play_cooldown, added_cooldown + get_sound_length(target))

// WHY BYOND WHYYYYY, WHY DO I HAVE THE QUERY THE CLIENT FOR THE SOUND, CAN'T YOU JUST FILL OUT LEN WHENEVER I MAKE A SOUND DATUM?!
/obj/item/soundsynth/proc/get_sound_length(mob/living/hearer)
	. = 0
	if(!selected_sound?.file || !hearer?.client)
		return
	if(sound_lengths[selected_sound.file])
		return sound_lengths[selected_sound.file]
	var/list/sound/sounds = hearer.client.SoundQuery()
	for(var/sound/sound as() in sounds)
		if(sound.file == selected_sound.file)
			// Just in case something goes fucky wucky, don't cache a bad result.
			if(!isnum_safe(sound.len) || sound.len <= 0)
				return
			var/sound_len = CEILING(sound.len * 10, 1)
			sound_lengths[selected_sound.file] = sound_len
			return sound_len

