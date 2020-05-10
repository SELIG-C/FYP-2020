meanVector = [];
for i = 1:length(controlSignal.Data)
    if controlSignal.Data(i,1)*outputSignal.Data(i,1)<0
        meanVector(i) = 100;
    else
        meanVector(i)=0;
    end
end