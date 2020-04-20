function signature(obj)
    %SIGNATURE Summary of this function goes here
    %   Detailed explanation goes here

    % Embedding parameters
    obj.params_list_ = {'center', 'radius'};

    % Chart coordinates boundaries
    obj.extrema_ = {0, pi, 0, 2 * pi};

    % Intrinsic manifold dimension
    obj.dim_ = 2;
end
