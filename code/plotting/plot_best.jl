
function plot_best(df::DataFrame,filename)

    plt1=plot(df, x=:n, y=:bottle, Geom.point,Theme(background_color=colorant"white",default_color="red"), Geom.smooth(method=:lm))
    draw(PNG(filename*"_bottle.png", 5inch, 2inch),plt1)
    draw(PNG(filename*"_bottle_big.png", 8inch, 4inch),plt1)

    plt2=plot(df, x=:n, y=:generation, Geom.point,Theme(background_color=colorant"white",default_color="red"),Geom.line)
    draw(PNG(filename*"_gen.png", 2.5inch, 2inch),plt2)
    draw(PNG(filename*"_gen_big.png", 5inch, 4inch),plt2)

    
end


function plot_best(df::DataFrame,filename,interscept,slope,range)

    line1(x) = interscept+slope*x-range
    line2(x) = interscept+slope*x+range
    
    xrange = minimum(df.n):1:maximum(df.n) 


    line1_df = DataFrame(x=xrange, y=line1.(xrange))
    line2_df = DataFrame(x=xrange, y=line2.(xrange))

    
    plt1=plot(
        layer(df, x=:n, y=:bottle,
              Geom.point,Theme(default_color="red"),
              Geom.smooth(method=:lm)),
    layer(line1_df, x=:x, y=:y, Geom.line, Theme(default_color=colorant"blue")), 
        layer(line2_df, x=:x, y=:y, Geom.line, Theme(default_color=colorant"blue")),
        Theme(background_color=colorant"white")
    )
    draw(PNG(filename*"_bottle_gutters.png", 8inch, 4inch),plt1)

    
end
