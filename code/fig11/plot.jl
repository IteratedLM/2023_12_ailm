
using CSV, DataFrames,Gadfly,Images, ImageMagick
import Cairo, Fontconfig
include("../plotting/plotting.jl")


df = CSV.File("ailm_epoch.csv") |> DataFrame

using DataFrames
using Gadfly

# Filter out rows where :propertyType is not "t"
df_filteredD = filter(row -> row[:propertyType] == "tD", df)
df_filteredE = filter(row -> row[:propertyType] == "tE", df)
df_filteredA = filter(row -> row[:propertyType] == "tA", df)

# Group by :generation, :epoch, and :propertyType, then calculate the mean of :property
dfD_grouped = combine(groupby(df_filteredD, [:generation, :epoch]), :property => mean => :property_mean)
dfE_grouped = combine(groupby(df_filteredE, [:generation, :epoch]), :property => mean => :property_mean)
dfA_grouped = combine(groupby(df_filteredA, [:generation, :epoch]), :property => mean => :property_mean)

xlabel="epoch"
ylabel="loss"

# Plot using Gadfly
pltD=plot(dfD_grouped, x=:epoch, y=:property_mean, color=:generation,
     Geom.line,
          Guide.xlabel(xlabel), Guide.ylabel(""),Guide.colorkey(nothing),
          Theme(background_color=colorant"white",key_position=:none))

pltE=plot(dfE_grouped, x=:epoch, y=:property_mean, color=:generation,
     Geom.line,
          Guide.xlabel(xlabel), Guide.ylabel(""),
          Theme(background_color=colorant"white",key_position=:none))


dfA_grouped.property_mean = dfA_grouped.property_mean./8

pltA=plot(dfA_grouped, x=:epoch, y=:property_mean, color=:generation,
     Geom.line,
          Guide.xlabel(xlabel), Guide.ylabel(""),
          Theme(background_color=colorant"white",key_position=:none))



pltYLabel=plot(dfA_grouped, x=:epoch, y=:property_mean, color=:generation,
     Geom.line,
          Guide.xlabel(xlabel), Guide.ylabel(ylabel),
          Theme(background_color=colorant"white",key_position=:none))


filename="ailm_epoch"

draw(PNG(filename*"D.png", 2.15inch, 2inch),pltD)
draw(PNG(filename*"D_big.png", 5inch, 4inch),pltD)

draw(PNG(filename*"E.png", 2.15inch, 2inch),pltE)
draw(PNG(filename*"E_big.png", 5inch, 4inch),pltE)


draw(PNG(filename*"A.png", 2.15inch, 2inch),pltA)
draw(PNG(filename*"A_big.png", 5inch, 4inch),pltA)

dummy_plot = plot(
    x=[0], y=[0], color=collect(1:30), 
    Geom.point, 
    Guide.colorkey("g"),
    Theme(
        key_title_font_size=12pt,
        background_color=colorant"white",  # set background color
        key_position=:right,  # position the key, adjust as needed
        panel_stroke=colorant"white"  # make panel border white to hide it
    )
)



# Then draw the plot
draw(PNG("color_key.png", 2.5inch, 2inch), dummy_plot)
draw(PNG("ylabel.png", 2.5inch, 2inch), pltYLabel)



function cropImage(imageName,cropX1,cropX2)
 
    img = load(imageName)

    height, width = size(img)


    x1 = Int(round(width * cropX1))  
    x2 = Int(round(width * cropX2))  


    cropped_img = img[1:height, x1:x2]


    save(imageName, cropped_img)

end

cropImage("color_key.png",0.75,1.0)
cropImage("ylabel.png",0.05,0.15)
cropImage("ailm_epochD.png",0.075,0.95)
cropImage("ailm_epochE.png",0.075,0.95)
cropImage("ailm_epochA.png",0.075,0.95)
