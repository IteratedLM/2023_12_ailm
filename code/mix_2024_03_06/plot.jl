
using CSV, DataFrames,Gadfly, Statistics, Random
import Cairo, Fontconfig

#filename="ailm_50"
#filename="ailm_100"
#filename="ailm_100_100"
filename="ailm_all"

function addPJitter(df::DataFrame, jitterMagnitude::Float64)
    Random.seed!(123) 
    jitterValues = jitterMagnitude .* (rand(size(df, 1)) .- 0.5)
    df[!, :pJitter] = df[!, :p] .+ jitterValues
    return df
end


df = CSV.File(filename*".csv") |> DataFrame

gen20Df = filter(row -> row.generation == 20 && (row.propertyType == "a" || row.propertyType == "b"), df)

df = filter(row -> !(row.propertyType == "b" && row.p == 0.5), gen20Df)
df.p[df.propertyType .== "b"] .= 1 .- df.p[df.propertyType .== "b"]


gen20Df=df
        
avgProperty = combine(groupby(gen20Df, :p), :property => mean => :propertyAvg)

gen20Df=addPJitter(gen20Df, 0.02)

# Merge average back into original dataframe for plotting
mergedDf = leftjoin(gen20Df, avgProperty, on = :p)



# Plotting with Gadfly
plt=plot(
layer(mergedDf, x=:p, y=:propertyAvg, Geom.line, Theme(default_color=colorant"red",line_width=2mm)),
    layer(mergedDf, x=:pJitter, y=:property, Geom.point, Theme(default_color=colorant"blue")),
    Coord.Cartesian(xmin=-0.05, xmax=1.05, ymin=-0.05, ymax=1.05),
         Guide.xlabel("p"), Guide.ylabel("similarity to A"),
                 Theme(plot_padding=[0mm,0mm,0mm,0mm],background_color=colorant"white")
         )

draw(PNG("p_a_n10.png", 5inch, 4inch),plt)
