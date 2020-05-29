extends Node

class_name ArgParser

var argument : String

func _init(arg : String):
	argument = arg

func getStrings(flagsToDetect : Array):
	for i in range(0, flagsToDetect.size()):
		flagsToDetect[i] = "-"+flagsToDetect[i]
	
	var args = argument.split(" ", false)
	var strings : Array
	var push : bool = false
	for arg in args:
		if push:
			if arg[0] == "-":
				break
			strings.push_back(arg)
			
		for ftd in flagsToDetect:
			if arg == ftd:
				push = true
	if strings.size() == 0 and push:
		return null
	return strings

func getString(flag : String, default = null, retTrueWhenFlag : bool = true):
	flag = "-"+flag
	var words = argument.split(" ", false)
	var strings : Array
	var push : bool = false
	for word in words:
		if push:
			return word
		if word == flag:
			push = true
	if push and retTrueWhenFlag:
		return true
	return default

func getBool(flag : String, default):
	flag = "-"+flag
	var words = argument.split(" ", false)
	for word in words:
		if word == flag:
			return !default
	return default
