/obj/item/organ/heart/cybernetic
	name = "cybernetic heart"
	desc = "An electronic device which mimics the functions of an organic human heart, albeit less efficiently. Also holds an emergency dose of epinephrine, used automatically after facing severe trauma."
	icon_state = "heart-c-on"
	base_icon_state = "heart-c"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	circulation_effectiveness = 0.9
	var/dose_available = TRUE
	var/rid = /datum/reagent/medicine/epinephrine
	var/ramount = 10

/obj/item/organ/heart/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		Stop()
		addtimer(CALLBACK(src, PROC_REF(Restart)), 10 SECONDS)

/obj/item/organ/heart/cybernetic/on_life(delta_time, times_fired)
	. = ..()
	if(dose_available && owner.stat == UNCONSCIOUS && !owner.reagents.has_reagent(rid))
		owner.reagents.add_reagent(rid, ramount)
		used_dose()

/obj/item/organ/heart/cybernetic/proc/used_dose()
	dose_available = FALSE

/obj/item/organ/heart/cybernetic/upgraded
	name = "upgraded cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart with greater effectiveness. Holds a self-refilling emergency dose of epinephrine, used automatically after facing severe trauma."
	icon_state = "heart-c-u-on"
	base_icon_state = "heart-c-u"
	circulation_effectiveness = 1.3

/obj/item/organ/heart/cybernetic/upgraded/used_dose()
	. = ..()
	addtimer(VARSET_CALLBACK(src, dose_available, TRUE), 5 MINUTES)

/obj/item/organ/heart/cybernetic/ipc
	desc = "An electronic device that appears to mimic the functions of an organic heart."
	dose_available = FALSE
	circulation_effectiveness = 1
