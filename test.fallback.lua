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
