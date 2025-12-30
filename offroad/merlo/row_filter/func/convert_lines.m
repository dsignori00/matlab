function line_eq = convert_lines(line_eq,out_line_form, LINEFORM_type)
% convert line form to desired form
    invalid = isnan(line_eq.p1);
    for i = 1:size(line_eq.coeff,1)
        for j = 1:size(line_eq.coeff,2)
            [line_eq.p1(i,j), line_eq.p2(i,j), line_eq.form(i,j)] = ...
                convert_line_form(line_eq.coeff(i,j,:), line_eq.form(i,j), out_line_form, LINEFORM_type, line_eq.p1(i,j), line_eq.p2(i,j) );
        end
    end

    line_eq.form(invalid) = nan;
end

