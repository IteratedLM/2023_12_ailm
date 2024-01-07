#ideal bottleneck sweep for ailm

using Statistics,DataFrames

include("../utilities/two_way_agent.jl")
include("../utilities/utilities.jl")

learningRate=5.0

optimizer=Flux.Optimise.Descent(learningRate)
loss(nn, x,y)= Flux.mse(nn(x), y)

reflectionM=3
reflectionE=8

cutOff=0.95

#epochN=6

epochN=20
bitN=parse(Int,ARGS[1])
bottleOff = 10
bottleMin =round(Int,5.9+6.81*bitN)-bottleOff
bottleMax =bottleMin+2*bottleOff

bottleStep=1

backgroundN=20


trial0=parse(Int,ARGS[2])
dTrial=0

println(bitN," ",bottleMin," ",trial0)

filename="results_01_07/best_ailm_"*ARGS[1]*"_"*ARGS[2]*".csv"

let

    generationMax=15*bitN
    
    bgCompose=0.0::Float64
    bgExpress=0.0::Float64
    bgStable =0.0::Float64
    
    for backgroundC in 1:backgroundN

        child=makeAgent(bitN)
        makeTable(child)
        anotherChild=makeAgent(bitN)
        makeTable(anotherChild)
        bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
        bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
        bgStable+=stability(child.m2sTable,anotherChild.m2sTable)/backgroundN
     
    end
    
    global(bottleMin,bottleStep,bottleMax)

    bottleT=collect(bottleMin:bottleStep:bottleMax)
    
    for bottleC in bottleT
        
#        numEpochs=epochN*bitN
        numEpochs=epochN
        
        for trialC in trial0:trial0+dTrial
            
            global(cutOff)

            child=makeAgent(bitN)
            parentTable=randomTable(bitN)
            GC.gc()
            
            express=0.0
            compose=0.0
            stable= 0.0

            generation=1
            
            while ((generation <= generationMax) && ((express<cutOff || compose<cutOff)||stable<cutOff))
        
                shuffledMeanings = randperm(2^bitN)
                shuffledSignals =  randperm(2^bitN)


                exemplars1 = shuffledMeanings[1:bottleC]
                exemplars2 = copy(exemplars1)

                signals =   shuffledSignals[1:reflectionM*bottleC]
        
                makeTable(child)
                GC.gc()

                oldParent=copy(parentTable)
                parentTable=copy(child.m2sTable)
                GC.gc()

                express=rebased(expressivity(child),bgExpress)
                compose=rebased(compositionality(child),bgCompose)
                stable=rebased(stability(parentTable,oldParent),bgStable)

                deleteAgent(child)
                
                child=makeAgent(bitN)

                for epoch in 1:numEpochs
                    
                    shuffle!(exemplars1)
                    shuffle!(exemplars2)


                    for meaningC in 1:bottleC

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

                
                generation+=1
                
            end

            file=open(filename, "a")                   
            write(file,"$bitN,$bottleC,$trialC,$generation\n")
            flush(file)
            close(file)
            if generation==generationMax+1
                println("max gen $bitN,$bottleC,$trialC")               
            end

        end 

    end

end

println("done")