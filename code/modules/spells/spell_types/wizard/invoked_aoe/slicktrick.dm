/obj/effect/proc_holder/spell/invoked/slick_trick
	name = "Slick Trick"
	desc = "Temporarily create a slippery area that sends victims flying to the floor."
	cost = 5
	range = 4
	ignore_los = FALSE
	releasedrain = 50
	chargedrain = 2
	chargetime = 4 SECONDS
	recharge_time = 45 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	gesture_required = TRUE
	spell_tier = 3 // AOE
	invocation = "The ground betrays thee!" //Makes it a bit more obvious what it does
	invocation_type = "shout"
	glow_color = GLOW_COLOR_DISPLACEMENT
	glow_intensity = GLOW_INTENSITY_HIGH //Big warning as its AoE

/obj/effect/proc_holder/spell/invoked/slick_trick/cast(list/targets, mob/user = usr)
	var/turf/T = get_turf(targets[1])

	// Get all turfs in a 3x3 area
	var/list/affected_turfs = list()
	for(var/turf/open/O in range(1, T))
		affected_turfs += O

	if(affected_turfs.len)
		user.visible_message("<span class='warning'>[user] creates slick patches on the floor!</span>")

		// Apply effect to all open turfs in range
		for(var/turf/open/O in affected_turfs)
			playsound(O, 'sound/foley/waterenter.ogg', 25, TRUE)

			// First, clear any existing wet floor
			O.ClearWet()

			// Create a new one with our custom callback for slipping
			O.AddComponent(/datum/component/wet_floor, TURF_WET_LUBE, 15 SECONDS, 0, 120 SECONDS, FALSE)

			// Replace the slippery component with our own that has a custom callback
			var/datum/component/slippery/S = O.GetComponent(/datum/component/slippery)
			if(S)
				qdel(S)
			O.LoadComponent(/datum/component/slippery, 80, SLIDE | GALOSHES_DONT_HELP, CALLBACK(src, PROC_REF(after_slip)))

			// Create a visual indicator
			new /obj/effect/temp_visual/slick_warning(O)

		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/slick_trick/proc/after_slip(mob/living/L)
	if(istype(L))
		L.visible_message("<span class='warning'>[L] slips on the slick surface!</span>",
						  "<span class='warning'>You slip on a magically slick surface!</span>")
		return TRUE
	return FALSE

/obj/effect/temp_visual/slick_warning
	name = "slippery patch"
	desc = "Watch your step!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"
	color = "#0099FF" // Blue tint for water-like appearance
	randomdir = FALSE
	duration = 15 SECONDS
	layer = MASSIVE_OBJ_LAYER

	// Override the Initialize to ensure it stays visible for exactly the same duration as the slip effect
/obj/effect/temp_visual/slick_warning/Initialize()
	. = ..()
	// Clear any existing timer and set our own to exactly match the wet floor duration
	deltimer(timerid)
	timerid = QDEL_IN(src, 15 SECONDS)
