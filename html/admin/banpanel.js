function toggle_other_checkboxes(source, copycats_str, our_index_str) {
    const copycats = parseInt(copycats_str);
    const our_index = parseInt(our_index_str);
    for (var i = 1; i <= copycats; i++) {
        if(i === our_index) {
            continue;
        }
        document.getElementById(source.id.slice(0, -1) + i).checked = source.checked;
    }
}

function suppression_lock(activator) {
	var state = activator.checked
	var restricted_elements = document.getElementsByClassName("redact_incompatible")
	for (var i=0, n = restricted_elements.length; i < n; i++) {
		restricted_elements[i].checked = false;
		restricted_elements[i].disabled = state;
	}
	if(!state) {
		return;
	}
	var force_enabled = document.getElementsByClassName("redact_force_checked");
	for (var i=0, n = force_enabled.length; i < n; i++) {
		force_enabled[i].checked = true;
	}
}
