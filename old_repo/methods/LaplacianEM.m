function lem = LaplacianEM(X, learn_options, graph_options)
%KERNELPCA Summary of this function goes here
%   Detailed explanation goes here

if isfield(learn_options,'ktype')
    if isa(learn_options.ktype,'function_handle')
        k = learn_options.ktype;
        lem.kernel = k;
    else
        [k, dk] = Kernels(learn_options.ktype, learn_options.kpar);
        lem.kernel = k;
        lem.kernel_dev = dk; 
    end
else
    error('Give me a kernel!');
end

if isfield(learn_options,'num_eigen')
    num_eigen = learn_options.num_eigen;
else
    num_eigen = 1;
end

if isfield(learn_options,'normalize')
    normalize = learn_options.normalize;
else
    normalize = false;
end

W = GraphBuild(X, graph_options);

gram_options = struct('norm', normalize,...
                      'vv_rkhs', false);
K = GramMatrix(k, gram_options, X, X);

S = K.*W;
D = diag(sum(S,2));
L = D-S;

[V,D] = eigs(L, D, num_eigen, 'smallestabs');

% Remove zero eigenvalues
index = diag(D>1e-5);
D = diag(D(D>1e-5));
V = V(:,index);

% Store Results
lem.xtrain                  = X;
lem.alphas                  = V;
lem.eigens                  = diag(D);
lem.mappedData              = sqrt(D)*V';
lem.gram                    = K;

end