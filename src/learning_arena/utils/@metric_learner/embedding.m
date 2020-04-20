function f = embedding(obj)

    if ~obj.is_embedding_
        f = obj.params_.manifold.embedding(obj.params_.space);
        h = obj.metric;

        [m, s] = size(f);

        obj.embedding_ = zeros(m, s);

        for i = 1:m
            obj.embedding_(i, :) = h(s * (i - 1) + 1:s * (i - 1) + s, :)^0.5 \ f(i, :)';
        end

        obj.embedding_ = real(obj.embedding_);

        obj.is_embedding_ = true;
    end

    f = obj.embedding_;
end
