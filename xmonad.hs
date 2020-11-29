import qualified Data.Map        as M
import Data.Ratio
import XMonad
import XMonad.Util.Run (spawnPipe)
import XMonad.Layout.Combo
import XMonad.Layout.Grid
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Circle
import XMonad.Layout.MosaicAlt
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.SetWMName
import qualified XMonad.StackSet as W
import System.IO
import Control.Monad (liftM2)
import XMonad.Actions.CopyWindow

import XMonad.Actions.RotSlaves
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.XMonad

main = do
  _ <- spawnPipe myTrayRunner
  _ <- spawnPipe myNetworkApplet
  _ <- spawnPipe myScreenSaver
  -- _ <- spawnPipe myBackgroundInstaller
  xmproc <- spawnPipe myBar
  xmonad $ docks def
        { modMask             = mod4Mask -- Use Super instead of Alt
        , workspaces          = myWorkspaces
        , terminal            = "gnome-terminal"
        , normalBorderColor   = "black"
        , focusedBorderColor  = "grey"  
        , borderWidth         = 2
        , startupHook         = setWMName "LG3D" -- для совместимости определёных приложений, java например(IntelliJ IDEA)
        , manageHook          = myManageHook
        , layoutHook          = avoidStruts myLayouts
        , logHook             = dynamicLogWithPP xmobarPP
          { ppOutput = hPutStrLn xmproc
          , ppTitle = xmobarColor "green" "" . shorten 50
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "[" "]"
          , ppSep = "   "
          , ppWsSep = " "
          {-
          , ppLayout  = (\ x -> case x of
              "Spacing 6 Mosaic"                      -> "[:]"
              "Spacing 6 Mirror Tall"                 -> "[M]"
              "Spacing 6 Hinted Tabbed Simplest"      -> "[T]"
              "Spacing 6 Full"                        -> "[ ]"
              _                                       -> x )
          -}
          , ppHiddenNoWindows = showNamedWorkspaces
          }
        , keys = myKeys <+> keys def
        }
        where showNamedWorkspaces wsId = if any (`elem` wsId) ['a'..'z']
                                         then pad wsId
                                         else ""

myBackgroundInstaller = "~/.xmonad/feh.sh"
myTrayRunner = "~/.xmonad/tray.sh"
myNetworkApplet = "nm-applet"
myScreenSaver = "xscreensaver -no-splash"
myBar = "xmobar ~/.xmonad/xmobar.hs"

-- Workspaces
termWorkspace  = "term"
webWorkspace   = "web"
imWorkspace    = "im"
devWorkspace   = "dev"
mediaWorkspace = "media"

myWorkspaces =  [termWorkspace, webWorkspace, imWorkspace, devWorkspace, mediaWorkspace] ++ map show [6..9] ++ ["0", "-", "="]

xmobarCurrentWorkspaceColor = "green"

-- Layouts
basicLayout = Tall nmaster delta ratio where
    nmaster = 1
    delta   = 3/100
    ratio   = 1/2
tallLayout       = named "tall"     $ avoidStruts $ basicLayout
wideLayout       = named "wide"     $ avoidStruts $ Mirror basicLayout
singleLayout     = named "single"   $ avoidStruts $ noBorders Full
circleLayout     = named "circle"   $ Circle
twoPaneLayout    = named "two pane" $ TwoPane (2/100) (1/2)
mosaicLayout     = named "mosaic"   $ MosaicAlt M.empty
gridLayout       = named "grid"     $ Grid
spiralLayout     = named "spiral"   $ spiral (1 % 1)

myLayouts = tallLayout ||| wideLayout ||| singleLayout ||| circleLayout
          ||| mosaicLayout ||| gridLayout ||| spiralLayout
{-
mySDConfig = def { inactiveBorderColor = "gray"
                 , inactiveTextColor   = "grey"}
myLayouts = Circle ||| mosaic 2 [3,2]  ||| noBorders Full ||| dwmStyle shrinkText mySDConfig (tiled ||| Mirror tiled) ||| (noBorders simpleTabbed) ||| Accordion
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 2/3
     delta   = 3/100
-}
myManageHook = composeAll
    [ className =? "MPlayer"             --> doFloat
    , className =? "feh"                 --> doFloat
    , className =? "TelegramDesktop"     --> doFloat -- >> moveTo imWorkspace
    , className =? "Slack"               --> moveTo imWorkspace
    , className =? "Skype"               --> moveTo imWorkspace
    , className =? "Firefox"             --> moveTo webWorkspace
    , className =? "Google-chrome"       --> moveTo webWorkspace
    , className =? "Emacs"               --> moveTo devWorkspace
    , className =? "jetbrains-phpstorm"  --> moveTo devWorkspace
    , className =? "vscode"              --> moveTo devWorkspace
    , className =? "XClock"              --> doIgnore
    --, className =? "Emacs" --> (ask >>= doF .  \w -> (\ws -> foldr ($) ws (copyToWss ["2:web","4:dev"] w) ) . W.shift "3:im" ) :: ManageHook
    ]
    where moveTo = doF . liftM2 (.) W.greedyView W.shift
            -- copyToWss ids win = map (copyWindow win) ids

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
            [ ((modm, xK_F12), xmonadPrompt def)
            , ((modm, xK_F2 ), shellPrompt  def)
            , ((modm, xK_Tab   ), rotAllUp)
            , ((modm .|. shiftMask, xK_Tab   ), rotAllDown)
            ]
