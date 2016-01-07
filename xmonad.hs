--imports
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks

--needed for viewShift
import Control.Monad (liftM2)
import System.IO
import qualified XMonad.StackSet as W

--additional layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.Accordion
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Grid

--use urxvt terminal emulator
myTerminal = "urxvt"

--set workspace names and how many
myWorkspaces = ["1:term","2:web","3:docs","4:mail" ] ++ map show [5..8]

--border width in pixels
myBorderWidth = 2

--set windows key as the mod key
myModMask = mod4Mask

--command to launch taskbar
myTaskBar = "xmobar"

--key to toggle gap for taskbar
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

--what is written to taskbar
myPP = xmobarPP 
	{
		ppTitle = xmobarColor "#657b83" "" . shorten 100
		,ppCurrent = xmobarColor "#c0c0c0" "" . wrap "<" ">"
		,ppSep = xmobarColor "#c0c0c0" "" " | "
		,ppUrgent = xmobarColor "#ff69b4" ""
		,ppLayout = const ""
		
	}

--custom colors
myNormalBorderColor = "#002b36"
myFocusedBorderColor = "#657b83"
xmobarTitleColor = "green" --current window title color
xmobarCurrentWorkspaceColor = "#CEFFAC" --current workspace color

--layout hook specifies all layouts that are available including any customizations
	--some layouts require arguments, if layout doesn't change on recompile double check
	--run xmonad --recompile from command line to view errors
	--each layout seperated by |||
	--after recompile with mod-q need to press mod-shift-space to reload layout
myLayoutHook = 	avoidStruts --struts have to do with spacing between menu bar 
	(
		Tall 1 (3/100) (1/2) |||  --- args: num panes in master pane, size inc/dec %, initial size of master pan 
		Full ||| -- fullscreen
		Grid |||
		--Accordion ||| -- main pane with others stacked at bottom
		--noBorders (simpleTabbed) |||
		noBorders (tabbed shrinkText tabConfig) |||
		ThreeCol 1 (3/100) (1/2) ||| -- args: num panes in master pane, size inc/dec %, initial size of master pane
		spiralWithDir North CW  (4/5)  -- args: start dir, spiral dir, ratio of panes in spiral: 0-aspect ratio
		
	)

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = defaultTheme {
	activeBorderColor = "#657b83",
	activeTextColor = "#b58900",
    	activeColor = "#002b36",
    	inactiveBorderColor = "#1c1c1c",
    	inactiveTextColor = "#b58900",
    	inactiveColor = "#002b36"
}

--manage hook is run each time a new window is created 
	--can be used to specify custom actions for a specific program etc.
	--install xorg-utils
	--use: xprop | grep WM_CLASS and then use mouse to click on desired program to get its name
myManageHook = composeAll 
	[
		className =? "Firefox" --> viewShift"2:web"
		,className =? "sublime_text" -->viewShift"3:docs"
	]
	where viewShift = doF . liftM2 (.) W.greedyView W.shift

--structure to hold custom settings
mySettings = defaultConfig
	{
		terminal = myTerminal
		,modMask = myModMask
		,workspaces = myWorkspaces
		,borderWidth = myBorderWidth
		,normalBorderColor = myNormalBorderColor
		,focusedBorderColor = myFocusedBorderColor
		,handleEventHook = mconcat [docksEventHook ,handleEventHook defaultConfig] --magic to prevent tasbar from being covered
		,layoutHook = smartBorders $ myLayoutHook
		,manageHook = myManageHook <+> manageDocks <+> manageHook defaultConfig
	}

--main
main = xmonad =<< statusBar myTaskBar myPP toggleStrutsKey mySettings 
