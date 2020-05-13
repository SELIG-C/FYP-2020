figure
hold on
plot(AbsHeave.Time,AbsHeave.Data)
plot(EKFSurge)
title('Surge Amplitude Comparison')
legend('Absolute Amplitude','EKF Envelope')
ylabel('Excitation Force(N)')