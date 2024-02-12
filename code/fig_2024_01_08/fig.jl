#makes a a ILM agent


using Statistics,DataFrames

include("../utilities/two_way_agent.jl")
include("../utilities/utilities.jl")
    
bitN=16
generationN=40
bottleN=114
reflectionX=3
reflectionN=reflectionX*bottleN

same=false

#
numEpochs=20
filename="results/ailm_"*ARGS[1]*".csv"
#


loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

batchC=parse(Int,ARGS[1])
trialN=5

reflectionE=8

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

for trialC in 1:trialN
    
    global(bgCompose,bgExpress,bgStable,file,bitN,batchC)
    
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

        trialOverallC=(batchC-1)*trialN+trialC
        
        write(file,"$generation,$trialOverallC,e,$express\n")
        write(file,"$generation,$trialOverallC,c,$compose\n")
        write(file,"$generation,$trialOverallC,s,$stable\n")
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

        
        
    end

end 
