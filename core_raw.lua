return function()
	-- coreVersion = 140
	local base = system.DocumentsDirectory
	-- Write all files
	local write = function(path, content)
	    local f = io.open(system.pathForFile(path, base), "w")
	    if f then f:write(content) f:close() end
	end


write("reinternal/core.lua", [[
	core = {}
	lfs = lfs or require("lfs")
	ModManager.version = "1.5.0"

	-- ============================================  actual code under
	function core.init()
	    EnableDebugLog = true -- false in release
	    logToFile("=============== [CORE:start] ===============")
	    modloc = {}

	    -- =============
	    ModManager.extendRoute("lib.ally.ally_command", "ally_command")
	    ModManager.extendRoute("lib.ally.ally_list", "ally")
	    ModManager.extendRoute("lib.base_npc.base_npc_list", "basenpc")
	    ModManager.extendRoute("lib.base_npc.buyer_list", "base_buyer")
	    ModManager.extendRoute("lib.base_npc.trader_list", "base_trader")
	    ModManager.extendRoute("lib.base_npc.workshop_list", "base_workshop")
	    ModManager.extendRoute("lib.base_npc.train_list", "base_train")
	    ModManager.extendRoute("lib.base_npc.product_list", "base_product")
	    ModManager.extendRoute("lib.base_npc.product_sell_list", "base_product_sell")
	    ModManager.extendRoute("lib.base_npc.product_craft_list", "base_product_craft")
	    ModManager.extendRoute("lib.base_npc.product_repair_list", "base_product_repair")
	    ModManager.extendRoute("lib.battle.obj_list.battle_map_list", "battle_map")
	    ModManager.extendRoute("lib.battle.obj_list.battle_map_decor_list", "battle_map_decor")
	    ModManager.extendRoute("lib.battle.obj_list.terrain_list", "battle_terrain")
	    ModManager.extendRoute("lib.battle.obj_list.terrain_decor_list", "battle_terrain_decor")
	    ModManager.extendRoute("lib.battle.obj_list.faction_list", "battle_faction")
	    ModManager.extendRoute("lib.battle.obj_list.weapon_human_list", "battle_weapon")

	    ModManager.extendRoute("lib.battle.obj_list.unit_ally_list", "battle_unit_ally")
	    ModManager.extendRoute("lib.battle.obj_list.unit_bandit_list", "battle_unit_enemy")
	    
	    ModManager.extendRoute("lib.battle.obj_list.enemy_animal_list", "battle_enemy_set")
	    ModManager.extendRoute("lib.battle.obj_list.effect_list", "battle_effect")
	    ModManager.extendRoute("lib.battle.obj_list.perk_list", "battle_perk")
	    ModManager.extendRoute("lib.chest.item_chest_list", "item_chest")
	    ModManager.extendRoute("lib.chest.chest_list", "chest")
	    ModManager.extendRoute("lib.config.hard_config", "config_hard")
	    ModManager.extendRoute("lib.cooking_list", "cooking")
	    ModManager.extendRoute("lib.disease.disease_list", "disease")
	    ModManager.extendRoute("lib.interface.image_list", "image")
	    ModManager.extendRoute("lib.interface.image_sheet_list", "image_sheet")
	    ModManager.extendRoute("lib.items.ammo", "item")
	    ModManager.extendRoute("lib.level.recipe_list", "recipe")
	    ModManager.extendRoute("lib.level.perk_list", "perk")
	    ModManager.extendRoute("lib.level.level_list", "level")
	    ModManager.extendRoute("lib.location.city_list", "location_city")
	    ModManager.extendRoute("lib.location.location_list", "location")
	    -- ModManager.extendRoute("lib.location.location_season_list", "location")
	    ModManager.extendRoute("lib.location.base_npc", "location_base_npc")
	    ModManager.extendRoute("lib.location.base_enemy", "location_base_enemy")
	    ModManager.extendRoute("lib.loot.item_loot_list", "loot_item")
	    ModManager.extendRoute("lib.loot.miniloc_loot_list", "loot_miniloc")
	    ModManager.extendRoute("lib.loot.location_loot_list", "loot_location")
	    ModManager.extendRoute("lib.miniloc.miniloc_list", "miniloc")
	    ModManager.extendRoute("lib.npc.npc_list", "npc")
	    ModManager.extendRoute("lib.quest.bar_quest_list", "quest_bar")
	    ModManager.extendRoute("lib.quest.quest_list", "quest")
	    ModManager.extendRoute("lib.random_event_list", "random_event")
	    ModManager.extendRoute("lib.weather.weather_list", "weather")
	    
	    
	    ModManager.catroute() -- create category routing
	    
	    ModManager.extendFuncRoute("lib.interface.image_master", "image_method")
	    ModManager.extendFuncRoute("lib.battle.unit_logic", "battle_unit_logic")    
	        
	    -- =====================================    
	    local loader = require("angel_mod.loader")
	    
	    local allMods = loader.loadMods()
	    
	    local general = {
	        fontSize = {
	            title = 46,
	            body = 40,
	            footer = 34
	        },
	        button = {
	            close = {
	                size = 80,
	                height = 60
	            }
	        },
	        edgeRound = 8,
	    }
	    
	    -- Core util here 
	    
	    if #allMods.preload > 0 then        
	        loader.executeMods(allMods.preload, true)
	    else    
	        logToFile("ℹ️ No preload mods to load")
	    end
	    
	    if #allMods.normal > 0 then
	        -- Checker configuration
	        local checkInterval = 1000 -- milliseconds 
	        local maxAttempts = 40
	        local attempts = 0
	        local checkerTimer = nil
	        local labels = "main.gameNetwork"
	        
	        -- Self-destructing checker function
	        local function checkNotifications()
	    	    if checkerTimer then
			        timer.cancel(checkerTimer)
			        checkerTimer = nil
			    end

	            attempts = attempts + 1
	            
	            -- Success condition
	            if type(main) == "table" and type(main.gameNetwork) == "table" then
	                logToFile("✅ " .. labels .. " ready - Executing normal mods")
	                loader.executeMods(allMods.normal, false)
	                
	                itemlist = main.itemlist.table
	                bweapon = main.battle.weapon.table
	                
	                -- Clean up
	                if checkerTimer then timer.cancel(checkerTimer) end
	                checkNotifications = nil  -- Remove function reference
	                return
	            end
	            
	            -- Fail condition
	            if attempts >= maxAttempts then
	                logToFile("❌ Failed to find " .. labels .. " after "..maxAttempts.." attempts")
	                
	                -- Clean up
	                if checkerTimer then timer.cancel(checkerTimer) end
	                checkNotifications = nil
	                return
	            end
	            
	            -- Continue checking
	            logToFile("🔍 Waiting for " .. labels .. " (Attempt "..attempts.."/"..maxAttempts..")")
	            checkerTimer = timer.performWithDelay(checkInterval, checkNotifications)
	        end
	        
	        -- Start the checker
	        logToFile("⏳ Delaying "..#allMods.normal.." normal mods until " .. labels .. " exist...")
	        checkNotifications()  -- Initial call
	    else    
	        logToFile("ℹ️ No normal mods to load")
	    end
	    
	    logToFile("[CORE] finished")
	end 



	return core
]])


write("reinternal/files.lua", [[
]])


write("reinternal/lib.lua", [[
	-- ================================== Function Hijacks

	-- Updated in v150
	function require(path)
	    -- Splash screen hook (unchanged)
	    if path == "lib.loading._loading_master" then
	        local old = oldRequire(path)
	        local origStart = old.start
	        old.origStart = origStart
	        old.start = function(m)
	            timer.performWithDelay(2000, function()
	                timer.performWithDelay(500, showSplash)
	                old.origStart(m)
	            end)
	        end
	        return old
	    end
	    
	    -- Cache lookups
	    local funcCategory = ModManager.funcroute[path]
	    local funcOverride = funcCategory and ModManager.funcOverride[funcCategory]
	    local dataCategory = ModManager.routing[path]
	    local dataOverride = dataCategory and ModManager.mods[dataCategory]
	    
	    -- Early exit for non-modded paths
	    if not funcCategory and not dataCategory then
	        return oldRequire(path)
	    end

	    local success, original = pcall(oldRequire, path)
	    if not success then
	        logToFile("[ModManager] REQUIRE FAILED: "..path.." | Error: "..tostring(original))
	        return nil
	    end
	    
	    if type(original) == "table" then
	        local modified = table.copy({ original })[1]  -- Always copy first
	        
	        if funcOverride then
	            -- PHASE 1: Replace Whole Table
	            if funcOverride.isReplaceTable then
	                modified = funcOverride.replacement
	                logToFile("[ModManager] FULL TABLE REPLACEMENT: ".. path)        
	            -- PHASE 2: Function/Value overrides        
	            elseif funcOverride.isIndexedTable then
	                    -- check item key
	                local targetCond = funcOverride.targetKey
	                
	                for _, item in ipairs(modified) do -- loop original 
	                    local fix = item[targetCond]
	                    if fix and funcOverride[fix] then  -- Check if ID exists and has overrides
	                        for path, override in pairs(funcOverride[fix]) do -- loop mod entry
	                            local target = item
	                            local keys = {}
	                            
	                            -- Split path (e.g., "stat.damage" → {"stat", "damage"})
	                            for part in path:gmatch("[^.]+") do
	                                table.insert(keys, part)
	                            end
	            
	                            -- Navigate to target (skip if invalid path)
	                            for i = 1, #keys-1 do
	                                if type(target) ~= "table" or not target[keys[i\]\] then 
	                                    break 
	                                end
	                                target = target[keys[i\]\]
	                            end
	                            
	                            target[keys[#keys\]\] = override
	                            logToFile(string.format("[ModManager] Override [Index] %s.%s = %s", item.id, path, override))
	                        end
	                    end
	                end
	            elseif funcOverride.append then
	                if funcOverride.data then
	                    modified = table.js.safeMerge(modified, funcOverride.data)
	                end
	            else 
	            -- Normal Mode (Flat/dot-notation overrides)
	                for path, override in pairs(funcOverride) do
	                    local target = modified
	                    local keys = {}
	                    
	                    for part in path:gmatch("[^.]+") do
	                        table.insert(keys, part)
	                    end
	                    
	                    for i = 1, #keys-1 do
	                        if not target[keys[i\]\] then break end
	                        target = target[keys[i\]\]
	                    end
	                    
	                    if target[keys[#keys\]\] then
	                        target[keys[#keys\]\] = override
	                        logToFile(string.format("[ModManager] Override [FlatKey] %s.%s", path, path))
	                    end
	                end
	            end
	        end
	        -- PHASE 3: Data merges
	        if dataOverride then
	            modified = table.copy(modified, ModManager.deepCopyWithResolution({}, dataOverride))
	        end

	        return modified
	    else
	        -- PHASE 2: Global hijacks
	        if funcOverride then
	            for funcPath, override in pairs(funcOverride) do
	                if override.nonExport and override.func then
	                    local target = _G
	                    local parts = {}
	                    
	                    for part in funcPath:gmatch("[^.]+") do
	                        table.insert(parts, part)
	                    end
	                    
	                    for i = 1, #parts-1 do
	                        if not target[parts[i]\] then break end
	                        target = target[parts[i]\]
	                    end
	                    
	                    if target and target[parts[#parts]\] then
	                        target[parts[#parts]\] = override.func
	                        logToFile("[ModManager] Hijacked: "..funcPath)
	                    end
	                end
	            end
	        end
	        return original
	    end
	end

	display.newImage = function(...)
	    -- Handle non-string paths safely
	    local args = {...}
	    local firstArg = args[1]
	    if type(firstArg) ~= "string" then
	        return originalNewImage(...)  -- Fall back to original behavior
	    end

	    local originalPath = firstArg
	    local isModded = includes(originalPath, "modded_assets/")
	    local finalPath = originalPath

	    -- Process modded paths
	    if isModded then
	        -- Extract mod path (e.g., "modded_assets/assets/image.png")
	        local modRelativePath = originalPath:match("modded_assets/(.+)")
	        if modRelativePath then
	            finalPath = system.pathForFile("angel_mod/modlist/"..modRelativePath, system.DocumentsDirectory)
	            
	            -- LFS file check
	            local fileAttr = lfs.attributes(finalPath)
	            if not fileAttr or fileAttr.mode ~= "file" then
	                logToFile("[Image Load] MOD MISSING: "..finalPath)
	                return originalNewImage(...)  -- Fallback to original asset
	            end
	        end
	    end

	    -- Debug logging
	    if EnableDebugLog then
	    	logToFile(string.format("[Image Load] %s: %s", isModded and "MOD" or "ORIGINAL", isModded and finalPath or originalPath ))
	    end

	    -- Protected load
	    local success, image = pcall(originalNewImage, finalPath, select(2, ...))
	    if success then
	        return image
	    else
	        logToFile("[Image Load] FAILED: "..finalPath.." | "..tostring(image))
	        return originalNewImage(...)  -- Ultimate fallback
	    end
	end
	-- ==================================================================== setup files

	local filesData = sreq("reinternal.files")

	if filesData then
		-- List of Folder that needs to be created
		local folders = {
		    "angel_mod",
		    "angel_mod/modlist",
		    "angel_mod/modlist/assets",
		    "angel_mod/modlist/.example_mod",
		    "angel_mod/modlist/.example_mod/afterload",
		    "angel_mod/modlist/.example_mod/preload",
		}

		-- list of files that needs to be created
		local files = {
		    {
		        path = "reinternal/core.lua",
		        content = filesData.core
		    },
		    { 
		        path = "angel_mod/feature.lua", 
		        content = filesData.feature
		    },
		    { 
		        path = "angel_mod/loader.lua", 
		        content = filesData.loader 
		    },
		    { 
		        path = "angel_mod/menu.lua", 
		        content = filesData.menu
		    },
		    {
		        path = "angel_mod/modlist/.example_mod/afterload/damage.lua",
		        content = filesData.example_mod_afterload
		    },
		    {
		        path = "angel_mod/modlist/.example_mod/preload/item.lua",
		        content = filesData.example_mod_preload
		    },
		    {
		        path = "angel_mod/modlist/.example_mod/manifest.lua",
		        content = filesData.example_mod_manifest
		    },
		    {
		        path = "angel_mod/modlist/readme.md",
		        content = filesData.readme
		    }
		}

		setupModDirectories(folders, files)

	end

	-- ==================================================================== Things
	ModManager.clearLog("debug_log.txt")
	modMenu = require("angel_mod.menu")



	-- ==================================================================== INIT
	local core = sreq("reinternal.core")
	if core and core.init then
		core.init()
	else
		logToFile("Core Not Found")
	end
]])


write("reinternal/manager.lua", [[
	-- Initialize core tables
	ModManager.mods = ModManager.mods or {}
	ModManager.routing = ModManager.routing or {}
	ModManager.category = ModManager.category or {}
	ModManager.funcOverride = ModManager.funcOverride or {}
	ModManager.funcroute = ModManager.funcroute or {}
	ModManager.funccat = ModManager.funccat or {}
	ModManager.loadedMods = ModManager.loadedMods or {}


	ModManager.debug = {
	    list = function()
	        local output = {}
	        for category, items in pairs(ModManager.mods) do
	            table.insert(output, string.format("%s (%d items)", category, #items))
	        end
	        ModManager.showToast("Mod Categories:\n"..table.concat(output, "\n"))
	    end,
	    find = function(id)
	        for category, items in pairs(ModManager.mods) do
	            for _, item in ipairs(items) do
	                if item.id == id then
	                    ModManager.showToast(string.format(
	                        "'%s' found in %s\nMod: %s",
	                        id, category, item.modName
	                    ))
	                    return
	                end
	            end
	        end
	        ModManager.showToast("ID '"..id.."' not found")
	    end
	}

	ModManager.resolutionPatterns = {
	    "^strings%.",
	    "^modloc%.",
	    -- Add more patterns here as needed
	}

	-- =========== General Functions
	function ModManager.safeRequire(path)  
	    local ok, result = pcall(require, path)  -- Wrap vanilla require
	    if not ok then
	        logToFile("[Mod Manager] Optional module not found: " .. path)
	        return nil
	    end
	    return result
	end

	function ModManager.clearLog(targetfile)
	    local logPath = system.pathForFile(targetfile, system.DocumentsDirectory)
	    local wipeFile = io.open(logPath, "w")
	    if wipeFile then
	        wipeFile:close()
	        return true  -- Return success status
	    end
	    return false
	end

	-- added for extending the resolution table
	function ModManager.addResolutionPatterns(...)
	    for _, pattern in ipairs({...}) do
	        table.insert(ModManager.resolutionPatterns, pattern)
	    end
	end

	-- Updated in v1.1.2
	function ModManager.deepCopyWithResolution(t, s)
	    for k, v in pairs(s) do
	        if type(v) == "string" then
	            local shouldResolve = false
	            -- Check against all configured patterns
	            for _, pattern in ipairs(ModManager.resolutionPatterns) do
	                if v:match(pattern) then
	                    shouldResolve = true
	                    break
	                end
	            end
	            
	            if shouldResolve then
	                t[k] = ModManager.resolveGlobalPath(v) or v
	            else
	                t[k] = v
	            end
	        elseif type(v) == "table" then 
	            t[k] = ModManager.deepCopyWithResolution({}, v)
	        else
	            t[k] = v
	        end
	    end
	    return t
	end

	function ModManager.resolveGlobalPath(path)
	    local func, err = loadstring("return " .. path)
	    if not func then
	        logToFile("[ModManager] Load error: " .. tostring(err))
	        return path
	    end

	    local ok, result = pcall(func)
	    if ok then
	        return result
	    else
	        logToFile("[ModManager] Resolve failed: " .. path .. " | " .. tostring(result))
	        return path
	    end
	end

	function ModManager.safeEval(path, noReturn)
	    local f, loadErr 
	    if noReturn then
	        f, loadErr = loadstring(path)
	    else
	        f, loadErr = loadstring("return " .. path)
	    end
	    if not f then
	        logToFile("[ModManager] safeEval load error: " .. tostring(loadErr))
	        return false, loadErr
	    end

	    local ok, result = pcall(f)
	    if not ok then
	        logToFile("[ModManager] safeEval runtime error: " .. tostring(result))
	        return false, result
	    end

	    return true, result
	end

	function ModManager.replaceSlashes(input_str, replacement)
	    replacement = replacement or ""  -- Default: remove slashes
	    return string.gsub(input_str, "/", replacement)
	end

	function ModManager.showToast(message, title, opt)
	    if not message then
	    	return ModManager.showToast("ModManager.showToast(message[string], title[string], opt[table])")
	    end
	    if type(opt) ~= "table" then
	        opt = { "OK" }
	    end
	    
	    title = title or "Info"
	    
	    -- Attempt native toast first
	    if native.showAlert then
	        native.showAlert(title, message, opt)
	    else
	    	main.interface:open({
				id = "message",
				title = "Toast",
				text = message
			})
	    end
	    
	    logToFile("[TOAST] "..message)
	end

	function ModManager.exportModList()
	    local path = system.pathForFile("modlist.txt", system.DocumentsDirectory)
	    local file = io.open(path, "w")
	    
	    if not file then
	        ModManager.showToast("Failed to save modlist!")
	        return
	    end
	    
	    file:write("=== ACTIVE MODS ===\n")
	    for _, items in pairs(ModManager.loadedMods) do
	        file:write(string.format("\n[%s]\n", items.name))
	        
	    end
	    
	    file:close()
	    ModManager.showToast("Modlist saved to documents")
	    logToFile("[EXPORT] Modlist saved to "..path)
	end

	-- Added: 1.1.0
	function ModManager.isVersionSufficient(requiredVersion, currentVersion)
	    -- Return true if no required version is specified
	    if not requiredVersion or requiredVersion == "" then return true end
	    
	    -- Return false if current version doesn't exist
	    if not currentVersion or currentVersion == "" then return false end

	    -- Split version strings into numeric components
	    local function splitVersion(version)
	        local parts = {}
	        for part in string.gmatch(version, "%d+") do
	            table.insert(parts, tonumber(part))
	        end
	        return parts
	    end

	    local reqParts = splitVersion(requiredVersion)
	    local curParts = splitVersion(currentVersion)

	    -- Compare each component
	    for i = 1, math.max(#reqParts, #curParts) do
	        local req = reqParts[i] or 0
	        local cur = curParts[i] or 0

	        if req > cur then
	            return false  -- Current version is insufficient
	        elseif req < cur then
	            return true   -- Current version exceeds requirement
	        end
	        -- If equal, skip
	    end

	    return true  -- Versions are exactly equal
	end


	-- =========== Modder-friendly API
	function ModManager.regFuncOverride(category, funcData, label)
	    label = label or "unnamed"
	    
	    if type(funcData) ~= "table" then
	        logToFile("[ModManager] ERROR: funcData must be a table ("..label..")")
	        return
	    end
	    
	    -- Check if category exists
	    if not ModManager.funccat[category] then
	        local available = {}
	        for _, cat in pairs(ModManager.funccat) do
	            table.insert(available, cat)
	        end
	        table.sort(available)
	        
	        logToFile(string.format(
	            "[ModManager] ERROR (%s): Invalid category '%s'\n"..
	            "Available: %s\n"..
	            "Did you mean? Or call ModManager.extendFuncRoute('your.path', '%s')",
	            label, category, table.concat(available, ", "), category
	        ))
	        return
	    end

	    -- Initialize mods table for this category if needed
	    if not ModManager.funcOverride[category] then
	        ModManager.funcOverride[category] = {}
	    end
	    
	    for funcName, newFunc in pairs(funcData) do
	        ModManager.funcOverride[category][funcName] = newFunc
	        logToFile(string.format(
	            "[ModManager] Registered function '%s' in category '%s' (%s)",
	            funcName, category, label
	        ))
	    end
	end

	function ModManager.register(category, data, label) -- "drink", {} , "MOD Kewl"
	    -- Input validation
	    label = label or "unnamed_mod"

	    if type(data) ~= "table" then
	        logToFile("[ModManager] ERROR: Data must be a table ("..label..")")
	        return
	    end
	    
	    -- Check if category exists
	    if not ModManager.category[category] then
	        local available = {}
	        for _, cat in pairs(ModManager.category) do
	            table.insert(available, cat)
	        end
	        table.sort(available)
	        
	        logToFile(string.format(
	            "[ModManager] ERROR (%s): Invalid category '%s'\n"..
	            "Available: %s\n"..
	            "Did you mean? Or call ModManager.extendRoute('your.path', '%s')",
	            label, category, table.concat(available, ", "), category
	        ))
	        return
	    end

	    -- Initialize mods table for this category if needed
	    if not ModManager.mods[category] then
	        ModManager.mods[category] = {}
	    end
	    
	    -- Filter and insert valid data
	    local filteredData = {}
	    for _, item in pairs(data) do
	        if item and (item.id or item.name) then
	            table.insert(filteredData, item)
	        end
	    end
	  
	    for _, cleanData in pairs(filteredData) do
		    -- Conflict check
	    	local key = cleanData.id or cleanData.name
	        if key then
	            if conflictTracker[key] then
	                -- ModManager.showToast(string.format("CONFLICT: %s overwrites %s", label, key))
	                logToFile(string.format(
	                    "[CONFLICT] %s -> %s (previously by %s)",
	                    label, key, conflictTracker[key]
	                ))
	            end
	            conflictTracker[key] = label
	        end
	        table.insert(ModManager.mods[category], cleanData)
	    end
	    
	    logToFile(string.format(
	        "[ModManager] Registered %d/%s entry to '%s' (Mod Name: %s)",
	        #filteredData,
	        tostring(#data) or "n",
	        category,
	        label
	    ))
	end


	-- =========== Extend the Routing
	function ModManager.extendFuncRoute(path, category)
	    if type(path) == "string" and type(category) == "string" then
	        ModManager.funcroute[path] = category
	        ModManager.funccat[category] = path
	        logToFile("[ModManager] Mapped '"..path.."' → function category '"..category.."' | '".. category .."' → to path'"..path.."'")
	    else
	        logToFile("[ModManager.extendFuncRoute] WARNING: Invalid route extension - both arguments must be strings")
	    end
	end

	function ModManager.extendRoute(path, category) -- "lib.items.drink", "drink"
	    if type(path) == "string" and type(category) == "string" then
	        -- Add to path→category mapping
	        ModManager.routing[path] = category
	        
	        -- Check if category exist
	        if not ModManager.category then
	        	ModManager.category = {}
	        end

	        -- Add to category→paths mapping
	        ModManager.category[category] = path
	        
	        logToFile("[ModManager] Added route: "..path.." → "..category)
	        logToFile("[ModManager] Added category: "..category.." → "..path)
	    else
	        logToFile("[ModManager.extendRoute] WARNING: Invalid route extension - both arguments must be strings")
	    end
	end

	-- init mods routing for category
	function ModManager.catroute()
	    if ModManager.category then
	        ModManager.category = {}
	    end
	    
	    for path, category in pairs(ModManager.routing) do
	        ModManager.category[category] = path
	    end

	    logToFile("[ModManager] categories has been setup")
	end
]])


write("reinternal/utility.lua", [[
	function setupModDirectories(folders, files)
		local basePath = system.pathForFile("", system.DocumentsDirectory)

		if not folders and not files then
			logToFile("[setupModDirectories] ❌ inputs[folders|files] nil")
			return
		end
		
		if type(folders) ~= "table" and type(files) ~= "table" then
			logToFile("[setupModDirectories] ❌ inputs[folders|files] is not a table")
			return
		end
		
		-- Create folders
		for _, folder in ipairs(folders) do
			local fullPath = basePath .. "/" .. folder
			if not lfs.attributes(fullPath) then
				local success, err = lfs.mkdir(fullPath)
				if not success then
					logToFile("[setupModDirectories] ❌ Failed to create '"..folder.."': "..tostring(err))
					return false
				end
				logToFile("[setupModDirectories] ✔ Created directory: "..folder)
			end
		end
		
		-- Create files (only if they don't exist)
		for _, file in ipairs(files) do
			local fullPath = basePath .. "/" .. file.path
			if not io.open(fullPath, "r") then
				local f = io.open(fullPath, "w")
				if f then
					f:write(file.content)
					f:close()
					logToFile("[setupModDirectories] ✔ Created file: "..file.path)
				else
					logToFile("[setupModDirectories] ❌ Failed to create file: "..file.path)
					return false
				end
			end
		end
		
		return true
	end

	function includes(s, substring)
		return string.find(s, substring, 1, true) ~= nil
	end

	function endswith(s, suffix)
		return string.sub(s, -#suffix) == suffix
	end

	function startswith(s, prefix)
		return string.sub(s, 1, #prefix) == prefix
	end

	function tableContains(tbl, item)
		for _, value in pairs(tbl) do
			if value == item then
				return true
			end
		end
		return false
	end

	function getModPath(originalPath)
		-- Check if path contains "modded_assets/"
		if not includes(originalPath, "modded_assets/") then
			return nil  -- Not a mod path
		end

		-- Extract everything after "modded_assets/"
		local modRelativePath = originalPath:match("modded_assets/(.+)")
		
		-- Rebuild full path in DocumentsDirectory
		return system.pathForFile("angel_mod/modlist/" .. modRelativePath, system.DocumentsDirectory)
	end

	function dump(tbl, maxDepth)
		if type(tbl) ~= "table" then
			return tbl
		end
		maxDepth = maxDepth or 5

		local function dumpTable(tbl, depth, maxDepth)
			if depth > maxDepth then
				return "default table: " .. tostring(tbl)
			end

			local nl = "\n"
			local eqm = "\""

			local result = "{" .. nl
			local indent = string.rep("  ", depth)


			for k, v in pairs(tbl) do
				result = result .. indent .. "[" .. tostring(k) .. "] = "

				if type(v) == "table" then
					result = result .. dumpTable(v, depth + 1, maxDepth)
				elseif type(v) == "string" then
					result = result .. eqm .. tostring(v) .. eqm
				else
					result = result .. tostring(v)
				end

				result = result .. "," .. nl
			end

			result = result .. string.rep("  ", depth - 1) .. "}"
			return result
		end

		return dumpTable(tbl, 1, maxDepth)
	end


	function wtf(filename, message)
		local path = system.pathForFile(filename .. ".txt" or "unnamed.txt", system.DocumentsDirectory)
		local file = io.open(path, "a") -- Append mode
		if file then
			if type(message) == "table" then				
				file:write("\n\n" .. tostring(dump(message)) .. "\n\n")
				io.close(file)
			else
				file:write(tostring(message) .. " \n\n")
				io.close(file)
			end
		end
	end
		
			
	--- Helper: Checks if a table is an array (sequential numeric indices starting at 1)
	--- @param t table The table to check
	--- @return boolean True if the table is an array
	function isArray(t)
	    if type(t) ~= "table" then return false end
	    local count = 0
	    for k, _ in pairs(t) do
	        if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
	            return false
	        end
	        count = count + 1
	    end
	    -- Check if indices are sequential (no gaps)
	    for i = 1, count do
	        if t[i] == nil then
	            return false
	        end
	    end
	    return true
	end

	--- Helper: Appends array items from source to destination
	--- @param dest table Destination array
	--- @param src table Source array
	function appendArray(dest, src)
	    for _, item in ipairs(src) do
	        table.insert(dest, item)
	    end
	end

	--- Deep-merges tables, recursively. Last value wins on conflicts.
	--- Arrays are concatenated instead of having indices overwritten.
	--- @param ... Tables to merge (rightmost has highest priority for non-arrays)
	--- @return Merged table
	function table.js.merge(...)
	    local result = {}
	    for i = 1, select("#", ...) do
	        local tbl = select(i, ...)
	        if type(tbl) == "table" and tbl ~= nil then
	            for k, v in pairs(tbl) do
	                if type(v) == "table" and type(result[k]) == "table" then
	                    -- Check if both are arrays
	                    if isArray(v) and isArray(result[k]) then
	                        -- Create a new array combining both
	                        local merged = {}
	                        appendArray(merged, result[k])
	                        appendArray(merged, v)
	                        result[k] = merged
	                    else
	                        result[k] = table.js.merge(result[k], v)  -- Recurse
	                    end
	                else
	                    result[k] = v  -- Overwrite (or set new key)
	                end
	            end
	        end
	    end
	    return result
	end

	--- Deep-merges tables but errors on type clashes.
	--- Arrays are concatenated instead of having indices overwritten.
	--- @param ... Tables to merge
	--- @return Merged table
	--- @error If types conflict (e.g., string vs table) for non-array values
	function table.js.safeMerge(...)
	    local result = {}
	    for i = 1, select("#", ...) do
	        local tbl = select(i, ...)
	        if type(tbl) == "table" and tbl ~= nil then
	            for k, v in pairs(tbl) do
	                if type(v) == "table" and type(result[k]) == "table" then
	                    -- Check if both are arrays
	                    if isArray(v) and isArray(result[k]) then
	                        -- Create a new array combining both
	                        local merged = {}
	                        appendArray(merged, result[k])
	                        appendArray(merged, v)
	                        result[k] = merged
	                    else
	                        result[k] = table.js.safeMerge(result[k], v)  -- Recurse
	                    end
	                elseif result[k] ~= nil and type(v) ~= type(result[k]) then
	                    error(string.format(
					        "Type clash at key '%s': expected %s, got %s",
					        k, type(result[k]), type(v)
					    ))
					    return {}
	                else
	                    result[k] = v
	                end
	            end
	        end
	    end
	    return result
	end

	--- Safely fetches nested keys using a dot-delimited path.
	--- @param tbl table The root table to traverse.
	--- @param path string The path (e.g., "item.player.data").
	--- @return any|nil The value or nil if not found.
	function table.safeGet(tbl, path)
	    if type(tbl) ~= "table" then return nil end
	    local keys = {}
	    for key in path:gmatch("([^.]+)") do  -- Split by dots
	        table.insert(keys, key)
	    end
	    for _, key in ipairs(keys) do
	        if type(tbl) ~= "table" then return nil end
	        tbl = tbl[key]
	    end
	    return tbl
	end

	-- ====== table utilities 
	function table.js.values(tbl)
	    if type(tbl) ~= "table" then return tbl end
	    local values = {}
	    for _, v in pairs(tbl) do table.insert(values, v) end
	    return values
	end

	function table.js.keys(tbl)
	    if type(tbl) ~= "table" then return tbl end
	    local keys = {}
	    for k in pairs(tbl) do table.insert(keys, k) end
	    return keys
	end

	function table.js.find(tbl, fn)
	    for k, v in pairs(tbl) do
	        if fn(v, k) then return v end
	    end
	end

	function table.js.filter(tbl, fn)
	    local result = {}
	    for k, v in pairs(tbl) do
	        if fn(v, k) then result[k] = v end
	    end
	    return result
	end

	function table.js.map(tbl, fn)
	    local result = {}
	    for k, v in pairs(tbl) do
	        result[k] = fn(v, k)
	    end
	    return result
	end

	function table.js.findIndex(tbl, predicate, usePairs)
	    local iterator = usePairs and pairs or ipairs
	    for k, v in iterator(tbl) do
	        if predicate(v, k, tbl) then
	            return usePairs and k or tonumber(k)
	        end
	    end
	    return nil
	end	
		
	function ensurePath(path)
	    local current = ""
	    for part in path:gmatch("[^/]+") do
	        current = current .. "/" .. part
	        lfs.mkdir(current)
	    end
	end

	function tableContains(tbl, item)
	    if type(tbl) ~= "table" then
	        return false
	    end
	    for _, v in pairs(tbl) do
	        if v == item then
	            return true
	        end
	    end
	    return false
	end
]])


-- write("reinternal/.lua", [[]])
-- write("reinternal/.lua", [[]])


write("coreVersion.lua", [[
	return {
		version = 150
	}
]])


end