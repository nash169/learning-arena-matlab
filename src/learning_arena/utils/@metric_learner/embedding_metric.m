function h = embedding_metric(obj, intrinsic_dim)
    obj.check;

    if ~obj.is_metric_
        s = length(obj.params_.space);

        f = obj.params_.manifold.embedding(obj.params_.space);
        f_i = repmat(f, 1, s);
        f_j = repelem(f, 1, s);

        L = obj.laplace_.infinitesimal;

        h_inv = (L * (f_i .* f_j) - f_i .* (L * f_j) - f_j .* (L * f_i)) / 2;
        h_inv = c_reshape(h_inv, [], s);

        if nargin > 1
            obj.embedding_metric_ = obj.metric_invert(h_inv, intrinsic_dim);
        else
            obj.embedding_metric_ = obj.metric_invert(h_inv, s);
        end

        obj.is_embedding_metric_ = true;
    end

    if nargout > 0; h = obj.embedding_metric_; end
end
