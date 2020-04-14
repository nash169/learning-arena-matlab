function f = calc_embedding(obj)
    %CALC_EMBEDDING Summary of this function goes here
    %   Detailed explanation goes here

    % Define embedding
    f = cell(3, 1);

    % Define variables
    theta = obj.data_{1};
    x = obj.data_{2};

    % Calculate embedding
    f{1} = theta .* cos(theta);
    f{2} = obj.params_.width * x;
    f{3} = theta .* sin(theta);
end
