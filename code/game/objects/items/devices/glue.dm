/obj/item/syndie_glue
	name = "bottle of super glue"
	desc = "A black market brand of high strength adhesive, rarely sold to the public. Sudden air movements may cause instant drying! Do not ingest."
	icon = 'icons/obj/tools.dmi'
	icon_state	= "glue"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	var/uses = 1
	var/drying_time = 30 SECONDS //Adminbus, woo! Set to 0 if you want the glue to work instantly

/obj/item/syndie_glue/suicide_act(mob/living/M)
	M.visible_message("<span class='suicide'>[M] is drinking the whole bottle of glue! It looks like [M.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS) // read the warning n00b

/obj/item/syndie_glue/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !target)
		return
	else
		if(uses <= 0) //Just in case it somehow goes below 0
			to_chat(user, "<span class='warning'>\The [name] is empty!</span>")
			return
		if(istype(target, /obj/item))
			var/obj/item/I = target
			if(HAS_TRAIT_FROM(I, TRAIT_NODROP, GLUED_ITEM_TRAIT))
				to_chat(user, "<span class='warning'>\The [I] is already sticky!</span>")
				return
			uses -= 1
			if(uses <= 0)
				icon_state = "glue_used"
				name = "empty bottle of super glue"
			if(drying_time > 0)
				addtimer(CALLBACK(I, PROC_REF(get_glued)), drying_time)
				I.register_glue_signals()
				to_chat(user, "<span class='notice'>You smear \the [I] with glue, which will make it incredibly sticky once the glue dries!</span>")
			else
				get_glued()
				to_chat(user, "<span class='notice'>You smear \the [I] with glue, making it incredibly sticky!</span>")
			return

/obj/item/proc/register_glue_signals()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(get_glued))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(get_glued))

/obj/item/proc/get_glued()
	SIGNAL_HANDLER
	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, GLUED_ITEM_TRAIT))
		return
	ADD_TRAIT(src, TRAIT_NODROP, GLUED_ITEM_TRAIT)
	desc += "<span class='notice'> It looks sticky.</span>"
	UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
