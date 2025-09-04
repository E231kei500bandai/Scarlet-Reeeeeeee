/obj/effect/proc_holder/spell/invoked/wheel
	name = "The Wheel"
	releasedrain = 10
	chargedrain = 0
	chargetime = 3
	range = 1
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/misc/letsgogambling.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 5 MINUTES
	
/obj/effect/proc_holder/spell/invoked/wheel/cast(list/targets, mob/user = usr)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE
		target.apply_status_effect(/datum/status_effect/wheel)		
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/mastersillusion
	name = "Set Decoy"
	releasedrain = 10
	chargedrain = 0
	chargetime = 0
	range = 1
	no_early_release = TRUE
	movement_interrupt = FALSE
	chargedloop = /datum/looping_sound/invokeholy
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 30 SECONDS
	var/firstcast = TRUE
	var/icon/clone_icon

/obj/effect/proc_holder/spell/invoked/mastersillusion/cast(list/targets, mob/living/carbon/human/user = usr)
	if(firstcast)
		to_chat(user, span_italics("...Oh, oh, thy visage is so grand! Let us prepare it for tricks!"))
		clone_icon = get_flat_human_icon("[user.real_name] decoy", null, null, DUMMY_HUMAN_SLOT_MANIFEST, GLOB.cardinals, TRUE, user, TRUE) // We can only set our decoy icon once. This proc is sort of expensive on generation.
		firstcast = FALSE
		name = "Master's Illusion"
		to_chat(user, "There we are... Perfect.")
		revert_cast()
		return
	var/turf/T = get_turf(user)
	new /mob/living/simple_animal/hostile/rogue/xylixdouble(T, user, clone_icon)
	animate(user, alpha = 0, time = 0 SECONDS, easing = EASE_IN)
	user.mob_timers[MT_INVISIBILITY] = world.time + 7 SECONDS
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon/human, update_sneak_invis), TRUE), 7 SECONDS)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/atom/movable, visible_message), span_warning("[user] fades back into view."), span_notice("You become visible again.")), 7 SECONDS)
	return TRUE

/mob/living/simple_animal/hostile/rogue/xylixdouble
	name = "Xylixian Double - You shouldnt be seeing this."
	desc = ""
	gender = NEUTER
	mob_biotypes = MOB_HUMANOID
	maxHealth = 20
	health = 20
	canparry = TRUE
	d_intent = INTENT_PARRY
	defprob = 50
	footstep_type = FOOTSTEP_MOB_BAREFOOT
	del_on_death = TRUE
	loot = list(/obj/item/smokebomb/decoy)
	can_have_ai = FALSE
	AIStatus = AI_OFF
	ai_controller = /datum/ai_controller/mudcrab // doesnt really matter


/obj/item/smokebomb/decoy/Initialize()
	. = ..()
	playsound(loc, 'sound/magic/decoylaugh.ogg', 50)
	explode()

/mob/living/simple_animal/hostile/rogue/xylixdouble/Initialize(mapload, mob/living/carbon/human/copycat, icon/I)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/simple_animal, death), TRUE), 7 SECONDS)
	icon = I
	name = copycat.name
	

/obj/effect/proc_holder/spell/invoked/mockery
	name = "Vicious Mockery"
	releasedrain = 50
	associated_skill = /datum/skill/misc/music
	recharge_time = 2 MINUTES
	range = 7

/obj/effect/proc_holder/spell/invoked/mockery/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), 'sound/magic/mockery.ogg', 40, FALSE)
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(target.anti_magic_check(TRUE, TRUE))
			return FALSE
		if(!target.can_hear()) // Vicious mockery requires people to be able to hear you.
			revert_cast()
			return FALSE
		target.apply_status_effect(/datum/status_effect/debuff/viciousmockery)
		SEND_SIGNAL(user, COMSIG_VICIOUSLY_MOCKED, target)
		GLOB.scarlet_round_stats[STATS_PEOPLE_MOCKED]++
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/mockery/invocation(mob/user = usr)
	if(ishuman(user))
		switch(pick(1,2,3,4,5,6,7,8,9,10,11,12,13))
			if(1)
				user.say("Your mother was a Rous, and your father smelled of jacksberries!", forced = "spell")
			if(2)
				user.say("What are you going to do for a face when the Archdevil wants his arse back?!", forced = "spell")
			if(3)
				user.say("Wandought thine blades stand, much like thine loving parts!", forced = "spell")
			if(4)
				user.say("That's a face not even Eora could love!", forced = "spell")
			if(5)
				user.say("Your breath smells like raw butter and cheap beer!.", forced = "spell")
			if(6)
				user.say("I bite mine thumb, ser!", forced = "spell")
			if(7)
				user.say("But enough talk- have at thee!", forced = "spell")
			if(8)
				user.say("My grandmother fights better than you!", forced = "spell")
			if(9)
				user.say("Need you borrow mine spectacles? Come get them!", forced = "spell")
			if(10)
				user.say("How much sparring did it take to become this awful?!", forced = "spell")
			if(11)
				user.say("You may need a smith- for you seem ill-equipped for a battle of wits!", forced = "spell")
			if(12)
				user.say("Looks as if thou art PSY-DONE! No? Too soon? Alright.", forced = "spell")
			if(13)
				user.say("Ravox bring justice to your useless mentor, ser!", forced = "spell")

/datum/status_effect/debuff/viciousmockery
	id = "viciousmockery"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/viciousmockery
	duration = 600 // One minute
	effectedstats = list("strength" = -1, "speed" = -1,"endurance" = -1, "intelligence" = -3)

/atom/movable/screen/alert/status_effect/debuff/viciousmockery
	name = "Vicious Mockery"
	desc = "<span class='warning'>THAT ARROGANT BARD! ARGH!</span>\n"
	icon_state = "muscles"

/obj/effect/proc_holder/spell/self/xylixslip
	name = "Xylixian Slip"
	overlay_state = "xylix_slip"
	releasedrain = 10
	chargedrain = 0
	chargetime = 0
	chargedloop = /datum/looping_sound/invokeholy
	sound = null
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 12 SECONDS
	devotion_cost = 30
	miracle = TRUE
	var/leap_dist = 4	//3 tiles (+1 to account for origin tile)
	var/static/list/sounds = list('sound/magic/xylix_slip1.ogg','sound/magic/xylix_slip2.ogg','sound/magic/xylix_slip3.ogg','sound/magic/xylix_slip4.ogg')
	
/obj/effect/proc_holder/spell/self/xylixslip/cast(list/targets, mob/user = usr)
	. = ..()
	if(!ishuman(user))
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/H = user

	if(H.IsImmobilized() || !(H.mobility_flags & MOBILITY_STAND))
		revert_cast()
		return FALSE

	if(H.IsOffBalanced())
		H.visible_message(span_warning("[H] loses their footing!"))
		var/turnangle = (prob(50) ? 270 : 90)
		var/turndir = turn(dir, turnangle)
		var/dist = rand(1, 2)
		var/current_turf = get_turf(H)
		var/target_turf = get_ranged_target_turf(current_turf, turndir, dist)
		H.throw_at(target_turf, dist, 1, H, TRUE)
		playsound(H,'sound/magic/xylix_slip_fail.ogg', 100)
		H.Knockdown(10)
		return TRUE
	else
		var/current_turf = get_turf(H)
		var/turf/target_turf = get_ranged_target_turf(current_turf, H.dir, leap_dist)
		H.visible_message(span_warning("[H] slips away!"))
		H.throw_at(target_turf, leap_dist, 1, H, TRUE)
		if(target_turf.landsound)
			playsound(target_turf, target_turf.landsound, 100, FALSE)
		H.emote("jump", forced = TRUE)
		H.OffBalance(8 SECONDS)
		if(prob(50))
			playsound(H, pick(sounds), 100, TRUE)
		return TRUE

/obj/effect/proc_holder/spell/invoked/slick_trick
	name = "Slick Trick"
	releasedrain = 30
	chargedrain = 0
	chargetime = 2
	range = 12
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/magic/antimagic.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 45 SECONDS

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

		// Play various laughter sounds from Xylix the trickster god
		var/list/laugh_sounds = list(
			'sound/vo/male/jester/laugh (1).ogg',
			'sound/vo/male/jester/laugh (2).ogg',
			'sound/vo/male/jester/laugh (3).ogg',
			'sound/vo/male/evil/laugh (1).ogg',
			'sound/vo/male/evil/laugh (2).ogg'
		)

		// Play all laughter sounds at the same time for a chorus of laughter
		var/turf/T = get_turf(L)
		for(var/sound_file in laugh_sounds)
			playsound(T, sound_file, 50, TRUE, -1) // Lower volume to avoid being too loud

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
