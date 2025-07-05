UI_IMAGE = {
    KEY_IDLE = {
        src = "img/ui/key_idle.png",
        slice = { x = 8, y = 8 },
        padding = 8,
    },
    MOUSE_PLATE = {
        src = "img/ui/mouse_plate.png",
    },
    MOUSE_PRIMARY = {
        src = "img/ui/mouse_primary.png",
    },
    MOUSE_SECONDARY = {
        src = "img/ui/mouse_secondary.png",
    },
    MOUSE_MIDDLE = {
        src = "img/ui/mouse_middle.png",
    },
    MOUSE_MOVE_BASE = {
        src = "img/ui/mouse_move.png",
    },
    MOUSE_MOVE_UP = {
        src = "img/ui/mouse_move_up.png",
    },
    MOUSE_MOVE_DOWN = {
        src = "img/ui/mouse_move_down.png",
    },
    MOUSE_MOVE_LEFT = {
        src = "img/ui/mouse_move_left.png",
    },
    MOUSE_MOVE_RIGHT = {
        src = "img/ui/mouse_move_right.png",
    },
    MOUSE_SCROLL_BASE = {
        src = "img/ui/mouse_scroll.png",
    },
    MOUSE_SCROLL_UP = {
        src = "img/ui/mouse_scroll_up.png",
    },
    MOUSE_SCROLL_DOWN = {
        src = "img/ui/mouse_scroll_down.png",
    },
    MOUSE_SHADOW = {
        src = "img/ui/mouse_shadow.png",
    },
}

function FdUiLoadImageMetadata()
    for key, value in pairs(UI_IMAGE) do
        UI_IMAGE[key].size = { UiGetImageSize(value.src) }
    end
end
