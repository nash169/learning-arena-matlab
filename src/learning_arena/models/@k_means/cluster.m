function [labels, centroids] = cluster(obj, data)
%CLUSTER Summary of this function goes here
%   Detailed explanation goes here
if nargin > 1
    obj.set_data(data);
else
    assert(obj.is_data_, 'Data not present')
end

if ~obj.is_clustered_
    obj.check;
    
    for i = 1 : obj.params_.step
        if ~obj.params_.soft
            [~, obj.labels_] = min(reshape(vecnorm(repelem(obj.centroids_, obj.m_, 1) ...
                - repmat(obj.data_, obj.params_.cluster, 1), obj.params_.norm, 2), ...
                obj.m_, []), [], 2);
            r = (repmat(1:obj.params_.cluster, obj.m_,1) - obj.labels_) == 0;
        else
            gram = obj.params_.kernel.gramian(obj.data_, obj.centroids_);
            r = gram./sum(gram,2);
        end
        
        obj.centroids_ = c_reshape(sum(blk_reshape(repmat(r(:), 1, obj.d_).*...
            repmat(obj.data_,obj.params_.cluster,1),obj.m_,1)),obj.params_.cluster,[])./ ...
            sum(r)';
    end
    
    [~, obj.labels_] = min(reshape(vecnorm(repelem(obj.centroids_, obj.m_, 1) ...
                - repmat(obj.data_, obj.params_.cluster, 1), obj.params_.norm, 2), ...
                obj.m_, []), [], 2);
    
    obj.is_clustered_ = true;
end

if nargout > 0; labels = obj.labels_; end
if nargout > 1; centroids = obj.centroids_; end
end

% for j = 1 : obj.params_.cluster
%     test = obj.labels_ == j;
%     obj.centroids_(j,:) = sum(test.*obj.data_)/sum(test);
% end

