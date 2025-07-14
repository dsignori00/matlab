function [M ,Mf, Ms, Mt] = compute_bspline_matrices(d_knots)

    [N_vec, Np_vec, Ns_vec, Nt_vec] = compute_bspline_endpoints(d_knots);

    M = [N_vec;
         d_knots(3).*Np_vec;
         (d_knots(3)^2)./2.*Ns_vec;
         (d_knots(3)^3)./6.*Nt_vec];

    Mf = [Np_vec;
          d_knots(3).*Ns_vec;
          (d_knots(3)^2)./2.*Nt_vec];

    Ms = [Ns_vec;
          d_knots(3).*Nt_vec];

    Mt = Nt_vec;
    
end

