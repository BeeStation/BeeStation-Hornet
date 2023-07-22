/obj/item/xenoartifact
	name = "artifact"
	icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	icon_state = "map_editor"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = ISWEAPON
	light_color = LIGHT_COLOR_FIRE
	desc = "A strange alien device. What could it possibly do?"
	throw_range = 3

	///How much input the artifact is getting from activator traits
	var/charge = 0
	///This isn't a requirement anymore. This just affects how effective the charge is
	var/charge_req
	///Processing type, used for tick
	var/process_type
	///List of targted entities for traits
	var/list/true_target = list()

	///Associated traits & colour
	var/material
	///activation trait, minor 1, minor 2, minor 3, major, malfunction
	var/list/traits = list()
	///Internal list of unallowed traits
	var/list/blacklist = list()
	///Touch hint
	var/datum/xenoartifact_trait/touch_desc
	///used for special examine circumstance, science goggles & ghosts
	var/special_desc = "The artifact is made from a"
	///Description used for label, used because directly adding shit to desc isn't a good idea
	var/label_desc
	///How far the artifact can reach
	var/max_range = 1

	//Used for signaler trait
	var/code
	var/frequency
	var/datum/radio_frequency/radio_connection

	//Time between uses
	var/cooldown = 8 SECONDS
	///Extra time traits can add to the cooldown
	var/cooldownmod = 0
	COOLDOWN_DECLARE(xenoa_cooldown)

	///Everytime the artifact is used this increases. When this is successfully proc'd the artifact gains a malfunction and this is lowered.
	var/malfunction_chance = 0
	///How much the chance can change in a sinlge itteration
	var/malfunction_mod = 1
	///Ref to trait list for malfunctions
	var/list/blacklist_ref

	//snowflake variable for shaped
	var/transfer_prints = FALSE

/obj/item/xenoartifact/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/xenoartifact_pricing)
	AddComponent(/datum/component/discoverable, XENOA_DP, TRUE) //Same values as original artifacts from exploration

/obj/item/xenoartifact/Initialize(mapload, difficulty)
	. = ..()

	generate_xenoa_statics() //This wont load if it's already done, aka this wont spam

	blacklist_ref = GLOB.xenoa_bluespace_blacklist
	material = difficulty //Difficulty is set, in most cases
	if(!material)
		material = pick_weight(list(XENOA_BLUESPACE = 8, XENOA_PLASMA = 5, XENOA_URANIUM = 3, XENOA_BANANIUM = 1)) //Maint artifacts and similar situations

	var/price
	var/extra_masks = 0
	switch(material)
		if(XENOA_BLUESPACE) //Check xenoartifact_materials.dm for info on artifact materials/types/traits
			name = "bluespace [name]"
			generate_traits(GLOB.xenoa_bluespace_blacklist)
			if(!price)
				price = pick(100, 200, 300)
			extra_masks = pick(1)

		if(XENOA_PLASMA)
			name = "plasma [name]"
			blacklist_ref = GLOB.xenoa_plasma_blacklist
			generate_traits(GLOB.xenoa_plasma_blacklist)
			if(!price)
				price = pick(200, 300, 500)
			malfunction_mod = 3
			extra_masks = pick(1)

		if(XENOA_URANIUM)
			name = "uranium [name]"
			blacklist_ref = GLOB.xenoa_uranium_blacklist
			generate_traits(GLOB.xenoa_uranium_blacklist, TRUE)
			if(!price)
				price = pick(300, 500, 800)
			malfunction_mod = 5
			extra_masks = pick(1)

		if(XENOA_BANANIUM)
			name = "bananium [name]"
			generate_traits()
			if(!price)
				price = pick(500, 800, 1000)
			malfunction_mod = 5
			extra_masks = 0
	SEND_SIGNAL(src, XENOA_CHANGE_PRICE, price) //update price, bacon requested signals

	//Initialize traits that require that.
	for(var/datum/xenoartifact_trait/t as() in traits)
		t.on_init(src)

	//Sprite process
	//Base texture
	var/icon/texture = new('icons/obj/xenoarchaeology/xenoartifact.dmi', "texture-[material]-[pick(1, 2, 3)]")
	//Masking
	var/list/indecies = list(1, 2, 3, 4, 5) //Indecies for masks
	var/index = pick(indecies)
	indecies -= index
	var/icon/mask = new('icons/obj/xenoarchaeology/xenoartifact.dmi', "mask-[material]-[index]")
	for(var/i in 1 to extra_masks)
		index = pick(indecies)
		indecies -= index
		var/icon/extra_mask = new('icons/obj/xenoarchaeology/xenoartifact.dmi', "mask-[material]-[index]")
		mask.Blend(extra_mask, ICON_UNDERLAY)
	texture.AddAlphaMask(mask)
	icon = texture
	add_filter("inner_band", 1, list("type" = "outline", "color" = "#000", "size" = 1))
	add_filter("outer_band", 1.1, list("type" = "outline", "color" = material, "size" = 1))

/obj/item/xenoartifact/Destroy()
	SSradio.remove_object(src, frequency)
	for(var/datum/xenoartifact_trait/T as() in traits)
		qdel(T) //deleting the traits individually ensures they properly destroy, deleting the list bunks it
	traits = null
	qdel(touch_desc)
	for(var/atom/movable/AM in contents)
		if(istype(AM, /obj/item/xenoartifact_label)) //Delete stickers
			qdel(AM)
		else
			AM.forceMove((loc ? loc : get_turf(src)))
	return ..()

/obj/item/xenoartifact/CanAllowThrough(atom/movable/mover, turf/target) //tweedle dee, density feature
	if(get_trait(/datum/xenoartifact_trait/minor/dense) || anchored)
		return FALSE
	return ..()

/obj/item/xenoartifact/attack_hand(mob/user) //tweedle dum, density feature
	var/obj/item/clothing/gloves/artifact_pinchers/P = locate(/obj/item/clothing/gloves/artifact_pinchers) in user.contents

	if(isliving(loc) && touch_desc?.on_touch(src, user) && user.can_see_reagents())
		balloon_alert(user, (initial(touch_desc.desc) ? initial(touch_desc.desc) : initial(touch_desc.label_name)), material)

	if(get_trait(/datum/xenoartifact_trait/minor/dense) || anchored)
		if(process_type == PROCESS_TYPE_LIT) //Snuff out candle
			to_chat(user, "<span class='notice'>You snuff out [name]</span>")
			process_type = null
			return FALSE
		if(P?.safety && isliving(loc))
			SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, src, user, user) //we're in the ghetto now

	if(P?.safety && isliving(loc))
		return
	..()

/obj/item/xenoartifact/examine(mob/living/carbon/user)
	. = ..()
	if(user.can_see_reagents()) //Not checking carbon throws a runtime concerning observers
		. += "<span class='notice'>[special_desc]</span>"
	if(isobserver(user))
		for(var/datum/xenoartifact_trait/t as() in traits)
			. += (t?.desc ? "<span class='notice'>[t.desc]</span>" : "<span class='notice'>[t.label_name]</span>")
	. += label_desc

/obj/item/xenoartifact/attack_self(mob/user)
	if(!isliving(loc) && (!get_trait(/datum/xenoartifact_trait/minor/dense) || anchored))
		return

	if(process_type == PROCESS_TYPE_LIT) //Snuff out candle
		to_chat(user, "<span class='notice'>You snuff out [name]</span>")
		process_type = null
		return

	if(isliving(loc) && touch_desc?.on_touch(src, user) && user.can_see_reagents())
		balloon_alert(user, (initial(touch_desc.desc) ? initial(touch_desc.desc) : initial(touch_desc.label_name)), material)

	var/obj/item/clothing/gloves/artifact_pinchers/P = locate(/obj/item/clothing/gloves/artifact_pinchers) in user.contents
	if(P?.safety && isliving(loc))
		return
	..()

/obj/item/xenoartifact/attackby(obj/item/I, mob/living/user, params)
	var/tool_text
	for(var/datum/xenoartifact_trait/t as() in traits) //chat, bubble-hints & helpers
		if(t?.on_item(src, user, I) && user.can_see_reagents())
			tool_text = "[tool_text][t.desc ? t.desc : t.label_name]\n"
	if(tool_text)
		balloon_alert(user, tool_text, material)

	//allow people to remove stickers
	if(I.tool_behaviour == TOOL_WIRECUTTER && (locate(/obj/item/xenoartifact_label) in contents))
		label_desc = null
		I.use_tool()
		qdel(locate(/obj/item/xenoartifact_label) in contents)

	//Let people label in peace
	if(istype(I, /obj/item/xenoartifact_label) || istype(I, /obj/item/xenoartifact_labeler))
		return

	//abort if safety
	var/obj/item/clothing/gloves/artifact_pinchers/P = locate(/obj/item/clothing/gloves/artifact_pinchers) in user.contents
	if(P?.safety)
		to_chat(user, "<span class='notice'>You perform a safe operation on [src] with [I].</span>")
		return
	..()

/obj/item/xenoartifact/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	//abort if safety
	var/obj/item/clothing/gloves/artifact_pinchers/P = locate(/obj/item/clothing/gloves/artifact_pinchers) in user.contents
	if(P?.safety)
		to_chat(user, "<span class='notice'>You perform a safe operation on [src].</span>")
		return
	..()

///Run traits. Used to activate all minor, major, and malfunctioning traits in the artifact's trait list. Sets cooldown when properly finished.
/obj/item/xenoartifact/proc/check_charge(mob/user, charge_mod)
	log_game("[user] attempted to activate [src] at [world.time]. Located at [AREACOORD(src)].")

	if(COOLDOWN_FINISHED(src, xenoa_cooldown) && !istype(loc, /obj/item/storage))
		COOLDOWN_START(src, xenoa_cooldown, cooldown+cooldownmod)
		if(prob(malfunction_chance) && traits.len < 7 + (material == XENOA_URANIUM ? 1 : 0)) //See if we pick up an malfunction
			generate_malfunction_unique()
			malfunction_chance = 0 //Lower chance after contracting
		else //otherwise increase chance.
			malfunction_chance = min(malfunction_chance + malfunction_mod, 100)

		charge += charge_mod
		charge = (charge+charge_req)/1.9 //Not quite an average. Generally produces better results.

		for(var/datum/xenoartifact_trait/minor/t in traits)//Minor traits aren't apart of the target loop, specifically becuase they pass data into it.
			t.activate(src, user, user)
			log_game("[src] activated minor trait [t] at [world.time]. Located at [AREACOORD(src)]")

		//Clamp charge to avoid fucky wucky
		charge = max(10, charge)

		//Add holder for muh balance
		/*
		Uncomment this if artifact abuse becomes a huge issue

		if(isliving(loc) || isliving(pulledby))
			var/mob/living/M = isliving(loc) ? loc : pulledby
			if(!istype(M.get_item_by_slot(ITEM_SLOT_GLOVES), /obj/item/clothing/gloves/artifact_pinchers) && !istype(get_area(M), /area/science))
				true_target |= list(M)
		*/

		for(var/atom/M in true_target) //target loop, majors & malfunctions
			if(get_dist(get_turf(src), get_turf(M)) <= max_range)
				create_beam(M) //Indicator beam, points to target, M
				for(var/datum/xenoartifact_trait/t as() in traits) //Major traits
					if(!istype(t, /datum/xenoartifact_trait/minor))
						log_game("[src] activated trait [t] at [world.time]. Located at [AREACOORD(src)]")
						t.activate(src, M, user)
		if(!get_trait(/datum/xenoartifact_trait/major/horn))
			playsound(get_turf(src), 'sound/magic/blink.ogg', 25, TRUE)

	charge = 0
	true_target?.Cut(1, 0)

///Generate traits outside of blacklist. Malf = TRUE if you want malfunctioning traits.
/obj/item/xenoartifact/proc/generate_traits(list/blacklist_traits, malf = FALSE)
	//Provided blacklist or nothing, covers bananium
	blacklist = blacklist_traits?.Copy() || list()

	var/datum/xenoartifact_trait/desc_holder
	desc_holder = generate_trait_unique(GLOB.xenoa_activators, blacklist, FALSE) //Activator
	special_desc = initial(desc_holder.desc) ? "[special_desc] [initial(desc_holder.desc)]" : "[special_desc]n Unknown"

	desc_holder = null
	var/datum/xenoartifact_trait/minor_desc_holder
	for(var/i in 1 to 3)
		minor_desc_holder = generate_trait_unique(GLOB.xenoa_minors, blacklist, FALSE) //Minor/s
		desc_holder = desc_holder ? desc_holder : minor_desc_holder
		if(!touch_desc)
			touch_desc = traits[traits.len]
			if(!touch_desc.on_touch(src, src))
				touch_desc = null //not setting this to null fucks with check, qdel refuses to be helpful another day

	special_desc = initial(desc_holder?.desc) ? "[special_desc] [initial(desc_holder.desc)] material." : "[special_desc] material."

	if(malf)
		generate_trait_unique(GLOB.xenoa_malfs, blacklist) //Malf

	desc_holder = generate_trait_unique(GLOB.xenoa_majors, blacklist, FALSE) //Major
	special_desc = initial(desc_holder.desc) ? "[special_desc] The shape is [initial(desc_holder.desc)]." : "[special_desc] The shape is Unknown."

	charge_req = rand(1, 10) * 10

///generate a single trait against a blacklist. Used in larger /obj/item/xenoartifact/proc/generate_traits()
/obj/item/xenoartifact/proc/generate_trait_unique(list/trait_list, list/blacklist_traits = list())
	var/datum/xenoartifact_trait/new_trait //Selection
	var/list/selection = trait_list.Copy() //Selectable traits
	selection -= blacklist_traits
	if(selection.len < 1)
		log_game("An impossible event has occured. [src] has failed to generate any traits!")
		return
	new_trait = pick_weight(selection)
	blacklist += new_trait //Add chosen trait to blacklist
	traits += new new_trait
	new_trait = new new_trait //type converting doesn't work too well here but this should be fine.
	blacklist += new_trait.blacklist_traits //Cant use initial() to access lists without bork'ing it
	return new_trait

///generates a malfunction respective to the artifact's type - don't use anywhere but for check_charge malfunctions
/obj/item/xenoartifact/proc/generate_malfunction_unique(list/blacklist)
	var/list/malfunctions = GLOB.xenoa_malfs.Copy()
	malfunctions -= blacklist
	malfunctions -= traits
	if(!malfunctions.len)
		return
	//Pick one to use
	var/datum/xenoartifact_trait/T = pick(malfunctions)
	T = new T
	traits += T

///Gets a singular entity, there's a specific traits that handles multiple.
/obj/item/xenoartifact/proc/get_target_in_proximity(range)
	for(var/mob/living/M in oview(range, get_turf(src)))
		. = process_target(M)
	if(isliving(loc) && !.)
		. = process_target(loc)
	//Return a list becuase byond is fucky and WILL overwrite the typing
	return list(.)

///Returns the desired trait and it's values if it's in the artifact's list
/obj/item/xenoartifact/proc/get_trait(typepath)
	return (locate(typepath) in traits)

///Used for hand-holding secret technique. Pulling entities swaps them for you in the target list.
/obj/item/xenoartifact/proc/process_target(atom/target)
	if(ishuman(target)) //early return if deflect chance
		var/mob/living/carbon/human/H = target
		if(H.wear_suit && H.head && isclothing(H.wear_suit) && isclothing(H.head))
			if(H.anti_artifact_check())
				to_chat(target, "<span class='warning'>The [name] was unable to target you!</span>")
				playsound(get_turf(target), 'sound/weapons/deflect.ogg', 25, TRUE)
				return

	if(isliving(target)) //handle pulling
		var/mob/living/M = target
		. = M?.pulling ? M.pulling : M
	else
		. = target
	RegisterSignal(., COMSIG_PARENT_QDELETING, PROC_REF(on_target_del), TRUE)
	return

///Hard del handle
/obj/item/xenoartifact/proc/on_target_del(atom/target)
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	true_target -= list(target)

///Helps show how the artifact is working. Hint stuff. Draws a beam between artifact and target
/obj/item/xenoartifact/proc/create_beam(atom/target)
	if((locate(src) in target?.contents) || !get_turf(target))
		return
	var/datum/beam/xenoa_beam/B = new((!isturf(loc) ? loc : src), target, time=1.5 SECONDS, beam_icon='icons/obj/xenoarchaeology/xenoartifact.dmi', beam_icon_state="xenoa_beam", btype=/obj/effect/ebeam/xenoa_ebeam)
	B.set_color(material)
	INVOKE_ASYNC(B, TYPE_PROC_REF(/datum/beam/xenoa_beam, Start))

///Default template used to interface with activator signals.
/obj/item/xenoartifact/proc/default_activate(chr, mob/user, atom/target)
	if(!COOLDOWN_FINISHED(src, xenoa_cooldown))
		return FALSE
	charge = chr
	true_target |= process_target(target)
	check_charge(user)
	return TRUE

///Signaler traits. Sets listening freq
/obj/item/xenoartifact/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, "[RADIO_XENOA]_[REF(src)]") //not doing the weird filter fucks with other artifacts

///Signaler traits. Sends signal
/obj/item/xenoartifact/proc/send_signal(datum/signal/signal)
	if(!radio_connection||!signal)
		return
	radio_connection.post_signal(src, signal)

/obj/item/xenoartifact/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return
	SEND_SIGNAL(src, XENOA_SIGNAL, null, get_target_in_proximity(max_range), get_target_in_proximity(max_range)) //I don't think this sends a signal

/obj/item/xenoartifact/on_block(mob/living/carbon/human/owner, atom/movable/hitby)
	. = ..()
	if(!(COOLDOWN_FINISHED(src, xenoa_cooldown)) || !get_trait(/datum/xenoartifact_trait/minor/blocking))
		return
	SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, src, owner, hitby) //I don't think this sends a signal

/obj/item/xenoartifact/process(delta_time)
	switch(process_type)
		if(PROCESS_TYPE_LIT) //Burning
			true_target = get_target_in_proximity(min(max_range, 5))
			if(true_target[1])
				visible_message("<span class='danger' size='4'>The [name] flicks out.</span>")
				default_activate(25, null, null)
				process_type = null
				return PROCESS_KILL
		if(PROCESS_TYPE_TICK) //Clock-ing
			playsound(get_turf(src), 'sound/effects/clock_tick.ogg', 50, TRUE)
			visible_message("<span class='danger' size='10'>The [name] ticks.</span>")
			true_target = get_target_in_proximity(min(max_range, 5))
			default_activate(25, null, null)
			if(DT_PROB(XENOA_TICK_CANCEL_PROB, delta_time) && COOLDOWN_FINISHED(src, xenoa_cooldown))
				process_type = null
				return PROCESS_KILL
		else
			return PROCESS_KILL

/obj/item/xenoartifact/maint //Semi-toddler-safe version, for maint loot table.
	material = XENOA_BLUESPACE

/obj/item/xenoartifact/maint/Initialize(mapload, difficulty)
	if(prob(1))
		material = pick(XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM)
	difficulty = material
	..()

/datum/component/xenoartifact_pricing ///Pricing component for shipping solution. Consider swapping to cargo after change.
	///Buying and selling related, based on guess qaulity
	var/modifier = 0.5
	///default price gets generated if it isn't set by console. This only happens if the artifact spawns outside of that process
	var/price

/datum/component/xenoartifact_pricing/Initialize(...)
	RegisterSignal(parent, XENOA_CHANGE_PRICE, PROC_REF(update_price))
	..()

/datum/component/xenoartifact_pricing/Destroy(force, silent)
	UnregisterSignal(parent, XENOA_CHANGE_PRICE)
	..()

///Typically used to change internally
/datum/component/xenoartifact_pricing/proc/update_price(datum/source, f_price)
	price = f_price

 ///Objective version for exploration
/obj/item/xenoartifact/objective/Initialize(mapload, difficulty)
	traits += new /datum/xenoartifact_trait/special/objective
	..()

/obj/item/xenoartifact/objective/ComponentInitialize()
	AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)
	AddComponent(/datum/component/tracking_beacon, EXPLORATION_TRACKING, null, null, TRUE, "#eb4d4d", TRUE, TRUE)
	..()

/obj/effect/ebeam/xenoa_ebeam //Beam code. This isn't mine. See beam.dm for better documentation.
	name = "artifact beam"

/datum/beam/xenoa_beam
	var/color

/datum/beam/xenoa_beam/proc/set_color(col) //Custom proc to set beam colour
	color = col

/datum/beam/xenoa_beam/Draw()
	var/Angle = round(get_angle(origin,target))
	var/matrix/rot_matrix = matrix()
	var/turf/origin_turf = get_turf(origin)
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (32*target?.x+target?.pixel_x)-(32*origin?.x+origin?.pixel_x)
	var/DY = (32*target?.y+target?.pixel_y)-(32*origin?.y+origin?.pixel_y)
	var/n = 0
	var/length = round(sqrt((DX)**2+(DY)**2)) //hypotenuse of the triangle formed by target and origin's displacement

	for(n in 0 to length-1 step 32)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		if(QDELETED(src))
			break
		var/obj/effect/ebeam/xenoa_ebeam/X = new(origin_turf) // Start Xenoartifact - This assigns colour to the beam
		X.color = color
		X.owner = src
		elements += X // End Xenoartifact

		//Assign our single visual ebeam to each ebeam's vis_contents
		//ends are cropped by a transparent box icon of length-N pixel size laid over the visuals obj
		if(n+32>length)
			var/icon/II = new(icon, icon_state)
			II.DrawBox(null,1,(length-n),32,32)
			X.icon = II
		else
			X.vis_contents += visuals
		X.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle)+32*sin(Angle)*(n+16)/32)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle)+32*cos(Angle)*(n+16)/32)

		//Position the effect so the beam is one continous line
		var/a
		if(abs(Pixel_x)>32)
			a = Pixel_x > 0 ? round(Pixel_x/32) : CEILING(Pixel_x/32, 1)
			X.x += a
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			a = Pixel_y > 0 ? round(Pixel_y/32) : CEILING(Pixel_y/32, 1)
			X.y += a
			Pixel_y %= 32

		X.pixel_x = Pixel_x
		X.pixel_y = Pixel_y
		CHECK_TICK
