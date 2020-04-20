function metric_invert(obj, h_inv)
    % Metric inverse eigen decomposition
    [h_inv, ~, ~] = blk_matrix(h_inv);
    [U, D] = eig(full(h_inv));

    %  Reshape the eigenvalue matrix
    D = c_reshape(diag(D), [], size(h_inv, 2));

    % Sort the eingevalues
    [~, I] = sort(D, 2, 'descend');

    % Select intrinsic dimension
    D_inv = 1 ./ D;
    D(I > obj.params_.dim) = 0;
    D_inv(I > obj.params_.dim) = 0;

    % Rebuild sparse matrix
    D_inv = sparse_eye(c_reshape(D_inv, [], 1));
    D = sparse_eye(c_reshape(D, [], 1));

    % Rebuild sparse eigenvectors matrix
    U = sparse(U);

    % Calculate the embedding space metric
    obj.metric_ = U * D * U';
    obj.metric_inv_ = U * D_inv * U';
end
