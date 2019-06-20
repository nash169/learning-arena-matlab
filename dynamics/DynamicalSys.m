function f = DynamicalSys(type, param)
%LINEARDS Summary of this function goes here
%   Detailed explanation goes here

switch (type)
    case 'linear'
        f = @(x) (x-param.x_a)*param.A';
        
    case 'quadratic'
        f = @(x) (x.^2-param.x_a)*param.A';
        
    case 'cubic'
        f = @(x) (x.^3-param.x_a)*param.A';
    
end

end

