function D = degree(obj, M)
% Get the deegre matrix. By default it is computed based on the
% similarity matrix.
if nargin < 2; M = obj.similarity; end

D = diag(sum(M,2));
end
