--!nonstrict
local RegEx = require("./RegEx")
type Array<T> = { [number]: T }

type RegExpExecArray = Array<string> & { index: number?, input: string?, n: number }

export type RegExp = {
	exec: (self: RegExp, input: string) -> RegExpExecArray | nil,
	test: (self: RegExp, input: string) -> boolean,
}

local RegExp = {}
local RegExpMetatable = {
	__index = RegExp,
	__tostring = function(self)
		return tostring(self._innerRegEx)
	end,
}

function RegExp:exec(str: string): RegExpExecArray | nil
	local match = self._innerRegEx:match(str)
	if not match then
		return nil
	end

	local index = match:span()
	local groups = match:grouparr()

	local matches = { groups[0] }
	for i = 1, groups.n do
		matches[i + 1] = groups[i]
	end
	matches.n = groups.n + 1
	matches.index = index
	matches.input = str
	return matches
end

function RegExp:test(str: string): boolean
	return self:exec(str) ~= nil
end

local function new(pattern: RegExp | string, flags: string?): RegExp
	flags = flags or ""
	local innerRegEx = RegEx.new(pattern, flags)
	local object = {
		source = pattern,
		ignoreCase = (flags :: string):find("i") ~= nil,
		global = (flags :: string):find("g") ~= nil,
		multiline = (flags :: string):find("m") ~= nil,
		_innerRegEx = innerRegEx,
	}

	return setmetatable(object, RegExpMetatable) :: any
end

return {
	new = new,
}
