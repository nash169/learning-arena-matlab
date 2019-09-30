function funs = eigenfun(obj, x, vecs, data)
% Get the eigenfunction. It computes the continuous eigenfunction
% as a linear combination of kernels weighted by a specific
% eigenvector
if nargin < 3; vecs = 1; end
if nargin > 3; obj.set_data(data); end
obj.eigensolve;

funs = zeros(size(x,1), length(vecs));
for i = 1:length(vecs)
    obj.expansion_.set_params('weights', obj.right_vec_(:,vecs(i)));
    funs(:,i) = obj.expansion_.expansion(x);
end
end
