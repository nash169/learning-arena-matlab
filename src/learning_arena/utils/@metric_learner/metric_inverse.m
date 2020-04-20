function h_inv = metric_inverse(obj)

    if ~obj.is_metric_inv_
        % Get laplacian
        L = obj.laplacian;

        % Set space dimension
        s = length(obj.params_.space);

        % Get emebdding
        f = obj.params_.manifold.embedding(obj.params_.space);
        f_i = repmat(f, 1, s);
        f_j = repelem(f, 1, s);

        % Get the metric inverse
        obj.metric_inv_ = (L * (f_i .* f_j) - f_i .* (L * f_j) - f_j .* (L * f_i)) / 2;

        % Reshape the metric
        obj.metric_inv_ = c_reshape(obj.metric_inv_, [], s);

        obj.is_metric_inv_ = true;
    end

    h_inv = obj.metric_inv_;
end
