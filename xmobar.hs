Config { font = "-misc-fixed-*-*-*-*-10-*-*-*-*-*-*-*"
       , additionalFonts = []
       , borderColor = "black"
       , border = TopB
       , bgColor = "black"
       , fgColor = "grey"
       , alpha = 255
       , position = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
       , textOffset = -1
       , iconOffset = -1
       , lowerOnStart = True
       , pickBroadest = False
       , persistent = False
       , hideOnStart = False
       , iconRoot = "."
       , allDesktops = True
       , overrideRedirect = True
       , commands = [ Run Weather "UNNT" [ "--template", "<skyCondition> | <fc=#4682B4><tempC></fc>°C | <fc=#4682B4><rh></fc>%"
                                         ] 36000
                    , Run DynNetwork     [ "--template" , "<dev>: <tx>kB/s|<rx>kB/s"
                                         , "--Low"      , "1000"       -- units: B/s
                                         , "--High"     , "5000"       -- units: B/s
                                         , "--low"      , "darkgreen"
                                         , "--normal"   , "darkorange"
                                         , "--high"     , "darkred"
                                         ] 10

                    , Run Cpu ["-L","50","-H","85","--low","darkgreen","--normal","darkorange","--high","darkred"] 10
                    , Run Memory ["-t","Mem: <usedratio>%"] 10
                    , Run Swap [] 10
                    , Run Com "uname" ["-s","-n"] "" 0
                    , Run Com "/home/ktak/.xmonad/volume.sh" [] "vol" 10
                    , Run Date           "<fc=darkgreen>%F (%a) %T</fc>" "date" 10
                    , Run Kbd            [ ("ru" , "<fc=#00008B>RU</fc>")
                                         , ("us"         , "<fc=#8B0000>US</fc>")
                                         ]
                    , Run Battery        [ "--template" , "Batt: <acstatus>"
                                         , "--Low"      , "10"        -- units: %
                                         , "--High"     , "80"        -- units: %
                                         , "--low"      , "darkred"
                                         , "--normal"   , "darkorange"
                                         , "--high"     , "darkgreen"
            
                                         , "--" -- battery specific options
                                                   -- discharging status
                                                   , "-o"	, "<left>% (<timeleft>)"
                                                   -- AC "on" status
                                                   , "-O"	, "<fc=#dAA520>Charging</fc>"
                                                   -- charged status
                                                   , "-i"	, "<fc=#006000>Charged</fc>"
                                         ] 50
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% | %battery% | %cpu% | %memory% * %swap% | %dynnetwork% }{ Vol: %vol% | %kbd% | %date% | %UNNT% | %uname%"
       }
