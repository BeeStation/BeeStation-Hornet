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
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.
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
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Greeter
/obj/item/integrated_circuit/template/greeter
	template_name = "greeter"

/datum/design/integrated_circuit_template/greeter
	name = "2. Greeter"
	desc = "A simple circuit which greets you."
	id = "template_greeter"
	build_path = /obj/item/integrated_circuit/template/greeter
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Ticker
/obj/item/integrated_circuit/template/ticker
	template_name = "ticker"

/datum/design/integrated_circuit_template/ticker
	name = "3. Ticker"
	desc = "Tick Tock, a circuit which keeps time."
	id = "template_ticker"
	build_path = /obj/item/integrated_circuit/template/ticker
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Simple Math
/obj/item/integrated_circuit/template/simple_math
	template_name = "simple_math"

/datum/design/integrated_circuit_template/simple_math
	name = "4. Simple Math"
	desc = "A simple circuit which does basic math and tells you if it is greater than 5."
	id = "template_simple_math"
	build_path = /obj/item/integrated_circuit/template/simple_math
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Times Table
/obj/item/integrated_circuit/template/times_table
	template_name = "times_table"

/datum/design/integrated_circuit_template/times_table
	name = "5. Times Table"
	desc = "You needed to learn your 7 times table, right?"
	id = "template_times_table"
	build_path = /obj/item/integrated_circuit/template/times_table
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

/obj/item/clipboard/preloaded/circuit_templates
	name="\improper Professor's Notes"
	papers_to_add = list(/obj/item/paper/guides/circuits/greeting,
						/obj/item/paper/guides/circuits/hello_world,
						/obj/item/paper/guides/circuits/greeter,
						/obj/item/paper/guides/circuits/ticker,
						/obj/item/paper/guides/circuits/simple_math,
						/obj/item/paper/guides/circuits/times_table,
						)

/datum/design/integrated_circuit_template/times_table //Printable at circuit fabs for ease of finding. Yes, it's not really realistic, but this is a tutorial.
	name = "0. The Professor's Notes"
	desc = "I could use some help! Please read me!"
	id = "template_notes"
	build_path = /obj/item/clipboard/preloaded/circuit_templates
	materials = list(/datum/material/iron = 3000)

/obj/item/paper/guides/circuits/greeting
	name = "paper - Greetings!"
	default_raw_text = {"<font face="Almendra"><h4>Greetings!</h4>
	You can call me The Professor. Although, I'm not actually a professor, it is kind of the nickname that I've picked up around here.
	I could use some help with my circuit work, but I can't have you just blundering around this fancy circuit fabricator... So, I've given you my clipboard with my notes to help you along.<br>
	<br>
	It has notes on some simple circuits and how they work, along with some notes on some fancier circuits which I couldn't get working... so maybe you could give me a hand and get some of them working?<br>
	</font><br>
	<p align=right><font face="Segoe Script">Professor IV</font></p>"}

/obj/item/paper/guides/circuits/hello_world
	name = "paper - Circuit 1: Hello, World!"
	default_raw_text = {"<font face="Almendra"><h4>The Basics</h4>
	This is about the most basic circuit we can have, but it shows off some of the features of these circuits.
	Use the circuit fabricator to print off a 'Hello, World!' and then push the button on the front. You should be greeted with a warm 'Hello, World!'.<br>
	<br>
	Now, how does this work? All circuits have 3 parts to them:<br>
	<ul>
	<li>A shell, which holds the circuit itself, and gives the circuit some things to interact with</li>
	<li>An integrated circuit, which holds all the components to make the circuit do something</li>
	<li>A power cell, which powers everything on the circuit. Run out of power, and the circuit stops working!</li></ul>
	<br>
	To take a peek inside, you need to find either a normal or a circuit multitool. Use that tool on the circuit, and you should see the internals of the circuit displayed on the tool's screen.
	This circuit has two parts, the Compact Remote component, and a speech component. The Compact remote component gives access to the button on the shell itself, and the speech component is what plays the voice through a speaker.<br>
	There's a wire that connects the parts, which is how data flows around the circuit. In this case, the blue wire is a 'signal'. It is like you pushing a button. It sends a signal to the connected component, usually to trigger it.<br>
	In this case, the next component is the 'Speech' component, which has a 'string' input which gets spoken every time the component is triggered. A string is just text. It can be letters, numbers, or symbols.<br>
	<h3>Inputs and Outputs</h3>
	For these circuits, any inputs to a component are on the left hand side. Any outputs are on the right hand side.<br>
	So, for instance, the 'Compact Remote Shell' has two outputs, a trigger for when the button is pushed, and another output for who pushed it. <br>
	The 'Speech' component has two inputs and one output: An input for what wants to be said and a trigger signal to actually trigger it. It also has an output when the component is triggered, so you can chain parts together."}

/obj/item/paper/guides/circuits/greeter
	name = "paper - Circuit 2: Greeter"
	default_raw_text = {"<font face="Almendra">
	This circuit expands on the 'Hello, World' circuit, greeting you and telling you what species you are.
	<br>
	The Compact Remote also outputs the 'entity' which used the remote through the 'User' output. If we tie that to a 'Get Name' and a 'Get Species' component, we can then tell who pushed the button, and their name.
	We wire the triggers together so that the signal flows from left to right, and triggers each block in turn, before going to the final two blocks.<br>
	<br>
	<h3>The Concatenate Component</h3>
	This new component is used to combine strings into one longer string. You can push the + and - buttons to add or remove inputs if you need more space. It takes in all the inputs when it is triggered, and combines them from top to bottom into one string.<br>
	<br>
	From there, the combined string gets passed to the speech component, which is spoken after they are combined.<br>
	<br>
	The key to reading circuits is to follow the trigger signals. Not a lot happens in these circuits without a trigger signal causing it to happen."}

/obj/item/paper/guides/circuits/ticker
	name = "paper - Circuit 3: Ticker"
	default_raw_text = {"<font face="Almendra">
	Now, we can start to add in some more interesting components. This circuit creates a clock which can be turned on or off using the button on the front of the remote.
	<br>
	<h3>The Toggle Component</h3>
	This component simply toggles its output from zero to one and back every time a signal is received. <br>
	<br>
	<h3>The Clock Component</h3>
	When turned on, this component creates a signal at a regular beat. If you want to slow it down, you can use the 'clock divider' to slow the clock in multiples of the clock. For instance, a clock divider of 3 would multiply the delay by 3 between each signal pulse.
	<br>
	<h3>Disassembly and Reassembling Circuits</h3>
	If you need to change the shell or the cell that is inside, you'll need to grab a screwdriver, and take the shell apart. A circuit board will fall out, which is the true guts of the circuit! If you use your screwdriver to pry out the battery on the circuit,
	you can replace it with a different, higher capacity cell.
	"}

/obj/item/paper/guides/circuits/simple_math
	name = "paper - Circuit 4: Simple Math"
	default_raw_text = {"<font face="Almendra">
	Strings are great, but sometimes, you just need a solid number to do some math on. This circuit performs a single math operation, and compares it to the number 5. If it is greater than 5, it lets you know that it is. Green wires indicate a number datatype, which can only store numbers.
	<br>
	<h3>The Arithmetic Component</h3>
	This component does math. About as simple as it gets, and you can select what type of math you want to do via the dropdown menu.<br>
	<br>
	<h3>The Comparison Component</h3>
	If you need to compare something, this is the component to use. A signal is output on true when the condition in the dropdown is met, or false otherwise. At the same time, the 'Result' output is updated with a 1 if the result is true, or 0 if it is false.<br>
	"}

/obj/item/paper/guides/circuits/times_table
	name = "paper - Circuit 5: Times Table"
	default_raw_text = {"<font face="Almendra">
	This circuit combines the Ticker circuit and the simple math circuit, to speak out the times table for 7 from 0 to 10.
	<br>
	<h3>The Iterator Component</h3>
	If you need to count, the iterator component is the part to go to. You can select the starting number to count at, how far to count up, and the increment for each step. When a signal gets received at the 'Step' input, the 'Output' gets the 'Step Value' added to it, until it is larger than the 'Final Value'.
	If that happens, the value wraps back down to the starting value, and a signal is sent on the 'Overflow' output.
	You can use this to count things or do something a certain number of times.<br>
	<br>
	Combine that with our friend, the 'Arithmetic Component', and you have a simple circuit which outputs the times table for the number 7. <br>
	<br>
	But... is there another way to do this multiplication <strong> without </strong> the 'Arithmetic' component?
	"}
