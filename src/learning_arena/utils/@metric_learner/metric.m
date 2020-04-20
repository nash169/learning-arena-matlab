function h = metric(obj)

    if ~obj.is_metric_
        h_inv = obj.metric_inverse;

        [m, s] = size(h_inv);

        D = zeros(m / s, s);
        U = zeros(m, s);

        for i = 1:m / s
            [U(s * (i - 1) + 1:s * (i - 1) + s, :), D(i, :)] = eig(h_inv(s * (i - 1) + 1:s * (i - 1) + s, :), 'vector');
        end

        % Reshape the eigenvalue matrix
        [~, I] = sort(D, 2);
        D = 1 ./ D;
        D(I > obj.params_.dim) = 0;
        D(D == Inf) = 0;
        D = sparse_eye(c_reshape(D, [], 1));

        U = blk_matrix(U);

        % Calculate the embedding metric
        obj.metric_ = U' * D * U;

        obj.is_metric_ = true;
    end

    h = blk_revert(obj.metric_, length(obj.params_.space));
end
