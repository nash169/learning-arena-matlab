function f_handle = OptimConstraints(type, varargin)
    switch type
        case 'l1Ball'
            f_handle = @l1Ball;
        case 'l2Ball'
            f_handle = @l2Ball;
        case 'K-l2Ball'
            f_handle = @(x) K_l2Ball(x, varargin{1});
        case 'ortho'
            f_handle = @(x) ortho(x, varargin{1});
        case 'K-ortho'
            f_handle = @(x) K_ortho(x, varargin{1}, varargin{2});    
        case 'pos-orthant'
            f_handle = @pos_orthant;
        case 'neg-sum'
            f_handle = @neg_sum;
        case 'lyap'
            f_handle = @(x) lyap(x, varargin{1});
        case 'lyap-square'
            f_handle = @(x) lyap_square(x, varargin{1});
        case 'lyap-sqsum'
            f_handle = @(x) lyap_sqsum(x, varargin{1});
        otherwise
            error('Error cazzo');
    end
end

function [c, ceq, DC, DCeq] = K_l2Ball(x, K)
    c = x'*K*x - 1;
    ceq = [];
    
    if nargout > 2
        DC= (K + K')*x;
        DCeq = [];
    end
end

function [c, ceq, DC, DCeq] = l2Ball(x)
    c = x'*x - 1;
    ceq = [];
    
    if nargout > 2
        DC = 2*x;
        DCeq = [];
    end
end

function [c, ceq, DC, DCeq] = l1Ball(x)
    c = norm(x,1) - 1;
    ceq = [];
    
    if nargout > 2
        DCeq = [];
        DC = ones(size(x,1),1);
    end
end

function [c, ceq, DC, DCeq] = ortho(x, orthoSpace)
    c = [];
    ceq = x'*orthoSpace;
    
    if nargout > 2
        DC = [];
        DCeq = orthoSpace;
    end
end

function [c, ceq, DC, DCeq] = K_ortho(x, K, orthoSpace)
    c = [];
    ceq = x'*K*orthoSpace;

    if nargout > 2
        DC = [];
        DCeq = K*orthoSpace;
    end
end

function [c, ceq, DC, DCeq] = pos_orthant(x)
    ceq = [];
    c = -x;
    
    if nargout > 2
        DCeq = [];
        DC = -eye(size(x,1));
    end
end

function [c, ceq, DC, DCeq] = neg_sum(x)
    ceq = [];

    c = sum(x);
    
    if nargout > 2
        DCeq = [];
        DC = sign(x);
    end
end

function [c, ceq, DC, DCeq] = lyap(x, G)
    ceq = [];
    c = -G'*x;
    
    if nargout > 2
        DCeq = [];
        DC = -G';
    end
end

function [c, ceq, DC, DCeq] = lyap_square(x, G)
    ceq = [];
    c = -(x'*G).*(G*x);
    
    if nargout > 2
        DCeq = [];
        DC = [];
    end
end

function [c, ceq, DC, DCeq] = lyap_sqsum(x, G)
    m = size(G,1);     
    ceq = [];
    c = -1/m*x'*G^2*x;
        
    if nargout > 2
        DCeq = [];
        DC = -2/m*G^2*x;
    end
end