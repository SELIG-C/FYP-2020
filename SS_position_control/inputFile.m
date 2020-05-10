%Run SSModel_calc.m to populate workspace.
SSModel_calc;
load('FEX_samples/FEX_8_6.mat') %Grab a demo FEX sample. Comment out if running batch process.

%Specify the excitation force sinusoid
% seaWave.amp = 1e6;s
% seaWave.freq = 0.4;

%Calculate the lookup table values
%Surge TF
%According to this Matlab Answers page, bode returns absolute values, not
%decibels: https://www.mathworks.com/matlabcentral/answers/90310-does-the-bode-function-automatically-converts-the-vector-points-into-decibels
load tfsurge_04numden.mat
surge.tf = tf(tfsurge_04num,tfsurge_04den);
surge.tf = surge.tf/(1.424e7/2.91e5);
[surge.amp,dummy,surge.freq] = bode(surge.tf);
surge.amp = squeeze(surge.amp);
surge.freq = squeeze(surge.freq);
clear dummy

%Heave TF
load tfheave_04numden.mat
heave.tf=tf(tfheave_04num,tfheave_04den);
heave.tf=heave.tf/(100/2);
[heave.amp,dummy,heave.freq] = bode(heave.tf);
heave.amp = squeeze(heave.amp);
heave.freq = squeeze(heave.freq);
clear dummy


% Construct the discrete inverse:
% L = 1; %L is 1 ! Don't forget this. Have proven
Ts = 0.02; %Time-step, remember to set in simulink as well.

SS_discrete = c2d(SS_full,Ts);

M0 = SS_discrete.D;
M1 = [         M0,            zeros(length(M0),length(M0));...
      SS_discrete.C*SS_discrete.B,                   M0           ];

K = pinv(M1(:,1:6));

O_L = [SS_discrete.C;SS_discrete.C*SS_discrete.A]; %Observability of M1
SS_inverse.A = SS_discrete.A - (SS_discrete.B*K*O_L);
SS_inverse.B = SS_discrete.B*K;
SS_inverse.C = -K*O_L;
SS_inverse.D = K;
SS_inverse = ss(SS_inverse.A, SS_inverse.B,SS_inverse.C,SS_inverse.D,Ts);

%Due to discreteInverse being realisable in real time, the filter can be
%anything! It has uncancelled zeroes at:
%0.129 rads, 0.989+-0.128j for Heave
%0.131 rads, 0.989+-0.13j for Surge (Discrete time pzmap)
