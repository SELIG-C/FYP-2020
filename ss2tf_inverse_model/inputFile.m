%First run Andy's script. Should eventually combine these two scripts into
%one file that produces a cleaner workspace.
SSModel_calc;

%Specify the excitation force sinusoid
seaWave.amp = 1e6;
seaWave.freq = 0.2;

%Calculate the lookup table values
%Surge TF
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

%make inverse transfer functions for heave and surge via ss2tf:
%den and num are switched in ss2tf line so the TF is already inverted
[dummy.den, dummy.num] = ss2tf(SS_full.A,SS_full.B,SS_full.C,SS_full.D,3);
dummy.den = dummy.den(3,:); %Just take the surge output TF
invTF.surge = tf(dummy.num, dummy.den);
clear dummy

%Heave TF(same process as surge)
[dummy.den, dummy.num] = ss2tf(SS_full.A,SS_full.B,SS_full.C,SS_full.D,1);
dummy.den = dummy.den(1,:); %Just take the heave output TF
invTF.heave = tf(dummy.num, dummy.den);
clear dummy

%Simulink won't accept improper TF, so implement bandpass filter:
Kp = 7;
lowFreq = 0.1;
highFreq = 2*pi; %This is 1Hz in rad/s
filterK = tf([Kp, 0],[1, lowFreq+highFreq, lowFreq*highFreq]);
filteredInvTF.heave = filterK*invTF.heave;
filteredInvTF.surge = filterK*invTF.surge;
