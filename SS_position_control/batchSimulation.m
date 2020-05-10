TeVector = [6:1:16];
HsVector = [0.5:0.5:6.5];
powerMatrix = [];
surgePosAmp = [];
heavePosAmp = [];
progressCounter = 0;
loadingBar = waitbar(0,'Simulation Run Started', 'Name', 'Simulation Progress');

for ii = 1:length(TeVector)
    Te = TeVector(ii);
    for yy = 1:length(HsVector)
        Hs = HsVector(yy);
        
        %Update the loading bar:
        waitbar(progressCounter/(length(TeVector)*length(HsVector)), loadingBar,...
            ['Current Te=',num2str(Te),' and Hs =',num2str(Hs)])
        progressCounter = progressCounter+1;
        
        clear('fex')
        load(['FEX_samples/FEX_',num2str(Te),'_',num2str(Hs),'.mat'])
        %simOut = sim('position_control_model.slx','ReturnWorkspaceOutputs','on');
        sim('position_control_model.slx');
        powerMatrix(yy,ii) = mean(totalPower);
        if abs(max(surgePos))>abs(min(surgePos))
            surgePosAmp = [surgePosAmp, abs(max(surgePos))];
        else
            surgePosAmp = [surgePosAmp, abs(min(surgePos))];
        end
        
        if abs(max(heavePos))>abs(min(heavePos))
            heavePosAmp = [heavePosAmp, abs(max(heavePos))];
        else
            heavePosAmp = [heavePosAmp, abs(min(heavePos))];
        end
        %save(['Results/intPosFeedback_',num2str(Te),'_',num2str(Hs),'.mat'],'logsout')
        %figure
        %plot(totalPower)
    end
end

waitbar(1,loadingBar,'Simulation Complete')