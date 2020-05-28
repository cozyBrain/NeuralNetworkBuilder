extends Node

class_name ArgParser

var argument : String

func _init(arg : String):
	argument = arg

func getStrings(flag : String):
	flag = "-"+flag
	var words = argument.split(" ", false)
	var strings : Array
	var push : bool = false
	for word in words:
		if push:
			if word[0] == "-":
				break
			strings.push_back(word)
			
		if word == flag:
			push = true
	
	return strings

func getString(flag : String, default, retTrueWhenFlag : bool = true):
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
