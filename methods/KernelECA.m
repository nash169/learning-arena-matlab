function keca = KernelECA(X, options)
%KERNELPCA Summary of this function goes here
%   Detailed explanation goes here

if isfield(options,'vv_rkhs')
    vv_rkhs = options.vv_rkhs;
else
    vv_rkhs = false;
end

if isfield(options,'ktype')
    if isa(options.ktype,'function_handle')
        k = options.ktype;
        keca.kernel = k;
    else
        if vv_rkhs
            k = Kernels(options.ktype, options.kpar);
            keca.kernel = k;
        else
            [k, dk] = Kernels(options.ktype, options.kpar);
            keca.kernel = k;
            keca.kernel_dev = dk;
        end
    end
else
    error('Give me a kernel!');
end

if isfield(options,'num_eigen')
    num_eigen = options.num_eigen;
else
    num_eigen = 1;
end

gram_options = struct('norm', false,...
                      'vv_rkhs', vv_rkhs);
K = GramMatrix(k, gram_options, X, X);
[V,D] = eigs(K,num_eigen);

c = sum(V*sqrt(D)).^2; % entropy

% Store Results
keca.xtrain                  = X;
keca.alphas                  = V;
keca.eigens                  = c;
keca.mappedData              = sqrt(D)*V';
keca.gram                    = K;

if vv_rkhs
    [~, dim] = size(X);
    keca.vv_alphas           = permute(reshape(V,dim,[],num_eigen),[2,1,3]);
    keca.vv_eigens           = permute(reshape(c,dim,[]),[2,1]);
    keca.vv_mappedData       = permute(reshape(sqrt(D)*V',dim,[],num_eigen),[2,1,3]);
end

end

