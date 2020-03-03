%Run SSModel_calc.m to populate workspace.
SSModel_calc;

%Specify the excitation force sinusoid
seaWave.amp = 1e6;
seaWave.freq = 0.4;

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

%Run discreteInverse to make the inverse SS.
discreteInverse;

%Due to discreteInverse being realisable in real time, the filter can be
%anything! It has uncancelled zeroes at:
%0.129 rads, 0.989+-0.128j for Heave
%0.131 rads, 0.989+-0.13j for Surge (Discrete time pzmap)
