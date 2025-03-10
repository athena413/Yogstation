/datum/mutation/human/antenna
	name = "Antenna"
	desc = "The affected person sprouts an antenna. This is known to allow them to access common radio channels passively."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel an antenna sprout from your forehead.")
	text_lose_indication = span_notice("Your antenna shrinks back down.")
	instability = 10
	difficulty = 8
	var/obj/item/implant/radio/antenna/radio

/datum/mutation/human/antenna/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	radio = new(owner)
	radio.implant(owner, null, TRUE, TRUE)

/datum/mutation/human/antenna/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	if(radio)
		radio.Destroy()

/datum/mutation/human/antenna/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "antenna", -FRONT_MUTATIONS_LAYER+1))//-MUTATIONS_LAYER+1

/datum/mutation/human/antenna/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/mindreader
	name = "Mind Reader"
	desc = "The affected person can look into the recent memories of others."
	quality = POSITIVE
	text_gain_indication = span_notice("You hear distant voices at the corners of your mind.")
	text_lose_indication = span_notice("The distant voices fade.")
	power_path = /datum/action/cooldown/spell/pointed/mindread
	instability = 40
	difficulty = 8
	locked = TRUE

/datum/action/cooldown/spell/pointed/mindread
	name = "Mindread"
	desc = "Read the target's mind."
	button_icon_state = "mindread"
	cooldown_time = 5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_MIND
	ranged_mousepointer = 'icons/effects/mouse_pointers/mindswap_target.dmi'

/datum/action/cooldown/spell/pointed/mindread/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(!living_cast_on.mind)
		to_chat(owner, span_warning("[cast_on] has no mind to read!"))
		return FALSE
	if(living_cast_on.stat == DEAD)
		to_chat(owner, span_warning("[cast_on] is dead!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/mindread/cast(mob/living/cast_on)
	. = ..()
	if(cast_on.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		to_chat(owner, span_warning("As you reach into [cast_on]'s mind, \
			you are stopped by a mental blockage. It seems you've been foiled."))
		return

	if(cast_on == owner)
		to_chat(owner, span_warning("You plunge into your mind... Yep, it's your mind."))
		return

	to_chat(owner, span_boldnotice("You plunge into [cast_on]'s mind..."))
	if(prob(20))
		// chance to alert the read-ee
		to_chat(cast_on, span_danger("You feel something foreign enter your mind."))

	var/list/recent_speech = list()
	var/list/say_log = list()
	var/log_source = cast_on.logging
	//this whole loop puts the read-ee's say logs into say_log in an easy to access way
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				say_log = reverse_range(reversed.Copy())
				break

	for(var/spoken_memory in say_log)
		//up to 3 random lines of speech, favoring more recent speech
		if(length(recent_speech) >= 3)
			break
		if(prob(50))
			continue
		// log messages with tags like telepathy are displayed like "(Telepathy to Ckey/(target)) "greetings"""
		// by splitting the text by using a " delimiter, we can grab JUST the greetings part
		recent_speech[spoken_memory] = splittext(say_log[spoken_memory], "\"", 1, 0, TRUE)[3]

	if(length(recent_speech))
		to_chat(owner, span_boldnotice("You catch some drifting memories of their past conversations..."))
		for(var/spoken_memory in recent_speech)
			to_chat(owner, span_notice("[recent_speech[spoken_memory]]"))

	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_cast_on = cast_on
		to_chat(owner, span_boldnotice("You find that their intent is to [carbon_cast_on.a_intent]..."))
		to_chat(owner, span_boldnotice("You uncover that [carbon_cast_on.p_their()] true identity is [carbon_cast_on.mind.name]."))

/datum/mutation/human/mindreader/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "antenna", -FRONT_MUTATIONS_LAYER+1))

/datum/mutation/human/mindreader/get_visual_indicator()
	return visual_indicators[type][1]
