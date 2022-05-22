/obj/item/xenoartifact
	name = "xenoartifact"
	icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	icon_state = "map_editor"
	w_class = WEIGHT_CLASS_NORMAL
	light_color = LIGHT_COLOR_FIRE
	desc = "A strange alien artifact. What could it possibly do?"
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
	///Touch hint
	var/datum/xenoartifact_trait/touch_desc
	///used for special examine circumstance, science goggles & ghosts
	var/special_desc = "The Xenoartifact is made from a"
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

	//Associated with random sprite stuff. It's setup as [4] so it's easier to check for slots being assigned by traits and such
	var/list/icon_slots[4]
	var/mutable_appearance/icon_overlay 

	///Everytime the artifact is used this increases. When this is successfully proc'd the artifact gains a malfunction and this is lowered.
	var/malfunction_chance = 0
	///How much the chance can change in a sinlge itteration
	var/malfunction_mod = 1

/obj/item/xenoartifact/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/xenoartifact_pricing)
	AddComponent(/datum/component/discoverable, XENOA_DP, TRUE) //Same values as original artifacts from exploration

/obj/item/xenoartifact/Initialize(mapload, difficulty)
	. = ..()
	material = difficulty //Difficulty is set, in most cases
	if(!material)
		material = pick(XENOA_BLUESPACE, XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM) //Maint artifacts and similar situations

	var/datum/component/xenoartifact_pricing/xenop = GetComponent(/datum/component/xenoartifact_pricing)

	switch(material)
		if(XENOA_BLUESPACE) //Check xenoartifact_materials.dm for info on artifact materials/types/traits
			name = "bluespace [name]"
			generate_traits(list(/datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/radioactive,
							/datum/xenoartifact_trait/minor/sentient, /datum/xenoartifact_trait/major/sing, 
							/datum/xenoartifact_trait/major/laser, /datum/xenoartifact_trait/major/bomb,
							/datum/xenoartifact_trait/major/handmore, /datum/xenoartifact_trait/major/emp))
			if(!xenop.price)
				xenop.price = pick(100, 200, 300)

		if(XENOA_PLASMA)
			name = "plasma [name]"
			generate_traits(list(/datum/xenoartifact_trait/major/sing, /datum/xenoartifact_trait/activator/burn,
							/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/sentient, 
							/datum/xenoartifact_trait/major/capture, /datum/xenoartifact_trait/major/timestop,
							/datum/xenoartifact_trait/major/bomb, /datum/xenoartifact_trait/major/mirrored,
							/datum/xenoartifact_trait/major/corginator,/datum/xenoartifact_trait/activator/clock,
							/datum/xenoartifact_trait/major/invisible,/datum/xenoartifact_trait/major/handmore,
							/datum/xenoartifact_trait/major/lamp, /datum/xenoartifact_trait/major/forcefield,
							/datum/xenoartifact_trait/activator/signal,/datum/xenoartifact_trait/major/heal, 
							/datum/xenoartifact_trait/activator/batteryneed))
			if(!xenop.price)
				xenop.price = pick(200, 300, 500)
			malfunction_mod = 2

		if(XENOA_URANIUM)
			name = "uranium [name]"
			generate_traits(list(/datum/xenoartifact_trait/major/sing, /datum/xenoartifact_trait/minor/sharp,
							/datum/xenoartifact_trait/major/laser, /datum/xenoartifact_trait/major/corginator,
							/datum/xenoartifact_trait/minor/sentient, /datum/xenoartifact_trait/minor/wearable,
							/datum/xenoartifact_trait/major/handmore, /datum/xenoartifact_trait/major/invisible,
							/datum/xenoartifact_trait/major/heal), TRUE) 
			if(!xenop.price)
				xenop.price = pick(300, 500, 800) 
			malfunction_mod = 8

		if(XENOA_BANANIUM)
			name = "bananium [name]"
			generate_traits(list(/datum/xenoartifact_trait/major/sing))
			if(!xenop.price)
				xenop.price = pick(500, 800, 1000) 
			malfunction_mod = 0.5

	//Initialize traits that require that.
	for(var/datum/xenoartifact_trait/t as() in traits)
		t.on_init(src)

	//Random sprite process, I'd like to maybe revisit this, make it a function. probably don't
	icon_state = null
	if(!(icon_state))
		var/holdthisplease = rand(1, 3)
		icon_state = "IB[holdthisplease]"//base
		generate_icon(icon, "IBL[holdthisplease]", material)
	if(prob(50) || icon_slots[1])//Top
		if(!(icon_slots[1])) //Some traits can set this too, it will be set to a code that looks like 901, 908, 905 ect.
			icon_slots[1] = rand(1, 2)
		generate_icon(icon, "ITP[icon_slots[1]]")
		generate_icon(icon, "ITPL[icon_slots[1]]", material)

	if(prob(30) || icon_slots[3])//Left
		if(!(icon_slots[3]))
			icon_slots[3] = rand(1, 2)
		generate_icon(icon, "IL[icon_slots[3]]")
		generate_icon(icon, "ILL[icon_slots[3]]", material)

	if(prob(50)  || icon_slots[4])//Right
		if(!(icon_slots[4]))
			icon_slots[4] = rand(1, 2)
		generate_icon(icon, "IR[icon_slots[4]]")
		generate_icon(icon, "IRL[icon_slots[4]]", material)

	if(prob(30) || icon_slots[2])//Bottom
		if(!(icon_slots[2]))
			icon_slots[2] = rand(1, 2)
		generate_icon(icon, "IBTM[icon_slots[2]]")
		generate_icon(icon, "IBTML[icon_slots[2]]", material)

/obj/item/xenoartifact/CanAllowThrough(atom/movable/mover, turf/target) //tweedle dee, density feature
	if(get_trait(/datum/xenoartifact_trait/minor/dense))
		return FALSE
	return ..()

/obj/item/xenoartifact/attack_hand(mob/user) //tweedle dum, density feature
	if(get_trait(/datum/xenoartifact_trait/minor/dense))
		if(user.a_intent != INTENT_GRAB)
			SEND_SIGNAL(src, XENOA_INTERACT, null, user, user) //Calling the regular attack_hand signal causes feature issues, like picking up the artifact.
		else
			touch_desc?.on_touch(src, user)
		return FALSE
	..()

/obj/item/xenoartifact/examine(mob/living/carbon/user)
	. = ..()	
	if(isobserver(user))
		to_chat(user, "<span class='notice'>[special_desc]</span>")
		for(var/datum/xenoartifact_trait/t as() in traits)
			to_chat(user, "<span class='notice'>[t.desc ? t.desc : t.label_name]</span>")
	else if(iscarbon(user) && istype(user?.glasses, /obj/item/clothing/glasses/science)) //Not checking carbon throws a runtime concerning observers
		to_chat(user, "<span class='notice'>[special_desc]</span>")

/obj/item/xenoartifact/interact(mob/user)
	. = ..()
	if(process_type == PROCESS_TYPE_LIT) //Snuff out candle
		to_chat(user, "<span class='notice'>You snuff out [name]</span>")
		process_type = null
		return
	if(user.a_intent == INTENT_GRAB)
		touch_desc?.on_touch(src, user)
		return
	SEND_SIGNAL(src, XENOA_INTERACT, null, user, user)

/obj/item/xenoartifact/attackby(obj/item/I, mob/living/user, params)
	for(var/datum/xenoartifact_trait/t as() in traits)
		t.on_item(src, user, I)
	if(!(COOLDOWN_FINISHED(src, xenoa_cooldown))||user?.a_intent == INTENT_GRAB||istype(I, /obj/item/xenoartifact_label)||istype(I, /obj/item/xenoartifact_labeler))
		return
	..()

/obj/item/xenoartifact/proc/check_charge(mob/user, charge_mod) //Run traits
	log_game("[user] attempted to activate [src] at [world.time]. Located at [x] [y] [z].")

	if(COOLDOWN_FINISHED(src, xenoa_cooldown))
		if(prob(malfunction_chance)) //See if we pick up an malfunction
			var/datum/xenoartifact_trait/t = pick(subtypesof(/datum/xenoartifact_trait/malfunction))
			traits += new t
			malfunction_chance = malfunction_chance*0.2 //Lower chance after contracting 
		else
			malfunction_chance += malfunction_mod //otherwise increase chance

		charge += charge_mod
		for(var/datum/xenoartifact_trait/t as() in traits)//Minor & malfunction traits aren't apart of the target loop
			if(!istype(t, /datum/xenoartifact_trait/major))
				t.activate(src, user, user)
				log_game("[src] activated [istype(t, /datum/xenoartifact_trait/malfunction) ? "malfunction" : "minor"] trait [t] at [world.time]. Located at [x] [y] [z]")
		charge = (charge+charge_req)/1.9 //Not quite an average. Generally produces better results.     
		for(var/atom/M in true_target) //target loop
			if(get_dist(get_turf(src), get_turf(M)) <= max_range) 
				create_beam(M) //Indicator beam, points to target, M
				for(var/datum/xenoartifact_trait/major/t as() in traits) //Major traits
					log_game("[src] activated major trait [t] at [world.time]. Located at [x] [y] [z]")
					t.activate(src, M, user)
				if(!(get_trait(/datum/xenoartifact_trait/minor/aura))) //Quick fix for bug that selects multiple targets for noraisin
					break
		COOLDOWN_START(src, xenoa_cooldown, cooldown+cooldownmod)
	charge = 0
	true_target = list()

/obj/item/xenoartifact/proc/generate_traits(var/list/blacklist_traits, malf = FALSE) //Generate traits outside of blacklist. Malf = TRUE if you want malfunctions
	var/datum/xenoartifact_trait/desc_holder
	desc_holder = generate_trait_unique(XENOA_ACTIVATORS, blacklist_traits, FALSE) //Activator
	special_desc = initial(desc_holder.desc) ? "[special_desc] [initial(desc_holder.desc)]" : special_desc

	desc_holder = null
	var/datum/xenoartifact_trait/minor_desc_holder
	for(var/i in 1 to 3)
		minor_desc_holder = generate_trait_unique(XENOA_MINORS, blacklist_traits, FALSE) //Minor/s
		desc_holder = desc_holder ? desc_holder : minor_desc_holder
		if(!touch_desc)
			touch_desc = traits[traits.len] 
			if(!touch_desc.on_touch(src, src))
				qdel(touch_desc)
				touch_desc = null //not setting this to null fucks with check, qdel refuses to be helpful another day

	special_desc = desc_holder ? "[special_desc] [initial(desc_holder.desc)] material." : "[special_desc] material"

	desc_holder = generate_trait_unique(XENOA_MAJORS, blacklist_traits, FALSE) //Major
	special_desc = initial(desc_holder.desc) ? "[special_desc] The shape is [initial(desc_holder.desc)]." : special_desc

	if(malf)
		generate_trait_unique(XENOA_MALFS, blacklist_traits) //Malf

	charge_req = rand(1, 10) * 10

/obj/item/xenoartifact/proc/generate_trait_unique(var/list/trait_list, var/list/blacklist_traits) //generate a single trait against a blacklist.
	var/datum/xenoartifact_trait/new_trait //Selection
	var/list/selection = trait_list //Selectable traits
	selection -= blacklist_traits
	if(selection.len < 1)
		log_game("An almost impossible event has occured. [src] has failed to generate any traits with [trait_list]!")
		return
	new_trait = pick(selection)
	blacklist_traits += new_trait //Add chosen trait to blacklist
	traits += new new_trait
	new_trait = new new_trait
	blacklist_traits += new_trait.blacklist_traits
	qdel(new_trait)
	return new_trait
	
/obj/item/xenoartifact/proc/get_target_in_proximity(range) //Gets a singular entity, there's a specific traits that handles multiple.
	for(var/mob/living/M in oview(range, get_turf(src)))
		. = process_target(M)
	if(isliving(loc) && !.)
		. = loc
	return

/obj/item/xenoartifact/proc/get_trait(typepath) //Returns the desired trait and it's values if it's in the artifact's list
	return (locate(typepath) in traits)

/obj/item/xenoartifact/proc/generate_icon(var/icn, var/icnst = "", colour) //Add extra icon overlays. Ghetto GAGS
	icon_overlay = mutable_appearance(icn, icnst)
	icon_overlay.layer = FLOAT_LAYER //Not doing this fucks the object icons when you're holding it
	icon_overlay.appearance_flags = RESET_ALPHA// Not doing this fucks the alpha?
	icon_overlay.alpha = alpha
	if(colour)
		icon_overlay.color = colour
	add_overlay(icon_overlay)

/obj/item/xenoartifact/proc/process_target(atom/target) //Used for hand-holding secret technique. Pulling entities swaps them for you in the target list.
	. = target
	if(isliving(target?.loc))
		. = target?.loc
	var/mob/living/M = istype(target, /mob/living) ? target : null //Have to type convert to access pulling
	if(M?.pulling)
		. = M?.pulling
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/on_target_del, target)
	return

/obj/item/xenoartifact/proc/on_target_del(atom/target) //Hard del handle
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	true_target -= target
	target = null

/obj/item/xenoartifact/proc/create_beam(atom/target) //Helps show how the artifact is working. Hint stuff.
	if(isliving(loc) || !get_turf(target))
		return
	var/datum/beam/xenoa_beam/B = new(src.loc, target, time=1.5 SECONDS, beam_icon='icons/obj/xenoarchaeology/xenoartifact.dmi', beam_icon_state="xenoa_beam", btype=/obj/effect/ebeam/xenoa_ebeam)
	B.set_color(material)
	INVOKE_ASYNC(B, /datum/beam/xenoa_beam.proc/Start)

/obj/item/xenoartifact/proc/default_activate(chr, mob/user, atom/target) //Default template used to interface with activator signals. Handle
	if(!COOLDOWN_FINISHED(src, xenoa_cooldown))
		return FALSE
	charge = chr
	true_target = !(locate(target) in true_target) ? true_target+process_target(target) : true_target
	check_charge(user)
	return TRUE

/obj/item/xenoartifact/proc/set_frequency(new_frequency) //Signaler traits
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)

/obj/item/xenoartifact/proc/send_signal(var/datum/signal/signal)
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
			true_target = list(get_target_in_proximity(min(max_range, 5)))
			if(!isnull(true_target))
				visible_message("<span class='danger'>The [name] flicks out.</span>")
				default_activate(25, null, null)
				process_type = null
				return PROCESS_KILL
		if(PROCESS_TYPE_TICK) //Clock-ing
			visible_message("<span class='notice'>The [name] ticks.</span>")
			true_target = list(get_target_in_proximity(min(max_range, 5)))
			default_activate(25, null, null)
			if(prob(13) && COOLDOWN_FINISHED(src, xenoa_cooldown))
				process_type = null
				return PROCESS_KILL
		else    
			return PROCESS_KILL

/obj/item/xenoartifact/Destroy()
	SSradio.remove_object(src, frequency)
	qdel(radio_connection)
	qdel(traits)
	qdel(touch_desc)
	for(var/atom/movable/AM in contents)
		if(istype(AM, /obj/item/xenoartifact_label)) //Delete stickers
			qdel(AM)
		else
			AM.forceMove(get_turf(loc))
	..()

/obj/item/xenoartifact/maint //Semi-toddler-safe version, for maint loot table.
	material = XENOA_BLUESPACE

/obj/item/xenoartifact/maint/Initialize(mapload, difficulty)
	if(prob(0.1))
		material = pick(XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM)
	difficulty = material
	..()

/datum/component/xenoartifact_pricing ///Pricing component for shipping solution. Consider swapping to cargo after change.
	var/modifier = 0.65 ///Buying and selling related
	var/price ///default price gets generated if it isn't set by console. This only happens if the artifact spawns outside of that process

/obj/item/xenoartifact/objective/Initialize(mapload, difficulty) //Objective version for exploration
	. = ..()
	traits += new /datum/xenoartifact_trait/special/objective

/obj/item/xenoartifact/objective/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)

/obj/effect/ebeam/xenoa_ebeam //Beam code. This isn't mine. See beam.dm for better documentation.
	name = "xenoartifact beam"

/datum/beam/xenoa_beam
	var/color

/datum/beam/xenoa_beam/proc/set_color(col) //Custom proc to set beam colour
	color = col

/datum/beam/xenoa_beam/Draw()
	var/Angle = round(Get_Angle(origin,target))
	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (32*target?.x+target?.pixel_x)-(32*origin?.x+origin?.pixel_x)
	var/DY = (32*target?.y+target?.pixel_y)-(32*origin?.y+origin?.pixel_y)
	var/n = 0
	var/length = round(sqrt((DX)**2+(DY)**2)) //hypotenuse of the triangle formed by target and origin's displacement

	for(n in 0 to length-1 step 32)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		if(QDELETED(src) || finished)
			break
		var/obj/effect/ebeam/xenoa_ebeam/X = new(origin_oldloc) // Start Xenoartifact - This assigns colour to the beam
		X.color = color
		X.owner = src
		elements += X // End Xenoartifact

		//Assign icon, for main segments it's base_icon, for the end, it's icon+icon_state
		//cropped by a transparent box of length-N pixel size
		if(n+32>length)
			var/icon/II = new(icon, icon_state)
			II.DrawBox(null,1,(length-n),32,32)
			X.icon = II
		else
			X.icon = base_icon
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
	afterDraw()
