//This file is a child of item/integrated_circuit and attempts to load a circuit from approved_circuits.json upon creation.
/obj/item/integrated_circuit/template
	/// The name from approved_circuits.json to load
	var/template_name = "hello_world"

//The research design template
/datum/design/integrated_circuit_template
	name = "Hello, World!"
	desc = "A simple \"Hello, World\" circuit."
	id = "template_circuit"
	build_path = /obj/item/integrated_circuit/template/hello_world
	category = list(WIREMOD_TEMPLATES)
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 3550, /datum/material/copper = 550) //Hello world costs
	build_type = IMPRINTER | COMPONENT_PRINTER
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/obj/item/integrated_circuit/template/Initialize(mapload)
	.=..()

	var/list/errors = list()
	var/circuit_json = pick(strings(APPROVED_CIRCUITS_FILE, template_name))
	load_circuit_data(circuit_json, errors)

	if(length(errors))
		to_chat(src, span_warning("The following errors were found whilst compiling the circuit data:"))
		for(var/error in errors)
			to_chat(src, span_warning("[error]"))

//Hello World
/obj/item/integrated_circuit/template/hello_world
	template_name = "hello_world"

/datum/design/integrated_circuit_template/hello_world
	name = "1. Hello, World!"
	desc = "A simple \"Hello, World\" circuit."
	id = "template_hello_world"
	build_path = /obj/item/integrated_circuit/template/hello_world
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 3550, /datum/material/copper = 650)

//Greeter
/obj/item/integrated_circuit/template/greeter
	template_name = "greeter"

/datum/design/integrated_circuit_template/greeter
	name = "2. Greeter"
	desc = "A simple circuit which greets you."
	id = "template_greeter"
	build_path = /obj/item/integrated_circuit/template/greeter
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 5050, /datum/material/copper = 1100)

//Ticker
/obj/item/integrated_circuit/template/ticker
	template_name = "ticker"

/datum/design/integrated_circuit_template/ticker
	name = "3. Ticker"
	desc = "Tick Tock, a circuit which keeps time."
	id = "template_ticker"
	build_path = /obj/item/integrated_circuit/template/ticker
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 4550, /datum/material/copper = 950)

//Simple Math
/obj/item/integrated_circuit/template/simple_math
	template_name = "simple_math"

/datum/design/integrated_circuit_template/simple_math
	name = "4. Simple Math"
	desc = "A simple circuit which does basic math and tells you if it is greater than 5."
	id = "template_simple_math"
	build_path = /obj/item/integrated_circuit/template/simple_math
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 4050, /datum/material/copper = 800)

//Times Table
/obj/item/integrated_circuit/template/times_table
	template_name = "times_table"

/datum/design/integrated_circuit_template/times_table
	name = "5. Times Table"
	desc = "You needed to learn your 7 times table, right?"
	id = "template_times_table"
	build_path = /obj/item/integrated_circuit/template/times_table
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 5550, /datum/material/copper = 1250)

//Coin Flip
/obj/item/integrated_circuit/template/coin_flip
	template_name = "coin_flip"

/datum/design/integrated_circuit_template/coin_flip
	name = "6. Coin Flip"
	desc = "A Simple Coin Flipper"
	id = "template_coin_flip"
	build_path = /obj/item/integrated_circuit/template/coin_flip
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 5050, /datum/material/copper = 1100)

//Atmos Safety Checker
/obj/item/integrated_circuit/template/atmos_checker
	template_name = "atmos_check"

/datum/design/integrated_circuit_template/atmos_checker
	name = "7. Atmos Safety Checker"
	desc = "Is your air safe? Find out!"
	id = "template_atmos_checker"
	build_path = /obj/item/integrated_circuit/template/atmos_checker
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 10050, /datum/material/copper = 2600)

///ADVANCED TEMPLATES
//Broken Universal Translator
/obj/item/integrated_circuit/template/broken_translator
	template_name = "broken_translator"

/datum/design/integrated_circuit_template/broken_translator
	name = "A1. Broken Translator"
	desc = "A translator that doesn't work"
	id = "template_broken_translator"
	build_path = /obj/item/integrated_circuit/template/broken_translator
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 4550, /datum/material/copper = 950)

//NTNet Scanning Gate
/obj/item/integrated_circuit/template/scanning_gate
	template_name = "scanning_gate"

/datum/design/integrated_circuit_template/scanning_gate
	name = "A2. NTNet Scanning Gate"
	desc = "A wireless scanning gate"
	id = "template_scanning_gate"
	build_path = /obj/item/integrated_circuit/template/scanning_gate
	materials = list(/datum/material/iron = 13700, /datum/material/glass = 7050, /datum/material/copper = 1100)

//Vending Circuit
/obj/item/integrated_circuit/template/vending_circuit
	template_name = "vending_circuit"

/datum/design/integrated_circuit_template/vending_circuit
	name = "A3. Vending Circuit"
	desc = "A simple vending machine circuit"
	id = "template_circuit_vendor"
	build_path = /obj/item/integrated_circuit/template/vending_circuit
	materials = list(/datum/material/iron = 11700, /datum/material/glass = 6050, /datum/material/gold = 50, /datum/material/copper = 1400)

/obj/item/clipboard/preloaded/circuit_templates
	name="\improper Professor's Notes"
	papers_to_add = list(/obj/item/paper/guides/circuits/greeting,
						/obj/item/paper/guides/circuits/hello_world,
						/obj/item/paper/guides/circuits/greeter,
						/obj/item/paper/guides/circuits/ticker,
						/obj/item/paper/guides/circuits/simple_math,
						/obj/item/paper/guides/circuits/times_table,
						/obj/item/paper/guides/circuits/coin_flip,
						/obj/item/paper/guides/circuits/atmos_check,
						/obj/item/paper/guides/circuits/advanced_circuits,
						)

/datum/design/integrated_circuit_template/professors_notes //Printable at circuit fabs for ease of finding. Yes, it's not really realistic, but this is a tutorial.
	name = "0. The Professor's Notes"
	desc = "I could use some help! Please read me!"
	id = "template_notes"
	build_path = /obj/item/clipboard/preloaded/circuit_templates
	materials = list(/datum/material/iron = 3000) //Ehh, seems about right.

/obj/item/paper/guides/circuits/greeting
	name = "paper - Greetings!"
	default_raw_text = {"<font face="Almendra"><h4>Greetings!</h4>
	You can call me The Professor. Although, I'm not actually a professor, it is kind of the nickname that I've picked up around here.
	I could use some help with my circuit work, but I can't have you just blundering around this fancy circuit fabricator... So, I've given you my clipboard with my notes to help you along.
	<br>
	It has notes on some simple circuits and how they work, along with some on a few fancier circuits which I couldn't get working... maybe you could give me a hand?
	You can unlock the advanced circuits in the technology node <strong>Advanced Circuit Templates</strong>.
	</font><br>
	<p align=right><font face="Segoe Script">Professor IV</font></p>"}

/obj/item/paper/guides/circuits/hello_world
	name = "paper - Circuit 1: Hello, World!"
	default_raw_text = {"<font face="Almendra"><h4>The Basics</h4>
	This is about the most basic circuit we can have, but it shows off some of the features of these circuits.
	Use the circuit fabricator to print off a 'Hello, World!' and then push the button on the front. You should be greeted with a warm 'Hello, World!'.
	<br>
	Now, how does this work? All circuits have 3 parts to them:
	<ul>
	<li>A shell, which holds the circuit itself, and gives the circuit some things to interact with</li>
	<li>An integrated circuit, which holds all the components to make the circuit do something</li>
	<li>A power cell, which powers everything on the circuit. Run out of power, and the circuit stops working!</li></ul>
	To take a peek inside, you need to find either a normal or a circuit multitool. Use that tool on the circuit, and you should see the internals of the circuit displayed on the tool's screen.
	This circuit has two parts, the Compact Remote component, and a speech component. The Compact remote component gives access to the button on the shell itself, and the speech component is what plays the voice through a speaker.
	There's a wire that connects the parts, which is how data flows around the circuit. In this case, the blue wire is a 'signal'. It is like you pushing a button. It sends a signal to the connected component, usually to trigger it.
	In this case, the next component is the 'Speech' component, which has a 'string' input which gets spoken every time the component is triggered. A string is just text. It can be letters, numbers, or symbols.
	<h3>Inputs and Outputs</h3>
	For these circuits, any inputs to a component are on the left hand side. Any outputs are on the right hand side.<br>
	So, for instance, the 'Compact Remote Shell' has two outputs, a trigger for when the button is pushed, and another output for who pushed it. <br>
	The 'Speech' component has two inputs and one output: An input for what wants to be said and a trigger signal to actually trigger it.
	It also has an output when the component is triggered, so you can chain parts together."}

/obj/item/paper/guides/circuits/greeter
	name = "paper - Circuit 2: Greeter"
	default_raw_text = {"<font face="Almendra">
	This circuit expands on the 'Hello, World' circuit, greeting you and telling you what species you are.
	<br>
	The Compact Remote also outputs the 'entity' which used the remote through the 'User' output.
	If we tie that to a 'Get Name' and a 'Get Species' component, we can then tell who pushed the button, and their name.
	We wire the triggers together so that the signal flows from left to right, and triggers each block in turn, before going to the final two blocks.
	<br>
	<h3>The Concatenate Component</h3>
	This new component is used to combine strings into one longer string. You can push the + and - buttons to add or remove inputs if you need more space.
	It takes in all the inputs when it is triggered, and combines them from top to bottom into one string.
	<br>
	From there, the combined string gets passed to the speech component, which is spoken after they are combined.
	<br>
	The key to reading circuits is to follow the trigger signals. Not a lot happens in these circuits without a trigger signal causing it to happen."}

/obj/item/paper/guides/circuits/ticker
	name = "paper - Circuit 3: Ticker"
	default_raw_text = {"<font face="Almendra">
	Now, we can start to add in some more interesting components. This circuit creates a clock which can be turned on or off using the button on the front of the remote.
	<br>
	<h3>The Toggle Component</h3>
	This component simply toggles its output from zero to one and back every time a signal is received.
	<br>
	<h3>The Clock Component</h3>
	When turned on, this component creates a signal at a regular beat. If you want to slow it down, you can use the 'clock divider' to slow the clock in multiples of the clock.
	For instance, a clock divider of 3 would multiply the delay by 3 between each signal pulse.
	<br>
	<h3>Disassembly and Reassembling Circuits</h3>
	If you need to change the shell or the cell that is inside, you'll need to grab a screwdriver, and take the shell apart.
	A circuit board will fall out, which is the true guts of the circuit! If you use your screwdriver to pry out the battery on the circuit,
	you can replace it with a different, higher capacity cell.
	"}

/obj/item/paper/guides/circuits/simple_math
	name = "paper - Circuit 4: Simple Math"
	default_raw_text = {"<font face="Almendra">
	Strings are great, but sometimes, you just need a solid number to do some math on. This circuit performs a single math operation, and compares it to the number 5.
	If it is greater than 5, it lets you know that it is. Green wires indicate a number datatype, which can only store numbers.
	<br>
	<h3>The Arithmetic Component</h3>
	This component does math. About as simple as it gets, and you can select what type of math you want to do via the dropdown menu.
	<br>
	<h3>The Comparison Component</h3>
	If you need to compare something, this is the component to use. A signal is output on true when the condition in the dropdown is met, or false otherwise.
	At the same time, the 'Result' output is updated with a 1 if the result is true, or 0 if it is false.
	"}

/obj/item/paper/guides/circuits/times_table
	name = "paper - Circuit 5: Times Table"
	default_raw_text = {"<font face="Almendra">
	This circuit combines the Ticker circuit and the simple math circuit, to speak out the times table for 7 from 0 to 10.
	<br>
	<h3>The Iterator Component</h3>
	If you need to count, the iterator component is the part to go to. You can select the starting number to count at, how far to count up, and the increment for each step.
	When a signal gets received at the 'Step' input, the 'Output' gets the 'Step Value' added to it, until it is larger than the 'Final Value'.
	If that happens, the value wraps back down to the starting value, and a signal is sent on the 'Overflow' output.
	You can use this to count things or do something a certain number of times.
	<br>
	Combine that with our friend, the 'Arithmetic Component', and you have a simple circuit which outputs the times table for the number 7.
	<br>
	But... is there another way to do this "multiplication" <strong> without </strong> the 'Arithmetic' component?
	"}

/obj/item/paper/guides/circuits/coin_flip
	name = "paper - Circuit 6: Coin Flipper"
	default_raw_text = {"<font face="Almendra">
	A simple coin simulator. Heads or Tails?
	<br>
	<h3>The Random Component</h3>
	This component generates a random value from minimum, to maximum. Both minimum and maximum will show up in the output.
	<br>
	<h3>The Switch Case Component</h3>
	If you need to compare one integer to multiple values, this is the easiest way. It's like a more advanced comparison component.
	Feed your value that you want to compare to the "Switch" input, and the values to compare in the cases. When your input matches the case, the matching output will trigger.
	If the value doesn't match any of them, the default output will trigger! Don't forget to add more inputs if you need via the +/- buttons at the top.
	<br>
	Can this be expanded to a 'Rock, Goliath, Lasso' opponent?"
	"}

/obj/item/paper/guides/circuits/atmos_check
	name = "paper - Circuit 7: Atmos Safety Checker"
	default_raw_text = {"<font face="Almendra">
	This circuit is a larger circuit just to demonstrate chaining components together. This circuit lets you know what the pressure and temperature of the air is, and if it is unsafe to be here.
	<br>
	Take a look at the last concatenate before the Speech component.... 3 Outputs into 1 input‽ What's going on here‽
	The answer is simple: An input takes the "latest" value that was written to the input, overwriting whatever was there.
	So in this case, the temperature and pressure messages overwrite each other, depending on which one gets written last.
	By default, the phrase "The pressure is X kilopascals" will be added, but, if one of the safety comparisons triggered, that phrase will be overwritten with the safety phrase added on.
	<br>
	Can we make this read the temperature in Celsius rather than Kelvin so I don't have to do the conversion in my head?<br>

	This is the last of my training circuits I have for you. The remaining circuits are all broken or not useful by themselves. I could use some help getting them to work. Happy Wiring!<br>
	Thanks,</font><br>
	<p align=right><font face="Segoe Script">Professor IV</font></p>
	"}

/obj/item/paper/guides/circuits/advanced_circuits
	name = "paper - Advanced Circuits"
	default_raw_text = {"<font face="Almendra">
	The remaining circuits in the fabricator are all circuits that I couldn't get working due to time or other constraints. Maybe you can get some of them working?
	You can unlock them in the technology node <strong>Advanced Circuit Templates</strong>.
	<br>
	<h3>Broken Translator</h3>
	A colleague of mine gave me this circuit, but I didn't have enough time to make it work. I believe he was trying to talk to the locals?
	<br>
	<h3>NTNet Scanner Gate</h3>
	Not broken per-say, just not very useful by itself. It scans any item passed through it and sends it out on NTNet. It also has a speech enabled receiver, so you can send a status back and it will read it out."
	<h3>Custom Vending Circuit</h3>
	Needs work. Accepts money, and triggers a sequence of events if the amount is more than a threshold. If it is less, a refund is given. Does not give change."
	"}
