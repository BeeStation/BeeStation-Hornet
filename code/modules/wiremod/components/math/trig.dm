/**
 * # Trig Component
 *
 * Math trig, not a trigger
 * Does trig stuff
 */

 //Generic class for other trig components
/obj/item/circuit_component/trig
	display_name = "Generic Trigonometry"
	desc = "A useless component that all trigonometric based components are built off of."

	/// The input port
	var/datum/port/input/input
	var/datum/port/input/option/options_port

	/// The result from the output
	var/datum/port/output/output

	//An increase in power usage due to more complex calculations
	power_usage_per_input = 2

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL


/obj/item/circuit_component/trig/populate_ports()
	input = add_input_port("Input", PORT_TYPE_NUMBER)
	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/trig/Destroy()
	input = null
	output = null
	return ..()

//The output is set to the return value of this proc on input received
/obj/item/circuit_component/trig/proc/do_calculation(value)

/obj/item/circuit_component/trig/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	//The output is based on the override of do_calculation()
	output.set_output(do_calculation(input.value))


//Does your typical Sine, Cosine, and Tangent, as well as their inverses
/obj/item/circuit_component/trig/trig
	display_name = "Trigonometry"
	desc = "A component capable of trigonometric functions."

/obj/item/circuit_component/trig/trig/populate_options()
	var/static/list/options = list(
		COMP_TRIG_SINE,
		COMP_TRIG_COSINE,
		COMP_TRIG_TANGENT,
		COMP_TRIG_ASINE,
		COMP_TRIG_ACOSINE,
		COMP_TRIG_ATANGENT
	)
	options_port = add_option_port("Mode", options)

/obj/item/circuit_component/trig/trig/do_calculation(value)
	value = TODEGREES(value) //apparently BYOND doesn't believe in the almighty radian
	switch(options_port.value)
		if(COMP_TRIG_SINE)
			return sin(value)
		if(COMP_TRIG_COSINE)
			return cos(value)
		if(COMP_TRIG_TANGENT)
			return cos(value) == 0 ? null : tan(value)
		if(COMP_TRIG_ASINE)
			return (value >= -1 && value <= 1) ? TORADIANS(arcsin(value)) : null
		if(COMP_TRIG_ACOSINE)
			return (value >= -1 && value <= 1) ? TORADIANS(arccos(value)) * PI/180 : null
		if(COMP_TRIG_ATANGENT)
			return arctan(value) * PI/180

//Performs Secant, Cosecant, and Cotangent
/obj/item/circuit_component/trig/adv_trig
	display_name = "Advanced Trigonometry"
	desc = "Following outstanding advancements in the field of Mathematics, NanoTrasen scientist have discovered how to take the reciprical of trignometric functions"


/obj/item/circuit_component/trig/adv_trig/populate_options()
	var/static/list/options = list(
		COMP_TRIG_SECANT,
		COMP_TRIG_COSECANT,
		COMP_TRIG_COTANGENT
	)
	options_port = add_option_port("Mode", options)

/obj/item/circuit_component/trig/adv_trig/do_calculation(value)
	value = TODEGREES(value) //apparently BYOND doesn't believe in the almighty radian
	switch(options_port.value)
		if(COMP_TRIG_SECANT)
			return cos(value) == 0 ? null : SEC(value)
		if(COMP_TRIG_COSECANT)
			return sin(value) == 0 ? null : CSC(value)
		if(COMP_TRIG_COTANGENT)
			return sin(value) == 0 ? null : (cos(value) * CSC(value)) //The define for COT uses 1/tan(x), which throws a divide by zero error when x = pi/2 + kpi where k is an integer

//Hyperbolic Sine and Cosine
/obj/item/circuit_component/trig/hyper_trig
	display_name = "Hyperbolic Trigonometry"
	desc = "This component makes all your trig calculations be based on hyperbolas and natural exponentials instead of circles"

/obj/item/circuit_component/trig/hyper_trig/populate_options()
	var/static/list/options = list(
		COMP_TRIG_HYPERBOLIC_SINE,
		COMP_TRIG_HYPERBOLIC_COSINE,
		COMP_TRIG_AHYPERBOLIC_SINE,
		COMP_TRIG_AHYPERBOLIC_COSINE,
	)
	options_port = add_option_port("Mode", options)

/obj/item/circuit_component/trig/hyper_trig/do_calculation(value)
	switch(options_port.value)
		if(COMP_TRIG_HYPERBOLIC_SINE)
			return (NUM_E**value - NUM_E**(-value))/2
		if(COMP_TRIG_HYPERBOLIC_COSINE)
			return (NUM_E**value + NUM_E**(-value))/2 //I suppose this could be used for exponents, using the identity cosh(x) + sinh(x) = e^x, I might look into making this more efficent if people end up using this for that
		if(COMP_TRIG_AHYPERBOLIC_SINE)
			return log(value+sqrt(value**2+1))
		if(COMP_TRIG_AHYPERBOLIC_COSINE)
			return value < 1 ? null : log(value+sqrt(value**2-1))
