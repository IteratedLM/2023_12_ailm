#makes two perfect languages for n=8
#splices them with different mixing parameters
#uses this as a tutor-0
#trains and measures stability relative to the original parents
#prints out the results


using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/two_way_agent.jl")
include("../utilities/utilities.jl")
    
bitN=8

reflectionE=8

bottleN=50
reflectionN=150
same=false
p=0.85
filename="ailm"*string(p)*".csv"

loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

numEpochs=20

generationN=20
trialsN=50



firstRun=true

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

file=open(filename, "a")                   


for trialC in 1:trialsN

    tableA=randomCompositionalTable(bitN)
    tableB=randomCompositionalTable(bitN)
    
    global(bgCompose,bgExpress,bgStable,file,bitN)
    
    child=makeAgent(bitN)
    
    parentTable=spliceTable(p,tableA,tableB)
    
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

        signals =   shuffledSignals[1:reflectionN]
        
        makeTable(child)
        oldParent=copy(parentTable)
        if generation>1
            parentTable=child.m2sTable
        end
        
        express=rebased(expressivity(child),bgExpress)
        compose=rebased(compositionality(child),bgCompose)
        stable =rebased(stability(parentTable,oldParent),bgStable)
        stableA=rebased(stability(parentTable,tableA),bgStable)
        stableB=rebased(stability(parentTable,tableB),bgStable)
        
        write(file,"$generation,$trialC,e,$express\n")
        write(file,"$generation,$trialC,c,$compose\n")
        write(file,"$generation,$trialC,s,$stable\n")
        write(file,"$generation,$trialC,a,$stableA\n")
        write(file,"$generation,$trialC,b,$stableB\n")
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
