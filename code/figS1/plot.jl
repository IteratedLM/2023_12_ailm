
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/plotting.jl")


ilmName="ailm"
conditionName="vb_same"


df = CSV.File(ilmName*"_"*conditionName*".csv") |> DataFrame

function makeMatrix(df::DataFrame,type::String)
    filteredDf = filter(row -> row.propertyType == type, df)

    bottleV=sort(unique(filteredDf.bottle))
    
    filteredDf.bottleI = [findfirst(==(b), bottleV) for b in filteredDf.bottle]
    
    maxBottle = maximum(filteredDf.bottleI)
    maxTrial = maximum(filteredDf.trial)


    matrix = fill(NaN, maxBottle, maxTrial) 

    
    for row in eachrow(filteredDf)
        matrix[row.bottleI, row.trial] = row.property
    end

    matrix

end

bottleV = sort(unique(df.bottle))

expressMatrix0=makeMatrix(df,"e0")
expressMatrix1=makeMatrix(df,"e1")
composeMatrix0=makeMatrix(df,"c0")
composeMatrix1=makeMatrix(df,"c1")
stableMatrix0=makeMatrix(df,"s0")
stableMatrix1=makeMatrix(df,"s1")

pngName=conditionName*".png"


plotProperty(expressMatrix1,expressMatrix0,bottleV,ilmName*"_express_"*pngName,colorant"blue","x")
plotProperty(composeMatrix1,composeMatrix0,bottleV,ilmName*"_compress_"*pngName,colorant"orange","c")
plotProperty(stableMatrix1,  stableMatrix0,bottleV,ilmName*"_stable_"*pngName,colorant"purple","s")
