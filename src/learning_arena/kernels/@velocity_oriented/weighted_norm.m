function V = weighted_norm(v, a, b)
switch nargin
    case 1
        a = 0.5;
        b = 1;
    case 2
        b = 1;
end
v_norm = vecnorm(v,2,2);
V = [a*v_norm, b*repmat(v_norm, 1, size(v,2) -1)];
end

