function f = embedding(obj)
    obj.check;

    if ~obj.is_embedding_

        phi = obj.params_.manifold.embedding(obj.params_.space);
        [~, h_inv] = obj.metric;

        obj.embedding_ = c_reshape(h_inv * c_reshape(phi, [], 1), [], size(phi, 2));

        obj.is_embedding_ = true;
    end

    if nargout > 0; f = obj.embedding_; end
end
