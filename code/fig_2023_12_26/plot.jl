
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/plotting.jl")


df = CSV.File("oilm_vb.csv") |> DataFrame

function makeMatrix(df::DataFrame,type::String)
    filtered_df = filter(row -> row.propertyType == type, df)

    max_bottle = maximum(filtered_df.bottle)
    max_trial = maximum(filtered_df.trial)


    matrix = fill(NaN, max_bottle, max_trial)  # or use zeros() if you prefer

    
    for row in eachrow(filtered_df)
        matrix[row.bottle, row.trial] = row.property
    end

    matrix

end



bottleMin=10
bottleMax=150
bottleStep=10

botV=collect(bottleMin:bottleStep:bottleMax)

expressMatrix0=makeMatrix(df,"e0")
expressMatrix1=makeMatrix(df,"e1")
composeMatrix0=makeMatrix(df,"c0")
composeMatrix1=makeMatrix(df,"c1")
stableMatrix0=makeMatrix(df,"s0")
stableMatrix1=makeMatrix(df,"s1")

plotProperty(expressMatrix1,expressMatrix0,botV,"oilm_express_vb.png",colorant"blue","e")
plotProperty(composeMatrix1,composeMatrix0,botV,"oilm_compose_vb.png",colorant"orange","c")
plotProperty(stableMatrix1,  stableMatrix0,botV,"oilm_stable_vb.png",colorant"purple","s")
