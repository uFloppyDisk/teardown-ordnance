OrdServer = {}

function OrdServer.init()
    FdLog("Server Init")

    RegisterTool("ordnance", "Ordnance [FD]", "MOD/assets/vox/radio.xml")
    SetBool("game.tool.ordnance.enabled", true)
end
