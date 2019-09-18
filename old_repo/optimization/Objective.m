function [f1, f2] = Objective(x, varargin)

n = length(varargin);
f_h = cell(n,1);

for i = 1:n
   f_h{i} =  varargin{i};
end

if nargout > 1
    [f1_cell, f2_cell] = cellfun(@(c) c(x), f_h, 'UniformOutput',false);
    f1 = sum(cat(1,f1_cell{:}));
    f2 = sum(cat(2,f2_cell{:}),2);
else
    [f1_cell] = cellfun(@(c) c(x), f_h, 'UniformOutput',false);
    f1 = sum(cat(1,f1_cell{:}));
end

end

