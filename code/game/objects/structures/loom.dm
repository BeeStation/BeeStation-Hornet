#define FABRIC_PER_SHEET 4


///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE

/obj/structure/loom/attackby(obj/item/I, mob/user)
	if(weave(I, user))
		return
	return ..()

/obj/structure/loom/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I, 5)
	return TRUE

///Handles the weaving.
/obj/structure/loom/proc/weave(obj/item/stack/sheet/cotton/W, mob/user)
	if(!istype(W))
		return FALSE
	if(!anchored)
		user.show_message("<span class='notice'>The loom needs to be wrenched down.</span>", MSG_VISUAL)
		return FALSE
	if(W.amount < FABRIC_PER_SHEET)
		user.show_message("<span class='notice'>You need at least [FABRIC_PER_SHEET] units of fabric before using this.</span>", MSG_VISUAL)
		return FALSE
	if(src in user.do_afters)
		to_chat(user,"<span class='warning'>You already are weaving \the [W.name] through the loom!</span>")
		return FALSE
	user.show_message("<span class='notice'>You start weaving \the [W.name] through the loom..</span>", MSG_VISUAL)
	var/speed_mult = 1
	var/atom/movable/fake_atom = new
	var/atom/fake_result = W.loom_result
	fake_atom.icon = initial(fake_result.icon)
	fake_atom.icon_state = initial(fake_result.icon_state)
	while(W.amount >= FABRIC_PER_SHEET)
		if(!do_after(user, W.pull_effort * speed_mult, src, add_item = fake_atom))
			return
		if(W.amount < FABRIC_PER_SHEET)
			user.show_message("<span class='notice'>You need at least [FABRIC_PER_SHEET] units of fabric before using this.</span>")
			return
		new W.loom_result(drop_location())
		W.use(FABRIC_PER_SHEET)
		user.show_message("<span class='notice'>You weave \the [W.name] into a workable fabric.</span>")
		if(speed_mult > 0.2)
			speed_mult -= 0.1
	user.show_message("<span class='notice'>You finish weaving.</span>")
	return TRUE

#undef FABRIC_PER_SHEET
