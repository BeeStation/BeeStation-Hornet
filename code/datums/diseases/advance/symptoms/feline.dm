/datum/symptom/feline
	name = "Feline Minor Retrovirus"
	desc = "A derivative of the fabled felinid virus"
	stealth = -2
	resistance = -2
	stage_speed = 1
	transmittable = 2
	level = -1 //Uplink Symptom
	severity = 5 //Class F Biohazard
	symptom_delay_max = 10
	symptom_delay_max = 60
	var/nya_transmit = FALSE //Var that stores the transmission threshhold
	var/full_Feline = FALSE //Var that checks the stage speed and resistance threshold
	threshold_desc = "<b>Transmission 12:</b> Chance for virus to spread when nyaaa ing. <br>\
	<b>Stage Speed 12 and Resistance 10:</b> Acts as the regular felinid retrovirus."


