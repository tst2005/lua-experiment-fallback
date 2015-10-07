
-- ----------------------------------------------------------

--local assert = assert
local error, ipairs, type = error, ipairs, type
local format = string.format
--local loadfile = loadfile

local function lassert(cond, msg, lvl)
	if not cond then
		error(msg, lvl+1)
	end
	return cond
end
local function checkmodname(s)
	local t = type(s)
	if t == "string" then
	        return s
	elseif t == "number" then
		return tostring(s)
	else
		error("bad argument #1 to `require' (string expected, got "..t..")", 3)
	end
end
--
-- iterate over available searchers
--
local function iload(modname, searchers)
	lassert(type(searchers) == "table", "`package.searchers' must be a table", 2)
	local msg = ""
	for _, searcher in ipairs(searchers) do
		local loader, param = searcher(modname)
		if type(loader) == "function" then
			return loader, param -- success
		end
		if type(loader) == "string" then
			-- `loader` is actually an error message
			msg = msg .. loader
		end
	end
	error("module `" .. modname .. "' not found: "..msg, 2)
end

local function bigfunction_new(with_loaded)

	local _PACKAGE = {}
	local _LOADED = with_loaded or {}
	local _SEARCHERS  = {}

	--
	-- new require
	--
	local function _require(modname)

		modname = checkmodname(modname)
		local p = _LOADED[modname]
		if p then -- is it there?
			return p -- package is already loaded
		end

		local loader, param = iload(modname, _SEARCHERS)

		local res = loader(modname, param)
		if res ~= nil then
			p = res
		elseif not _LOADED[modname] then
			p = true
		else
			p = _LOADED[name]
		end

		_LOADED[modname] = p
		return p
	end

	_LOADED.package = _PACKAGE
	do
		local package = _PACKAGE
		package.loaded		= _LOADED
		package.searchers	= _SEARCHERS
	end
	return _require, _PACKAGE
end -- big function

local new = bigfunction_new

local with_loaded = {}
local _require, _PACKAGE = new(with_loaded)
local searchers = _PACKAGE.searchers

-- [keep] 0) already loaded package (in _PACKAGE.loaded)
-- [keep] 1) local submodule will be stored in _PACKAGE.preload[?]
-- [new ] 2) uplevel require() (follow uplevel's loaded/preload/...)
-- [new ] 3) fallback -> search in preload table but with a suffix name "fallback."

--
-- check whether library is already loaded
--
local _PRELOAD = {}
_PACKAGE.preload = _PRELOAD
local function searcher_preload(name)
	lassert(type(name) == "string", format("bad argument #1 to `require' (string expected, got %s)", type(name)), 2)
	lassert(type(_PRELOAD) == "table", "`package.preload' must be a table", 2)
	return _PRELOAD[name]
end
table.insert(searchers, searcher_preload)

--
local function search_uplevel(modname)
	local ok, ret = pcall(require, modname)
	if not ok then return false end
	return function() return ret end
end
table.insert(searchers, search_uplevel)

--
local function search_fallback(modname)
	return _PRELOAD["fallback." .. modname]
end
table.insert(searchers, search_fallback)

return setmetatable({require = _require, package = _PACKAGE}, {__call = function(_self, ...) return _require(...) end})
