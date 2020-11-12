function L = laplacian(obj)
    obj.check;

    if ~obj.is_laplacian_
        dm = diffusion_maps('alpha', 1, 'operator', 'inifinitesimal');
        dm.set_graph('type', 'k-nearest', 'k', 100);
        dm.set_data(obj.params_.manifold.data);
        dm.set_params('kernel', obj.params_.kernel, 'epsilon', obj.params_.epsilon);

        obj.laplacian_ = dm.infinitesimal;
        obj.is_laplacian_ = true;
    end

    L = obj.laplacian_;
end
