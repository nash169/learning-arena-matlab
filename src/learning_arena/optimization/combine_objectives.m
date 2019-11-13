function varargout = combine_objectives(x, varargin)
%COMBINE_OBJECTIVES Summary of this function goes here
%   Detailed explanation goes here
n = length(varargin);
f_h = cell(n,1);

for i = 1:n
   f_h{i} =  varargin{i};
end

[varargout{1:nargout}] = cellfun(@(c) c(x), f_h, 'UniformOutput',false);

if nargout > 0
    varargout{1} = sum(cat(1,varargout{1}{:}));
end

if nargout > 1
    varargout{2} = sum(cat(2,varargout{2}{:}),2);
end
end

