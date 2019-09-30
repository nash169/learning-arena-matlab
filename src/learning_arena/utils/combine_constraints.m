function varargout = combine_constraints(x, varargin)
%COMBINE_FUNS Summary of this function goes here
%   Detailed explanation goes here

n = length(varargin);
f_h = cell(n,1);

for i = 1:n
   f_h{i} =  varargin{i};
end

[varargout{1:nargout}] = cellfun(@(c) c(x), f_h, 'UniformOutput',false);

if nargout > 1
    varargout{1} = cat(1,varargout{1}{:});
    varargout{2} = cat(1,varargout{2}{:});
end

if nargout > 2
    varargout{3} = [varargout{3}{:}];
    varargout{4} = [varargout{4}{:}];
end

end