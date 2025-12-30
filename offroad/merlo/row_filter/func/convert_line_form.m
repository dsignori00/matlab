function [p1_out, p2_out, form_out] = convert_line_form(coeff, form_in, to_form, LINEFORM, p1_in, p2_in)
%CONVERTLINEFORM Convert between NORMAL and EXPLICIT line forms.
% Gracefully handles degenerate direction (dx,dy) ~ (0,0) by returning NaNs.

    % Accept 1x1x6 or 1x6
    coeff = squeeze(coeff);
    if ~isrow(coeff), coeff = coeff.'; end
    if numel(coeff) ~= 6
        error("convertLineForm:BadCoeffSize", "coeff must have 6 elements.");
    end

    NORMAL   = int8(LINEFORM.NORMAL);
    EXPLICIT = int8(LINEFORM.EXPLICIT);

    form_in = int8(form_in);
    to_form = int8(to_form);

    % default outputs
    form_out = form_in;
    p1_out = p1_in;
    p2_out = p2_in;

    % If already in desired form, just return current form unchanged
    if form_in == to_form
        return;
    end

    x0 = coeff(1);
    y0 = coeff(2);
    dx = coeff(4);
    dy = coeff(5);

    % Tolerance for "near zero" direction
    tol = 1e-9;

    % If direction is degenerate, cannot define a line reliably
    if hypot(dx, dy) < tol
        % leave NaNs, keep form_out = form_in
        return;
    end

    % Implicit form: A*x + B*y + C = 0
    A = dy;
    B = -dx;
    C = -(A*x0 + B*y0);

    if to_form == NORMAL
        nrm = hypot(A, B);
        if nrm < tol
            return; % degenerate again (should match dx/dy check)
        end
        A = A / nrm;
        B = B / nrm;
        C = C / nrm;

        rho   = -C;
        theta = atan2(B, A);

        if rho < 0
            rho   = -rho;
            theta = theta + pi;
        end

        p1_out = theta;
        p2_out = rho;
        form_out = NORMAL;

    elseif to_form == EXPLICIT
        % Vertical handling like your C++
        if abs(dx) > 1e-6
            nrm = hypot(dx, dy);
            dirx = dx / nrm;
            diry = dy / nrm;

            p1_out = diry / dirx;
            p2_out = y0 - p1_out * x0;
        else
            p1_out = inf;
            p2_out = x0;
        end

        form_out = EXPLICIT;

    else
        error("convertLineForm:UnsupportedForm", "Unsupported line form conversion.");
    end
end
