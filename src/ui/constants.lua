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
    MOUSE_SHADOW = {
        src = "img/ui/mouse_shadow.png",
    },
}

function FdUiLoadImageMetadata()
    for key, value in pairs(UI_IMAGE) do
        UI_IMAGE[key].size = { UiGetImageSize(value.src) }
    end
end
