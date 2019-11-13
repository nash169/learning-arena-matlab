function [c, ceq, DC, DCeq] = lp_ball(x,p)
%LP_BALL Summary of this function goes here
%   lp ball -> ||x||_p^p <= 1
if nargin < 2; p=2; end

c = sum(abs(x).^p) - 1;
ceq = [];

if nargout > 2
    DCeq = [];
    DC = p*ones(size(x,1),1).*x^(p-1);
end

end

