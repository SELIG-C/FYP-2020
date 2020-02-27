L = 1; %L is 1 ! Don't forget this. Have proven
M_vec = zeros(6,6);

SS_discrete = c2d(SS_full,0.2); %make sure time step here is same as in simulink!

M0 = SS_discrete.D;
M1 = [         M0,            zeros(length(M0),length(M0));...
      SS_discrete.C*SS_discrete.B,                   M0           ];

K = pinv(M1(:,1:6));

O_L = [SS_discrete.C;SS_discrete.C*SS_discrete.A];
SS_inverse.A = SS_discrete.A - (SS_discrete.B*K*O_L);
SS_inverse.B = SS_discrete.B*K;
SS_inverse.C = -K*O_L;
SS_inverse.D = K;
SS_inverse = ss(SS_inverse.A, SS_inverse.B,SS_inverse.C,SS_inverse.D,-1);

%This loop makes the vector 'M_vec' which is one column of the overall M
%matrix
% for i = 1:L
%    %i
%    new_M = SS_discrete.C * (SS_discrete.A^(i-1)) * SS_discrete.B;
%    M_vec = [M_vec; new_M];
% end

% M = zeros(L*7,L*7);
%Add M_vecs repeatedly to generate discrete M:
%  for i = 1:6:L*7
%      M(i:end,i:i+5) = M_vec(1:((L*7)+1-i),:); %mucky indexing to line up diagonals
%  end
 
 %'Find K such that K*M_L = [I_m | 0_m]'
 %is 'm' always 6? (no)