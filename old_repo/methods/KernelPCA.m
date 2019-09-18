function kpca = KernelPCA(X, options)
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
        kpca.kernel = k;
    else
        if vv_rkhs
           k = Kernels(options.ktype, options.kpar);
           kpca.kernel = k; 
        else
           [k, dk] = Kernels(options.ktype, options.kpar);
           kpca.kernel = k;
           kpca.kernel_dev = dk; 
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

gram_options = struct('norm', true,...
                      'vv_rkhs', vv_rkhs);
                  
K = GramMatrix(k, gram_options, X, X);
[V,D] = eigs(K,num_eigen);

% Store Results
kpca.xtrain                  = X;
kpca.alphas                  = V;
kpca.eigens                  = diag(D);
kpca.mappedData              = sqrt(D)*V';
kpca.gram                    = K;

if vv_rkhs
    [~, dim] = size(X);
    kpca.vv_alphas           = permute(reshape(V,dim,[],num_eigen),[2,1,3]);
    kpca.vv_eigens           = permute(reshape(diag(D),dim,[]),[2,1]);
    kpca.vv_mappedData       = permute(reshape(sqrt(D)*V',dim,[],num_eigen),[2,1,3]);
end

end

