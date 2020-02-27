% Uncomment these to plot, remember to set up inputfile.m appropriately

% figure
% bode(SS_full(1,1))
% title('SS Model Heave')

% figure
% bode(invTF.heave(1,1))
% title('Inverse of SS Model Heave')
% 
% figure
% hold on
% bode(SS_full(1,1))
% bode(invTF.heave(1,1))
% title('Comparison of SS Model and inverse Model in Heave')

% figure
% bode(SS_full(3,3))
% title('SS Model Surge')
% 
% figure
% bode(invTF.surge)
% title('Inverse of SS Model Surge')
% 
% figure
% hold on
% bode(SS_full(3,3))
% bode(invTF.surge)
% title('Comparison of SS Model and inverse Model in Surge')

figure
hold on
bode(invTF.heave)
bode(filteredInvTF.heave)
bode(filterK)
legend('unfiltered inverse','filtered inverse','filter')