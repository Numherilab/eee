-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

-- Features can be enabled to disabled independently by commenting
-- or uncommenting lines below.

require("scripts/menus/alttp_dialog_box")
require"scripts/achievements/achievements_manager"
require"scripts/action/hole_drop_landing"
require("scripts/hud/hud")
require("scripts/hud/small_key")
require("scripts/meta/hero")
require("scripts/meta/enemy")
require("scripts/meta/destructable")
require("scripts/meta/camera")
require("scripts/meta/carried_object")
--require("scripts/meta/sensor")
require("scripts/meta/map")
require("scripts/meta/item")
require"scripts/meta/sprite"
require"scripts/meta/switch"

return true