function f = rbf(x,y,sigma,derivative)
%RBF_KERNEL Summary of this function goes here
%   Detailed explanation goes here
v = (x-y);

if nargin < 4
   f = exp(-vecnorm(v,2,2).^2/2/sigma^2); 
else
    switch derivative
        case 'd'
            f = -v/sigma^2.*(exp(-vecnorm(v,2,2).^2/2/sigma^2));
        case 'd2'
            [m,n] = size(v);
            V = zeros(m,n^2);
            for i = 1:n
                for j = 1:n
                    V(:,j+(i-1)*n) = v(i).*v(j)/sigma^2;
                    if i==j
                        V(:,j+(i-1)*n) = 1 - V(:,j+(i-1)*n);
                    end
                end
            end
            f = V/sigma^2.*(exp(-vecnorm(v,2,2).^2/2/sigma^2));
        otherwise
            error('Error');
    end
end

end

