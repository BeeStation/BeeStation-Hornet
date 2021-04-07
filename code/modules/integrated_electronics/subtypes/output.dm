/obj/item/integrated_circuit/output
	category_text = "Output"
	speech_span = SPAN_ROBOT

/obj/item/integrated_circuit/output/screen
	name = "small screen"
	extended_desc = " use &lt;br&gt; to start a new line"
	desc = "Takes any data type as an input, and displays it to the user upon examining."
	icon_state = "screen"
	inputs = list("displayed data" = IC_PINTYPE_ANY)
	outputs = list()
	activators = list("load data" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 10
	var/eol = "&lt;br&gt;"
	var/stuff_to_display = null

/obj/item/integrated_circuit/output/screen/disconnect_all()
	..()
	stuff_to_display = null

/obj/item/integrated_circuit/output/screen/any_examine(mob/user)
	var/shown_label = ""
	if(displayed_name && displayed_name != name)
		shown_label = " labeled '[displayed_name]'"

	to_chat(user, "There is \a [src][shown_label], which displays [!isnull(stuff_to_display) ? "'[stuff_to_display]'" : "nothing"].")

/obj/item/integrated_circuit/output/screen/do_work()
	var/datum/integrated_io/I = inputs[1]
	if(isweakref(I.data))
		var/datum/d = I.data_as_type(/datum)
		if(d)
			stuff_to_display = "[d]"
	else
		stuff_to_display = replacetext("[I.data]", eol , "<br>")

/obj/item/integrated_circuit/output/screen/large
	name = "large screen"
	desc = "Takes any data type as an input and displays it to anybody near the device when pulsed. \
	It can also be examined to see the last thing it displayed."
	icon_state = "screen_medium"
	power_draw_per_use = 20

/obj/item/integrated_circuit/output/screen/large/do_work()
	..()

	if(isliving(assembly.loc))//this whole block just returns if the assembly is neither in a mobs hands or on the ground
		var/mob/living/H = assembly.loc
		if(H.get_active_held_item() != assembly && H.get_inactive_held_item() != assembly)
			return
	else
		if(!isturf(assembly.loc))
			return

	for(var/mob/M in get_turf(src))
		var/obj/O = assembly || src
		to_chat(M, "<span class='notice'>[icon2html(O.icon, world, O.icon_state)] [stuff_to_display]</span>")
	if(assembly)
		assembly.investigate_log("displayed \"[html_encode(stuff_to_display)]\" with [type].", INVESTIGATE_CIRCUIT)
	else
		investigate_log("displayed \"[html_encode(stuff_to_display)]\" as [type].", INVESTIGATE_CIRCUIT)

/obj/item/integrated_circuit/output/light
	name = "light"
	desc = "A basic light which can be toggled on/off when pulsed."
	icon_state = "light"
	complexity = 4
	max_allowed = 4
	inputs = list()
	outputs = list()
	activators = list("toggle light" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/light_toggled = 0
	var/light_brightness = 3
	var/light_rgb = "#FFFFFF"
	power_draw_idle = 0 // Adjusted based on brightness.

/obj/item/integrated_circuit/output/light/do_work()
	light_toggled = !light_toggled
	update_lighting()

/obj/item/integrated_circuit/output/light/proc/update_lighting()
	if(light_toggled)
		if(assembly)
			assembly.set_light(l_range = light_brightness, l_power = 1, l_color = light_rgb)
	else
		if(assembly)
			assembly.set_light(0)
	power_draw_idle = light_toggled ? light_brightness * 2 : 0

/obj/item/integrated_circuit/output/light/power_fail() // Turns off the flashlight if there's no power left.
	light_toggled = FALSE
	update_lighting()

/obj/item/integrated_circuit/output/light/advanced
	name = "advanced light"
	desc = "A light that takes a hexadecimal color value and a brightness value, and can be toggled on/off by pulsing it."
	icon_state = "light_adv"
	complexity = 8
	inputs = list(
		"color" = IC_PINTYPE_COLOR,
		"brightness" = IC_PINTYPE_NUMBER
	)
	outputs = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/light/advanced/on_data_written()
	update_lighting()

/obj/item/integrated_circuit/output/light/advanced/update_lighting()
	var/new_color = get_pin_data(IC_INPUT, 1)
	var/brightness = get_pin_data(IC_INPUT, 2)

	if(new_color && isnum_safe(brightness))
		brightness = CLAMP(brightness, 0, 4)
		light_rgb = new_color
		light_brightness = brightness

	..()

/obj/item/integrated_circuit/output/sound
	name = "speaker circuit"
	desc = "A miniature speaker is attached to this component."
	icon_state = "speaker"
	complexity = 8
	cooldown_per_use = 4 SECONDS
	inputs = list(
		"sound ID" = IC_PINTYPE_STRING,
		"volume" = IC_PINTYPE_NUMBER,
		"frequency" = IC_PINTYPE_BOOLEAN
	)
	max_allowed = 5
	outputs = list()
	activators = list("play sound" = IC_PINTYPE_PULSE_IN)
	power_draw_per_use = 10
	var/list/sounds = list()

/obj/item/integrated_circuit/output/sound/Initialize()
	.= ..()
	extended_desc = list()
	extended_desc += "The first input pin determines which sound is used. The choices are; "
	extended_desc += jointext(sounds, ", ")
	extended_desc += ". The second pin determines the volume of sound that is played"
	extended_desc += ", and the third determines if the frequency of the sound will vary with each activation."
	extended_desc = jointext(extended_desc, null)

/obj/item/integrated_circuit/output/sound/do_work()
	var/ID = get_pin_data(IC_INPUT, 1)
	var/vol = get_pin_data(IC_INPUT, 2)
	var/freq = get_pin_data(IC_INPUT, 3)
	if(!isnull(ID) && !isnull(vol))
		var/selected_sound = sounds[ID]
		if(!selected_sound)
			return
		vol = CLAMP(vol ,0 , 100)
		playsound(get_turf(src), selected_sound, vol, freq, -1)
		var/atom/A = get_object()
		A.investigate_log("played a sound ([selected_sound]) as [type].", INVESTIGATE_CIRCUIT)

/obj/item/integrated_circuit/output/sound/on_data_written()
	power_draw_per_use =  get_pin_data(IC_INPUT, 2) * 15

/obj/item/integrated_circuit/output/sound/beeper
	name = "beeper circuit"
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit has a variety of beeps, boops, and buzzes to choose from."
	sounds = list(
		"beep"			= 'sound/machines/twobeep.ogg',
		"chime"			= 'sound/machines/chime.ogg',
		"buzz sigh"		= 'sound/machines/buzz-sigh.ogg',
		"buzz twice"	= 'sound/machines/buzz-two.ogg',
		"ping"			= 'sound/machines/ping.ogg',
		"synth yes"		= 'sound/machines/synth_yes.ogg',
		"synth no"		= 'sound/machines/synth_no.ogg',
		"warning buzz"	= 'sound/machines/warning-buzzer.ogg'
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/sound/beepsky
	name = "securitron sound circuit"
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit is similar to those used in Securitrons."
	sounds = list(
		"creep"			= 'sound/voice/beepsky/creep.ogg',
		"criminal"		= 'sound/voice/beepsky/criminal.ogg',
		"freeze"		= 'sound/voice/beepsky/freeze.ogg',
		"god"			= 'sound/voice/beepsky/god.ogg',
		"i am the law"	= 'sound/voice/beepsky/iamthelaw.ogg',
		"insult"		= 'sound/voice/beepsky/insult.ogg',
		"radio"			= 'sound/voice/beepsky/radio.ogg',
		"secure day"	= 'sound/voice/beepsky/secureday.ogg',
		)
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/sound/medbot
	name = "medbot sound circuit"
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit is often found in medical robots."
	sounds = list(
		"surgeon"		= 'sound/voice/medbot/surgeon.ogg',
		"radar"			= 'sound/voice/medbot/radar.ogg',
		"feel better"	= 'sound/voice/medbot/feelbetter.ogg',
		"patched up"	= 'sound/voice/medbot/patchedup.ogg',
		"injured"		= 'sound/voice/medbot/injured.ogg',
		"insult"		= 'sound/voice/medbot/insult.ogg',
		"coming"		= 'sound/voice/medbot/coming.ogg',
		"help"			= 'sound/voice/medbot/help.ogg',
		"live"			= 'sound/voice/medbot/live.ogg',
		"lost"			= 'sound/voice/medbot/lost.ogg',
		"flies"			= 'sound/voice/medbot/flies.ogg',
		"catch"			= 'sound/voice/medbot/catch.ogg',
		"delicious"		= 'sound/voice/medbot/delicious.ogg',
		"apple"			= 'sound/voice/medbot/apple.ogg',
		"no"			= 'sound/voice/medbot/no.ogg',
		)
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/sound/vox
	name = "ai vox sound circuit"
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit is often found in AI announcement systems."
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/sound/vox/Initialize()
	.= ..()
	sounds = GLOB.vox_sounds
	extended_desc = "The first input pin determines which sound is used. It uses the AI Vox Broadcast word list. So either experiment to find words that work, or ask the AI to help in figuring them out. The second pin determines the volume of sound that is played, and the third determines if the frequency of the sound will vary with each activation."

/obj/item/integrated_circuit/output/text_to_speech
	name = "text-to-speech circuit"
	desc = "Takes any string as an input and will make the device say the string when pulsed."
	extended_desc = "This unit is more advanced than the plain speaker circuit, able to transpose any valid text to speech."
	icon_state = "speaker"
	cooldown_per_use = 10
	complexity = 12
	inputs = list("text" = IC_PINTYPE_STRING)
	outputs = list()
	activators = list("to speech" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 60

/obj/item/integrated_circuit/output/text_to_speech/do_work()
	text = get_pin_data(IC_INPUT, 1)
	if(!isnull(text))
		var/atom/movable/A = get_object()
		var/sanitized_text = sanitize(text)
		A.say(sanitized_text)
		if (assembly)
			log_say("[assembly] [REF(assembly)] : [sanitized_text]")
		else
			log_say("[name] ([type]) : [sanitized_text]")

/obj/item/integrated_circuit/output/video_camera
	name = "video camera circuit"
	desc = "Takes a string as a name and a boolean to determine whether it is on, and uses this to be a camera linked to a list of networks you choose."
	extended_desc = "The camera is linked to a list of camera networks of your choosing. Common choices are 'rd' for the research network, 'ss13' for the main station network (visible to AI), 'mine' for the mining network, and 'thunder' for the thunderdome network (viewable from bar)."
	icon_state = "video_camera"
	w_class = WEIGHT_CLASS_TINY
	complexity = 10
	inputs = list(
		"camera name" = IC_PINTYPE_STRING,
		"camera active" = IC_PINTYPE_BOOLEAN,
		"camera network" = IC_PINTYPE_LIST
		)
	inputs_default = list("1" = "video camera circuit", "3" = list("rd"))
	outputs = list()
	activators = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_LONG_RANGE
	power_draw_idle = 0 // Raises to 20 when on.
	var/obj/machinery/camera/camera
	var/updating = FALSE

/obj/item/integrated_circuit/output/video_camera/New()
	..()
	camera = new(src)
	camera.network = list("rd")
	on_data_written()

/obj/item/integrated_circuit/output/video_camera/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/integrated_circuit/output/video_camera/proc/set_camera_status(var/status)
	if(camera)
		camera.status = status
		GLOB.cameranet.updatePortableCamera(camera)
		power_draw_idle = camera.status ? 20 : 0
		if(camera.status) // Ensure that there's actually power.
			if(!draw_idle_power())
				power_fail()

/obj/item/integrated_circuit/output/video_camera/on_data_written()
	if(camera)
		var/cam_name = get_pin_data(IC_INPUT, 1)
		var/cam_active = get_pin_data(IC_INPUT, 2)
		var/list/new_network = get_pin_data(IC_INPUT, 3)
		if(!isnull(cam_name))
			camera.c_tag = cam_name
		if(!isnull(new_network))
			camera.network = new_network
		set_camera_status(cam_active)

/obj/item/integrated_circuit/output/video_camera/power_fail()
	if(camera)
		set_camera_status(0)
		set_pin_data(IC_INPUT, 2, FALSE)

/obj/item/integrated_circuit/output/video_camera/ext_moved(oldLoc, dir)
	. = ..()
	update_camera_location(oldLoc)

#define VIDEO_CAMERA_BUFFER 10
/obj/item/integrated_circuit/output/video_camera/proc/update_camera_location(oldLoc)
	oldLoc = get_turf(oldLoc)
	if(!QDELETED(camera) && !updating && oldLoc != get_turf(src))
		updating = TRUE
		addtimer(CALLBACK(src, .proc/do_camera_update, oldLoc), VIDEO_CAMERA_BUFFER)
#undef VIDEO_CAMERA_BUFFER

/obj/item/integrated_circuit/output/video_camera/proc/do_camera_update(oldLoc)
	if(!QDELETED(camera) && oldLoc != get_turf(src))
		GLOB.cameranet.updatePortableCamera(camera)
	updating = FALSE

/obj/item/integrated_circuit/output/led
	name = "light-emitting diode"
	desc = "RGB LED. Takes a boolean value in, and if the boolean value is 'true-equivalent', the LED will be marked as lit on examine."
	extended_desc = "TRUE-equivalent values are: Non-empty strings, non-zero numbers, and valid refs."
	complexity = 0.1
	max_allowed = 4
	icon_state = "led"
	inputs = list(
		"lit" = IC_PINTYPE_BOOLEAN,
		"color" = IC_PINTYPE_COLOR
	)
	outputs = list()
	activators = list()
	inputs_default = list(
		"2" = "#FF0000"
	)
	power_draw_idle = 0 // Raises to 1 when lit.
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/led_color = "#FF0000"

/obj/item/integrated_circuit/output/led/on_data_written()
	power_draw_idle = get_pin_data(IC_INPUT, 1) ? 1 : 0
	led_color = get_pin_data(IC_INPUT, 2)

/obj/item/integrated_circuit/output/led/power_fail()
	set_pin_data(IC_INPUT, 1, FALSE)

/obj/item/integrated_circuit/output/led/external_examine(mob/user)
	var/text_output = "There is "

	if(name == displayed_name)
		text_output += "\an [name]"
	else
		text_output += "\an ["\improper[name]"] labeled '[displayed_name]'"
	text_output += " which is currently [get_pin_data(IC_INPUT, 1) ? "lit <font color=[led_color]>*</font>" : "unlit"]."
	to_chat(user, text_output)

/obj/item/integrated_circuit/output/diagnostic_hud
	name = "AR interface"
	desc = "Takes an icon name as an input, and will update the status hud when data is written to it."
	extended_desc = "Takes an icon name as an input, and will update the status hud when data is written to it, this means it can change the icon and have the icon stay that way even if the circuit is removed. The acceptable inputs are 'alert', 'move', 'working', 'patrol', 'called', and 'heart'. Any input other than that will return the icon to its default state."
	var/list/icons = list(
		"alert" = "hudalert",
		"move" = "hudmove",
		"working" = "hudworkingleft",
		"patrol" = "hudpatrolleft",
		"called" = "hudcalledleft",
		"heart" = "hudsentientleft"
		)
	complexity = 1
	icon_state = "led"
	inputs = list(
		"icon" = IC_PINTYPE_STRING
	)
	outputs = list()
	activators = list()
	power_draw_idle = 0
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/diagnostic_hud/on_data_written()
	var/ID = get_pin_data(IC_INPUT, 1)
	var/selected_icon = icons[ID]
	if(assembly)
		if(selected_icon)
			assembly.prefered_hud_icon = selected_icon
		else
			assembly.prefered_hud_icon = "hudstat"
		//update the diagnostic hud
		assembly.diag_hud_set_circuitstat()


//Text to radio
//Outputs a simple string into radio (good to couple with the interceptor)
//Input:
//Text: the actual string to output
//Frequency: what channel to output in. This is a STRING, not a number, due to how comms work. It has to be the frequency without the dot, aka for common you need to put "1459"
/obj/item/integrated_circuit/output/text_to_radio
	name = "text-to-radio circuit"
	desc = "Takes any string as an input and will make the device output it in the radio with the frequency chosen as input."
	extended_desc = "Similar to the text-to-speech circuit, except the fact that the text is converted into a subspace signal and broadcasted to the desired frequency, or 1459 as default.\
					The frequency is a number, and doesn't need the dot. Example: Common frequency is 145.9, so the result is 1459 as a number."
	icon_state = "speaker"
	complexity = 15
	inputs = list("text" = IC_PINTYPE_STRING, "frequency" = IC_PINTYPE_NUMBER)
	outputs = list("encryption keys" = IC_PINTYPE_LIST)
	activators = list("broadcast" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 100
	cooldown_per_use = 0.1
	var/list/whitelisted_freqs = list() // special freqs can be used by inserting encryption keys
	var/list/encryption_keys = list()
	var/obj/item/radio/headset/integrated/radio

/obj/item/integrated_circuit/output/text_to_radio/Initialize()
	. = ..()
	radio = new(src)
	radio.frequency = FREQ_COMMON
	GLOB.ic_speakers += src

/obj/item/integrated_circuit/output/text_to_radio/Destroy()
	qdel(radio)
	GLOB.ic_speakers -= src
	..()

/obj/item/integrated_circuit/output/text_to_radio/on_data_written()
	var/freq = get_pin_data(IC_INPUT, 2)
	if(!(freq in whitelisted_freqs))
		freq = sanitize_frequency(get_pin_data(IC_INPUT, 2), radio.freerange)
	radio.set_frequency(freq)

/obj/item/integrated_circuit/output/text_to_radio/do_work()
	text = get_pin_data(IC_INPUT, 1)
	if(!isnull(text))
		var/atom/movable/A = get_object()
		var/sanitized_text = sanitize(text)
		radio.talk_into(A, sanitized_text, )
		if (assembly)
			log_say("[assembly] [REF(assembly)] : [sanitized_text]")

/obj/item/integrated_circuit/output/text_to_radio/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/encryptionkey))
		user.transferItemToLoc(O,src)
		encryption_keys += O
		recalculate_channels()
		to_chat(user, "<span class='notice'>You slide \the [O] inside the circuit.</span>")
	else
		..()

/obj/item/integrated_circuit/output/text_to_radio/proc/recalculate_channels()
	whitelisted_freqs.Cut()
	set_pin_data(IC_INPUT, 2, 1459)
	radio.set_frequency(FREQ_COMMON) //reset it
	var/list/weakreffd_ekeys = list()
	for(var/o in encryption_keys)
		var/obj/item/encryptionkey/K = o
		weakreffd_ekeys += WEAKREF(K)
		for(var/i in K.channels)
			whitelisted_freqs |= GLOB.radiochannels[i]
	set_pin_data(IC_OUTPUT, 1, weakreffd_ekeys)


/obj/item/integrated_circuit/output/text_to_radio/attack_self(mob/user)
	if(encryption_keys.len)
		for(var/i in encryption_keys)
			var/obj/O = i
			O.forceMove(drop_location())
		encryption_keys.Cut()
		set_pin_data(IC_OUTPUT, 1, WEAKREF(null))
		to_chat(user, "<span class='notice'>You slide the encryption keys out of the circuit.</span>")
		recalculate_channels()
	else
		to_chat(user, "<span class='notice'>There are no encryption keys to remove from the mechanism.</span>")

/obj/item/radio/headset/integrated

/obj/item/integrated_circuit/output/screen/large
	name = "medium screen"

/obj/item/integrated_circuit/output/screen/extralarge // the subtype is called "extralarge" because tg brought back medium screens and they named the subtype /screen/large
	name = "large screen"
	desc = "Takes any data type as an input and displays it to the user upon examining, and to all nearby beings when pulsed."
	icon_state = "screen_large"
	power_draw_per_use = 40
	cooldown_per_use = 10

/obj/item/integrated_circuit/output/screen/extralarge/do_work()
	..()
	var/obj/O = assembly ? get_turf(assembly) : loc
	O.visible_message("<span class='notice'>[icon2html(O.icon, world, O.icon_state)]  [stuff_to_display]</span>")
	if(assembly)
		assembly.investigate_log("displayed \"[html_encode(stuff_to_display)]\" with [type].", INVESTIGATE_CIRCUIT)
	else
		investigate_log("displayed \"[html_encode(stuff_to_display)]\" as [type].", INVESTIGATE_CIRCUIT)
