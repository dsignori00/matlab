% Dato un modello, schematizzato tramite una certa funzione (non lineare) f
% che ne descrive l'evoluzione ne calcolo la matrice del gradiente
% simbolico. Tramite l'esponenziale di tale matrice calcolo la matrice Q
% discretizzata.

syms x y psi v a rho tau qx qy qv qa qp ts real;


%CTRA
% Q = diag([qx qy qv qa qp]);
% f = [v*cos(psi);
%     v*sin(psi); ...
%     a;
%     0;
%     rho*v];


% %CTRV
Q = diag([qx qy qv qp]);
f = [v*cos(psi);
    v*sin(psi); ...
    0;
    rho*v];

J = jacobian(f,[x,y,v,psi]); %rimuovi a per ctrv

expA = expm(J*tau);

integrand = expm(J*tau)*Q*expm(J'*tau);

Qk = int(integrand,tau,[0 ts])



