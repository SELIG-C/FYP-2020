%This struct controls the input wave
seaWave.amp = 1e6;
seaWave.freq = 0.5;

%These are the lookup table values, they're static
load('heave_data.mat');
load('surge_data.mat');