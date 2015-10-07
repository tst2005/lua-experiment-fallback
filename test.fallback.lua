local fallback = require "fallback"
local _require = fallback.require -- or directly fallback
local _PACKAGE = fallback.package
local preload = _PACKAGE.preload

preload["fallback.compat_env"] = function()
        return {_NAME="compat_env"}
end

preload["foo.bar"] = function()
        return {_NAME="foo.bar"}
end

preload["fallback.mod1"] = function()
        return {_NAME="mod1(fallback)"}
end

preload["fallback.mod2"] = function()
        return {_NAME="mod2(fallback)"}
end



assert( _require"mod1"._NAME == "mod1(file)" ) -- the mod1.lua file, not the preload["mod1"] one
assert( _require"mod2"._NAME == "mod2(fallback)" ) -- the fallback mod2 because the mod2.lua is not exists.


assert( require "string" ==  _require("string") )
assert(_require("foo.bar")._NAME == "foo.bar")
assert(_require("compat_env")._NAME == "compat_env")

do
	local loaded = assert( package.loaded )
	local _loaded = assert( _PACKAGE.loaded )

	assert( not loaded["foo.bar"] )
	assert( _loaded["foo.bar"] )

	assert( not loaded["compat_env"] )
	assert( _loaded["compat_env"] )

	assert( loaded["string"] )
	assert( _loaded["string"] )

end
print("ok")
