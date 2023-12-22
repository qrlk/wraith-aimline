require "lib.moonloader"

script_name("wraith-aimline")
script_author("qrlk")
script_description("aimline render cut from https://github.com/qrlk/wraith.lua")
-- made for https://www.blast.hk/threads/193650/
script_url("https://github.com/qrlk/wraith-aimline")
script_version("21.12.2023-dev1")

-- https://github.com/qrlk/qrlk.lua.moonloader
local enable_sentry = true -- false to disable error reports to sentry.io
if enable_sentry then
    local sentry_loaded, Sentry =
        pcall(
            loadstring,
            [=[return {init=function(a)local b,c,d=string.match(a.dsn,"https://(.+)@(.+)/(%d+)")local e=string.format("https://%s/api/%d/store/?sentry_key=%s&sentry_version=7&sentry_data=",c,d,b)local f=string.format("local target_id = %d local target_name = \"%s\" local target_path = \"%s\" local sentry_url = \"%s\"\n",thisScript().id,thisScript().name,thisScript().path:gsub("\\","\\\\"),e)..[[require"lib.moonloader"script_name("sentry-error-reporter-for: "..target_name.." (ID: "..target_id..")")script_description("Этот скрипт перехватывает вылеты скрипта '"..target_name.." (ID: "..target_id..")".."' и отправляет их в систему мониторинга ошибок Sentry.")local a=require"encoding"a.default="CP1251"local b=a.UTF8;local c="moonloader"function getVolumeSerial()local d=require"ffi"d.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local e=d.new("unsigned long[1]",0)d.C.GetVolumeInformationA(nil,nil,0,e,nil,nil,nil,0)e=e[0]return e end;function getNick()local f,g=pcall(function()local f,h=sampGetPlayerIdByCharHandle(PLAYER_PED)return sampGetPlayerNickname(h)end)if f then return g else return"unknown"end end;function getRealPath(i)if doesFileExist(i)then return i end;local j=-1;local k=getWorkingDirectory()while j*-1~=string.len(i)+1 do local l=string.sub(i,0,j)local m,n=string.find(string.sub(k,-string.len(l),-1),l)if m and n then return k:sub(0,-1*(m+string.len(l)))..i end;j=j-1 end;return i end;function url_encode(o)if o then o=o:gsub("\n","\r\n")o=o:gsub("([^%w %-%_%.%~])",function(p)return("%%%02X"):format(string.byte(p))end)o=o:gsub(" ","+")end;return o end;function parseType(q)local r=q:match("([^\n]*)\n?")local s=r:match("^.+:%d+: (.+)")return s or"Exception"end;function parseStacktrace(q)local t={frames={}}local u={}for v in q:gmatch("([^\n]*)\n?")do local w,x=v:match("^	*(.:.-):(%d+):")if not w then w,x=v:match("^	*%.%.%.(.-):(%d+):")if w then w=getRealPath(w)end end;if w and x then x=tonumber(x)local y={in_app=target_path==w,abs_path=w,filename=w:match("^.+\\(.+)$"),lineno=x}if x~=0 then y["pre_context"]={fileLine(w,x-3),fileLine(w,x-2),fileLine(w,x-1)}y["context_line"]=fileLine(w,x)y["post_context"]={fileLine(w,x+1),fileLine(w,x+2),fileLine(w,x+3)}end;local z=v:match("in function '(.-)'")if z then y["function"]=z else local A,B=v:match("in function <%.* *(.-):(%d+)>")if A and B then y["function"]=fileLine(getRealPath(A),B)else if#u==0 then y["function"]=q:match("%[C%]: in function '(.-)'\n")end end end;table.insert(u,y)end end;for j=#u,1,-1 do table.insert(t.frames,u[j])end;if#t.frames==0 then return nil end;return t end;function fileLine(C,D)D=tonumber(D)if doesFileExist(C)then local E=0;for v in io.lines(C)do E=E+1;if E==D then return v end end;return nil else return C..D end end;function onSystemMessage(q,type,i)if i and type==3 and i.id==target_id and i.name==target_name and i.path==target_path and not q:find("Script died due to an error.")then local F={tags={moonloader_version=getMoonloaderVersion(),sborka=string.match(getGameDirectory(),".+\\(.-)$")},level="error",exception={values={{type=parseType(q),value=q,mechanism={type="generic",handled=false},stacktrace=parseStacktrace(q)}}},environment="production",logger=c.." (no sampfuncs)",release=i.name.."@"..i.version,extra={uptime=os.clock()},user={id=getVolumeSerial()},sdk={name="qrlk.lua.moonloader",version="0.0.0"}}if isSampAvailable()and isSampfuncsLoaded()then F.logger=c;F.user.username=getNick().."@"..sampGetCurrentServerAddress()F.tags.game_state=sampGetGamestate()F.tags.server=sampGetCurrentServerAddress()F.tags.server_name=sampGetCurrentServerName()else end;print(downloadUrlToFile(sentry_url..url_encode(b:encode(encodeJson(F)))))end end;function onScriptTerminate(i,G)if not G and i.id==target_id then lua_thread.create(function()print("скрипт "..target_name.." (ID: "..target_id..")".."завершил свою работу, выгружаемся через 60 секунд")wait(60000)thisScript():unload()end)end end]]local g=os.tmpname()local h=io.open(g,"w+")h:write(f)h:close()script.load(g)os.remove(g)end}]=]
        )
    if sentry_loaded and Sentry then
        pcall(
            Sentry().init,
            {
                dsn = "https://6912ae70fe8bbfe151be80b1aaf6eb25@o1272228.ingest.sentry.io/4506433063682048"
            }
        )
    end
end

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater =
        pcall(
            loadstring,
            [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]]
        )
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url =
                "https://raw.githubusercontent.com/qrlk/wraith-aimline/master/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/qrlk/wraith-aimline/"
        end
    end
end

--- start
local inicfg = require "inicfg"
local sampev = require "lib.samp.events"
local aspectRatioKey = sampev.MODULEINFO.version >= 3 and 'aspectRatio' or 'unknown'

local font_flag = require("moonloader").font_flag
local my_font = renderCreateFont("Verdana", 12, font_flag.BOLD + font_flag.SHADOW)

local tempThreads = {}
local mod_submenus_sa = {}

local cfg =
    inicfg.load(
        {
            options = {
                welcomeMessage = true,
                debug = true,
                debugNeedAimLines = true,
                debugNeedAimLinesFull = true,
                debugNeedAimLinesLOS = true,
                debugNeedAimLine = true,
                debugNeedAimLineFull = true,
                debugNeedAimLineLOS = true,
                debugNeedToDrawAngles = false,
                debugNeedToTweakAngles = false,
                debugNeedToSaveAngles = false
            }
        },
        "wraith-aimline"
    )

function saveCfg()
    inicfg.save(cfg, "wraith-aimline")
end

saveCfg()

local DEBUG_NEED_TO_EMULATE_CAMERA = false
local DEBUG_NEED_TO_EMULATE_CAMERA_BY_ID = 3
--

local playersAimData = {}
local playerPedAimData = false

-- trying to ulitize aspectRatio property from aimSync

local aspectRatios = {
    [63] = "5:4",    -- 1,25
    [85] = "4:3",    -- 1,333333333333333
    [98] = "43:18",  -- 2,388888888888889
    [127] = "3:2",   -- 1,5
    [143] = "25:16", -- 1,5625
    [153] = "16:10", -- 1,6
    [169] = "5:3",   -- 1,666666666666667
    -- [196] = "16:9 (alt)", -- 1,771084337349398
    [198] = "16:9"   -- 1,777777777777778
}

local approximateAspectRatio = {
    {
        ["start"] = 63 - 11,
        ["end"] = 63 + 11,
        ["value"] = "5:4"
    },
    {
        ["start"] = 85 - 11,
        ["end"] = 85 + 6.5,
        ["value"] = "4:3"
    },
    {
        ["start"] = 98 - 6.5,
        ["end"] = 98 + 14,
        ["value"] = "43:18"
    },
    {
        ["start"] = 127 - 14,
        ["end"] = 127 + 8,
        ["value"] = "3:2"
    },
    {
        ["start"] = 143 - 8,
        ["end"] = 143 + 5,
        ["value"] = "25:16"
    },
    {
        ["start"] = 153 - 5,
        ["end"] = 153 + 8,
        ["value"] = "16:10"
    },
    {
        ["start"] = 169 - 8,
        ["end"] = 169 + 14.5,
        ["value"] = "5:3"
    },
    {
        ["start"] = 198 - 14.5,
        ["end"] = 198 + 14.5,
        ["value"] = "16:9"
    }
}

function getRealAspectRatioByWeirdValue(aspectRatio)
    local hit = false
    if aspectRatios[aspectRatio] ~= nil then
        hit = true
        return hit, aspectRatios[aspectRatio]
    end
    for k, v in pairs(approximateAspectRatio) do
        if aspectRatio > v["start"] and aspectRatio < v["end"] then
            return hit, v["value"]
        end
    end
    return false, "unknown"
end

-- 2. 720x480 - Aspect Ratio: 3:2  127

-- 1. 640x480 - Aspect Ratio: 4:3 85
-- 4. 800x600 - Aspect Ratio: 4:3 85
-- 5. 1024x768 - Aspect Ratio: 4:3 85
-- 6. 1152x864 - Aspect Ratio: 4:3 85
-- 11. 1280x960 - Aspect Ratio: 4:3 85
-- 15. 1440x1080 - Aspect Ratio: 4:3 85
-- 18. 1600x1200 - Aspect Ratio: 4:3 85
-- 24. 1920x1440 - Aspect Ratio: 4:3 85

-- 9. 1280x768 - Aspect Ratio: 5:3 169

-- 3. 720x576 - Aspect Ratio: 5:4 63
-- 12. 1280x1024 - Aspect Ratio: 5:4 63

-- 7. 1176x664 - Aspect Ratio: 16:9 196
-- 13. 1360x768 - Aspect Ratio: 16:9 196

-- 8. 1280x720 - Aspect Ratio: 16:9 198
-- 14. 1366x768 - Aspect Ratio: 16:9 198
-- 16. 1600x900 - Aspect Ratio: 16:9 198
-- 22. 1920x1080 - Aspect Ratio: 16:9 198
-- 25. 2560x1440 - Aspect Ratio: 16:9 198

-- 26. 3440x1440 - Aspect Ratio: 43:18 98 2,38 2,388888888888889 2,365253077975376
-- 27. 2580x1080 - Aspect Ratio: 43:18 98

-- 17. 1600x1024 - Aspect Ratio: 25:16 143

-- 10. 1280x800 - Aspect Ratio: 16:10 153
-- 21. 1680x1050 - Aspect Ratio: 16:10 153
-- 23. 1920x1200 - Aspect Ratio: 16:10 153

-- thi debug ini is not saved by default and formally loads for debugging purposes only
-- if the values change in possible updates, the name of the .ini file will be changed

local angelsIniFileName = "wraith-aimline-debug-21122023"
local anglesPerAspectRatio =
    inicfg.load(
        {
            ["5:4"] = {
                curxy = -0.04,
                curz = 0.105,
                curARxy = -0.027,
                curARz = 0.07,
                curRFxy = -0.019,
                curRFz = 0.047
            },
            ["4:3"] = {
                curxy = -0.044,
                curz = 0.109,
                curARxy = -0.03,
                curARz = 0.07,
                curRFxy = -0.019,
                curRFz = 0.047
            },
            ["43:18"] = {
                curxy = -0.079,
                curz = 0.104,
                curARxy = -0.052,
                curARz = 0.07,
                curRFxy = -0.034,
                curRFz = 0.047
            },
            ["3:2"] = {
                curxy = -0.047,
                curz = 0.105,
                curARxy = -0.033,
                curARz = 0.07,
                curRFxy = -0.022,
                curRFz = 0.048
            },
            ["25:16"] = {
                curxy = -0.049,
                curz = 0.105,
                curARxy = -0.033,
                curARz = 0.07,
                curRFxy = -0.023,
                curRFz = 0.048
            },
            ["16:10"] = {
                curxy = -0.05,
                curz = 0.105,
                curARxy = -0.036,
                curARz = 0.07,
                curRFxy = -0.024,
                curRFz = 0.047
            },
            ["5:3"] = {
                curxy = -0.052,
                curz = 0.105,
                curARxy = -0.036,
                curARz = 0.07,
                curRFxy = -0.024,
                curRFz = 0.047
            },
            ["16:9"] = {
                curxy = -0.056,
                curz = 0.104,
                curARxy = -0.037,
                curARz = 0.07,
                curRFxy = -0.026,
                curRFz = 0.047
            },
            -- need to investigate the issue with 16:9 clients without widescreenfix
            -- It’s not clear how to distinguish people with a 16:9 fix from those who don’t have it
            -- if widescreen fix is not installed but widescreen mode is enabled in the settings, the values should be like this:

            ["16:9noWSF"] = {
                curxy = -0.043,
                curz = 0.079,
                curARxy = -0.028,
                curARz = 0.052,
                curRFxy = -0.019,
                curRFz = 0.035
            }
        },
        angelsIniFileName
    )

function getCurrentWeaponAngle(aspect, weapon)
    if aspect == "unknown" then
        aspect = "4:3"
    end

    if (weapon >= 22 and weapon <= 29) or weapon == 32 then
        return { anglesPerAspectRatio[aspect].curxy, anglesPerAspectRatio[aspect].curz }
    elseif weapon == 30 or weapon == 31 then
        return { anglesPerAspectRatio[aspect].curARxy, anglesPerAspectRatio[aspect].curARz }
    elseif weapon == 33 then
        return { anglesPerAspectRatio[aspect].curRFxy, anglesPerAspectRatio[aspect].curRFz }
    end

    return { 0.0, 0.0 }
end

function openLink(link)
    local ffi = require "ffi"
    ffi.cdef [[
                void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
                uint32_t __stdcall CoInitializeEx(void*, uint32_t);
            ]]
    local shell32 = ffi.load "Shell32"
    local ole32 = ffi.load "Ole32"
    ole32.CoInitializeEx(nil, 2 + 4) -- COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE
    sampAddChatMessage("Пытаемся открыть в браузере, сверните игру: " .. link, -1)
    print(shell32.ShellExecuteA(nil, "open", link, nil, nil, 1))
end

function checkWraith()
    openLink('https://www.blast.hk/threads/198111/')
end

function checkWraithXiaomi()
    openLink('https://www.blast.hk/threads/198256/')
end

function callMenu(id, pos, title)
    while sampIsDialogActive() do
        wait(0)
    end
    updateMenu()
    submenus_show(
        mod_submenus_sa,
        "{348cb2}/wraith-aimline v." .. thisScript().version,
        "Выбрать",
        "Закрыть",
        "Назад",
        callMenu,
        id,
        pos
    )
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end

    -- вырежи тут, если хочешь отключить проверку обновлений
    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    -- вырежи тут, если хочешь отключить проверку обновлений

    sampRegisterChatCommand(
        "wraith-aimline",
        function()
            table.insert(tempThreads, lua_thread.create(callMenu))
        end
    )

    while sampGetCurrentServerName() == "SA-MP" do
        wait(500)
    end

    if cfg.options.welcomeMessage then
        sampAddChatMessage(
            "{348cb2}/wraith-aimline v" ..
            thisScript().version .. " активирован! Меню: {FFFF00}/wraith-aimline{348cb2}. Автор: qrlk.",
            0x7ef3fa
        )
        sampAddChatMessage(
            "{348cb2}Рендер линии прицела вырезан из {7ef3fa}wraith.lua -> {FFFF00}/checkwraith{348cb2}",
            0x7ef3fa
        )
    end
    sampRegisterChatCommand("checkwraith", checkWraith)

    while true do
        wait(0)

        if cfg.options.debug and cfg.options.debugNeedAimLines then
            for nick, data in pairs(playersAimData) do
                if sampIsPlayerConnected(data.playerId) then
                    local result, ped = sampGetCharHandleBySampPlayerId(data.playerId)
                    if result and sampGetPlayerNickname(data.playerId) == nick then
                        if cfg.options.debugNeedAimLines and data.camMode ~= 4 then
                            local aspects = { data.realAspect }

                            if data.realAspect == "16:9" then
                                aspects[2] = "16:9noWSF"
                            end

                            for k, aspect in pairs(aspects) do
                                local p1x, p1y, p1z, p2x, p2y, p2z = processAimLine(data, aspect)

                                if (data.camMode ~= 4 and (readMemory(getCharPointer(ped) + 0x528, 1, false) == 19 or readMemory(getCharPointer(ped) + 0x528, 1, false) == 27)) or data.camMode == 55 then
                                    if cfg.options.debugNeedAimLinesFull then
                                        drawDebugLine(p1x, p1y, p1z, p2x, p2y, p2z, 0xff00ffff, 0xffffffff, 0xff348cb2)
                                    end

                                    if cfg.options.debugNeedAimLinesLOS then
                                        local result, colPoint =
                                            processLineOfSight(
                                                p1x,
                                                p1y,
                                                p1z,
                                                p2x,
                                                p2y,
                                                p2z,
                                                true,
                                                true,
                                                true,
                                                true,
                                                true,
                                                true,
                                                true,
                                                true
                                            )
                                        if result then
                                            drawDebugLine(
                                                p1x,
                                                p1y,
                                                p1z,
                                                colPoint.pos[1],
                                                colPoint.pos[2],
                                                colPoint.pos[3],
                                                0xff004cff,
                                                0xff004cff,
                                                0xff004cff
                                            )
                                        end
                                    end
                                end
                            end
                        end
                    else
                        playersAimData[nick] = nil
                    end
                else
                    playersAimData[nick] = nil
                end
            end
        end

        if cfg.options.debug and cfg.options.debugNeedAimLine and playerPedAimData then
            if cfg.options.debug and cfg.options.debugNeedToTweakAngles then
                processDebugOffset(playerPedAimData.realAspect, playerPedAimData.weapon)
            end

            if cfg.options.debugNeedAimLine then
                local aspects = { playerPedAimData.realAspect }

                if playerPedAimData.realAspect == "16:9" then
                    aspects[2] = "16:9noWSF"
                end

                for k, aspect in pairs(aspects) do
                    local p1x, p1y, p1z, p2x, p2y, p2z = processAimLine(playerPedAimData, aspect)

                    if cfg.options.debugNeedAimLineFull then
                        drawDebugLine(p1x, p1y, p1z, p2x, p2y, p2z, 0xff00ffff, 0xffffffff, 0xff348cb2)
                    end

                    if cfg.options.debugNeedAimLineLOS then
                        local result, colPoint =
                            processLineOfSight(
                                p1x,
                                p1y,
                                p1z,
                                p2x,
                                p2y,
                                p2z,
                                true,
                                true,
                                true,
                                true,
                                true,
                                true,
                                true,
                                true
                            )
                        if result then
                            drawDebugLine(
                                p1x,
                                p1y,
                                p1z,
                                colPoint.pos[1],
                                colPoint.pos[2],
                                colPoint.pos[3],
                                0xff004cff,
                                0xff004cff,
                                0xff004cff
                            )
                        end
                    end
                end
            end
        end
    end

    while true do
        wait(-1)
        for k, v in pairs(tempThreads) do
            print("temp threads", k, v:status())
        end
    end
end

function processAimLine(data, aspect)
    -- data.weapon
    local currentWeaponAngle = getCurrentWeaponAngle(aspect, data.weapon)

    if cfg.options.debug and cfg.options.debugNeedToDrawAngles then
        renderFontDrawText(
            my_font,
            string.format(
                "a: %s || w: %s || curxy: %s || curz: %s",
                aspect,
                data.weapon,
                currentWeaponAngle[1],
                currentWeaponAngle[2]
            ),
            100,
            300,
            0xFFFFFFFF
        )
    end

    local frontAngleXY = math.atan2(-data.camFrontY, -data.camFrontX)
    local frontAngleZ = 1.5708 - math.acos(data.camFrontZ)

    -- a small offset is needed because the camera is behind the player model and it cannot be ignored by processLineOfSight
    -- NOTE: https://github.com/THE-FYP/MoonAdditions/blob/659eb22d2217fd5870e8e1ead797a2175d314337/src/lua_general.cpp#L353

    local p1x =
        data.camPosX -
        2.5 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) * math.cos(frontAngleXY + currentWeaponAngle[1])
    local p1y =
        data.camPosY -
        2.5 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) * math.sin(frontAngleXY + currentWeaponAngle[1])
    local p1z = data.camPosZ - 2.5 * math.cos(1.5708 + frontAngleZ + currentWeaponAngle[2])

    local p2x =
        data.camPosX -
        250 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) * math.cos(frontAngleXY + currentWeaponAngle[1])
    local p2y =
        data.camPosY -
        250 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) * math.sin(frontAngleXY + currentWeaponAngle[1])
    local p2z = data.camPosZ - 250 * math.cos(1.5708 + frontAngleZ + currentWeaponAngle[2])

    return p1x, p1y, p1z, p2x, p2y, p2z
end

-- sampev

function sampev.onSendAimSync(data)
    if cfg.options.debug and cfg.options.debugNeedAimLine and data.camMode ~= 4 and data.camMode ~= 18 then
        local hit, realAspect = getRealAspectRatioByWeirdValue(data[aspectRatioKey])

        playerPedAimData = {
            camMode = data.camMode,
            camFrontX = data.camFront.x,
            camFrontY = data.camFront.y,
            camFrontZ = data.camFront.z,
            camPosX = data.camPos.x,
            camPosY = data.camPos.y,
            camPosZ = data.camPos.z,
            aimZ = data.aimZ,
            camExtZoom = data.camExtZoom,
            weaponState = data.weaponState,
            aspectRatio = data[aspectRatioKey],
            realAspectHit = hit,
            realAspect = realAspect,
            weapon = getCurrentCharWeapon(playerPed)
        }
    end
end

function sampev.onAimSync(playerId, data)
    if sampIsPlayerConnected(playerId) then
        local res, char = sampGetCharHandleBySampPlayerId(playerId)
        if res then
            local nick = sampGetPlayerNickname(playerId)
            local hit, realAspect = getRealAspectRatioByWeirdValue(data[aspectRatioKey])

            local playerAimData = {
                camMode = data.camMode,
                camFrontX = data.camFront.x,
                camFrontY = data.camFront.y,
                camFrontZ = data.camFront.z,
                camPosX = data.camPos.x,
                camPosY = data.camPos.y,
                camPosZ = data.camPos.z,
                aimZ = data.aimZ,
                camExtZoom = data.camExtZoom,
                weaponState = data.weaponState,
                aspectRatio = data[aspectRatioKey],
                playerId = playerId,
                realAspectHit = hit,
                realAspect = realAspect,
                weapon = getCurrentCharWeapon(char)
            }

            if cfg.options.debug and cfg.options.debugNeedAimLines then
                playersAimData[nick] = playerAimData
            end

            if cfg.options.debug and DEBUG_NEED_TO_EMULATE_CAMERA then
                local _, lId = sampGetPlayerIdByCharHandle(playerPed)
                if _ and lId == DEBUG_NEED_TO_EMULATE_CAMERA_BY_ID then
                    local p1x, p1y, p1z = data.camPos.x, data.camPos.y, data.camPos.z
                    local p2x, p2y, p2z =
                        data.camPos.x + data.camFront.x * 5,
                        data.camPos.y + data.camFront.y * 5,
                        data.camPos.z + data.camFront.z * 5
                    camPos(p1x, p1y, p1z, 0.0, 0.0, 0.0)
                    ponCameraPoint(p2x, p2y, p2z, 2)
                end
            end
        end
    end
end

-- debug
function saveDebugIniIfNeeded()
    if cfg.options.debug and cfg.options.debugNeedToSaveAngles then
        inicfg.save(anglesPerAspectRatio, angelsIniFileName)
    end
end

saveDebugIniIfNeeded()

function camPos(x, y, z, x1, y1, z1)
    setFixedCameraPosition(x, y, z, x1, y1, z1)
    print("setFixedCameraPosition: ", x, y, z, x1, y1, z1)
end

function ponCameraPoint(x, y, z, m)
    pointCameraAtPoint(x, y, z, m)
    print("pointCameraAtPoint: ", x, y, z, m)
end

function drawDebugLine(ax, ay, az, bx, by, bz, color1, color2, color3)
    local _1, x1, y1, z1 = convert3DCoordsToScreenEx(ax, ay, az)
    local _2, x2, y2, z2 = convert3DCoordsToScreenEx(bx, by, bz)
    if _1 and _2 and z1 > 0 and z2 > 0 then
        renderDrawPolygon(x1, y1, 10, 10, 10, 0.0, color1)
        renderDrawLine(x1, y1, x2, y2, 2, color2)
        renderDrawPolygon(x2, y2, 10, 10, 10, 0.0, color3)
    end
end

function processDebugOffset(aspect, weapon)
    if isKeyDown(0xA4) and (isKeyDown(0x25) or isKeyDown(0x26) or isKeyDown(0x27) or isKeyDown(0x28)) then
        local property1 = false
        local property2 = false

        if (weapon >= 22 and weapon <= 29) or weapon == 32 then
            property1 = "curxy"
            property2 = "curz"
        elseif weapon == 30 or weapon == 31 then
            property1 = "curARxy"
            property2 = "curARz"
        elseif weapon == 33 then
            property1 = "curRFxy"
            property2 = "curRFz"
        end

        if property1 and property2 then
            if isKeyDown(0x25) then
                -- left
                print(string.format("left"), 1, 1)
                anglesPerAspectRatio[aspect][property1] = anglesPerAspectRatio[aspect][property1] - 0.001
            elseif isKeyDown(0x26) then
                -- up
                print(string.format("up"), 1, 1)
                anglesPerAspectRatio[aspect][property2] = anglesPerAspectRatio[aspect][property2] + 0.001
            elseif isKeyDown(0x27) then
                -- right
                print(string.format("right"), 1, 1)
                anglesPerAspectRatio[aspect][property1] = anglesPerAspectRatio[aspect][property1] + 0.001
            elseif isKeyDown(0x28) then
                -- down
                print(string.format("down"), 1, 1)
                anglesPerAspectRatio[aspect][property2] = anglesPerAspectRatio[aspect][property2] - 0.001
            end

            saveDebugIniIfNeeded()
            wait(100)
        end
    end
end

-- menu

function createSimpleToggle(group, setting, text)
    return {
        title = text .. tostring(cfg[group][setting]),
        onclick = function()
            cfg[group][setting] = not cfg[group][setting]
            saveCfg()
        end
    }
end

function updateMenu()
    mod_submenus_sa = {
        {
            title = "Информация о скрипте",
            onclick = function()
                sampShowDialog(
                    0,
                    "{7ef3fa}/wraith-aimline v." .. thisScript().version,
                    "{ffffff}Рендер приблизительной линии прицела игроков.\n\n1. Перехватывает синхронизацию камеры.\n2. Пытается воспроизвести линию прицела.\n3. Работает на основе значения aspectRatio в aimSync.\n4. Для снайперской винтовки, рифлы, м4 и ак47 отдельные углы.",
                    "Окей"
                )
            end
        },
        {
            title = "Открыть скрипт, из которого был вырезан рендер",
            onclick = checkWraith
        },
        {
            title = "Открыть скрипт который показывает соотношение сторон",
            onclick = checkWraithXiaomi
        },
        {
            title = " "
        },
        createSimpleToggle("options", "debug", "Скрипт работает: "),
        {
            title = "Настройки",
            submenu = {
                {
                    title = "{AAAAAA}Рендеры всех игроков"
                },
                createSimpleToggle("options", "debugNeedAimLines", "Общий тогл: "),
                createSimpleToggle("options", "debugNeedAimLinesFull", "Показывать полную линию: "),
                createSimpleToggle("options", "debugNeedAimLinesLOS", "Показывать до столкновения: "),
                {
                    title = " "
                },
                {
                    title = "{AAAAAA}Рендер линии вашего персонажа"
                },
                createSimpleToggle("options", "debugNeedAimLine", "Общий тогл: "),
                createSimpleToggle("options", "debugNeedAimLineFull", "Показывать полную линию: "),
                createSimpleToggle("options", "debugNeedAimLineLOS", "Показывать до столкновения: "),
                {
                    title = " "
                },
                {
                    title = "{AAAAAA}Дебаг дебага (не трогать)"
                },
                createSimpleToggle("options", "debugNeedToDrawAngles", "Рендерить текущий угол: "),
                createSimpleToggle("options", "debugNeedToTweakAngles", "Менять углы (alt+стрелки): "),
                createSimpleToggle("options", "debugNeedToSaveAngles", "Сохранять измененные углы: ")
            }
        }
    }
end

--------------------------------------------------------------------------------
--------------------------------------3RD---------------------------------------
--------------------------------------------------------------------------------
-- made by FYP, modified by qrlk
function submenus_show(menu, caption, select_button, close_button, back_button, callback, start, pos)
    select_button, close_button, back_button = select_button or "Select", close_button or "Close", back_button or "Back"
    prev_menus = {}
    function display(menu, id, caption, start, pos)
        local string_list = {}
        for i, v in ipairs(menu) do
            table.insert(string_list, type(v.submenu) == "table" and v.title .. "  >>" or v.title)
        end
        wait(100)
        if not start then
            sampShowDialog(
                id,
                caption,
                table.concat(string_list, "\n"),
                select_button,
                (#prev_menus > 0) and back_button or close_button,
                4
            )
            if pos then
                sampSetCurrentDialogListItem(pos)
                if pos > 20 then
                    setVirtualKeyDown(40, true)
                    setVirtualKeyDown(40, false)
                    setVirtualKeyDown(38, true)
                    setVirtualKeyDown(38, false)
                end
            end
            pos = nil
        end

        repeat
            wait(0)
            local result, button, list = sampHasDialogRespond(id)
            if start then
                result, button, list = true, 1, start - 1
            end
            if result then
                if button == 1 and list ~= -1 then
                    local item = menu[list + 1]
                    if type(item.submenu) == "table" then
                        -- submenu
                        table.insert(
                            prev_menus,
                            {
                                menu = menu,
                                caption = caption,
                                id = list + 1
                            }
                        )
                        if type(item.onclick) == "function" then
                            item.onclick(menu, list + 1, item.submenu)
                        end
                        return display(
                            item.submenu,
                            id + 1,
                            item.submenu.title and item.submenu.title or item.title,
                            nil,
                            pos
                        )
                    elseif type(item.onclick) == "function" then
                        local result = item.onclick(menu, list + 1)
                        if not result then
                            if prev_menus and prev_menus[#prev_menus] and prev_menus[#prev_menus].id then
                                if callback then
                                    callback(prev_menus[#prev_menus].id, list, item.title)
                                end
                            end
                            return result
                        end
                        return display(menu, id, caption)
                    end
                else
                    -- if button == 0
                    if #prev_menus > 0 then
                        local prev_menu = prev_menus[#prev_menus]
                        prev_menus[#prev_menus] = nil
                        return display(prev_menu.menu, id - 1, prev_menu.caption, nil, prev_menu.id - 1)
                    end
                    return false
                end
            end
        until result
    end

    return display(menu, 31337, caption or menu.title, start, pos)
end
