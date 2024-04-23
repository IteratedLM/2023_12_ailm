
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/plotting.jl")



df = CSV.File("ailm.csv") |> DataFrame

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


plotProperty(expressMatrix1,expressMatrix0,bottleV,"ailm_express.png",colorant"blue","x")
plotProperty(composeMatrix1,composeMatrix0,bottleV,"ailm_compose.png",colorant"orange","c")
plotProperty(stableMatrix1,  stableMatrix0,bottleV,"ailm_stable.png",colorant"purple","s")
