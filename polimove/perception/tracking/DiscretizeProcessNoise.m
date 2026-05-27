% Dato un modello, schematizzato tramite una certa funzione (non lineare) f
% che ne descrive l'evoluzione ne calcolo la matrice del gradiente
% simbolico. Tramite l'esponenziale di tale matrice calcolo la matrice Q
% discretizzata.

syms x y v psi omega a rho tau qx qy qv qa qp qw qr ts real;

%% Model definition

% % CTRA
% Q = diag([0 0 0 0 qw qa]);
% f = [v*cos(psi);
%     v*sin(psi); ...
%     a;
%     omega;
%     0;
%     0];

% % %CTRV
% Q = diag([0 0 qv 0 qw]);
% f = [v*cos(psi);
%     v*sin(psi); ...
%     0;
%     omega;
%     0];

% CCV
Q = diag([0 0 qv qp 0 0]);
f = [v*cos(psi);
     v*sin(psi); ...
     0;
     rho*v;
     0;
     0];

% % CCA
% Q = diag([0 0 0 qp 0 qa]);
% f = [v*cos(psi);
%      v*sin(psi); ...
%      a;
%      rho*v;
%      0;
%      0];


%% Process noise

J = jacobian(f,[x,y,v,psi,rho,a]); 
expA = expm(J*tau);
integrand = expm(J*tau)*Q*expm(J'*tau);
Qk = int(integrand,tau,[0 ts]);


%% Jacobian

% CTRA
fk = [ x + ( (v + a*ts)*omega*sin(psi + omega*ts) ...
          - v*omega*sin(psi) ...
          + a*cos(psi + omega*ts) ...
          - a*cos(psi) ) / (omega^2);

       y + ( -(v + a*ts)*omega*cos(psi + omega*ts) ...
          + v*omega*cos(psi) ...
          + a*sin(psi + omega*ts) ...
          - a*sin(psi) ) / (omega^2);
       
       v + a*ts;
       psi + omega * ts;
       omega;
       a];

Jk = jacobian(fk,[x y v psi omega a]);

%% Input matrix

B = jacobian(f,rho);


