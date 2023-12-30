#ideal bottleneck sweep for ailm

using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/two_way_agent.jl")
include("../utilities/utilities.jl")
    
loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

generationMax=200

trialsN=25

mu1=0.125
mu2=0.125

reflectionM=3

cutOff=0.95

bottleMin =87
bottleStep=1

bitNV=Int64[]
bottleBestV=Float64[]
generationBestV=Float64[]

bitN0=13
bitN1=20

backgroundN=20

filename="best_ailm.csv"
firstRun=false

if firstRun
    header = "n,bottle,trial,generation\n"
    open(filename, "w") do file
        write(file, header)
    end
end

file=open(filename, "a")                   

for bitN in bitN0:bitN1

    bgCompose=0.0::Float64
    bgExpress=0.0::Float64
    bgStable =0.0::Float64
    
    for backgroundC in 1:backgroundN

        child=makeAgent(bitN)
        makeTable(child)
        GC.gc()
        anotherChild=makeAgent(bitN)
        makeTable(anotherChild)
        GC.gc()
        bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
        bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
        bgStable+=stability(child.m2sTable,anotherChild.m2sTable)/backgroundN
     
    end
    
    global(bottleMin,bottleStep)
    
    genBest=generationMax
    bottleBest=bottleMin

    bottleMax=round(Int64,(2^bitN-2)/reflectionM)
    
    bottleT=collect(bottleMin:bottleStep:bottleMax)
    
    for bottleC in bottleT

        numEpochs=round(Int64,200*100/bottleC)
        
        generationC=0.0
        
        for trialC in 1:trialsN
            
            global(generationMax,cutOff)
                
            child=makeAgent(bitN)
            parentTable=randomTable(bitN)
            GC.gc()
            express=0.0
            compose=0.0
            stable= 0.0

            generation=1
            
            while ((generation <= generationMax) && ((express<cutOff || compose<cutOff)||stable<cutOff))
        
                shuffledMeanings = randperm(2^bitN)
                shuffledSignals = randperm(2^bitN)
                
                exemplars = shuffledMeanings[1:bottleC]
                signals =   shuffledSignals[1:reflectionM*bottleC]
        
                makeTable(child)
                GC.gc()

                oldParent=copy(parentTable)
                parentTable=child.m2sTable
                GC.gc()

                express=rebased(expressivity(child),bgExpress)
                compose=rebased(compositionality(child),bgCompose)
                stable=rebased(stability(parentTable,oldParent),bgStable)                      

                child=makeAgent(bitN)

                for epoch in 1:numEpochs
                    
                    shuffle!(exemplars)
                    
                    for meaning in exemplars
                        
                        p=rand()
                        if p<mu1
                            dataI=[(v2BV(bitN,parentTable[meaning]-1),v2BV(bitN,meaning-1))]
                            Flux.train!(loss, child.s2m, dataI, optimizer)
                        elseif p<mu1+mu2
                            dataI=[(v2BV(bitN,meaning-1),v2BV(bitN,parentTable[meaning]-1))]
                            Flux.train!(loss, child.m2s, dataI, optimizer)
                        else
                            signal=rand(signals)
                            dataI=[(v2BV(bitN,signal-1),v2BV(bitN,signal-1))]
                            Flux.train!(loss, child.s2s, dataI, optimizer)
                        end
                        
                    end

                end

                
                generation+=1
                
            end

            generationC+=generation
            if generation==generationMax+1
                println("max gen $bitN,$bottleC,$trialC")
            end
            write(file,"$bitN,$bottleC,$trialC,$generation\n")
            flush(file)

            
        end 

        
        generationC/=trialsN

        if generationC<genBest
            genBest=generationC
            bottleBest=bottleC
        elseif generationC>1.5*genBest
            break
        end

    end

    println(bitN," ",genBest," ",bottleBest)

    append!(bitNV,bitN)
    append!(bottleBestV,bottleBest)
    append!(generationBestV,genBest)
    
    bottleMin=bottleBest
    
end
