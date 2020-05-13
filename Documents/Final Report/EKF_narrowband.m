function [Amplitude, Phase, Frequency]   = EKF_narrowband(y)
coder.extrinsic('evalin')
% Initialization
persistent P;
persistent x;

dt = 0; %edit this to match your timestep
dt = evalin('base','Ts');
if isempty(P)
    x = [0 0 0.1]';       %state estimate
    P = diag([1e0 1e0 1e0]);    %Covariance matrix
end

%%%%%%%%%%%From Fusco thesis%%%%%%%%%%%%%%%%%%%%%
%%%State vector X = [a theta w]
x1 = x(1);  %Amplitude
x2 = x(2);  %Phase
w = x(3);   %frequency

%State transition matrices
A = [cos(w*dt) sin(w*dt) 0;
    -sin(w*dt) cos(w*dt) 0;
    0 0 1];

q1 = 1e12; q2 = 1e-1; q3 = 1e-2;%Must be comparable to expected magnitudes of each state

% q = [rand*q1 rand*q2 rand*q3]';
% Q = diag(q);
% R=rand*0.1;

q = [q1 q2 q3]';
Q = diag(q);
R=1e-1; %Measurement noise

%Jacobian
dA = [cos(w*dt) sin(w*dt) (-dt*x1*sin(w*dt) + dt*x2*cos(w*dt));
    -sin(w*dt) cos(w*dt) (-dt*x1*cos(w*dt) - dt*x2*sin(w*dt));
     0 0 1];
F = [(x1*cos(w*dt) + x2*sin(w*dt)); (-x1*sin(w*dt) + x2*cos(w*dt)); w];
C = [1 0 0];

%EKF predict/correct
x = A*x;
P = dA*P*dA' + Q;

S = C*P*C' + R;
K = P*C'/S;
x = x + K*(y-C*x);
P = (eye(3) - K*C)*P;

%outputs
Amplitude = sqrt(x(1)^2 + x(2)^2);
Frequency = x(3);
Phase = x(2);
