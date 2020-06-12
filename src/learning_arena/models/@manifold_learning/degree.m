function D = degree(obj, M)
    % Get the deegre matrix. By default it is computed based on the
    % similarity matrix.
    if nargin < 2; M = obj.similarity; end

    D = sparse_eye(sum(M, 2));
end
