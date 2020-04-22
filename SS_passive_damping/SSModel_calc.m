%%%Calculate state-space model of float in static position
%%%Full scale
load('ssRadf.mat')

rho_sea=1000;
g=9.81;
% Float
depth = 2;                  % Depth to top of float
Des = 12;                   % Outer diameter of float shell [m]
R = Des/2;                  % Outer radius of float shell [m]
CylLength = 4.75;           % Length of cylinder between hemispheres [m]
reldenfloat = 0.8;          % Density of float reative to sea water [-]
rho_steel = 7850;           % Density of steel [kg/m^3]
alphaDeg = 45;               % deg xz-plane (zero if att point is on horizontal central line, 90 if on bottom og float)
betaDeg = 0;               % deg xy-plane (zero if x value of att point is max (corner of cylinder) 90 y is max (peak of hemisphere))
FloatCd = 0.5;
FloatCdVector = [FloatCd 100 FloatCd 200*FloatCd 0 200*FloatCd];% Drag coefficients in 6 degrees of freedom, 4 and 6 picked at random to reduce yaw movement

% Reactor
ReactorD = 4.3;
ReactorCylLength = 35.7;                        % Only cylinder (excluding the two hemispheres)
ReactorWidth = 30;                              % From centre of tube to centre of tube
NetBuoyReactor = 101.9*10^3;                    % Net buoyancy of reactor [f kg] (Positive is buoyant)
ReactorDepth = 25.85;                           % Distance from mean sea surface to top of reactor (positive nr)
SeaDepth = 75;                                  % Distance from mean sea surface to seabed (positive nr)
ReactorCd = 0.5;
ReactorCdVector = [ReactorCd 100 ReactorCd 200*ReactorCd 200*ReactorCd 200*ReactorCd];   % Drag coefficients in 6 degrees of freedom, 4 and 6 picked at random to reduce yaw movement

%% Coordinates  (m, m, m)
% Tether line attachemnt point on float in global frame

alphaRad = alphaDeg*pi/180;
betaRad = betaDeg*pi/180;
% F1 = [R*cos(alphaRad)*cos(betaRad) R*cos(alphaRad)*sin(betaRad)+CylLength/2 -depth-R-R*sin(alphaRad)];     % Corner tether

%Transform to Float local frame - subtract float radius from z co-ord
%(Global frame at sea level)
F1 = [R*cos(alphaRad)*cos(betaRad) R*cos(alphaRad)*sin(betaRad)+CylLength/2 -R*sin(alphaRad)];     % Corner tether
F2 = [F1(1) -F1(2) F1(3)];     % Corner tether
F3 = [-F1(1) -F1(2) F1(3)];    % Corner tether
F4 = [-F1(1) F1(2) F1(3)];     % Corner tether
FC = [0 0 -depth-2*R];         % Central tether

% Tether line attachemnt point on reactor in global frame
T1 = [ReactorCylLength/2 ReactorWidth/2 -ReactorDepth+depth+R];      % Corner tether transformed to relative to float COG
T2 = [T1(1) -T1(2) T1(3)];               % Corner tether
T3 = [-T1(1) -T1(2) T1(3)];              % Corner tether
T4 = [-T1(1) T1(2) T1(3)];               % Corner tether
TC = [0 0 T1(3)];                        % Central tether
alfaXYT1F1 = abs(atan((T1(3)-F1(3))/((T1(1)-F1(1))^2+(T1(2)-F1(2))^2)^0.5));% PTO tether line [rad]
StiffnessCorner = 500*10^3;                    % Corner PTO tether stiffness coefficient [N/m]
%Do something about this, needs to match sea-state. Lookup table?


%Calculate corner tether initial length
xyz_pto=T1-F1;
corner_line_init_length=(Des/2) + sqrt(xyz_pto(1)^2 + xyz_pto(2)^2 + xyz_pto(3)^2); %add radius of float - assume lines point to cob

%Vectors to float thether attachment points relative to float COG
N_01=[0 F1(3) -F1(2);-F1(3) 0 F1(1);F1(2) -F1(1) 0];
N_02=[0 F2(3) -F2(2);-F2(3) 0 F2(1);F2(2) -F2(1) 0];
N_03=[0 F3(3) -F3(2);-F3(3) 0 F3(1);F3(2) -F3(1) 0];
N_04=[0 F4(3) -F4(2);-F4(3) 0 F4(1);F4(2) -F4(1) 0];

%Vectors along PTO tethers
S1=F1-T1;
S2=F2-T2;
S3=F3-T3;
S4=F4-T4;

S_01=[0 S1(3) -S1(2);-S1(3) 0 S1(1);S1(2) -S1(1) 0];
S_02=[0 S2(3) -S2(2);-S2(3) 0 S2(1);S2(2) -S2(1) 0];
S_03=[0 S3(3) -S3(2);-S3(3) 0 S3(1);S3(2) -S3(1) 0];
S_04=[0 S4(3) -S4(2);-S4(3) 0 S4(1);S4(2) -S4(1) 0];

%Unit vectors along PTO tethers
e_s1=S1./norm(S1);
e_s2=S2./norm(S2);
e_s3=S3./norm(S3);
e_s4=S4./norm(S4);

%%%Calculate stiffness matrix

%% Preload
VolumeFloat =4/3*pi*(Des/2)^3 + pi*(Des/2)^2*CylLength;
VolumeReactor =  1198.533;                                                  % kg from .h5 file
Mdisplacedfloat = VolumeFloat*rho_sea;                                      % kg
Mdisplacedreactor = VolumeReactor*rho_sea;                                  % kg
Mfloat = reldenfloat*Mdisplacedfloat;                                       % kg
Mreactor=Mdisplacedreactor-NetBuoyReactor;                                  % Net buoyancy of reactor [f kg]
Systemnetbuoyancy = (Mdisplacedfloat+Mdisplacedreactor-Mfloat-Mreactor)*g;  % N
TotalPreloadPTO = -(Mdisplacedfloat-Mfloat)*g;                              % N opposite of net buoyancy
PercentPreloadCentral = 0;                     % Percent of preload in central tether [%]
PreloadPTOCorner =  -((1-PercentPreloadCentral/100)*TotalPreloadPTO/4)/sin(alfaXYT1F1);  % Force aligned with tether line

G_0 = PreloadPTOCorner/norm(S1);  %All norms of Dxyz are the same as symettical

%%%%Kt for non colinear lines
G_01 = -[eye(3);N_01']*e_s1';
G_02 = -[eye(3);N_02']*e_s2';
G_03 = -[eye(3);N_03']*e_s3';
G_04 = -[eye(3);N_04']*e_s4';

Kt1 = [(StiffnessCorner-G_0)*(G_01)*(G_01') + G_0*[eye(3);N_01']*[eye(3) N_01] + [zeros(3,3) zeros(3,3); zeros(3,3) G_0*S_01*N_01]];
Kt2 = [(StiffnessCorner-G_0)*(G_02)*(G_02') + G_0*[eye(3);N_02']*[eye(3) N_02] + [zeros(3,3) zeros(3,3); zeros(3,3) G_0*S_02*N_02]];
Kt3 = [(StiffnessCorner-G_0)*(G_03)*(G_03') + G_0*[eye(3);N_03']*[eye(3) N_03] + [zeros(3,3) zeros(3,3); zeros(3,3) G_0*S_03*N_03]];
Kt4 = [(StiffnessCorner-G_0)*(G_04)*(G_04') + G_0*[eye(3);N_04']*[eye(3) N_04] + [zeros(3,3) zeros(3,3); zeros(3,3) G_0*S_04*N_04]];
Kt = Kt1 + Kt2 + Kt3 + Kt4;

%Inverse kinematic Jacobian
L = -[G_01 G_02 G_03 G_04]';

%Radiation state space model derived from 4th order transfer function fits.
%From 4th order optimisation, observable canonical form
load tfsurge_04numden.mat
G_surge = tf(tfsurge_04num,tfsurge_04den);
G_surge = G_surge/(1.424e7/2.91e5);
Gsden = G_surge.den{1};
Gsnum = G_surge.num{1};
Gsden = Gsden./Gsden(1);
Gsnum = Gsnum./Gsden(1);
Ars = [0 1 0 0;
      0 0 1 0;
      0 0 0 1;
      -fliplr(Gsden(2:end))];
  
Brs = [0 0 0 1.2e-3]';

Crs = fliplr([Gsnum(2:end-1) 0]);

load tfheave_04numden.mat
G_heave=tf(tfheave_04num,tfheave_04den);
G_heave=G_heave/(100/2);
Ghden = G_heave.den{1};
Ghnum = G_heave.num{1};
Ghden = Ghden./Ghden(1);
Ghnum = Ghnum./Ghden(1);
Arh = [0 1 0 0;
      0 0 1 0;
      0 0 0 1;
      -fliplr(Ghden(2:end))];
  
Ar_blank = [0 1 0 0;
      0 0 1 0;
      0 0 0 1;
      zeros(1,4)].*1;
  
Brh = [0 0 0 1.2e-3]';

Crh = fliplr([Ghnum(2:end-1) 0]);

%Form complete radiation state space model for all DOFs (but only include
%surge and heave)
Ar = blkdiag(Ars, Ar_blank, Arh, Ar_blank,Ar_blank,Ar_blank);
Br = blkdiag(Brs, zeros(size(Brs)), Brh, zeros(size(Brs)), zeros(size(Brs)), zeros(size(Brs)));
Cr = blkdiag(Crs, zeros(size(Crs)), Crh, zeros(size(Crs)), zeros(size(Crs)), zeros(size(Crs)));
Dr = zeros(6,6);

%%%Mass and added mass
M = diag([body(1).mass body(1).mass body(1).mass body(1).momOfInertia]);
Ainf = body(1).hydroForce.fAddedMass(:,1:6);

Bv = body(1).hydroForce.visDrag;
%%ADD PTO DAMPING IF INCLUDED
% Bv=Bv+diag([250*10^3 250*10^3 250*10^3 250*10^3 250*10^3 250*10^3]);

%%%Adjust Bv for linearised viscous drag approximation - based on emprical
%%%tuning with no control force
Bv_adj=ones(6,6).*1;
Bv = Bv.*Bv_adj;
%%%Add some damping to pitch-pitch mode to aid controller design
Bv(5,5)=Bv(6,6)./1e2;

%%%Create augmented ss matrices including radiation
A_wec = [zeros(6,6) eye(6) zeros(size(Cr)); -(M + Ainf)\Kt -(M + Ainf)\Bv -(M + Ainf)\Cr; zeros(size(Br)) Br Ar];
B_wec = [zeros(6,6); inv(M + Ainf); zeros(size(Br))];
% C_wec = [eye(12) zeros(12,24)];
C_wec = [zeros(6,6) eye(6) zeros(size(Cr))];
D_wec=0;

SS_full=ss(A_wec,B_wec,C_wec,D_wec); %This has 144 states including radiation damping in all modes

%remove non-relevant poles

%remove using balreal and modred
[SYSB,G] = balreal(SS_full);
elim = (G<1e-8);          % small entries of g -> negligible states
SYS_min = modred(SYSB,elim);  % remove negligible states

%without radiation: This one is used with LQRY as other models do not find
%feasible solution. Radiation damping is not too significant anyway.
A_wec_nr = [zeros(6,6) eye(6); -(M + Ainf)\Kt -(M + Ainf)\Bv];
B_wec_nr = [zeros(6,6); inv(M + Ainf)];
C_wec_nr = [zeros(6,6) eye(6)];
D_wec_nr = zeros(6,6);



