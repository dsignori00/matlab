function m_MX = sparsify_matrix_casadi(m_double, tol)

    N = size(m_double, 1);
    M = size(m_double, 2);

    import casadi.*

    m_MX = MX(N, M);

    for i=1:N
        for j=1:M
            if abs(m_double(i, j)) > tol
                m_MX(i, j) = m_double(i, j);
            end
        end
    end

end

