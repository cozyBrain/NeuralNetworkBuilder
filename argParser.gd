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

func getString(flagsToDetect : Array, default = null, retTrueWhenFlag : bool = false):
	for i in range(0, flagsToDetect.size()):
		flagsToDetect[i] = "-"+flagsToDetect[i]
	var args = argument.split(" ", false)
	var strings : Array
	var push : bool = false
	for arg in args:
		if push:
			return arg
		for ftd in flagsToDetect:
			if arg == ftd:
				push = true
	if push and retTrueWhenFlag:
		return true
	return default

func getBool(flagsToDetect : Array, default : bool = false):  # detectFlag -> return default or return !default
	for i in range(0, flagsToDetect.size()):
		flagsToDetect[i] = "-"+flagsToDetect[i]
	var args = argument.split(" ", false)
	for arg in args:
		for ftd in flagsToDetect:
			if arg == ftd:
				return !default
	return default
