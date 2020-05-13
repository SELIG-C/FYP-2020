% figure
% plot(controlSignal.Time, controlSignal.Data(:,1))
% hold on
% yyaxis right
% plot(outputSignal.Time, outputSignal.Data(:,1))

figure
plot(surgePos)
ylabel('Position (metres)')
title('Position in Surge over time')

figure
plot(heavePos)
ylabel('Position (metres)')
title('Position in Heave over time')