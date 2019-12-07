function U = embedding(obj, space)
% Get the emebedding. Returns the embedding space related to the
% specified eigenvectors. The embedding is built on the left
% eigenvectors
if nargin < 2; space = 1; end
[~,U] = obj.eigensolve;
U = U(:, space);
end
