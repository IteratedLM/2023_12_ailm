
function plot_best(df::DataFrame,filename)

    plt1=plot(df, x=:n, y=:bottle, Geom.point,Theme(background_color=colorant"white",default_color="red"), Geom.smooth(method=:lm))
    draw(PNG(filename*"_bottle.png", 4inch, 2inch),plt1)
    draw(PNG(filename*"_bottle_big.png", 8inch, 4inch),plt1)

    plt2=plot(df, x=:n, y=:generation, Geom.point,Theme(background_color=colorant"white",default_color="red"),Geom.line)
    draw(PNG(filename*"_gen.png", 2.5inch, 2inch),plt2)
    draw(PNG(filename*"_gen_big.png", 5inch, 4inch),plt2)

    
end
