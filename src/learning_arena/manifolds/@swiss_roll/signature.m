function signature(obj)
    %SIGNATURE Summary of this function goes here
    %   Detailed explanation goes here

    % List of parameters for the 3D embedding
    obj.params_list_ = {'width'};

    % Default boundaries to draw the embedding
    obj.extrema_ = {0, 4 * pi, 0, 1};

    % Manifold dimension
    obj.dim_ = 2;
end
