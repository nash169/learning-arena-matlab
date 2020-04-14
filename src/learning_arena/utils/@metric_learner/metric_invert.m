function h = metric_invert(metric_inv, d)
    s = size(metric_inv, 2);

    % Metric inverse eigen decomposition
    [h_inv, ~, ~] = blk_matrix(metric_inv);
    [U, D] = eig(full(h_inv));

    %  Reshape the eigenvalue matrix
    D = c_reshape(diag(D), [], s);
    % Sort the eingevalues
    [D, I] = sort(D, 2, 'descend');
    % Select intrinsic dimension
    D = D(:, 1:d);
    % Rebuild sparse matrix
    D = sparse_eye(c_reshape(D, [], 1));

    % Reshape eigenvector matrix
    U = blk_revert(U, s);
    % Sort eigenvectors
    U = U(:, repelem(I, s, 1));
    % Select intrinsic dimension
    U = U(:, 1:d);
    % Rebuild sparse matrix
    U = blk_matrix(U);

    % Calculate the embedding space metric
    h = U * (D \ U');
end
