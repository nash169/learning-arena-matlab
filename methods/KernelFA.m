function kfa = KernelFA(X, options)
%KFACOPY Summary of this function goes here
%   Detailed explanation goes here

if isfield(options,'ktype')
    if isa(options.ktype,'function_handle')
        k = options.ktype;
        kfa.kernel = k;
    else
        [k, dk] = Kernels(options.ktype, options.kpar);
        kfa.kernel = k;
        kfa.kernel_dev = dk; 
    end
else
    error('Give me a kernel!');
end

if isfield(options,'num_eigen')
    features = options.num_eigen;
else
    features = 1;
end

m = size(X,1); 
  
alpha = zeros(m,features);
alphazero = ones(1,m);
alphafeat = zeros(features,features);
Qfeat = [];
 
idx = 1:m;

gram_options = struct('norm', false,...
                      'vv_rkhs', false);
K = GramMatrix(k, gram_options, X, X);

for i = 1:features
    K_tmp = K;
    alpha_tmp = alpha;
    alphazero_tmp = alphazero;
      
    if i > 1
        K_tmp(idx,:) = [];
        alpha_tmp(idx,:) = [];
        alphazero_tmp(idx) = [];
    end
 
    if i > 1
        projections = K_tmp.*alphazero_tmp' + alpha_tmp(:,1:(i-1))*K(idx,:);
    else
        projections = K_tmp.*alphazero_tmp'; 
    end
    
    [Qmax,Qidx] = max(var(projections,0,2));
 
    if i > 1 
       alphafeat(i,1:(i-1)) = alpha(Qidx,1:(i-1));
    end
 
    alphafeat(i,i) = alphazero(Qidx);
 
    if (i > 1)
       idx = [idx Qidx];
    else
       idx = Qidx;
    end
      
    Qfeat = [Qfeat Qmax];
 
    Ksub = K(idx, idx);
    alphasub = alphafeat(i,1:i);
    phisquare = alphasub*Ksub*alphasub';
    dotprod = (alphazero' .* (K(:,idx)*alphasub') + alpha(:,1:i)*(Ksub*alphasub'))/phisquare;
    alpha(:,1:i) = alpha(:,1:i) - dotprod*alphasub;
end

% Store Results
kfa.xtrain                  = X;
kfa.index                   = idx;
kfa.alphas                  = alpha;
kfa.eigens                  = Qfeat;
kfa.mappedData              = sqrt(diag(Qfeat))*alpha';
kfa.gram                    = K;

end

