#makes a a ILM agent
#does this for n=8
#trains it using different exemplar and reflection sets
#prints out the results


using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/two_way_agent.jl")
include("../utilities/utilities.jl")
    
bitN=16
generationN=120
bottleN=114
reflectionX=3
reflectionN=reflectionX*bottleN

same=false

#
#numEpochs=50
#filename="ailm_50e.csv"
#


#
numEpochs=20
filename="results/ailm_n16_"*ARGS[1]*".csv"
#


loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)


trialC=parse(Int,ARGS[1])

reflectionE=8

firstRun=false

if firstRun
    header1 = "generation,trial,propertyType,property\n"
    header2 = "$generationN,-1,m,-1.0\n"
    open(filename, "w") do file
        write(file, header1)
        write(file, header2)
    end
end

progress= Progress(trialsN*generationN)

bgCompose=0.0::Float64
bgExpress=0.0::Float64
bgStable =0.0::Float64
backgroundN=20

for backgroundC in 1:backgroundN

    global(bgCompose,bgExpress,bgStable)
    child=makeAgent(bitN)
    anotherChild=makeAgent(bitN)
    makeTable(child)
    makeTable(anotherChild)
    bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
    bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
    bgStable+=stability(child.m2sTable,anotherChild.m2sTable)/backgroundN
    
end



println("background")
println("compose"," ",bgCompose)
println("express"," ",bgExpress)
println("stable "," ",bgStable)

file=open(filename, "a")                   

let
    
    global(bgCompose,bgExpress,bgStable,file,bitN,trialC)
    
    child=makeAgent(bitN)
    parentTable=randomTable(bitN)
    
    for generation in 1:generationN
        
        shuffledMeanings = randperm(2^bitN)
        shuffledSignals  = Vector{Int64}[]
        if same
            shuffledSignals=copy(shuffledMeanings)
        else            
            shuffledSignals=randperm(2^bitN)
        end
        
        exemplars1 = shuffledMeanings[1:bottleN]
        exemplars2 = copy(exemplars1)
        signals = shuffledSignals[1:reflectionN]
        
        makeTable(child)
        oldParent=copy(parentTable)
        parentTable=child.m2sTable
        
        express=rebased(expressivity(child),bgExpress)
        compose=rebased(compositionality(child),bgCompose)
        stable =rebased(stability(parentTable,oldParent),bgStable)

        write(file,"$generation,$trialC,e,$express\n")
        write(file,"$generation,$trialC,c,$compose\n")
        write(file,"$generation,$trialC,s,$stable\n")
        flush(file)
        
        child=makeAgent(bitN)

        for epoch in 1:numEpochs
            
            shuffle!(exemplars1)
            shuffle!(exemplars2)
            
            for meaningC in 1:bottleN

                meaning1=exemplars1[meaningC]
                meaning2=exemplars2[meaningC]
                
                dataI=[(v2BV(bitN,parentTable[meaning1]-1),v2BV(bitN,meaning1-1))]
                Flux.train!(loss, child.s2m, dataI, optimizer)
                
                dataI=[(v2BV(bitN,meaning2-1),v2BV(bitN,parentTable[meaning2]-1))]
                Flux.train!(loss, child.m2s, dataI, optimizer)

                for _ in 1:reflectionE
                    signal=rand(signals)
                    dataI=[(v2BV(bitN,signal-1),v2BV(bitN,signal-1))]
                    Flux.train!(loss, child.s2s, dataI, optimizer)
                end
            end
        end

        
    next!(progress)
        
    end

end 
