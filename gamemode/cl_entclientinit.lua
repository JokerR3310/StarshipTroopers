-- Adds clientside support to entities which don't have it naturally (SNPCs)

local forced_client_class = {}
local class_meta = {}
--[[
function force_client_class_GetTable()
	return forced_client_class
end

function class_meta_GetTable()
	return class_meta
end
]]
if not __scripted_ents_register then
	__scripted_ents_register = scripted_ents.Register
end

function scripted_ents.Register(tbl, name, reload)
	if tbl.Building == true then
		forced_client_class[name] = true
	end
	
	return __scripted_ents_register(tbl, name, reload)
end

function GM:LoadEntityClientFunctions()
	local path = self.Folder.."/entities/entities/"
	local luapath = string.gsub(self.Folder, "gamemodes/", "").."/entities/entities/"

	local _, folders = file.Find(path.."*", "GAME")
	for _,class in ipairs(folders) do
		for _,luafile in ipairs(file.Find(path..class.."/*", "GAME")) do
			if luafile == "cl_init.lua" then
				ENT = {}
				include(luapath..class.."/"..luafile)

				if ENT.Building == true then
					scripted_ents.Register(ENT, class, false)
					forced_client_class[class] = true
				end
			end
		end
	end
end

GM:LoadEntityClientFunctions()

local function meta_init(ent)
	local class = ent:GetClass()
	if forced_client_class[class] then
		if not ent.__metainit then
			if not class_meta[class] then
				class_meta[class] = scripted_ents.Get(class)
			end
			
			local newmeta = class_meta[class]
			setmetatable(ent:GetTable(), {__index = newmeta})
			ent.__metainit = true
		end
	end
end

hook.Add("Think", "ClientEntityThink", function()
	for _,v in pairs(ents.GetAll()) do
		if IsValid(v) and forced_client_class[v:GetClass()] then
			meta_init(v)
			
			if not v.ClientInitialized then
				if v.Initialize then
					v:Initialize()
					v.ClientInitialized = true
				end
				v.ClientInitialized = true
			else
				if v.Think then v:Think() end
			end
		end
	end
end)

hook.Add("PostDrawOpaqueRenderables", "ClientEntityDraw", function()
	for _,v in pairs(ents.GetAll()) do
		if IsValid(v) and forced_client_class[v:GetClass()] and v.ClientInitialized then
			meta_init(v)
			if v.Draw then v:Draw() end
		end
	end
end)