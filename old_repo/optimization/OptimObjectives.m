function f_handle = OptimObjectives(type, varargin)
    switch type
        case 'pca'
            f_handle = @(x) pca(x, varargin{1});
        case 'G-kpca'
            f_handle = @(x) G_kpca(x, varargin{1});
        case 'kpca'
            f_handle = @(x) kpca(x,varargin{1});
        case 'max_coll_lyap'
            f_handle = @(x) max_coll_lyap(x,varargin{1},varargin{2});
        otherwise
            error('sto cazzo');
    end
end

function [f, g] = pca(x, C)
    f = -x'*C*x;
    g = -2*C*x;
end

function [f, g] = G_kpca(x, K)
    m = size(K,1);
    f = -1/m*x'* (K'*K)*x;
    g = -2/m*K^2*x;
end

function [f, g] = kpca(x, K)
    m = size(K,1);
    f = -1/m*x'*K*x;
    g = -2/m*K*x;
end

function [f, g] = max_coll_lyap(x,G,xi)
    m = size(G,1);
    f = xi*(-1/m*x'*(G*G')*x);
    g = xi*(-2/m*(G*G')*x);
end


% function [f, g] = mse_vel(x,dK,x_dot,xi)
%     m = size(G,1);
%     f = xi*(-1/m*x'*G^2*x);
%     g = xi*(-2/m*G^2*x);
% end