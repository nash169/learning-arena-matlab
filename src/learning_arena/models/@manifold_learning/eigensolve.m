function [D,V,W] = eigensolve(obj, data)
% Solve the (generalized) eigenvalue problem. By default both the
% right and the left eigenvectors are computes, plus the
% eigenvalues
if nargin > 1; obj.set_data(data); end

if ~obj.is_eigen_
    [obj.right_vec_, obj.eig_, obj.left_vec_] = obj.solve;
    obj.is_eigen_ = true;
end

if nargout > 0; D = obj.eig_; end
if nargout > 1; V = obj.right_vec_; end
if nargout > 2; W = obj.left_vec_; end
end
