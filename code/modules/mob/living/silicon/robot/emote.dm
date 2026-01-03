/datum/emote/silicon
	mob_type_allowed_typecache = list(/mob/living/brain, /mob/living/silicon, /mob/living/simple_animal/hostile/mining_drone)
	emote_type = EMOTE_AUDIBLE

/datum/emote/silicon/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops."
	sound = 'sound/machines/boop.ogg'

/datum/emote/silicon/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes."
	message_param = "buzzes at %t."
	sound = 'sound/machines/buzz-sigh.ogg'

/datum/emote/silicon/buzz2
	key = "buzz2"
	message = "buzzes twice."
	sound = 'sound/machines/buzz-two.ogg'

/datum/emote/silicon/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes."
	sound = 'sound/machines/chime.ogg'

/datum/emote/silicon/dwoop
	key = "dwoop"
	key_third_person = "dwoops"
	message = "emits a dwoop sound."
	sound = 'sound/emotes/dwoop.ogg'

/datum/emote/silicon/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks."
	vary = TRUE
	sound = 'sound/items/bikehorn.ogg'

/datum/emote/silicon/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings."
	message_param = "pings at %t."
	sound = 'sound/machines/ping.ogg'

/datum/emote/silicon/sad
	key = "sad"
	message = "plays a sad trombone..."
	sound = 'sound/misc/sadtrombone.ogg'

/datum/emote/silicon/alarm
	key = "alarm"
	message = "blares an alarm!"
	sound = 'sound/machines/warning-buzzer.ogg'

/datum/emote/silicon/slowclap
	key = "slowclap"
	message = "activates its slow clap processor."
	sound = 'sound/machines/slowclap.ogg'
