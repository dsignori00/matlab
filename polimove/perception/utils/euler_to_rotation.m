function R = euler_to_rotation(phi, theta, psi)
    % euler_to_rotation - Calcola la matrice di rotazione a partire dagli angoli di Eulero (ZYX)
    % INPUT:
    %   phi   - angolo di rotazione attorno all'asse X (roll)
    %   theta - angolo di rotazione attorno all'asse Y (pitch)
    %   psi   - angolo di rotazione attorno all'asse Z (yaw)
    % OUTPUT:
    %   R     - Matrice di rotazione 3x3 risultante

    % Matrice di rotazione attorno all'asse X (roll)
    Rx = [1    0           0;
          0  cos(phi)  -sin(phi);
          0  sin(phi)   cos(phi)];
    
    % Matrice di rotazione attorno all'asse Y (pitch)
    Ry = [cos(theta)   0   sin(theta);
          0            1   0;
         -sin(theta)   0   cos(theta)];
    
    % Matrice di rotazione attorno all'asse Z (yaw)
    Rz = [cos(psi)  -sin(psi)  0;
          sin(psi)   cos(psi)  0;
          0          0         1];

    % Matrice di rotazione totale (ZYX)
    R = Rz*Ry*Rx;
end