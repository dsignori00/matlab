syms ome real
syms t real
Av=[0 ome;-ome 0];

syms tau real
syms ax ay real
syms vx vy real
syms G1 G2 real
v=expm(Av*t)*[vx;vy] + int(expm(Av*(t-tau))*[ax;ay],tau,0,t) + int(expm(Av*(t-tau))*[G1;G2],tau,0,t)


syms k1 k2 k3 real
syms phi real
R=[k1*cos(phi+ome*t), k2*cos(phi+ome*t)-k3*sin(phi+ome*t); k1*sin(phi+ome*t), k2*sin(phi+ome*t)+k3*cos(phi+ome*t)];

syms ts_ real
x=int(R*v,t,0,ts_)

% A matrix computation
dx=gradient(x(1,1),[vx vy phi])
dy=gradient(x(2,1),[vx vy phi])
dvx=gradient(v(1,1),[vx vy phi])
dvy=gradient(v(2,1),[vx vy phi])
%% ome=0
R=[k1*cos(phi), k2*cos(phi)-k3*sin(phi); k1*sin(phi), k2*sin(phi)+k3*cos(phi)];
v=[ax*t; ay*t] + [G1; G2]*t + [vx; vy]
x=int(R*v,t,0,ts_)

% A matrix computation
dx=gradient(x(1,1),[vx vy phi])
dy=gradient(x(2,1),[vx vy phi])
dvx=gradient(v(1,1),[vx vy phi])
dvy=gradient(v(2,1),[vx vy phi])
