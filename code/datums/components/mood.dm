#define MINOR_INSANITY_PEN 5
#define MAJOR_INSANITY_PEN 10

/datum/component/mood
	var/mood //Real happiness
	var/sanity = 100 //Current sanity
	var/shown_mood //Shown happiness, this is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/mood_level = 5 //To track what stage of moodies they're on
	var/sanity_level = 5 //To track what stage of sanity they're on
	var/mood_modifier = 1 //Modifier to allow certain mobs to be less affected by moodlets
	var/list/datum/mood_event/mood_events = list()
	var/insanity_effect = 0 //is the owner being punished for low mood? If so, how much?
	var/atom/movable/screen/mood/screen_obj
	var/atom/movable/screen/sanity/screen_obj_sanity

/datum/component/mood/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSmood, src)

	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, PROC_REF(add_event))
	RegisterSignal(parent, COMSIG_CLEAR_MOOD_EVENT, PROC_REF(clear_event))

	RegisterSignal(parent, COMSIG_MOB_HUD_CREATED, PROC_REF(modify_hud))
	var/mob/living/owner = parent
	if(owner.hud_used)
		modify_hud()
		var/datum/hud/hud = owner.hud_used
		hud.show_hud(hud.hud_version)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSmood, src)
	unmodify_hud()
	return ..()

/datum/component/mood/proc/print_mood(mob/user)
	var/msg = "[span_info("<EM>Your Current Mood:</EM>")]\n"
	msg += span_notice("My mental status: ") //Long term
	switch(sanity)
		if(SANITY_GREAT to INFINITY)
			msg += "[span_nicegreen("My mind feels like a temple!")]\n"
		if(SANITY_NEUTRAL to SANITY_GREAT)
			msg += "[span_nicegreen("I have been feeling great lately!")]\n"
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			msg += "[span_nicegreen("I have felt quite decent lately.")]\n"
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			msg += "[span_warning("I'm feeling a little bit unhinged...")]\n"
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			msg += "[span_boldwarning("I'm freaking out!!")]\n"
		if(SANITY_INSANE to SANITY_CRAZY)
			msg += "[span_boldwarning("AHAHAHAHAHAHAHAHAHAH!!")]\n"

	msg += span_notice("My current mood: ") //Short term
	switch(mood_level)
		if(1)
			msg += "[span_boldwarning("I wish I was dead!")]\n"
		if(2)
			msg += "[span_boldwarning("I feel terrible...")]\n"
		if(3)
			msg += "[span_boldwarning("I feel very upset.")]\n"
		if(4)
			msg += "[span_boldwarning("I'm a bit sad.")]\n"
		if(5)
			msg += "[span_nicegreen("I'm alright.")]\n"
		if(6)
			msg += "[span_nicegreen("I feel pretty okay.")]\n"
		if(7)
			msg += "[span_nicegreen("I feel pretty good.")]\n"
		if(8)
			msg += "[span_nicegreen("II feel amazing!")]\n"
		if(9)
			msg += "[span_nicegreen("I love life!")]\n"

	msg += span_notice("Moodlets:\n")//All moodlets
	if(mood_events.len)
		for(var/i in mood_events)
			var/datum/mood_event/event = mood_events[i]
			msg += event.description
	else
		msg += "[span_nicegreen("I don't have much of a reaction to anything right now.")]\n"
	to_chat(user || parent, examine_block(msg))

/datum/component/mood/proc/update_mood() //Called whenever a mood event is added or removed
	mood = 0
	shown_mood = 0
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		mood += event.mood_change
		if(!event.hidden)
			shown_mood += event.mood_change
	mood *= mood_modifier
	shown_mood *= mood_modifier

	switch(mood)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9
	update_mood_icon()


/datum/component/mood/proc/update_mood_icon()
	var/mob/living/owner = parent
	if(!(owner.client || owner.hud_used))
		return
	screen_obj.cut_overlays()
	screen_obj.color = initial(screen_obj.color)
	//lets see if we have any special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for(var/i in mood_events) //adds overlays and sees which special icons need to vie for which one gets the icon_state
		var/datum/mood_event/event = mood_events[i]
		if(!event)
			listclearnulls(mood_events)
			continue
		if(!event.special_screen_obj)
			continue
		if(!event.special_screen_replace)
			screen_obj.add_overlay(event.special_screen_obj)
		else
			conflicting_moodies += event
			var/absmood = abs(event.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood

	if(!conflicting_moodies.len) //no special icons- go to the normal icon states
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker) //bloodsucker edit
		if(sanity < 25)
			screen_obj.icon_state = "mood_insane"
			if(IS_BLOODSUCKER(owner) && bloodsuckerdatum.my_clan?.get_clan() == CLAN_TOREADOR)
				screen_obj.add_overlay("teeth_insane")
		else
			if(IS_BLOODSUCKER(owner) && bloodsuckerdatum.my_clan?.get_clan() == CLAN_TOREADOR)
				screen_obj.add_overlay("teeth[mood_level]")
			screen_obj.icon_state = "mood[mood_level]"
		screen_obj_sanity.icon_state = "sanity[sanity_level]"
		return

	for(var/i in conflicting_moodies)
		var/datum/mood_event/event = i
		if(abs(event.mood_change) == highest_absolute_mood)
			screen_obj.icon_state = "[event.special_screen_obj]"
			switch(mood_level)
				if(1)
					screen_obj.color = "#747690"
				if(2)
					screen_obj.color = "#f15d36"
				if(3)
					screen_obj.color = "#f38a43"
				if(4)
					screen_obj.color = "#dfa65b"
				if(5)
					screen_obj.color = "#4b96c4"
				if(6)
					screen_obj.color = "#a8d259"
				if(7)
					screen_obj.color = "#86d656"
				if(8)
					screen_obj.color = "#30dd26"
				if(9)
					screen_obj.color = "#2eeb9a"
			break

/datum/component/mood/process(delta_time) //Called on SSmood process
	var/mob/living/owner = parent
	if(!owner)
		qdel(src)
		return

	switch(mood_level)
		if(1)
			setSanity(sanity-0.2*delta_time)
		if(2)
			setSanity(sanity-0.125*delta_time, minimum=SANITY_CRAZY)
		if(3)
			setSanity(sanity-0.075*delta_time, minimum=SANITY_UNSTABLE)
		if(4)
			setSanity(sanity-0.025*delta_time, minimum=SANITY_DISTURBED)
		if(5)
			setSanity(sanity+0.1)
		if(6)
			setSanity(sanity+0.15*delta_time)
		if(7)
			setSanity(sanity+0.2*delta_time)
		if(8)
			setSanity(sanity+0.25*delta_time, maximum=SANITY_GREAT)
		if(9)
			setSanity(sanity+0.4*delta_time, maximum=INFINITY)

	if(HAS_TRAIT(owner, TRAIT_DEPRESSION))
		if(prob(0.05))
			add_event(null, "depression", /datum/mood_event/depression_mild)
			clear_event(null, "jolly")
	if(HAS_TRAIT(owner, TRAIT_JOLLY))
		if(prob(0.05))
			add_event(null, "jolly", /datum/mood_event/jolly)
			clear_event(null, "depression")

	HandleNutrition(owner)

/datum/component/mood/proc/setSanity(amount, minimum=SANITY_INSANE, maximum=SANITY_NEUTRAL)
	var/mob/living/owner = parent

	amount = clamp(amount, minimum, maximum)
	if(amount == sanity)
		return
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.5
	// If the new amount would move towards the acceptable range faster then use it instead
	if(sanity < minimum && amount < sanity + 0.5)
		amount = sanity + 0.5
	else if(sanity > maximum && amount > sanity - 0.5)
		amount = sanity - 0.5

	// Disturbed stops you from getting any more sane
	if(HAS_TRAIT(owner, TRAIT_UNSTABLE))
		sanity = min(amount,sanity)
	else
		sanity = amount

	var/mob/living/master = parent
	switch(sanity)
		if(SANITY_INSANE to SANITY_CRAZY)
			setInsanityEffect(MAJOR_INSANITY_PEN)
			master.add_movespeed_modifier(MOVESPEED_ID_SANITY, TRUE, 100, override=TRUE, multiplicative_slowdown=0.75, movetypes=(~FLYING))
			sanity_level = 6
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			setInsanityEffect(MINOR_INSANITY_PEN)
			master.add_movespeed_modifier(MOVESPEED_ID_SANITY, TRUE, 100, override=TRUE, multiplicative_slowdown=0.5, movetypes=(~FLYING))
			sanity_level = 5
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			setInsanityEffect(0)
			master.add_movespeed_modifier(MOVESPEED_ID_SANITY, TRUE, 100, override=TRUE, multiplicative_slowdown=0.25, movetypes=(~FLYING))
			sanity_level = 4
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY, TRUE)
			sanity_level = 3
		if(SANITY_NEUTRAL+1 to SANITY_GREAT+1) //shitty hack but +1 to prevent it from responding to super small differences
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY, TRUE)
			sanity_level = 2
		if(SANITY_GREAT+1 to INFINITY)
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY, TRUE)
			sanity_level = 1
	update_mood_icon()

/datum/component/mood/proc/setInsanityEffect(newval)
	if(newval == insanity_effect)
		return
	var/mob/living/master = parent
	master.crit_threshold = (master.crit_threshold - insanity_effect) + newval
	insanity_effect = newval

/datum/component/mood/proc/add_event(datum/source, category, type, param) //Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
	var/datum/mood_event/the_event
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(null, category)
		else
			if(the_event.timeout)
				addtimer(CALLBACK(src, PROC_REF(clear_event), null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)
			return 0 //Don't have to update the event.
	the_event = new type(src, param)

	mood_events[category] = the_event
	the_event.category = category
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, PROC_REF(clear_event), null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/component/mood/proc/clear_event(datum/source, category)
	var/datum/mood_event/event = mood_events[category]
	if(!event)
		return 0

	mood_events -= category
	qdel(event)
	update_mood()

/datum/component/mood/proc/remove_temp_moods(admin) //Removes all temp moods
	for(var/i in mood_events)
		var/datum/mood_event/moodlet = mood_events[i]
		if(!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet.category
		qdel(moodlet)
		update_mood()


/datum/component/mood/proc/modify_hud(datum/source)
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	screen_obj_sanity = new
	hud.infodisplay += screen_obj
	hud.infodisplay += screen_obj_sanity
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, PROC_REF(unmodify_hud))
	RegisterSignal(screen_obj, COMSIG_CLICK, PROC_REF(hud_click))

/datum/component/mood/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER
	if(!screen_obj)
		return
	var/mob/living/owner = parent
	if(!owner)
		return
	var/datum/hud/hud = owner.hud_used
	if(hud && hud.infodisplay)
		hud.infodisplay -= screen_obj
		hud.infodisplay -= screen_obj_sanity
	QDEL_NULL(screen_obj)
	QDEL_NULL(screen_obj_sanity)

/datum/component/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	print_mood(user)

/datum/component/mood/proc/HandleNutrition(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(isethereal(H))
			HandleCharge(H)
		if(HAS_TRAIT(H, TRAIT_NOHUNGER))
			return FALSE //no mood events for nutrition
	switch(L.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			if (!HAS_TRAIT(L, TRAIT_VORACIOUS))
				add_event(null, "nutrition", /datum/mood_event/fat)
			else
				add_event(null, "nutrition", /datum/mood_event/wellfed) // round and full
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			add_event(null, "nutrition", /datum/mood_event/wellfed)
		if( NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			add_event(null, "nutrition", /datum/mood_event/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			clear_event(null, "nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			add_event(null, "nutrition", /datum/mood_event/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_event(null, "nutrition", /datum/mood_event/starving)

/datum/component/mood/proc/HandleCharge(mob/living/carbon/human/H)
	var/datum/species/ethereal/E = H.dna?.species
	switch(E.get_charge(H))
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			add_event(null, "charge", /datum/mood_event/decharged)
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			add_event(null, "charge", /datum/mood_event/lowpower)
		if(ETHEREAL_CHARGE_NORMAL to ETHEREAL_CHARGE_ALMOSTFULL)
			clear_event(null, "charge")
		if(ETHEREAL_CHARGE_ALMOSTFULL to ETHEREAL_CHARGE_FULL)
			add_event(null, "charge", /datum/mood_event/charged)
		if(ETHEREAL_CHARGE_FULL to ETHEREAL_CHARGE_OVERLOAD)
			add_event(null, "charge", /datum/mood_event/overcharged)
		if(ETHEREAL_CHARGE_OVERLOAD to ETHEREAL_CHARGE_DANGEROUS)
			add_event(null, "charge", /datum/mood_event/supercharged)

/datum/component/mood/proc/check_area_mood(datum/source, area/A)
	if(A.mood_bonus)
		add_event(null, "area", /datum/mood_event/area, A.mood_bonus, A.mood_message)

#undef MINOR_INSANITY_PEN
#undef MAJOR_INSANITY_PEN
