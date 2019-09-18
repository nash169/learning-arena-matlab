function [kpar, fig] = HyperparSearch(X, ktype, kpars, centered)
%HYPERPARSEARCH Summary of this function goes here
%   Detailed explanation goes here

C = {'k','b','r','g','y',[.5 .6 .7],[.8 .2 .6]};
num_eigens = 10;
xs = 1:num_eigens;

fig = figure;
hold on;
set(gca,'Xtick',xs);
xlabel('eigenvectors indices');
ylabel('eigenvalues');

if centered, title('Components Eigenvalues');else
     title('Components Entropy Contribution');end

max_diffs = zeros(length(kpars), 2);
legendInfo = cell(length(kpars), 1);

gram_options = struct('norm', centered,...
                      'vv_rkhs', false);

for i = 1:length(kpars) 
    kpar.sigma = kpars(i);
    K = GramMatrix(Kernels(ktype, kpar), gram_options, X, X);
    [V,D] = eigs(K, num_eigens);
    
    if centered
        eigens = diag(D);
        [max_diffs(i,1), max_diffs(i,2)] = max(eigens(1:end-1)-eigens(2:end));
        plot(xs, diag(D), '-o', 'color', C{i});
        
    else
        c = sum(V*sqrt(D)).^2;
        [max_diffs(i,1), max_diffs(i,2)] = max(c(1:end-1)-c(2:end));
        plot(xs, c, '-o', 'color', C{i});
       
    end
    legendInfo{i} = num2str(kpars(i));
end
legend(legendInfo);

[diff, vec_index] = max(max_diffs(:,1));
kpar = kpars(vec_index);

fprintf('Maximum difference (%f) found for sigma=%f between lambda=%d and lambda=%d',...
    diff, kpar, max_diffs(vec_index,2), max_diffs(vec_index,2)+1);

end

