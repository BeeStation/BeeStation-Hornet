/// Helper define that can only be used in /obj/item/circuit_component/input_received()
#define COMPONENT_TRIGGERED_BY(trigger, port) (trigger?.value && trigger == port)

/// Define to be placed at any proc that is triggered by a port.
#define CIRCUIT_TRIGGER SHOULD_NOT_SLEEP(TRUE)

// Port defines

#define PORT_MAX_NAME_LENGTH 50

// Port types. Determines what the port can connect to

/// Can accept any datatype. Only works for inputs, output types will runtime.
#define PORT_TYPE_ANY "any"

// Fundamental datatypes
/// String datatype
#define PORT_TYPE_STRING "string"
#define PORT_MAX_STRING_LENGTH 5000
#define PORT_MAX_STRING_DISPLAY 100
/// Number datatype
#define PORT_TYPE_NUMBER "number"
/// Signal datatype
#define PORT_TYPE_SIGNAL "signal"
/// List datatype
#define PORT_TYPE_LIST "list"
/// Table datatype. Derivative of list, contains other lists with matching columns.
#define PORT_TYPE_TABLE "table"
/// Options datatype. Derivative of string.
#define PORT_TYPE_OPTION "option"

// Other datatypes
/// Atom datatype
#define PORT_TYPE_ATOM "entity"


/// The maximum range between a port and an atom
#define PORT_ATOM_MAX_RANGE 7

#define COMPONENT_DEFAULT_NAME "component"

#define COMPONENT_DEFAULT_CATEGORY "Unassigned"

/// The minimum position of the x and y co-ordinates of the component in the UI
#define COMPONENT_MIN_RANDOM_POS 200
/// The maximum position of the x and y co-ordinates of the component in the UI
#define COMPONENT_MAX_RANDOM_POS 400

/// The maximum position in both directions that a component can be in.
/// Prevents someone from positioning a component at an absurdly high value.
#define COMPONENT_MAX_POS 10000

// Components

/// The value that is sent whenever a component is simply sending a signal. This can be anything, and is currently the seconds since roundstart.
#define COMPONENT_SIGNAL (world.time / (1 SECONDS))

/// The largest sized list a component can make
#define COMPONENT_MAXIMUM_LIST_SIZE 256

// Comparison defines
#define COMP_COMPARISON_EQUAL "="
#define COMP_COMPARISON_NOT_EQUAL "!="
#define COMP_COMPARISON_GREATER_THAN ">"
#define COMP_COMPARISON_LESS_THAN "<"
#define COMP_COMPARISON_GREATER_THAN_OR_EQUAL ">="
#define COMP_COMPARISON_LESS_THAN_OR_EQUAL "<="

// Clock component
#define COMP_CLOCK_DELAY 0.9 SECONDS

// Shells

/// Whether a circuit is stuck on a shell and cannot be removed (by a user)
#define SHELL_FLAG_CIRCUIT_UNREMOVABLE (1<<0)

/// Whether the shell needs to be anchored for the circuit to be on.
#define SHELL_FLAG_REQUIRE_ANCHOR (1<<1)

/// Whether or not the shell has a USB port.
#define SHELL_FLAG_USB_PORT (1<<2)

/// Whether the shell allows actions to be peformed on a shell if the action fails. This will additionally block the messages from being displayed.
#define SHELL_FLAG_ALLOW_FAILURE_ACTION (1<<3)

/// Whether a circuit is not able to be modified
#define SHELL_FLAG_CIRCUIT_UNMODIFIABLE (1<<5)

// Shell capacities. These can be converted to configs very easily later
#define SHELL_CAPACITY_SMALL 25
#define SHELL_CAPACITY_MEDIUM 50
#define SHELL_CAPACITY_LARGE 100
#define SHELL_CAPACITY_VERY_LARGE 500

/// The maximum range a USB cable can be apart from a source
#define USB_CABLE_MAX_RANGE 2
/// The maximum range a wireless USB transceiver can be apart from a source
#define USB_WIRELESS_MAX_RANGE 20

// Circuit flags
/// Creates an input trigger that means the component won't be triggered unless the trigger is pulsed.
#define CIRCUIT_FLAG_INPUT_SIGNAL (1<<0)
/// Creates an output trigger that sends a pulse whenever the component is successfully triggered
#define CIRCUIT_FLAG_OUTPUT_SIGNAL (1<<1)
/// This circuit component does not show in the menu.
#define CIRCUIT_FLAG_HIDDEN (1<<2)
/// This circuit component has been marked as a component that has instant execution and will show up in the UI as so. This will only cause a visual change.
#define CIRCUIT_FLAG_INSTANT (1<<3)
/// This circuit component cannot be inserted into the same circuit multiple times. Only use this for major headaches.
#define CIRCUIT_NO_DUPLICATES (1<<6)

// Datatype flags
/// The datatype supports manual inputs
#define DATATYPE_FLAG_ALLOW_MANUAL_INPUT (1<<0)
/// The datatype won't update the value when it is connected to the port
#define DATATYPE_FLAG_AVOID_VALUE_UPDATE (1<<1)

/// Any datatype (USED ONLY FOR DISPLAY, DO NOT USE)
#define COMP_TYPE_ANY "any"

// Delay defines
/// The minimum delay value that the delay component can have.
#define COMP_DELAY_MIN_VALUE 0.1

// Logic defines
#define COMP_LOGIC_AND "AND"
#define COMP_LOGIC_OR "OR"
#define COMP_LOGIC_XOR "XOR"

// Arithmetic defines
#define COMP_ARITHMETIC_ADD "Add"
#define COMP_ARITHMETIC_SUBTRACT "Subtract"
#define COMP_ARITHMETIC_MULTIPLY "Multiply"
#define COMP_ARITHMETIC_DIVIDE "Divide"
#define COMP_ARITHMETIC_MODULO "Modulus"
#define COMP_ARITHMETIC_MIN "Minimum"
#define COMP_ARITHMETIC_MAX "Maximum"

//Bitwise defines
#define COMP_BITWISE_AND "And"
#define COMP_BITWISE_OR "Or"
#define COMP_BITWISE_XOR "Xor"
#define COMP_BITWISE_LEFTSHIFT "Left Shift"
#define COMP_BITWISE_RIGHTSHIFT "Right Shift"

//Round defines
#define COMP_ROUND_ROUND "Round"
#define COMP_ROUND_FLOOR "Floor"
#define COMP_ROUND_CEIL "Ceil"

//Trig defines
#define COMP_TRIG_COSINE "COS"
#define COMP_TRIG_SINE "SIN"
#define COMP_TRIG_TANGENT "TAN"
#define COMP_TRIG_ASINE "ASIN"
#define COMP_TRIG_ACOSINE "ACOS"
#define COMP_TRIG_ATANGENT "ATAN"

//Advanced Trig defines
#define COMP_TRIG_SECANT "SEC"
#define COMP_TRIG_COSECANT "CSC"
#define COMP_TRIG_COTANGENT "COT"

//Hyperbolic Trig Defines
#define COMP_TRIG_HYPERBOLIC_COSINE "COSH"
#define COMP_TRIG_HYPERBOLIC_SINE "SINH"
#define COMP_TRIG_AHYPERBOLIC_COSINE "ACOSH"
#define COMP_TRIG_AHYPERBOLIC_SINE "ASING"

//Indexer defines
#define COMP_INDEXER_NONE "None"
#define COMP_INDEXER_INCREMENT "Increment"
#define COMP_INDEXER_LOOP "Loop"
#define COMP_INDEXER_BOTH "Both"

#define COMP_INDEXER_FLAG_INCREMENT (1<<0)
#define COMP_INDEXER_FLAG_LOOP (1<<1)

//Pop defines
#define COMP_POP_POP "Pop"
#define COMP_POP_DEQUEUE "Dequeue"

// Text defines
#define COMP_TEXT_LOWER "To Lower"
#define COMP_TEXT_UPPER "To Upper"

// Typecast component
#define COMP_TYPECAST_MOB "organism"
#define COMP_TYPECAST_HUMAN "humanoid"

// Radio component
#define COMP_RADIO_PUBLIC "public"
#define COMP_RADIO_PRIVATE "private"

// Sound component
#define COMP_SOUND_BUZZ "Buzz"
#define COMP_SOUND_BUZZ_TWO "Buzz Twice"
#define COMP_SOUND_CHIME "Chime"
#define COMP_SOUND_HONK "Honk"
#define COMP_SOUND_PING "Ping"
#define COMP_SOUND_SAD "Sad Trombone"
#define COMP_SOUND_WARN "Warn"
#define COMP_SOUND_SLOWCLAP "Slow Clap"

#define WIREMOD_CIRCUITRY "Circuitry"
#define WIREMOD_CORE "Core"
#define WIREMOD_SHELLS "Shells"
#define WIREMOD_INPUT_COMPONENTS "Input Components"
#define WIREMOD_OUTPUT_COMPONENTS "Output Components"
#define WIREMOD_MATH_COMPONENTS "Math Components"
#define WIREMOD_TIME_COMPONENTS "Time Components"
#define WIREMOD_LOGIC_COMPONENTS "Logic Components"
#define WIREMOD_GATE_COMPONENTS "Gate Components"
#define WIREMOD_LIST_COMPONENTS "List Components"
#define WIREMOD_MEMORY_COMPONENTS "Memory Components"
#define WIREMOD_CONVERSION_COMPONENTS "Conversion Components"
#define WIREMOD_STRING_COMPONENTS "String Components"
#define WIREMOD_REFERENCE_COMPONENTS "Reference Components"
#define WIREMOD_BCI_COMPONENTS "BCI Components"
#define WIREMOD_TEMPLATES "Professor's Circuits"

#define WIREMODE_CATEGORIES list(\
	WIREMOD_CIRCUITRY,\
	WIREMOD_CORE,\
	WIREMOD_SHELLS,\
	WIREMOD_INPUT_COMPONENTS,\
	WIREMOD_OUTPUT_COMPONENTS,\
	WIREMOD_MATH_COMPONENTS,\
	WIREMOD_TIME_COMPONENTS,\
	WIREMOD_LOGIC_COMPONENTS,\
	WIREMOD_GATE_COMPONENTS,\
	WIREMOD_BCI_COMPONENTS,\
	WIREMOD_TEMPLATES,\
	)
