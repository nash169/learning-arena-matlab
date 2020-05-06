function intersection = line_intersect(v, u)
    %myFun - Description
    %
    % Syntax: x = myFun(input)
    %
    % Long description

    A = [(u(2, :) - u(1, :))', (v(1, :) - v(2, :))'];
    b = (v(1, :) - u(1, :))';

    x = A \ b;
    intersection = A(:, 1) * x(1) + u(1, :)';
end
