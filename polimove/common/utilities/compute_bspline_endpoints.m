function [N, Np, Ns, Nt] = compute_bspline_endpoints(d_knots)

    N0 = d_knots(3)^2/((d_knots(2) + d_knots(3))*(d_knots(1) + d_knots(2) + d_knots(3)));
    N2 = d_knots(2)^2/((d_knots(2) + d_knots(3))*(d_knots(2) + d_knots(3) + d_knots(4)));
    N1 = 1 - N0 - N2;

    Np0 = -(3*d_knots(3))/((d_knots(2) + d_knots(3))*(d_knots(1) + d_knots(2) + d_knots(3)));
    Np2 = (3*d_knots(2))/((d_knots(2) + d_knots(3))*(d_knots(2) + d_knots(3) + d_knots(4)));
    Np1 = -Np0 -Np2;

    Ns0 = 6/((d_knots(2) + d_knots(3))*(d_knots(1) + d_knots(2) + d_knots(3)));
    Ns2 = 6/((d_knots(2) + d_knots(3))*(d_knots(2) + d_knots(3) + d_knots(4)));
    Ns1 = -Ns0 -Ns2;

    Nt0 = -6/(d_knots(3)*(d_knots(2) + d_knots(3))*(d_knots(1) + d_knots(2) + d_knots(3)));
    Nt1 = 6/(d_knots(3)*(d_knots(2) + d_knots(3))*(d_knots(1) + d_knots(2) + d_knots(3))) + (6*(d_knots(2) + 2*d_knots(3) + d_knots(4)))/(d_knots(3)*(d_knots(2) + d_knots(3))*(d_knots(3) + d_knots(4))*(d_knots(2) + d_knots(3) + d_knots(4)));
    Nt2 = - 6/(d_knots(3)*(d_knots(3) + d_knots(4))*(d_knots(3) + d_knots(4) + d_knots(5))) - (6*(d_knots(2) + 2*d_knots(3) + d_knots(4)))/(d_knots(3)*(d_knots(2) + d_knots(3))*(d_knots(3) + d_knots(4))*(d_knots(2) + d_knots(3) + d_knots(4)));
    Nt3 = 6/(d_knots(3)*(d_knots(3) + d_knots(4))*(d_knots(3) + d_knots(4) + d_knots(5)));

    N = [N0 N1 N2 0];

    Np = [Np0 Np1 Np2 0];

    Ns = [Ns0 Ns1 Ns2 0];

    Nt = [Nt0 Nt1 Nt2 Nt3];

end

