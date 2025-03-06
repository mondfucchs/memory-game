local love = require("love")

function love.conf(app)
    app.window.width  = 800
    app.window.height = 600

    app.window.title  = "HW: Memory Game"
    app.window.icon   = "assets/img/gameicon.png"
end