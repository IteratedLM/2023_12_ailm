
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/plotting.jl")


ilmName="ailm"
conditionName="vr"


df = CSV.File(ilmName*"_"*conditionName*".csv") |> DataFrame

function makeMatrix(df::DataFrame,type::String)
    filteredDf = filter(row -> row.propertyType == type, df)

    reflectionV=sort(unique(filteredDf.reflection))
    
    filteredDf.reflectionI = [findfirst(==(b), reflectionV) for b in filteredDf.reflection]
    
    maxReflection = maximum(filteredDf.reflectionI)
    maxTrial = maximum(filteredDf.trial)


    matrix = fill(NaN, maxReflection, maxTrial) 

    
    for row in eachrow(filteredDf)
        matrix[row.reflectionI, row.trial] = row.property
    end

    matrix

end

reflectionV = sort(unique(df.reflection))

expressMatrix0=makeMatrix(df,"e0")
expressMatrix1=makeMatrix(df,"e1")
composeMatrix0=makeMatrix(df,"c0")
composeMatrix1=makeMatrix(df,"c1")
stableMatrix0= makeMatrix(df,"s0")
stableMatrix1= makeMatrix(df,"s1")

pngName=conditionName*".png"

plotProperty(expressMatrix1,expressMatrix0,reflectionV,ilmName*"_express_"*pngName,colorant"blue","x","autoencoder")
plotProperty(composeMatrix1,composeMatrix0,reflectionV,ilmName*"_compress_"*pngName,colorant"orange","c","autoencoder")
plotProperty(stableMatrix1,  stableMatrix0,reflectionV,ilmName*"_stable_"*pngName,colorant"purple","s","autoencoder")
